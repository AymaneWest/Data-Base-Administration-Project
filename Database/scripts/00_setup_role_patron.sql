-- ============================================================================
-- Complete ROLE_PATRON Setup Script
-- This script creates the ROLE_PATRON role and assigns it to patron users
-- Run this as SYS or PROJET_ADMIN
-- ============================================================================

-- Step 1: Create ROLE_PATRON if it doesn't exist
DECLARE
    v_count NUMBER;
BEGIN
    -- Check if role already exists
    SELECT COUNT(*) INTO v_count
    FROM DBA_ROLES
    WHERE ROLE = 'ROLE_PATRON';
    
    IF v_count = 0 THEN
        EXECUTE IMMEDIATE 'CREATE ROLE ROLE_PATRON';
        DBMS_OUTPUT.PUT_LINE('✓ ROLE_PATRON created successfully');
    ELSE
        DBMS_OUTPUT.PUT_LINE('✓ ROLE_PATRON already exists');
    END IF;
END;
/

-- Step 2: Grant necessary permissions to ROLE_PATRON
-- (These grants allow patrons to browse materials and manage their own data)

-- Material browsing permissions
GRANT SELECT ON PROJET_ADMIN.MATERIALS TO ROLE_PATRON;
GRANT SELECT ON PROJET_ADMIN.AUTHORS TO ROLE_PATRON;
GRANT SELECT ON PROJET_ADMIN.PUBLISHERS TO ROLE_PATRON;
GRANT SELECT ON PROJET_ADMIN.GENRES TO ROLE_PATRON;
GRANT SELECT ON PROJET_ADMIN.MATERIAL_AUTHORS TO ROLE_PATRON;
GRANT SELECT ON PROJET_ADMIN.MATERIAL_GENRES TO ROLE_PATRON;
GRANT SELECT ON PROJET_ADMIN.COPIES TO ROLE_PATRON;
GRANT SELECT ON PROJET_ADMIN.BRANCHES TO ROLE_PATRON;

-- Patron's own data (loans, reservations, fines)
GRANT SELECT ON PROJET_ADMIN.PATRONS TO ROLE_PATRON;
GRANT SELECT ON PROJET_ADMIN.LOANS TO ROLE_PATRON;
GRANT SELECT ON PROJET_ADMIN.RESERVATIONS TO ROLE_PATRON;
GRANT SELECT ON PROJET_ADMIN.FINES TO ROLE_PATRON;

-- Views for statistics
GRANT SELECT ON PROJET_ADMIN.VIEW_POPULAR_BOOKS TO ROLE_PATRON;
GRANT SELECT ON PROJET_ADMIN.VIEW_MATERIAL_DISTRIBUTION TO ROLE_PATRON;

-- Procedures that patrons can execute
GRANT EXECUTE ON PROJET_ADMIN.SP_PLACE_RESERVATION TO ROLE_PATRON;
GRANT EXECUTE ON PROJET_ADMIN.SP_CANCEL_RESERVATION TO ROLE_PATRON;
GRANT EXECUTE ON PROJET_ADMIN.FN_CHECK_MATERIAL_AVAILABILITY TO ROLE_PATRON;
GRANT EXECUTE ON PROJET_ADMIN.FN_GET_PATRON_STATISTICS TO ROLE_PATRON;
GRANT EXECUTE ON PROJET_ADMIN.SP_AUTHENTICATE_USER TO ROLE_PATRON;
GRANT EXECUTE ON PROJET_ADMIN.SP_LOGOUT_USER TO ROLE_PATRON;
GRANT EXECUTE ON PROJET_ADMIN.SP_CHANGE_PASSWORD TO ROLE_PATRON;

DBMS_OUTPUT.PUT_LINE('✓ Permissions granted to ROLE_PATRON');

-- Step 3: Assign ROLE_PATRON to all patron users
-- First, let's see what patron users exist

-- Method 1: If you have specific patron usernames, assign directly
-- Replace 'user_ysadmin' with your actual patron username(s)

BEGIN
    -- Check if user exists before granting
    FOR user_rec IN (
        SELECT username 
        FROM DBA_USERS 
        WHERE username IN ('USER_YSADMIN', 'USER_PATRON', 'PATRON_USER')
    ) LOOP
        -- Check if role is already granted
        DECLARE
            v_has_role NUMBER;
        BEGIN
            SELECT COUNT(*) INTO v_has_role
            FROM DBA_ROLE_PRIVS
            WHERE GRANTEE = user_rec.username
            AND GRANTED_ROLE = 'ROLE_PATRON';
            
            IF v_has_role = 0 THEN
                EXECUTE IMMEDIATE 'GRANT ROLE_PATRON TO ' || user_rec.username;
                DBMS_OUTPUT.PUT_LINE('✓ ROLE_PATRON granted to ' || user_rec.username);
            ELSE
                DBMS_OUTPUT.PUT_LINE('✓ ' || user_rec.username || ' already has ROLE_PATRON');
            END IF;
        END;
    END LOOP;
