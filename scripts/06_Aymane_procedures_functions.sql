-- ============================================================================
-- SECTION 1: CREATE 10 FUNCTIONS
-- ============================================================================

-- ============================================================================
-- FUNCTION 1: fn_hash_password - Hash a password
-- ============================================================================
CREATE OR REPLACE FUNCTION fn_hash_password (
    p_password IN VARCHAR2
)
RETURN VARCHAR2
IS
    v_hash VARCHAR2(255);
BEGIN
    -- Hash the password using SHA-256
    v_hash := RAWTOHEX(
                DBMS_CRYPTO.HASH(
                    UTL_RAW.CAST_TO_RAW(p_password),
                    DBMS_CRYPTO.HASH_SH256
                )
             );
    RETURN v_hash;
END fn_hash_password;
/

-- ============================================================================
-- FUNCTION 2: fn_verify_password - Verify password matches hash
-- ============================================================================
CREATE OR REPLACE FUNCTION fn_verify_password (
    p_password IN VARCHAR2,
    p_password_hash IN VARCHAR2
)
RETURN NUMBER
IS
    v_computed_hash VARCHAR2(255);
BEGIN
    v_computed_hash := fn_hash_password(p_password);
    
    IF LOWER(v_computed_hash) = LOWER(p_password_hash) THEN
        RETURN 1;  -- Match
    ELSE
        RETURN 0;  -- No match
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
END fn_verify_password;
/

-- ============================================================================
-- FUNCTION 3: fn_has_permission - Check if user has specific permission
-- ============================================================================
CREATE OR REPLACE FUNCTION fn_has_permission (
    p_user_id IN NUMBER,
    p_permission_code IN VARCHAR2
)
RETURN NUMBER
IS
    v_permission_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_permission_count
    FROM USER_ROLES ur
    INNER JOIN ROLE_PERMISSIONS rp ON ur.role_id = rp.role_id
    INNER JOIN PERMISSIONS p ON rp.permission_id = p.permission_id
    WHERE ur.user_id = p_user_id
    AND p.permission_code = p_permission_code
    AND ur.is_active = 'Y'
    AND p.is_active = 'Y';

    IF v_permission_count > 0 THEN
        RETURN 1;  -- Has permission
    ELSE
        RETURN 0;  -- No permission
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
END fn_has_permission;
/

-- ============================================================================
-- FUNCTION 4: fn_has_role - Check if user has specific role
-- ============================================================================
CREATE OR REPLACE FUNCTION fn_has_role (
    p_user_id IN NUMBER,
    p_role_code IN VARCHAR2
)
RETURN NUMBER
IS
    v_role_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_role_count
    FROM USER_ROLES ur
    INNER JOIN ROLES r ON ur.role_id = r.role_id
    WHERE ur.user_id = p_user_id
    AND r.role_code = p_role_code
    AND ur.is_active = 'Y'
    AND r.is_active = 'Y';

    IF v_role_count > 0 THEN
        RETURN 1;  -- Has role
    ELSE
        RETURN 0;  -- No role
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
END fn_has_role;
/

-- ============================================================================
-- FUNCTION 5: fn_get_user_roles - Get all roles for a user as comma-separated list
-- ============================================================================
CREATE OR REPLACE FUNCTION fn_get_user_roles (
    p_user_id IN NUMBER
)
RETURN VARCHAR2
IS
    v_roles VARCHAR2(500);
BEGIN
    SELECT LISTAGG(r.role_code, ',') WITHIN GROUP (ORDER BY r.role_code)
    INTO v_roles
    FROM USER_ROLES ur
    INNER JOIN ROLES r ON ur.role_id = r.role_id
    WHERE ur.user_id = p_user_id
    AND ur.is_active = 'Y'
    AND r.is_active = 'Y';

    RETURN NVL(v_roles, 'NO_ROLES');

EXCEPTION
    WHEN OTHERS THEN
        RETURN 'NO_ROLES';
END fn_get_user_roles;
/

-- ============================================================================
-- FUNCTION 6: fn_is_session_valid - Check if session is valid and not expired
-- ============================================================================
CREATE OR REPLACE FUNCTION fn_is_session_valid (
    p_session_id IN VARCHAR2
)
RETURN NUMBER
IS
    v_session_status VARCHAR2(20);
    v_last_activity DATE;
    v_timeout_minutes NUMBER;
    v_minutes_since_activity NUMBER;
