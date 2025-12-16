-- ============================================================================
-- RE-INSERT ROLES AND PERMISSIONS FOR RBAC SYSTEM
-- ============================================================================

-- First, clear existing data (optional - only if you want to start fresh)
-- DELETE FROM ROLE_PERMISSIONS;
-- DELETE FROM USER_ROLES;
-- DELETE FROM PERMISSIONS;
-- DELETE FROM ROLES;
-- COMMIT;

-- ============================================================================
-- 1. INSERT ROLES TABLE
-- ============================================================================
INSERT INTO ROLES (role_id, role_code, role_name, role_description, is_active) VALUES (1, 'ROLE_SYS_ADMIN', 'System Administrator', 'Full system access and configuration', 'Y');
INSERT INTO ROLES (role_id, role_code, role_name, role_description, is_active) VALUES (2, 'ROLE_DIRECTOR', 'Library Director', 'Oversees operations and generates strategic reports', 'Y');
INSERT INTO ROLES (role_id, role_code, role_name, role_description, is_active) VALUES (3, 'ROLE_CATALOGER', 'Cataloger', 'Specialist in catalog management - adds new materials, updates metadata', 'Y');
INSERT INTO ROLES (role_id, role_code, role_name, role_description, is_active) VALUES (4, 'ROLE_CIRCULATION_CLERK', 'Circulation Clerk', 'Handles day-to-day circulation - checkouts, returns, holds, patron services', 'Y');
INSERT INTO ROLES (role_id, role_code, role_name, role_description, is_active) VALUES (5, 'ROLE_IT_SUPPORT', 'IT Support', 'Technical support - manages system, limited business data access', 'Y');

-- ============================================================================
-- 2. INSERT PERMISSIONS TABLE
-- ============================================================================
-- System Administration Permissions
INSERT INTO PERMISSIONS (permission_id, permission_code, permission_name, permission_description, permission_category, permission_resource, action) VALUES (1, 'SYS_FULL_ACCESS', 'Full System Access', 'Complete access to all system functions and data', 'System', 'All', 'All');
INSERT INTO PERMISSIONS (permission_id, permission_code, permission_name, permission_description, permission_category, permission_resource, action) VALUES (2, 'USER_MANAGE_ALL', 'Manage All Users', 'Create, edit and delete all user accounts', 'Administration', 'User', 'All');
INSERT INTO PERMISSIONS (permission_id, permission_code, permission_name, permission_description, permission_category, permission_resource, action) VALUES (3, 'ROLE_MANAGE', 'Manage Roles', 'Create and modify role definitions', 'Administration', 'Role', 'All');

-- Library Management Permissions
INSERT INTO PERMISSIONS (permission_id, permission_code, permission_name, permission_description, permission_category, permission_resource, action) VALUES (4, 'LIBRARY_VIEW_ALL', 'View All Libraries', 'Access to view all library information', 'Library', 'Library', 'Read');
INSERT INTO PERMISSIONS (permission_id, permission_code, permission_name, permission_description, permission_category, permission_resource, action) VALUES (5, 'BRANCH_VIEW_ALL', 'View All Branches', 'Access to view all branch information', 'Library', 'Branch', 'Read');
INSERT INTO PERMISSIONS (permission_id, permission_code, permission_name, permission_description, permission_category, permission_resource, action) VALUES (6, 'STAFF_VIEW_ALL', 'View All Staff', 'Access to view all staff information', 'Library', 'Staff', 'Read');

-- Catalog Management Permissions
INSERT INTO PERMISSIONS (permission_id, permission_code, permission_name, permission_description, permission_category, permission_resource, action) VALUES (7, 'CATALOG_MANAGE', 'Manage Catalog', 'Full access to catalog management functions', 'Catalog', 'Material', 'All');
INSERT INTO PERMISSIONS (permission_id, permission_code, permission_name, permission_description, permission_category, permission_resource, action) VALUES (8, 'MATERIAL_ADD', 'Add Materials', 'Add new materials to catalog', 'Catalog', 'Material', 'Create');
INSERT INTO PERMISSIONS (permission_id, permission_code, permission_name, permission_description, permission_category, permission_resource, action) VALUES (9, 'MATERIAL_EDIT', 'Edit Materials', 'Modify existing material records', 'Catalog', 'Material', 'Update');
INSERT INTO PERMISSIONS (permission_id, permission_code, permission_name, permission_description, permission_category, permission_resource, action) VALUES (10, 'MATERIAL_DELETE', 'Delete Materials', 'Remove materials from catalog', 'Catalog', 'Material', 'Delete');
INSERT INTO PERMISSIONS (permission_id, permission_code, permission_name, permission_description, permission_category, permission_resource, action) VALUES (11, 'COPY_MANAGE', 'Manage Copies', 'Manage physical/digital copies of materials', 'Catalog', 'Copy', 'All');