END;
/

-- Step 4: Insert role record into database ROLES table (if using custom roles table)
DECLARE
    v_count NUMBER;
BEGIN
    -- Check if ROLE_PATRON exists in custom ROLES table
    SELECT COUNT(*) INTO v_count
    FROM PROJET_ADMIN.ROLES
    WHERE role_code = 'ROLE_PATRON';
    
    IF v_count = 0 THEN
        INSERT INTO PROJET_ADMIN.ROLES (
            role_id, 
            role_code, 
            role_name, 
            role_description, 
            is_active
        ) VALUES (
            (SELECT NVL(MAX(role_id), 0) + 1 FROM PROJET_ADMIN.ROLES),
            'ROLE_PATRON',
            'Library Patron',
            'Regular library members who can browse materials, make reservations, and view their loans',
            'Y'
        );
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('✓ ROLE_PATRON added to ROLES table');
    ELSE
        DBMS_OUTPUT.PUT_LINE('✓ ROLE_PATRON already exists in ROLES table');
    END IF;
END;
/

-- Step 5: Link existing patrons to ROLE_PATRON in USER_ROLES table
BEGIN
    FOR user_rec IN (
        SELECT u.user_id, u.username
        FROM PROJET_ADMIN.USERS u
        JOIN PROJET_ADMIN.PATRONS p ON u.user_id = p.user_id
        WHERE NOT EXISTS (
            SELECT 1 
            FROM PROJET_ADMIN.USER_ROLES ur
            JOIN PROJET_ADMIN.ROLES r ON ur.role_id = r.role_id
            WHERE ur.user_id = u.user_id
            AND r.role_code = 'ROLE_PATRON'
        )
    ) LOOP
        INSERT INTO PROJET_ADMIN.USER_ROLES (
            user_id,
            role_id,
            assigned_date,
            is_active
        ) VALUES (
            user_rec.user_id,
            (SELECT role_id FROM PROJET_ADMIN.ROLES WHERE role_code = 'ROLE_PATRON'),
            SYSDATE,
            'Y'
        );
        DBMS_OUTPUT.PUT_LINE('✓ Linked patron user ' || user_rec.username || ' to ROLE_PATRON');
    END LOOP;
    COMMIT;
END;
/

-- Step 6: Verify the setup
SET SERVEROUTPUT ON;
DECLARE
    v_count NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('VERIFICATION REPORT');
    DBMS_OUTPUT.PUT_LINE('========================================');
    
    -- Check Oracle role
    SELECT COUNT(*) INTO v_count FROM DBA_ROLES WHERE ROLE = 'ROLE_PATRON';
    DBMS_OUTPUT.PUT_LINE('Oracle Role exists: ' || CASE WHEN v_count > 0 THEN 'YES ✓' ELSE 'NO ✗' END);
    
    -- Check custom ROLES table
    SELECT COUNT(*) INTO v_count FROM PROJET_ADMIN.ROLES WHERE role_code = 'ROLE_PATRON';
    DBMS_OUTPUT.PUT_LINE('ROLES table entry: ' || CASE WHEN v_count > 0 THEN 'YES ✓' ELSE 'NO ✗' END);
    
    -- Check number of users with role
    SELECT COUNT(*) INTO v_count FROM DBA_ROLE_PRIVS WHERE GRANTED_ROLE = 'ROLE_PATRON';
    DBMS_OUTPUT.PUT_LINE('Users granted role: ' || v_count);
    
    -- List users
    FOR user_rec IN (
        SELECT GRANTEE FROM DBA_ROLE_PRIVS WHERE GRANTED_ROLE = 'ROLE_PATRON'
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('  - ' || user_rec.GRANTEE);
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('========================================');
END;
/

-- Success message
PROMPT 
PROMPT ====================================================
PROMPT ROLE_PATRON Setup Complete!
PROMPT ====================================================
PROMPT Next steps:
PROMPT 1. Restart your backend server
PROMPT 2. Login as a patron user
PROMPT 3. Materials should now appear on the patron dashboard
PROMPT ====================================================