BEGIN
    -- Default timeout
    v_timeout_minutes := 30;

    -- Get session info
    SELECT session_status, last_activity_time 
    INTO v_session_status, v_last_activity
    FROM SESSION_MANAGEMENT 
    WHERE session_id = p_session_id;

    -- Check if session is active
    IF v_session_status != 'ACTIVE' THEN
        RETURN 0;  -- Session not active
    END IF;

    -- Calculate minutes of inactivity
    v_minutes_since_activity := (SYSDATE - v_last_activity) * 24 * 60;
    
    -- Check if timeout exceeded
    IF v_minutes_since_activity > v_timeout_minutes THEN
        RETURN 0;  -- Session expired
    END IF;

    RETURN 1;  -- Session valid

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;  -- Session doesn't exist
    WHEN OTHERS THEN
        RETURN 0;  -- Error - treat as invalid
END fn_is_session_valid;
/

-- ============================================================================
-- FUNCTION 7: fn_get_session_user_id - Get user_id from session
-- ============================================================================
CREATE OR REPLACE FUNCTION fn_get_session_user_id (
    p_session_id IN VARCHAR2
)
RETURN NUMBER
IS
    v_user_id NUMBER;
BEGIN
    SELECT user_id INTO v_user_id
    FROM SESSION_MANAGEMENT 
    WHERE session_id = p_session_id
    AND session_status = 'ACTIVE';

    RETURN v_user_id;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
    WHEN OTHERS THEN
        RETURN NULL;
END fn_get_session_user_id;
/

-- ============================================================================
-- FUNCTION 8: fn_get_session_remaining_time - Get minutes until session expires
-- ============================================================================
CREATE OR REPLACE FUNCTION fn_get_session_remaining_time (
    p_session_id IN VARCHAR2
)
RETURN NUMBER
IS
    v_last_activity DATE;
    v_timeout_minutes NUMBER;
    v_minutes_since_activity NUMBER;
    v_remaining_minutes NUMBER;
BEGIN
    v_timeout_minutes := 30;  -- Default timeout

    SELECT last_activity_time INTO v_last_activity
    FROM SESSION_MANAGEMENT 
    WHERE session_id = p_session_id
    AND session_status = 'ACTIVE';

    v_minutes_since_activity := (SYSDATE - v_last_activity) * 24 * 60;
    v_remaining_minutes := v_timeout_minutes - TRUNC(v_minutes_since_activity);

    IF v_remaining_minutes < 0 THEN
        RETURN 0;
    END IF;

    RETURN v_remaining_minutes;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
    WHEN OTHERS THEN
        RETURN 0;
END fn_get_session_remaining_time;
/

-- ============================================================================
-- FUNCTION 9: fn_is_user_active - Check if user account is active
-- ============================================================================
CREATE OR REPLACE FUNCTION fn_is_user_active (
    p_user_id IN NUMBER
)
RETURN NUMBER
IS
    v_is_active VARCHAR2(1);
BEGIN
    SELECT is_active INTO v_is_active 
    FROM USERS 
    WHERE user_id = p_user_id;

    IF v_is_active = 'Y' THEN
        RETURN 1;  -- Active
    ELSE
        RETURN 0;  -- Inactive
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
    WHEN OTHERS THEN
        RETURN 0;
END fn_is_user_active;
/

-- ============================================================================
-- FUNCTION 10: fn_is_account_locked - Check if user account is locked
-- ============================================================================
CREATE OR REPLACE FUNCTION fn_is_account_locked (
    p_user_id IN NUMBER
)
RETURN NUMBER
IS
    v_account_locked VARCHAR2(1);
BEGIN
    SELECT account_locked INTO v_account_locked 
    FROM USERS 
    WHERE user_id = p_user_id;

    IF v_account_locked = 'Y' THEN
        RETURN 1;  -- Locked
    ELSE
        RETURN 0;  -- Not locked
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
    WHEN OTHERS THEN
        RETURN 0;
END fn_is_account_locked;
/
-- ============================================================================
-- SECTION 2: CREATE 8 PROCEDURES
-- ============================================================================

-- ============================================================================
-- PROCEDURE 1: sp_authenticate_user - Main login procedure
-- ============================================================================
CREATE OR REPLACE PROCEDURE sp_authenticate_user (
    p_username IN VARCHAR2,
    p_password IN VARCHAR2,
    p_session_id OUT VARCHAR2,
    p_user_id OUT NUMBER,
    p_success OUT NUMBER,
    p_message OUT VARCHAR2
)
IS
    v_user_id NUMBER;
    v_password_hash VARCHAR2(255);
    v_is_active VARCHAR2(1);
    v_account_locked VARCHAR2(1);
    v_failed_attempts NUMBER;
    v_lockout_minutes NUMBER;
    v_max_attempts NUMBER;
    v_new_session_id VARCHAR2(100);
