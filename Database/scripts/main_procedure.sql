-- ============================================================================
-- PROCEDURE: sp_authenticate_and_get_oracle_user
-- Purpose: Authenticate user and return Oracle database user credentials
--          based on their role for connection management
-- ============================================================================
CREATE OR REPLACE PROCEDURE sp_authenticate_and_get_oracle_user (
    p_username IN VARCHAR2,
    p_password IN VARCHAR2,
    p_session_id OUT VARCHAR2,
    p_user_id OUT NUMBER,
    p_oracle_username OUT VARCHAR2,
    p_oracle_password OUT VARCHAR2,
    p_user_roles OUT VARCHAR2,
    p_success OUT NUMBER,
    p_message OUT VARCHAR2
)
IS
    v_user_id NUMBER;
    v_password_hash VARCHAR2(255);
    v_is_active VARCHAR2(1);
    v_account_locked VARCHAR2(1);
    v_new_session_id VARCHAR2(100);
    v_role_code VARCHAR2(50);
    v_role_count NUMBER;
    v_all_roles VARCHAR2(500);
BEGIN
    -- Initialize output parameters
    p_success := 0;
    p_message := '';
    p_session_id := NULL;
    p_user_id := NULL;
    p_oracle_username := NULL;
    p_oracle_password := NULL;
    p_user_roles := NULL;

    -- ========================================================================
    -- STEP 1: Verify user exists in USERS table
    -- ========================================================================
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

    -- ========================================================================
    -- STEP 2: Check if account is locked
    -- ========================================================================
    IF v_account_locked = 'Y' THEN
        INSERT INTO AUDIT_LOG (audit_id, user_id, action_type, status, failure_reason)
        VALUES (SQ_AUDIT_LOG.NEXTVAL, v_user_id, 'LOGIN', 'FAILURE', 'Account locked');
        COMMIT;
        
        p_success := 0;
        p_message := 'Account is locked. Contact administrator';
        RETURN;
    END IF;

    -- ========================================================================
    -- STEP 3: Check if user account is active
    -- ========================================================================
    IF v_is_active = 'N' THEN
        INSERT INTO AUDIT_LOG (audit_id, user_id, action_type, status, failure_reason)
        VALUES (SQ_AUDIT_LOG.NEXTVAL, v_user_id, 'LOGIN', 'FAILURE', 'Inactive account');
        COMMIT;
        
        p_success := 0;
        p_message := 'User account is inactive';
        RETURN;
    END IF;

    -- ========================================================================
    -- STEP 4: Verify password using existing function
    -- ========================================================================
    IF fn_verify_password(p_password, v_password_hash) = 0 THEN
        -- Log failed attempt
        INSERT INTO LOGIN_ATTEMPTS (attempt_id, username, login_result, failure_reason)
        VALUES (SQ_LOGIN_ATTEMPTS.NEXTVAL, p_username, 'FAILURE', 'Invalid password');
        COMMIT;
        
        p_success := 0;
        p_message := 'Invalid username or password';
        RETURN;
    END IF;

    -- ========================================================================
    -- STEP 5: Get all active roles for the user
    -- ========================================================================
    v_all_roles := fn_get_user_roles(v_user_id);
    
    IF v_all_roles = 'NO_ROLES' THEN
        INSERT INTO AUDIT_LOG (audit_id, user_id, action_type, status, failure_reason)
        VALUES (SQ_AUDIT_LOG.NEXTVAL, v_user_id, 'LOGIN', 'FAILURE', 'No active roles assigned');
        COMMIT;
        
        p_success := 0;
        p_message := 'No roles assigned to user. Contact administrator';
        RETURN;
    END IF;

    -- ========================================================================
    -- STEP 6: Map user role to Oracle database user
    -- Priority order: SYS_ADMIN > DIRECTOR > IT_SUPPORT > CATALOGER > 
    --                 CIRCULATION_CLERK > PATRON
    -- ========================================================================
    
    -- Check for SYS_ADMIN role (highest privilege)
    IF fn_has_role(v_user_id, 'ROLE_SYS_ADMIN') = 1 THEN
        p_oracle_username := 'user_sysadmin';
        p_oracle_password := 'SysAdminPass123';  -- Replace with actual password
        v_role_code := 'ROLE_SYS_ADMIN';
    
    -- Check for DIRECTOR role
    ELSIF fn_has_role(v_user_id, 'ROLE_DIRECTOR') = 1 THEN
        p_oracle_username := 'user_director';
        p_oracle_password := 'DirectorPass123';  -- Replace with actual password
        v_role_code := 'ROLE_DIRECTOR';
    
    -- Check for IT_SUPPORT role
    ELSIF fn_has_role(v_user_id, 'ROLE_IT_SUPPORT') = 1 THEN
        p_oracle_username := 'user_itsupport';
        p_oracle_password := 'ITSupportPass123';  -- Replace with actual password
        v_role_code := 'ROLE_IT_SUPPORT';
    
    -- Check for CATALOGER role
    ELSIF fn_has_role(v_user_id, 'ROLE_CATALOGER') = 1 THEN
        p_oracle_username := 'user_cataloger';
        p_oracle_password := 'CatalogPass123';  -- Replace with actual password
        v_role_code := 'ROLE_CATALOGER';
    
    -- Check for CIRCULATION_CLERK role
    ELSIF fn_has_role(v_user_id, 'ROLE_CIRCULATION_CLERK') = 1 THEN
        p_oracle_username := 'user_clerk';
        p_oracle_password := 'ClerkPass123';  -- Replace with actual password
        v_role_code := 'ROLE_CIRCULATION_CLERK';
    
    -- Check for PATRON role (lowest privilege)
    ELSIF fn_has_role(v_user_id, 'ROLE_PATRON') = 1 THEN
        p_oracle_username := 'user_patron';
        p_oracle_password := 'patron_password';  -- Replace with actual password
        v_role_code := 'ROLE_PATRON';
    
    ELSE
        -- User has roles but none match our defined roles
        INSERT INTO AUDIT_LOG (audit_id, user_id, action_type, status, failure_reason)
        VALUES (SQ_AUDIT_LOG.NEXTVAL, v_user_id, 'LOGIN', 'FAILURE', 'No valid role mapping found');
        COMMIT;
        
        p_success := 0;
        p_message := 'Invalid role configuration. Contact administrator';
        RETURN;
    END IF;

    -- ========================================================================
    -- STEP 7: Create session using existing logic
    -- ========================================================================
    v_new_session_id := DBMS_RANDOM.STRING('X', 32);
    
    INSERT INTO SESSION_MANAGEMENT (
        session_id, user_id, login_time, last_activity_time, session_status
    ) VALUES (
        v_new_session_id, v_user_id, SYSDATE, SYSDATE, 'ACTIVE'
    );
    
    -- ========================================================================
    -- STEP 8: Log successful login
    -- ========================================================================
    INSERT INTO LOGIN_ATTEMPTS (attempt_id, username, login_result)
    VALUES (SQ_LOGIN_ATTEMPTS.NEXTVAL, p_username, 'SUCCESS');
    
    INSERT INTO AUDIT_LOG (audit_id, user_id, action_type, status, action_details)
    VALUES (SQ_AUDIT_LOG.NEXTVAL, v_user_id, 'LOGIN', 'SUCCESS', 
            'Mapped to Oracle user: ' || p_oracle_username);
    
    -- Update user's last login timestamp
    UPDATE USERS SET last_login = SYSDATE WHERE user_id = v_user_id;
    
    COMMIT;
    
    -- ========================================================================
    -- STEP 9: Return success with Oracle credentials
    -- ========================================================================
    p_session_id := v_new_session_id;
    p_user_id := v_user_id;
    p_user_roles := v_all_roles;
    p_success := 1;
    p_message := 'Authentication successful. Mapped to: ' || v_role_code;

