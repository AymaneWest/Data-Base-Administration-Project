-- ============================================================================
-- SECTION 6: CREATE 4 TRIGGERS
-- ============================================================================

-- ============================================================================
-- TRIGGER 1: trg_audit_user_changes - Audit all changes to USERS table
-- ============================================================================
CREATE OR REPLACE TRIGGER trg_audit_user_changes
AFTER INSERT OR UPDATE OR DELETE ON USERS
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        INSERT INTO AUDIT_LOG (
            audit_id, action_type, resource_accessed, action_details, status, audit_timestamp
        ) VALUES (
            SQ_AUDIT_LOG.NEXTVAL, 'DATA_CREATE', 'USERS', 'New user created: ' || :NEW.username, 'SUCCESS', SYSDATE
        );
    ELSIF UPDATING THEN
        -- Log is_active changes
        IF NVL(:OLD.is_active, 'Y') != NVL(:NEW.is_active, 'Y') THEN
            INSERT INTO AUDIT_LOG (
                audit_id, user_id, action_type, resource_accessed, action_details, action_old_value, action_new_value, status, audit_timestamp
            ) VALUES (
                SQ_AUDIT_LOG.NEXTVAL, :NEW.user_id, 'DATA_UPDATE', 'USERS', 'User active status changed', 
                :OLD.is_active, :NEW.is_active, 'SUCCESS', SYSDATE
            );
        END IF;
        
        -- Log account_locked changes
        IF NVL(:OLD.account_locked, 'N') != NVL(:NEW.account_locked, 'N') THEN
            INSERT INTO AUDIT_LOG (
                audit_id, user_id, action_type, resource_accessed, action_details, action_old_value, action_new_value, status, audit_timestamp
            ) VALUES (
                SQ_AUDIT_LOG.NEXTVAL, :NEW.user_id, 'DATA_UPDATE', 'USERS', 'Account lock status changed', 
                :OLD.account_locked, :NEW.account_locked, 'SUCCESS', SYSDATE
            );
        END IF;
    ELSIF DELETING THEN
        INSERT INTO AUDIT_LOG (
            audit_id, user_id, action_type, resource_accessed, action_details, status, audit_timestamp
        ) VALUES (
            SQ_AUDIT_LOG.NEXTVAL, :OLD.user_id, 'DATA_DELETE', 'USERS', 'User deleted: ' || :OLD.username, 'SUCCESS', SYSDATE
        );
    END IF;
    
    COMMIT;
END trg_audit_user_changes;
/

-- ============================================================================
-- TRIGGER 2: trg_audit_role_assignment - Audit role assignments
-- ============================================================================
CREATE OR REPLACE TRIGGER trg_audit_role_assignment
AFTER INSERT OR DELETE ON USER_ROLES
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        INSERT INTO AUDIT_LOG (
            audit_id, action_type, resource_accessed, action_details, status, audit_timestamp
        ) VALUES (
            SQ_AUDIT_LOG.NEXTVAL, 'DATA_CREATE', 'USER_ROLES', 
            'Role ' || :NEW.role_id || ' assigned to user ' || :NEW.user_id, 'SUCCESS', SYSDATE
        );
    ELSIF DELETING THEN
        INSERT INTO AUDIT_LOG (
            audit_id, action_type, resource_accessed, action_details, status, audit_timestamp
        ) VALUES (
            SQ_AUDIT_LOG.NEXTVAL, 'DATA_DELETE', 'USER_ROLES', 
            'Role ' || :OLD.role_id || ' removed from user ' || :OLD.user_id, 'SUCCESS', SYSDATE
        );
    END IF;
    
    COMMIT;
END trg_audit_role_assignment;
/

-- ============================================================================
-- TRIGGER 3: trg_audit_permission_grant - Audit permission grants to roles
-- ============================================================================
CREATE OR REPLACE TRIGGER trg_audit_permission_grant
AFTER INSERT OR DELETE ON ROLE_PERMISSIONS
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        INSERT INTO AUDIT_LOG (
            audit_id, action_type, resource_accessed, action_details, status, audit_timestamp
        ) VALUES (
            SQ_AUDIT_LOG.NEXTVAL, 'DATA_CREATE', 'ROLE_PERMISSIONS', 
            'Permission ' || :NEW.permission_id || ' granted to role ' || :NEW.role_id, 'SUCCESS', SYSDATE
        );
    ELSIF DELETING THEN
        INSERT INTO AUDIT_LOG (
            audit_id, action_type, resource_accessed, action_details, status, audit_timestamp
        ) VALUES (
            SQ_AUDIT_LOG.NEXTVAL, 'DATA_DELETE', 'ROLE_PERMISSIONS', 
            'Permission ' || :OLD.permission_id || ' revoked from role ' || :OLD.role_id, 'SUCCESS', SYSDATE
        );
    END IF;
    
    COMMIT;
END trg_audit_permission_grant;
/

-- ============================================================================
-- TRIGGER 4: trg_lock_account_on_failed_attempts - Auto-lock account after failed logins
-- ============================================================================
CREATE OR REPLACE TRIGGER trg_lock_account_on_failed_attempts
AFTER INSERT ON LOGIN_ATTEMPTS
FOR EACH ROW
WHEN (NEW.login_result = 'FAILURE')
BEGIN
    DECLARE
        v_failed_attempts NUMBER;
        v_max_attempts NUMBER := 5;
        v_user_id NUMBER;
    BEGIN
        -- Count failed attempts in last 24 hours
        SELECT COUNT(*) INTO v_failed_attempts
        FROM LOGIN_ATTEMPTS 
        WHERE username = :NEW.username 
        AND login_result = 'FAILURE'
        AND attempt_timestamp > SYSDATE - 1;

        -- If max attempts exceeded, lock the account
        IF v_failed_attempts >= v_max_attempts THEN
            -- Find the user
            BEGIN
                SELECT user_id INTO v_user_id FROM USERS WHERE username = :NEW.username;
                
                -- Lock the account
                UPDATE USERS SET account_locked = 'Y' WHERE user_id = v_user_id;
                
                -- Log the lockup
                INSERT INTO AUDIT_LOG (audit_id, user_id, action_type, resource_accessed, action_details, status, audit_timestamp)
                VALUES (SQ_AUDIT_LOG.NEXTVAL, v_user_id, 'SECURITY_EVENT', 'ACCOUNT_LOCK', 
                        'Account locked after ' || v_failed_attempts || ' failed login attempts', 'SUCCESS', SYSDATE);
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    NULL;  -- User doesn't exist, ignore
            END;
        END IF;
    END;
END trg_lock_account_on_failed_attempts;
/