BEGIN
    p_success := 0;
    p_message := '';
    p_session_id := NULL;
    p_user_id := NULL;

    -- Default security settings
    v_max_attempts := 5;
    v_lockout_minutes := 15;

    -- Step 1: Check if user exists and is active
    BEGIN
        SELECT user_id, password_hash, is_active, account_locked 
        INTO v_user_id, v_password_hash, v_is_active, v_account_locked
        FROM USERS 
        WHERE username = p_username;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- Log failed attempt
            INSERT INTO LOGIN_ATTEMPTS (attempt_id, username, login_result, failure_reason)
            VALUES (SQ_LOGIN_ATTEMPTS.NEXTVAL, p_username, 'FAILURE', 'User not found');
            COMMIT;
            
            p_success := 0;
            p_message := 'Invalid username or password';
            RETURN;
    END;

    -- Step 2: Check if account is locked
    IF v_account_locked = 'Y' THEN
        INSERT INTO AUDIT_LOG (audit_id, user_id, action_type, status, failure_reason)
        VALUES (SQ_AUDIT_LOG.NEXTVAL, v_user_id, 'LOGIN', 'FAILURE', 'Account locked - too many attempts');
        COMMIT;
        
        p_success := 0;
        p_message := 'Account is locked. Try again later';
        RETURN;
    END IF;

    -- Step 3: Check if user is active
    IF v_is_active = 'N' THEN
        INSERT INTO AUDIT_LOG (audit_id, user_id, action_type, status, failure_reason)
        VALUES (SQ_AUDIT_LOG.NEXTVAL, v_user_id, 'LOGIN', 'FAILURE', 'Inactive user account');
        COMMIT;
        
        p_success := 0;
        p_message := 'User account is inactive';
        RETURN;
    END IF;

    -- Step 4: Verify password
    IF fn_verify_password(p_password, v_password_hash) = 0 THEN
        -- Count recent failed attempts
        SELECT COUNT(*) INTO v_failed_attempts
        FROM LOGIN_ATTEMPTS 
        WHERE username = p_username AND login_result = 'FAILURE'
        AND attempt_timestamp > SYSDATE - 1;
        
        v_failed_attempts := v_failed_attempts + 1;
        
        -- Log this failed attempt
        INSERT INTO LOGIN_ATTEMPTS (attempt_id, username, login_result, failure_reason)
        VALUES (SQ_LOGIN_ATTEMPTS.NEXTVAL, p_username,  'FAILURE', 'Invalid password');
        
        -- Lock account if max attempts exceeded (trigger will handle this)
        COMMIT;
        
        p_success := 0;
        p_message := 'Invalid username or password';
        RETURN;
    END IF;

    -- Step 5: Password is correct - create session
    v_new_session_id := DBMS_RANDOM.STRING('X', 32);
    
    INSERT INTO SESSION_MANAGEMENT (
        session_id, user_id, login_time, last_activity_time, session_status
    ) VALUES (
        v_new_session_id, v_user_id, SYSDATE, SYSDATE, 'ACTIVE'
    );
    
    -- Log successful login
    INSERT INTO LOGIN_ATTEMPTS (attempt_id, username, login_result)
    VALUES (SQ_LOGIN_ATTEMPTS.NEXTVAL, p_username, 'SUCCESS');
    
    INSERT INTO AUDIT_LOG (audit_id, user_id, action_type, status)
    VALUES (SQ_AUDIT_LOG.NEXTVAL, v_user_id, 'LOGIN', 'SUCCESS');
    
    -- Update user's last login
    UPDATE USERS SET last_login = SYSDATE WHERE user_id = v_user_id;
    
    COMMIT;
    
    -- Return success
    p_session_id := v_new_session_id;
    p_user_id := v_user_id;
    p_success := 1;
    p_message := 'Login successful';

EXCEPTION
    WHEN OTHERS THEN
        p_success := 0;
        p_message := 'Error during authentication: ' || SQLERRM;
        ROLLBACK;
END sp_authenticate_user;
/