-- Circulation Permissions
INSERT INTO PERMISSIONS (permission_id, permission_code, permission_name, permission_description, permission_category, permission_resource, action) VALUES (12, 'CIRCULATION_MANAGE', 'Manage Circulation', 'Full access to circulation functions', 'Circulation', 'Loan', 'All');
INSERT INTO PERMISSIONS (permission_id, permission_code, permission_name, permission_description, permission_category, permission_resource, action) VALUES (13, 'CHECKOUT_PROCESS', 'Process Checkouts', 'Check out materials to patrons', 'Circulation', 'Loan', 'Create');
INSERT INTO PERMISSIONS (permission_id, permission_code, permission_name, permission_description, permission_category, permission_resource, action) VALUES (14, 'CHECKIN_PROCESS', 'Process Check-ins', 'Check in returned materials', 'Circulation', 'Loan', 'Update');
INSERT INTO PERMISSIONS (permission_id, permission_code, permission_name, permission_description, permission_category, permission_resource, action) VALUES (15, 'RENEW_PROCESS', 'Process Renewals', 'Renew patron loans', 'Circulation', 'Loan', 'Update');
INSERT INTO PERMISSIONS (permission_id, permission_code, permission_name, permission_description, permission_category, permission_resource, action) VALUES (16, 'PATRON_MANAGE', 'Manage Patrons', 'Create and modify patron records', 'Circulation', 'Patron', 'All');

-- Reservation Permissions
INSERT INTO PERMISSIONS (permission_id, permission_code, permission_name, permission_description, permission_category, permission_resource, action) VALUES (17, 'RESERVATION_MANAGE', 'Manage Reservations', 'Handle hold requests and reservations', 'Circulation', 'Reservation', 'All');
INSERT INTO PERMISSIONS (permission_id, permission_code, permission_name, permission_description, permission_category, permission_resource, action) VALUES (18, 'RESERVATION_CREATE', 'Create Reservations', 'Place new reservations for patrons', 'Circulation', 'Reservation', 'Create');
INSERT INTO PERMISSIONS (permission_id, permission_code, permission_name, permission_description, permission_category, permission_resource, action) VALUES (19, 'RESERVATION_CANCEL', 'Cancel Reservations', 'Cancel existing reservations', 'Circulation', 'Reservation', 'Delete');

-- Fine Management Permissions
INSERT INTO PERMISSIONS (permission_id, permission_code, permission_name, permission_description, permission_category, permission_resource, action) VALUES (20, 'FINE_MANAGE', 'Manage Fines', 'Full access to fine management', 'Finance', 'Fine', 'All');
INSERT INTO PERMISSIONS (permission_id, permission_code, permission_name, permission_description, permission_category, permission_resource, action) VALUES (21, 'FINE_ASSESS', 'Assess Fines', 'Create fines for violations', 'Finance', 'Fine', 'Create');
INSERT INTO PERMISSIONS (permission_id, permission_code, permission_name, permission_description, permission_category, permission_resource, action) VALUES (22, 'FINE_WAIVE', 'Waive Fines', 'Waive or reduce fines', 'Finance', 'Fine', 'Update');
INSERT INTO PERMISSIONS (permission_id, permission_code, permission_name, permission_description, permission_category, permission_resource, action) VALUES (23, 'PAYMENT_PROCESS', 'Process Payments', 'Accept fine payments', 'Finance', 'Fine', 'Update');

-- Report Permissions
INSERT INTO PERMISSIONS (permission_id, permission_code, permission_name, permission_description, permission_category, permission_resource, action) VALUES (24, 'REPORTS_VIEW', 'View Reports', 'Access to system reports', 'Reports', 'Report', 'Read');
INSERT INTO PERMISSIONS (permission_id, permission_code, permission_name, permission_description, permission_category, permission_resource, action) VALUES (25, 'REPORTS_GENERATE', 'Generate Reports', 'Create and export reports', 'Reports', 'Report', 'Create');