EXCEPTION
    WHEN OTHERS THEN
        p_success := 0;
        p_message := 'System error during authentication: ' || SQLERRM;
        ROLLBACK;
END sp_authenticate_and_get_oracle_user;
/

-- ============================================================================
-- HELPER VIEW: v_user_oracle_mapping
-- Purpose: Quick view to see which users map to which Oracle users
-- ============================================================================
CREATE OR REPLACE VIEW v_user_oracle_mapping AS
SELECT 
    u.user_id,
    u.username,
    u.email,
    r.role_code,
    r.role_name,
    CASE r.role_code
        WHEN 'ROLE_SYS_ADMIN' THEN 'user_sysadmin'
        WHEN 'ROLE_DIRECTOR' THEN 'user_director'
        WHEN 'ROLE_IT_SUPPORT' THEN 'user_itsupport'
        WHEN 'ROLE_CATALOGER' THEN 'user_cataloger'
        WHEN 'ROLE_CIRCULATION_CLERK' THEN 'user_clerk'
        WHEN 'ROLE_PATRON' THEN 'user_patron'
        ELSE 'NO_MAPPING'
    END AS oracle_username,
    ur.assigned_date,
    ur.is_active
FROM USERS u
INNER JOIN USER_ROLES ur ON u.user_id = ur.user_id
INNER JOIN ROLES r ON ur.role_id = r.role_id
WHERE u.is_active = 'Y' AND ur.is_active = 'Y'
ORDER BY u.username, r.role_code;
/