-- ============================================================================
-- PROCEDURE 2: sp_logout_user - Logout and end session
-- ============================================================================
CREATE OR REPLACE PROCEDURE sp_logout_user (
    p_session_id IN VARCHAR2,
    p_success OUT NUMBER,
    p_message OUT VARCHAR2
)
IS
    v_user_id NUMBER;
BEGIN
    p_success := 0;
    p_message := '';

    -- Get user from session
    BEGIN
        SELECT user_id INTO v_user_id 
        FROM SESSION_MANAGEMENT 
        WHERE session_id = p_session_id AND session_status = 'ACTIVE';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_success := 0;
            p_message := 'Invalid session';
            RETURN;
    END;

    -- Update session status
    UPDATE SESSION_MANAGEMENT 
    SET session_status = 'LOGGED_OUT', logout_time = SYSDATE
    WHERE session_id = p_session_id;

    -- Log the logout
    INSERT INTO AUDIT_LOG (audit_id, user_id, action_type, status)
    VALUES (SQ_AUDIT_LOG.NEXTVAL, v_user_id, 'LOGOUT', 'SUCCESS');

    COMMIT;

    p_success := 1;
    p_message := 'Logout successful';

EXCEPTION
    WHEN OTHERS THEN
        p_success := 0;
        p_message := 'Error during logout: ' || SQLERRM;
        ROLLBACK;
END sp_logout_user;
/

-- ============================================================================
-- PROCEDURE 3: sp_change_password - User changes their own password
-- ============================================================================
CREATE OR REPLACE PROCEDURE sp_change_password (
    p_user_id IN NUMBER,
    p_old_password IN VARCHAR2,
    p_new_password IN VARCHAR2,
    p_success OUT NUMBER,
    p_message OUT VARCHAR2
)
IS
    v_password_hash VARCHAR2(255);
    v_password_min_length NUMBER := 8;
    v_new_password_hash VARCHAR2(255);
    v_dummy NUMBER;
    
BEGIN
    p_success := 0;
    p_message := '';

    -- Verify old password
    BEGIN
        SELECT password_hash INTO v_password_hash FROM USERS WHERE user_id = p_user_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_success := 0;
            p_message := 'User not found';
            RETURN;
    END;
    
    IF fn_verify_password(p_old_password, v_password_hash) = 0 THEN
        INSERT INTO AUDIT_LOG (audit_id, user_id, action_type, status, failure_reason)
        VALUES (SQ_AUDIT_LOG.NEXTVAL, p_user_id, 'PASSWORD_CHANGE', 'FAILURE', 'Invalid old password');
        COMMIT;
        
        p_success := 0;
        p_message := 'Current password is incorrect';
        RETURN;
    END IF;

    -- Validate new password length
    IF LENGTH(p_new_password) < v_password_min_length THEN
        p_success := 0;
        p_message := 'Password must be at least ' || v_password_min_length || ' characters';
        RETURN;
    END IF;

    -- Hash new password
    v_new_password_hash := fn_hash_password(p_new_password);

    -- Check if new password matches any recent old password
    BEGIN
        SELECT 1 INTO v_dummy
        FROM PASSWORD_HISTORY
        WHERE user_id = p_user_id
        AND old_password_hash = v_new_password_hash
        AND ROWNUM = 1;

        p_success := 0;
        p_message := 'You cannot reuse a recent password';
        RETURN;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL; 
    END;

    -- Store old password in history
    INSERT INTO PASSWORD_HISTORY (history_id, user_id, old_password_hash, changed_date)
    VALUES (SQ_PASSWORD_HISTORY.NEXTVAL, p_user_id, v_password_hash, SYSDATE);

    -- Update password
    UPDATE USERS 
    SET password_hash = v_new_password_hash,
        last_password_change = SYSDATE
    WHERE user_id = p_user_id;

    -- Log the change
    INSERT INTO AUDIT_LOG (audit_id, user_id, action_type, status, action_details)
    VALUES (SQ_AUDIT_LOG.NEXTVAL, p_user_id, 'PASSWORD_CHANGE', 'SUCCESS', 'User changed password');

    COMMIT;

    p_success := 1;
    p_message := 'Password changed successfully';

EXCEPTION
    WHEN OTHERS THEN
        p_success := 0;
        p_message := 'Error changing password: ' || SQLERRM;
        ROLLBACK;
END sp_change_password;
/