-- System Maintenance Permissions
INSERT INTO PERMISSIONS (permission_id, permission_code, permission_name, permission_description, permission_category, permission_resource, action) VALUES (26, 'SYSTEM_MAINTENANCE', 'System Maintenance', 'Perform system maintenance tasks', 'System', 'System', 'Update');
INSERT INTO PERMISSIONS (permission_id, permission_code, permission_name, permission_description, permission_category, permission_resource, action) VALUES (27, 'BATCH_PROCESS', 'Batch Processing', 'Run batch maintenance processes', 'System', 'System', 'Execute');

-- Authentication & Session Permissions
INSERT INTO PERMISSIONS (permission_id, permission_code, permission_name, permission_description, permission_category, permission_resource, action) VALUES (28, 'AUTH_MANAGE', 'Manage Authentication', 'Access to authentication functions', 'Security', 'Authentication', 'All');
INSERT INTO PERMISSIONS (permission_id, permission_code, permission_name, permission_description, permission_category, permission_resource, action) VALUES (29, 'SESSION_MANAGE', 'Manage Sessions', 'Access to session management functions', 'Security', 'Session', 'All');

-- ============================================================================
-- 3. INSERT ROLE_PERMISSIONS TABLE (Assign permissions to roles)
-- ============================================================================

-- ROLE_SYS_ADMIN - Full system access
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id, granted_date) VALUES (1, 1, 1, SYSDATE);  -- SYS_FULL_ACCESS
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id, granted_date) VALUES (1, 2, 1, SYSDATE);  -- USER_MANAGE_ALL
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id, granted_date) VALUES (1, 3, 1, SYSDATE);  -- ROLE_MANAGE
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id, granted_date) VALUES (1, 4, 1, SYSDATE);  -- LIBRARY_VIEW_ALL
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id, granted_date) VALUES (1, 5, 1, SYSDATE);  -- BRANCH_VIEW_ALL
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id, granted_date) VALUES (1, 6, 1, SYSDATE);  -- STAFF_VIEW_ALL
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id, granted_date) VALUES (1, 7, 1, SYSDATE);  -- CATALOG_MANAGE
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id, granted_date) VALUES (1, 12, 1, SYSDATE); -- CIRCULATION_MANAGE
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id, granted_date) VALUES (1, 17, 1, SYSDATE); -- RESERVATION_MANAGE
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id, granted_date) VALUES (1, 20, 1, SYSDATE); -- FINE_MANAGE
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id, granted_date) VALUES (1, 24, 1, SYSDATE); -- REPORTS_VIEW
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id, granted_date) VALUES (1, 25, 1, SYSDATE); -- REPORTS_GENERATE
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id, granted_date) VALUES (1, 26, 1, SYSDATE); -- SYSTEM_MAINTENANCE
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id, granted_date) VALUES (1, 27, 1, SYSDATE); -- BATCH_PROCESS
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id, granted_date) VALUES (1, 28, 1, SYSDATE); -- AUTH_MANAGE
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id, granted_date) VALUES (1, 29, 1, SYSDATE); -- SESSION_MANAGE

-- ROLE_DIRECTOR - Strategic oversight and reporting
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id, granted_date) VALUES (2, 4, 1, SYSDATE);  -- LIBRARY_VIEW_ALL
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id, granted_date) VALUES (2, 5, 1, SYSDATE);  -- BRANCH_VIEW_ALL
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id, granted_date) VALUES (2, 6, 1, SYSDATE);  -- STAFF_VIEW_ALL
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id, granted_date) VALUES (2, 24, 1, SYSDATE); -- REPORTS_VIEW
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id, granted_date) VALUES (2, 25, 1, SYSDATE); -- REPORTS_GENERATE
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id, granted_date) VALUES (2, 28, 1, SYSDATE); -- AUTH_MANAGE (for session management)
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id, granted_date) VALUES (2, 29, 1, SYSDATE); -- SESSION_MANAGE

