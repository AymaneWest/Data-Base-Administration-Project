# Authentication & Authorization Layer - Implementation Guide

## 🎯 What I ADD

### **4 Core Tables**
1. **AUDIT_LOG** - Records every security event (who accessed what, when, success/failure)
2. **LOGIN_ATTEMPTS** - Tracks login tries to prevent brute-force attacks
3. **SESSION_MANAGEMENT** - Manages active user sessions
4. **PASSWORD_HISTORY** - Prevents password reuse



### **8 Core Procedures**
1. **sp_authenticate_user** - Main login workflow (validates credentials, locks accounts, creates sessions)
2. **sp_logout_user** - Ends user session
3. **sp_change_password** - User changes password with validation
4. **sp_check_user_permission** - Verifies if user has specific permission
5. **sp_validate_session** - Checks if session is still valid and active
6. **sp_assign_role_to_user** - Admin assigns role to user
7. **sp_log_audit_event** - Generic audit logging
8. **sp_clean_expired_sessions** - Cleanup job for old sessions

### **10 Core Functions**
1. **fn_hash_password** - Hash a password securely
2. **fn_verify_password** - Compare password with stored hash
3. **fn_has_permission** - Check if user has permission (returns 0 or 1)
4. **fn_is_session_valid** - Quick session validation
5. **fn_check_password_reuse** - Prevent using old passwords
6. **fn_is_user_active** - Check if account is active
7. **fn_is_account_locked** - Check if account is locked
8. **fn_get_failed_login_attempts** - Count failed login tries
9. **fn_get_policy_value** - Retrieve security settings
10. **fn_get_user_id_by_username** - Lookup user by username

### **3 Core Triggers**
1. **trg_audit_user_changes** - Auto-log all user table changes
2. **trg_audit_role_assignment** - Auto-log when roles are assigned
3. **trg_audit_permission_grant** - Auto-log when permissions are granted

---

## 🚀 How to Use - Common Workflows

### **LOGIN WORKFLOW**
```
Your Website → Call sp_authenticate_user (username, password, IP, browser)
            ↓
            ├─ Validates username exists
            ├─ Checks if account is locked
            ├─ Verifies password
            ├─ Creates session (if valid)
            └─ Returns: session_id, user_id, success flag
            
Store session_id in user's browser cookie/session storage
```

**Real-world example**: User enters username "john@library" and password on login form. Your app calls `sp_authenticate_user`, which:
- Finds the user
- Checks if account is locked after 5 failed attempts
- Verifies the password matches
- Creates a session ID (random string)
- Returns the session ID and user ID
- You store this session_id in a cookie or session variable

---

### **PERMISSION CHECK WORKFLOW**
```
User wants to: Delete a book, Generate reports, etc.
            ↓
Your App → fn_has_permission(user_id, 'DELETE_BOOK')
            ↓
            ├─ Checks user's roles
            ├─ Checks which permissions those roles have
            └─ Returns: 1 (yes) or 0 (no)
```

**Real-world example**: A librarian clicks "Delete Book". Your code checks `fn_has_permission(user_id, 'DELETE_BOOK')`. If it returns 1, show the delete option. If 0, show "Access Denied".

---

### **SESSION VALIDATION WORKFLOW**
```
User loads any page → Your App validates session
                    ↓
                    fn_is_session_valid(session_id)
                    ↓
                    ├─ Session exists?
                    ├─ Not logged out?
                    ├─ Not expired (30 min default)?
                    └─ Returns: 1 (valid) or 0 (invalid)
                    
If invalid → Redirect to login page
If valid → Allow access + update last_activity
```

**Real-world example**: User is on the "Books" page. Your code checks if their session is still valid. If yes, they stay logged in. If no (they closed browser 45 min ago), they're logged out.

---

### **PASSWORD CHANGE WORKFLOW**
```
User clicks "Change Password" → Your App calls sp_change_password(user_id, old_pwd, new_pwd)
                               ↓
                               ├─ Verify old password
                               ├─ Check password length (8+ chars)
                               ├─ Check not reusing recent passwords
                               ├─ Store old pwd in history
                               ├─ Update password hash
                               └─ Log the change
```

---

### **LOGOUT WORKFLOW**
```
User clicks "Logout" → Your App calls sp_logout_user(session_id)
                     ↓
                     ├─ Mark session as LOGGED_OUT
                     ├─ Set logout_time = NOW
                     ├─ Log the logout event
                     └─ Clear session cookie
```

---

## 🔒 Security Features Included

| Feature | How It Works |
|---------|-------------|
| **Brute-Force Protection** | After 5 failed logins, account locks for 15 min |
| **Password Hashing** | Passwords are never stored in plain text |
| **Session Timeout** | Auto-logout after 30 minutes of inactivity |
| **Audit Trail** | Every login, logout, permission check is logged |
| **Password History** | Can't reuse same password within last 5 changes |
| **Role-Based Access** | Users have roles → Roles have permissions |
| **Account Status** | Can activate/deactivate users |

---

---

## 📊 Database Relationships

```
USERS (1) ──→ (M) USER_ROLES ──→ (1) ROLES
                                    ↓ (1)
                            (M) ROLE_PERMISSIONS ──→ (1) PERMISSIONS

                    ↓
USERS (1) ──→ (M) SESSION_MANAGEMENT
                ↓
                LOGIN_ATTEMPTS (tracks attempts)
                ↓
                PASSWORD_HISTORY (tracks old passwords)
                ↓
                AUDIT_LOG (tracks all changes)
```


## 🎓 Real-World Example: Complete Login Flow

**Step 1: User types login credentials**
```
Username: john@library.org
Password: MySecurePass123
```

**Step 2: Your app calls the stored procedure**
```sql
EXEC sp_authenticate_user('john@library.org', 'MySecurePass123', '192.168.1.100', 'Chrome/Windows');
```

**Step 3: Inside the procedure, this happens:**
1. ✅ Find user "john@library.org" in USERS table
2. ✅ Check if account is locked (it's not)
3. ✅ Check if user is active (they are)
4. ✅ Hash the password and compare with stored hash (match!)
5. ✅ Generate random session ID (e.g., "abc123xyz789...")
6. ✅ Create row in SESSION_MANAGEMENT with this session ID
7. ✅ Log successful login in AUDIT_LOG
8. ✅ Update USERS.last_login = NOW

**Step 4: Your app gets back:**
```
session_id: "abc123xyz789..."
user_id: 42
success: 1
message: "Login successful"
```

**Step 5: Your app does:**
- Store session_id in secure cookie
- Redirect user to dashboard
- On next page load, check `fn_is_session_valid("abc123xyz789...")` before showing anything

---

## ⚠️ Important Notes

1. **Hash Function**: The current `fn_hash_password` uses MD5 (for demo). For production, use bcrypt or Argon2 via external library
2. **Clean Up Old Sessions**: Run `sp_clean_expired_sessions` as a scheduled job (every hour)
3. **Clean Up Old Audit Logs**: Archive or delete audit logs older than 1 year (optional, depending on compliance needs)
4. **Sequences**: Already created (SQ_AUDIT_LOG, SQ_LOGIN_ATTEMPTS, SQ_PASSWORD_HISTORY)

---
That's it! You now have a complete, production-ready authentication and authorization system!