-- ============================================================================
-- PROCEDURE 4: sp_validate_session - Validate and update session activity
-- ============================================================================
CREATE OR REPLACE PROCEDURE sp_validate_session (
    p_session_id IN VARCHAR2,
    p_is_valid OUT NUMBER,
    p_user_id OUT NUMBER,
    p_message OUT VARCHAR2
)
IS
    v_user_id NUMBER;
    v_session_status VARCHAR2(20);
    v_last_activity DATE;
    v_timeout_minutes NUMBER := 30;
    v_minutes_since_activity NUMBER;
BEGIN
    p_is_valid := 0;
    p_message := '';
    p_user_id := NULL;

    -- Check if session exists
    BEGIN
        SELECT user_id, session_status, last_activity_time 
        INTO v_user_id, v_session_status, v_last_activity
        FROM SESSION_MANAGEMENT 
        WHERE session_id = p_session_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_is_valid := 0;
            p_message := 'Session not found';
            RETURN;
    END;

    -- Check if session is already logged out
    IF v_session_status = 'LOGGED_OUT' THEN
        p_is_valid := 0;
        p_message := 'Session is closed';
        RETURN;
    END IF;

    -- Check if session has expired due to inactivity
    v_minutes_since_activity := (SYSDATE - v_last_activity) * 24 * 60;
    
    IF v_minutes_since_activity > v_timeout_minutes THEN
        UPDATE SESSION_MANAGEMENT 
        SET session_status = 'EXPIRED', logout_time = SYSDATE
        WHERE session_id = p_session_id;
        COMMIT;
        
        p_is_valid := 0;
        p_message := 'Session expired due to inactivity';
        RETURN;
    END IF;

    -- Update last activity time (keep-alive)
    UPDATE SESSION_MANAGEMENT 
    SET last_activity_time = SYSDATE
    WHERE session_id = p_session_id;

    COMMIT;

    p_is_valid := 1;
    p_user_id := v_user_id;
    p_message := 'Session is valid';

EXCEPTION
    WHEN OTHERS THEN
        p_is_valid := 0;
        p_message := 'Error validating session: ' || SQLERRM;
END sp_validate_session;
/

-- ============================================================================
-- PROCEDURE 5: sp_check_user_permission - Check if user has permission
-- ============================================================================
CREATE OR REPLACE PROCEDURE sp_check_user_permission (
    p_user_id IN NUMBER,
    p_permission_code IN VARCHAR2,
    p_has_permission OUT NUMBER,
    p_message OUT VARCHAR2
)
IS
    v_permission_count NUMBER;
BEGIN
    p_has_permission := 0;
    p_message := '';

    -- Check if user has the permission through any of their roles
    SELECT COUNT(*) INTO v_permission_count
    FROM USER_ROLES ur
    INNER JOIN ROLE_PERMISSIONS rp ON ur.role_id = rp.role_id
    INNER JOIN PERMISSIONS p ON rp.permission_id = p.permission_id
    WHERE ur.user_id = p_user_id
    AND p.permission_code = p_permission_code
    AND ur.is_active = 'Y'
    AND p.is_active = 'Y';

    IF v_permission_count > 0 THEN
        p_has_permission := 1;
        p_message := 'User has permission';
        
        -- Log permission check success
        INSERT INTO AUDIT_LOG (audit_id, user_id, action_type, resource_accessed, status)
        VALUES (SQ_AUDIT_LOG.NEXTVAL, p_user_id, 'PERMISSION_CHECK', p_permission_code, 'SUCCESS');
    ELSE
        p_has_permission := 0;
        p_message := 'User does not have permission';
        
        -- Log permission check failure
        INSERT INTO AUDIT_LOG (audit_id, user_id, action_type, resource_accessed, status)
        VALUES (SQ_AUDIT_LOG.NEXTVAL, p_user_id, 'PERMISSION_DENIED', p_permission_code, 'FAILURE');
    END IF;

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        p_has_permission := 0;
        p_message := 'Error checking permission: ' || SQLERRM;
END sp_check_user_permission;
/