-- ROLE_CATALOGER - Catalog management specialist
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id, granted_date) VALUES (3, 7, 1, SYSDATE);  -- CATALOG_MANAGE
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id, granted_date) VALUES (3, 8, 1, SYSDATE);  -- MATERIAL_ADD
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id, granted_date) VALUES (3, 9, 1, SYSDATE);  -- MATERIAL_EDIT
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id, granted_date) VALUES (3, 10, 1, SYSDATE); -- MATERIAL_DELETE
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id, granted_date) VALUES (3, 11, 1, SYSDATE); -- COPY_MANAGE
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id, granted_date) VALUES (3, 28, 1, SYSDATE); -- AUTH_MANAGE (basic authentication)

-- ROLE_CIRCULATION_CLERK - Day-to-day circulation operations
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id, granted_date) VALUES (4, 12, 1, SYSDATE); -- CIRCULATION_MANAGE
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id, granted_date) VALUES (4, 13, 1, SYSDATE); -- CHECKOUT_PROCESS
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id, granted_date) VALUES (4, 14, 1, SYSDATE); -- CHECKIN_PROCESS
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id, granted_date) VALUES (4, 15, 1, SYSDATE); -- RENEW_PROCESS
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id, granted_date) VALUES (4, 16, 1, SYSDATE); -- PATRON_MANAGE
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id, granted_date) VALUES (4, 17, 1, SYSDATE); -- RESERVATION_MANAGE
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id, granted_date) VALUES (4, 18, 1, SYSDATE); -- RESERVATION_CREATE
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id, granted_date) VALUES (4, 19, 1, SYSDATE); -- RESERVATION_CANCEL
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id, granted_date) VALUES (4, 20, 1, SYSDATE); -- FINE_MANAGE
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id, granted_date) VALUES (4, 21, 1, SYSDATE); -- FINE_ASSESS
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id, granted_date) VALUES (4, 22, 1, SYSDATE); -- FINE_WAIVE
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id, granted_date) VALUES (4, 23, 1, SYSDATE); -- PAYMENT_PROCESS
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id, granted_date) VALUES (4, 28, 1, SYSDATE); -- AUTH_MANAGE
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id, granted_date) VALUES (4, 29, 1, SYSDATE); -- SESSION_MANAGE

-- ROLE_IT_SUPPORT - Technical system support
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id, granted_date) VALUES (5, 4, 1, SYSDATE);  -- LIBRARY_VIEW_ALL
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id, granted_date) VALUES (5, 5, 1, SYSDATE);  -- BRANCH_VIEW_ALL
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id, granted_date) VALUES (5, 26, 1, SYSDATE); -- SYSTEM_MAINTENANCE
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id, granted_date) VALUES (5, 27, 1, SYSDATE); -- BATCH_PROCESS
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id, granted_date) VALUES (5, 28, 1, SYSDATE); -- AUTH_MANAGE
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id, granted_date) VALUES (5, 29, 1, SYSDATE); -- SESSION_MANAGE

COMMIT;

-- ============================================================================
-- 4. VERIFICATION QUERIES
-- ============================================================================

-- Verify roles were inserted
SELECT 'ROLES' as table_name, COUNT(*) as row_count FROM ROLES
UNION ALL SELECT 'PERMISSIONS', COUNT(*) FROM PERMISSIONS
UNION ALL SELECT 'ROLE_PERMISSIONS', COUNT(*) FROM ROLE_PERMISSIONS;

-- Show all roles with their permissions
SELECT 
    r.role_code,
    r.role_name,
    p.permission_code,
    p.permission_name,
    p.permission_category,
    p.permission_resource,
    p.action
FROM ROLES r
JOIN ROLE_PERMISSIONS rp ON r.role_id = rp.role_id
JOIN PERMISSIONS p ON rp.permission_id = p.permission_id
ORDER BY r.role_code, p.permission_category, p.permission_code;

-- Count permissions per role
SELECT 
    r.role_code,
    r.role_name,
    COUNT(rp.permission_id) as permission_count
FROM ROLES r
LEFT JOIN ROLE_PERMISSIONS rp ON r.role_id = rp.role_id
GROUP BY r.role_code, r.role_name
ORDER BY r.role_code;

DBMS_OUTPUT.PUT_LINE('RBAC roles and permissions inserted successfully!');
DBMS_OUTPUT.PUT_LINE('✓ 5 roles created');
DBMS_OUTPUT.PUT_LINE('✓ 29 permissions defined');
DBMS_OUTPUT.PUT_LINE('✓ Role-permission assignments completed');