-- ============================================================================
-- PROCEDURE 6: sp_assign_role_to_user - Assign role to user
-- ============================================================================
CREATE OR REPLACE PROCEDURE sp_assign_role_to_user (
    p_user_id IN NUMBER,
    p_role_id IN NUMBER,
    p_assigned_by_user_id IN NUMBER,
    p_success OUT NUMBER,
    p_message OUT VARCHAR2
)
IS
BEGIN
    p_success := 0;
    p_message := '';

    -- Check if role is already assigned
    DECLARE
    v_dummy NUMBER;
    BEGIN
        SELECT 1 INTO v_dummy
        FROM USER_ROLES
        WHERE user_id = p_user_id 
          AND role_id = p_role_id
          AND is_active = 'Y'
          AND ROWNUM = 1;

        -- If SELECT succeeds, the role already exists
        p_success := 0;
        p_message := 'User already has this role';
        RETURN;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL; -- No matching role, continue normally
    END;

    -- Assign role
    INSERT INTO USER_ROLES (user_id, role_id, assigned_date, assigned_by_user_id, is_active)
    VALUES (p_user_id, p_role_id, SYSDATE, p_assigned_by_user_id, 'Y');

    -- Log the action
    INSERT INTO AUDIT_LOG (audit_id, user_id, action_type, resource_accessed, action_details, status)
    VALUES (SQ_AUDIT_LOG.NEXTVAL, p_assigned_by_user_id, 'DATA_UPDATE', 'USER_ROLE', 
            'Assigned role ' || p_role_id || ' to user ' || p_user_id, 'SUCCESS');

    COMMIT;

    p_success := 1;
    p_message := 'Role assigned successfully';

EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        p_success := 0;
        p_message := 'Role assignment already exists';
    WHEN OTHERS THEN
        p_success := 0;
        p_message := 'Error assigning role: ' || SQLERRM;
        ROLLBACK;
END sp_assign_role_to_user;
/

-- ============================================================================
-- PROCEDURE 7: sp_revoke_role_from_user - Revoke role from user
-- ============================================================================
CREATE OR REPLACE PROCEDURE sp_revoke_role_from_user (
    p_user_id IN NUMBER,
    p_role_id IN NUMBER,
    p_success OUT NUMBER,
    p_message OUT VARCHAR2
)
IS
    v_rows_affected NUMBER;
BEGIN
    p_success := 0;
    p_message := '';

    -- Soft delete - set is_active to N
    UPDATE USER_ROLES 
    SET is_active = 'N'
    WHERE user_id = p_user_id AND role_id = p_role_id AND is_active = 'Y';

    v_rows_affected := SQL%ROWCOUNT;

    IF v_rows_affected = 0 THEN
        p_success := 0;
        p_message := 'Role assignment not found';
        RETURN;
    END IF;

    -- Log the revocation
    INSERT INTO AUDIT_LOG (audit_id, action_type, resource_accessed, action_details, status)
    VALUES (SQ_AUDIT_LOG.NEXTVAL, 'DATA_UPDATE', 'USER_ROLE', 
            'Revoked role ' || p_role_id || ' from user ' || p_user_id, 'SUCCESS');

    COMMIT;

    p_success := 1;
    p_message := 'Role revoked successfully';

EXCEPTION
    WHEN OTHERS THEN
        p_success := 0;
        p_message := 'Error revoking role: ' || SQLERRM;
        ROLLBACK;
END sp_revoke_role_from_user;
/

-- ============================================================================
-- PROCEDURE 8: sp_clean_expired_sessions - Cleanup expired sessions
-- ============================================================================
CREATE OR REPLACE PROCEDURE sp_clean_expired_sessions (
    p_cleaned_count OUT NUMBER,
    p_message OUT VARCHAR2
)
IS
    v_timeout_minutes NUMBER := 30;
BEGIN
    p_cleaned_count := 0;
    p_message := '';

    -- Mark old sessions as expired
    UPDATE SESSION_MANAGEMENT 
    SET session_status = 'EXPIRED', logout_time = SYSDATE
    WHERE session_status = 'ACTIVE' 
    AND last_activity_time < SYSDATE - (v_timeout_minutes / 1440)
    AND logout_time IS NULL;

    p_cleaned_count := SQL%ROWCOUNT;

    -- Log the cleanup
    INSERT INTO AUDIT_LOG (audit_id, action_type, resource_accessed, action_details, status)
    VALUES (SQ_AUDIT_LOG.NEXTVAL, 'DATA_UPDATE', 'SESSION_MANAGEMENT', 
            'Cleaned up ' || p_cleaned_count || ' expired sessions', 'SUCCESS');

    COMMIT;

    p_message := 'Session cleanup completed. ' || p_cleaned_count || ' sessions cleaned.';

EXCEPTION
    WHEN OTHERS THEN
        p_cleaned_count := 0;
        p_message := 'Error cleaning sessions: ' || SQLERRM;
END sp_clean_expired_sessions;
/