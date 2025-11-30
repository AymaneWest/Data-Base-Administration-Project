-- ============================================================================
-- LIBRARY MANAGEMENT SYSTEM - SAMPLE DATA INSERTION
-- Inserting 20 rows into each table with proper Oracle syntax
-- ============================================================================
SET DEFINE OFF;

-- ============================================================================
-- 1. LIBRARIES TABLE
-- ============================================================================
INSERT INTO LIBRARIES (library_id, library_name, established_year, headquarters_address, phone, email, website, library_description) VALUES (1, 'City Central Library System', 1950, '123 Knowledge Avenue, Metropolis', '555-1001', 'info@citylibrary.org', 'www.citylibrary.org', 'Main public library serving the metropolitan area');
INSERT INTO LIBRARIES (library_id, library_name, established_year, headquarters_address, phone, email, website, library_description) VALUES (2, 'County Public Libraries', 1972, '456 County Road, Suburbia', '555-1002', 'admin@countylib.gov', 'www.countylibrary.gov', 'County-wide library network');
INSERT INTO LIBRARIES (library_id, library_name, established_year, headquarters_address, phone, email, website, library_description) VALUES (3, 'University Research Library', 1920, '789 Campus Drive, University Town', '555-1003', 'research@unilib.edu', 'www.uni-library.edu', 'Academic research library');
INSERT INTO LIBRARIES (library_id, library_name, established_year, headquarters_address, phone, email, website, library_description) VALUES (4, 'Community Learning Centers', 1985, '321 Learning Lane, Community Ville', '555-1004', 'contact@communitylearn.org', 'www.communitylearn.org', 'Community-focused learning centers');
INSERT INTO LIBRARIES (library_id, library_name, established_year, headquarters_address, phone, email, website, library_description) VALUES (5, 'Digital Knowledge Hub', 2010, '654 Tech Park, Innovation City', '555-1005', 'digital@knowledgehub.org', 'www.knowledgehub.org', 'Modern digital-focused library system');
INSERT INTO LIBRARIES (library_id, library_name, established_year, headquarters_address, phone, email, website, library_description) VALUES (6, 'Heritage Library Network', 1935, '987 History Street, Old Town', '555-1006', 'heritage@historiclib.org', 'www.heritagelib.org', 'Preserving historical documents and texts');
INSERT INTO LIBRARIES (library_id, library_name, established_year, headquarters_address, phone, email, website, library_description) VALUES (7, 'Children Wonder Library', 1990, '147 Imagination Road, Kids Ville', '555-1007', 'kids@wonderlibrary.org', 'www.wonderlibrary.org', 'Specialized in children education and entertainment');
INSERT INTO LIBRARIES (library_id, library_name, established_year, headquarters_address, phone, email, website, library_description) VALUES (8, 'Business Reference Center', 2005, '258 Commerce Ave, Business District', '555-1008', 'business@reflib.org', 'www.businessreflib.org', 'Business and professional reference materials');
INSERT INTO LIBRARIES (library_id, library_name, established_year, headquarters_address, phone, email, website, library_description) VALUES (9, 'Multicultural Library', 1988, '369 Diversity Street, Cultural Center', '555-1009', 'multicultural@worldlib.org', 'www.worldlibrary.org', 'Multilingual and multicultural collections');
INSERT INTO LIBRARIES (library_id, library_name, established_year, headquarters_address, phone, email, website, library_description) VALUES (10, 'Science & Technology Library', 1978, '741 Innovation Drive, Tech City', '555-1010', 'scitech@scilib.org', 'www.scitechlib.org', 'Science, technology and engineering focus');
INSERT INTO LIBRARIES (library_id, library_name, established_year, headquarters_address, phone, email, website, library_description) VALUES (11, 'Art & Design Library', 1965, '852 Creative Lane, Arts District', '555-1011', 'art@artlibrary.org', 'www.artlibrary.org', 'Visual arts and design collections');
INSERT INTO LIBRARIES (library_id, library_name, established_year, headquarters_address, phone, email, website, library_description) VALUES (12, 'Music & Performance Library', 1975, '963 Harmony Road, Music Ville', '555-1012', 'music@musiclib.org', 'www.musiclibrary.org', 'Music scores and performance materials');
INSERT INTO LIBRARIES (library_id, library_name, established_year, headquarters_address, phone, email, website, library_description) VALUES (13, 'Law & Legislation Library', 1945, '159 Justice Avenue, Legal District', '555-1013', 'law@lawlibrary.org', 'www.lawlibrary.org', 'Legal references and legislative documents');
INSERT INTO LIBRARIES (library_id, library_name, established_year, headquarters_address, phone, email, website, library_description) VALUES (14, 'Medical Research Library', 1960, '357 Health Street, Medical Center', '555-1014', 'medical@medlib.org', 'www.medlibrary.org', 'Medical and healthcare research materials');
INSERT INTO LIBRARIES (library_id, library_name, established_year, headquarters_address, phone, email, website, library_description) VALUES (15, 'Environmental Studies Library', 1995, '486 Nature Way, Green City', '555-1015', 'environment@greenlib.org', 'www.greenlibrary.org', 'Environmental science and ecology focus');
INSERT INTO LIBRARIES (library_id, library_name, established_year, headquarters_address, phone, email, website, library_description) VALUES (16, 'Travel & Geography Library', 1982, '579 Explorer Road, Adventure City', '555-1016', 'travel@worldlib.org', 'www.travellibrary.org', 'Travel guides and geographical materials');
INSERT INTO LIBRARIES (library_id, library_name, established_year, headquarters_address, phone, email, website, library_description) VALUES (17, 'Cooking & Nutrition Library', 1998, '684 Culinary Street, Foodie Town', '555-1017', 'cooking@foodlib.org', 'www.foodlibrary.org', 'Cookbooks and nutritional information');
INSERT INTO LIBRARIES (library_id, library_name, established_year, headquarters_address, phone, email, website, library_description) VALUES (18, 'Sports & Recreation Library', 1970, '795 Fitness Avenue, Sports City', '555-1018', 'sports@sportslib.org', 'www.sportslibrary.org', 'Sports history and recreation materials');
INSERT INTO LIBRARIES (library_id, library_name, established_year, headquarters_address, phone, email, website, library_description) VALUES (19, 'Philosophy & Religion Library', 1955, '816 Wisdom Road, Thought Ville', '555-1019', 'philosophy@thinklib.org', 'www.thinklibrary.org', 'Philosophical and religious texts');
INSERT INTO LIBRARIES (library_id, library_name, established_year, headquarters_address, phone, email, website, library_description) VALUES (20, 'Fiction & Literature Library', 1968, '927 Story Lane, Literary Town', '555-1020', 'fiction@storylib.org', 'www.storylibrary.org', 'Fiction and literary works collection');
SET DEFINE OFF;
-- ============================================================================
-- 2. BRANCHES TABLE
-- ============================================================================
INSERT INTO BRANCHES (branch_id, library_id, branch_name, address, phone, email, opening_hours, branch_capacity) VALUES (1, 1, 'Downtown Main Library', '123 Central Plaza, Downtown', '555-2001', 'downtown@citylibrary.org', 'Mon-Fri: 9AM-9PM, Sat-Sun: 10AM-6PM', 300);
INSERT INTO BRANCHES (branch_id, library_id, branch_name, address, phone, email, opening_hours, branch_capacity) VALUES (2, 1, 'Northside Branch', '456 North Avenue, Northside', '555-2002', 'north@citylibrary.org', 'Mon-Fri: 10AM-8PM, Sat: 10AM-5PM', 150);
INSERT INTO BRANCHES (branch_id, library_id, branch_name, address, phone, email, opening_hours, branch_capacity) VALUES (3, 1, 'Southside Community Library', '789 South Street, Southside', '555-2003', 'south@citylibrary.org', 'Mon-Fri: 9AM-7PM, Sat: 9AM-4PM', 120);
INSERT INTO BRANCHES (branch_id, library_id, branch_name, address, phone, email, opening_hours, branch_capacity) VALUES (4, 1, 'East End Branch', '321 East Boulevard, East End', '555-2004', 'east@citylibrary.org', 'Mon-Fri: 10AM-6PM, Sat: 10AM-4PM', 100);
INSERT INTO BRANCHES (branch_id, library_id, branch_name, address, phone, email, opening_hours, branch_capacity) VALUES (5, 1, 'Westwood Library', '654 West Road, Westwood', '555-2005', 'west@citylibrary.org', 'Mon-Fri: 9AM-8PM, Sat-Sun: 10AM-5PM', 180);
INSERT INTO BRANCHES (branch_id, library_id, branch_name, address, phone, email, opening_hours, branch_capacity) VALUES (6, 2, 'County Central Library', '147 County Center, County Seat', '555-2006', 'central@countylib.gov', 'Mon-Fri: 8AM-8PM, Sat: 9AM-5PM', 250);
INSERT INTO BRANCHES (branch_id, library_id, branch_name, address, phone, email, opening_hours, branch_capacity) VALUES (7, 2, 'Riverside Branch', '258 River Road, Riverside', '555-2007', 'riverside@countylib.gov', 'Mon-Fri: 10AM-6PM, Sat: 10AM-4PM', 90);
INSERT INTO BRANCHES (branch_id, library_id, branch_name, address, phone, email, opening_hours, branch_capacity) VALUES (8, 2, 'Hillside Library', '369 Hill Street, Hillside', '555-2008', 'hillside@countylib.gov', 'Mon-Fri: 9AM-7PM, Sat: 9AM-3PM', 80);
INSERT INTO BRANCHES (branch_id, library_id, branch_name, address, phone, email, opening_hours, branch_capacity) VALUES (9, 3, 'University Main Library', '741 Campus Center, University', '555-2009', 'mainlib@unilib.edu', '24/7 during semesters', 500);
INSERT INTO BRANCHES (branch_id, library_id, branch_name, address, phone, email, opening_hours, branch_capacity) VALUES (10, 3, 'Science Library', '852 Science Building, University', '555-2010', 'sciencelib@unilib.edu', 'Mon-Fri: 8AM-10PM, Sat-Sun: 10AM-8PM', 200);
INSERT INTO BRANCHES (branch_id, library_id, branch_name, address, phone, email, opening_hours, branch_capacity) VALUES (11, 4, 'Community Learning Center', '963 Community Plaza, Center City', '555-2011', 'clc@communitylearn.org', 'Mon-Sat: 8AM-9PM', 180);
INSERT INTO BRANCHES (branch_id, library_id, branch_name, address, phone, email, opening_hours, branch_capacity) VALUES (12, 4, 'Youth Learning Hub', '159 Youth Street, Kids Town', '555-2012', 'youth@communitylearn.org', 'Mon-Fri: 9AM-6PM, Sat: 10AM-4PM', 100);
INSERT INTO BRANCHES (branch_id, library_id, branch_name, address, phone, email, opening_hours, branch_capacity) VALUES (13, 5, 'Digital Innovation Center', '357 Digital Drive, Tech Park', '555-2013', 'digital@knowledgehub.org', 'Mon-Fri: 10AM-8PM, Sat-Sun: 12PM-6PM', 120);
INSERT INTO BRANCHES (branch_id, library_id, branch_name, address, phone, email, opening_hours, branch_capacity) VALUES (14, 6, 'Historical Archives', '486 History Lane, Old District', '555-2014', 'archives@historiclib.org', 'Mon-Fri: 9AM-5PM', 60);
INSERT INTO BRANCHES (branch_id, library_id, branch_name, address, phone, email, opening_hours, branch_capacity) VALUES (15, 7, 'Children Discovery Library', '579 Discovery Road, Family Ville', '555-2015', 'discovery@wonderlibrary.org', 'Mon-Sat: 9AM-6PM, Sun: 12PM-5PM', 150);
INSERT INTO BRANCHES (branch_id, library_id, branch_name, address, phone, email, opening_hours, branch_capacity) VALUES (16, 8, 'Business Reference Library', '684 Business Center, Downtown', '555-2016', 'business@reflib.org', 'Mon-Fri: 8AM-6PM', 110);
INSERT INTO BRANCHES (branch_id, library_id, branch_name, address, phone, email, opening_hours, branch_capacity) VALUES (17, 9, 'International Library', '795 World Avenue, Cultural District', '555-2017', 'international@worldlib.org', 'Mon-Sat: 9AM-7PM', 130);
INSERT INTO BRANCHES (branch_id, library_id, branch_name, address, phone, email, opening_hours, branch_capacity) VALUES (18, 10, 'Technology Library', '816 Tech Street, Innovation Zone', '555-2018', 'tech@scilib.org', 'Mon-Fri: 9AM-8PM, Sat: 10AM-5PM', 140);
INSERT INTO BRANCHES (branch_id, library_id, branch_name, address, phone, email, opening_hours, branch_capacity) VALUES (19, 11, 'Art Reference Library', '927 Art District, Creative Center', '555-2019', 'artref@artlibrary.org', 'Tue-Sat: 10AM-6PM', 70);
INSERT INTO BRANCHES (branch_id, library_id, branch_name, address, phone, email, opening_hours, branch_capacity) VALUES (20, 12, 'Music Library', '138 Music Hall, Performance Center', '555-2020', 'music@musiclib.org', 'Mon-Fri: 10AM-7PM, Sat: 10AM-4PM', 85);

-- ============================================================================
-- 3. USERS TABLE
-- ============================================================================
INSERT INTO USERS (user_id, username, email, password_hash, first_name, last_name, is_active, account_locked, last_login) VALUES (1, 'admin.johnson', 'admin.johnson@citylibrary.org', fn_hash_password('hashed_password_1'), 'John', 'Johnson', 'Y', 'N', SYSDATE-1);
INSERT INTO USERS (user_id, username, email, password_hash, first_name, last_name, is_active, account_locked, last_login) VALUES (2, 'librarian.smith', 'librarian.smith@citylibrary.org', fn_hash_password('hashed_password_2'), 'Sarah', 'Smith', 'Y', 'N', SYSDATE-2);
INSERT INTO USERS (user_id, username, email, password_hash, first_name, last_name, is_active, account_locked, last_login) VALUES (3, 'staff.davis', 'staff.davis@citylibrary.org', fn_hash_password('hashed_password_3'), 'Michael', 'Davis', 'Y', 'N', SYSDATE-3);
INSERT INTO USERS (user_id, username, email, password_hash, first_name, last_name, is_active, account_locked, last_login) VALUES (4, 'manager.wilson', 'manager.wilson@citylibrary.org',fn_hash_password('hashed_password_4'), 'Robert', 'Wilson', 'Y', 'N', SYSDATE-1);
INSERT INTO USERS (user_id, username, email, password_hash, first_name, last_name, is_active, account_locked, last_login) VALUES (5, 'catalog.brown', 'catalog.brown@citylibrary.org', fn_hash_password('hashed_password_5'), 'Jennifer', 'Brown', 'Y', 'N', SYSDATE-4);
INSERT INTO USERS (user_id, username, email, password_hash, first_name, last_name, is_active, account_locked, last_login) VALUES (6, 'patron.miller', 'patron.miller@email.com', fn_hash_password('hashed_password_6'), 'David', 'Miller', 'Y', 'N', SYSDATE-5);
INSERT INTO USERS (user_id, username, email, password_hash, first_name, last_name, is_active, account_locked, last_login) VALUES (7, 'reader.jones', 'reader.jones@email.com', fn_hash_password('hashed_password_7'), 'Emily', 'Jones', 'Y', 'N', SYSDATE-6);
INSERT INTO USERS (user_id, username, email, password_hash, first_name, last_name, is_active, account_locked, last_login) VALUES (8, 'student.garcia', 'student.garcia@email.com', fn_hash_password('hashed_password_8'), 'Carlos', 'Garcia', 'Y', 'N', SYSDATE-2);
INSERT INTO USERS (user_id, username, email, password_hash, first_name, last_name, is_active, account_locked, last_login) VALUES (9, 'researcher.martin', 'researcher.martin@email.com', fn_hash_password('hashed_password_9'), 'Lisa', 'Martin', 'Y', 'N', SYSDATE-3);
INSERT INTO USERS (user_id, username, email, password_hash, first_name, last_name, is_active, account_locked, last_login) VALUES (10, 'booklover.lee', 'booklover.lee@email.com', fn_hash_password('hashed_password_10'), 'Kevin', 'Lee', 'Y', 'N', SYSDATE-1);
INSERT INTO USERS (user_id, username, email, password_hash, first_name, last_name, is_active, account_locked, last_login) VALUES (11, 'academic.white', 'academic.white@email.com', fn_hash_password('hashed_password_11'), 'Amanda', 'White', 'Y', 'N', SYSDATE-4);
INSERT INTO USERS (user_id, username, email, password_hash, first_name, last_name, is_active, account_locked, last_login) VALUES (12, 'novel.clark', 'novel.clark@email.com', fn_hash_password('hashed_password_12'), 'Brian', 'Clark', 'Y', 'N', SYSDATE-5);
INSERT INTO USERS (user_id, username, email, password_hash, first_name, last_name, is_active, account_locked, last_login) VALUES (13, 'history.lopez', 'history.lopez@email.com', fn_hash_password('hashed_password_13'), 'Maria', 'Lopez', 'Y', 'N', SYSDATE-6);
INSERT INTO USERS (user_id, username, email, password_hash, first_name, last_name, is_active, account_locked, last_login) VALUES (14, 'science.hall', 'science.hall@email.com', fn_hash_password('hashed_password_14'), 'James', 'Hall', 'Y', 'N', SYSDATE-2);
INSERT INTO USERS (user_id, username, email, password_hash, first_name, last_name, is_active, account_locked, last_login) VALUES (15, 'art.young', 'art.young@email.com', fn_hash_password('hashed_password_15'), 'Sophia', 'Young', 'Y', 'N', SYSDATE-3);
INSERT INTO USERS (user_id, username, email, password_hash, first_name, last_name, is_active, account_locked, last_login) VALUES (16, 'music.king', 'music.king@email.com', fn_hash_password('hashed_password_16'), 'Daniel', 'King', 'Y', 'N', SYSDATE-1);
INSERT INTO USERS (user_id, username, email, password_hash, first_name, last_name, is_active, account_locked, last_login) VALUES (17, 'tech.scott', 'tech.scott@email.com', fn_hash_password('hashed_password_17'), 'Michelle', 'Scott', 'Y', 'N', SYSDATE-4);
INSERT INTO USERS (user_id, username, email, password_hash, first_name, last_name, is_active, account_locked, last_login) VALUES (18, 'business.green', 'business.green@email.com', fn_hash_password('hashed_password_18'), 'Richard', 'Green', 'Y', 'N', SYSDATE-5);
INSERT INTO USERS (user_id, username, email, password_hash, first_name, last_name, is_active, account_locked, last_login) VALUES (19, 'travel.adams', 'travel.adams@email.com', fn_hash_password('hashed_password_19'), 'Nancy', 'Adams', 'Y', 'N', SYSDATE-6);
INSERT INTO USERS (user_id, username, email, password_hash, first_name, last_name, is_active, account_locked, last_login) VALUES (20, 'child.parker', 'child.parker@email.com', fn_hash_password('hashed_password_20'), 'Thomas', 'Parker', 'Y', 'N', SYSDATE-2);
commit;
-- ============================================================================
-- 5. USER_ROLES TABLE
-- ============================================================================
INSERT INTO USER_ROLES (user_id, role_id, assigned_by_user_id) VALUES (1, 1, 1);
INSERT INTO USER_ROLES (user_id, role_id, assigned_by_user_id) VALUES (2, 2, 1);
INSERT INTO USER_ROLES (user_id, role_id, assigned_by_user_id) VALUES (3, 2, 2);
INSERT INTO USER_ROLES (user_id, role_id, assigned_by_user_id) VALUES (4, 2, 1);
INSERT INTO USER_ROLES (user_id, role_id, assigned_by_user_id) VALUES (5, 3, 1);
INSERT INTO USER_ROLES (user_id, role_id, assigned_by_user_id) VALUES (6, 3, 1);
INSERT INTO USER_ROLES (user_id, role_id, assigned_by_user_id) VALUES (7, 3, 1);
INSERT INTO USER_ROLES (user_id, role_id, assigned_by_user_id) VALUES (8, 4, 1);
INSERT INTO USER_ROLES (user_id, role_id, assigned_by_user_id) VALUES (9, 4, 1);
INSERT INTO USER_ROLES (user_id, role_id, assigned_by_user_id) VALUES (10, 4, 1);
INSERT INTO USER_ROLES (user_id, role_id, assigned_by_user_id) VALUES (11, 4, 1);
INSERT INTO USER_ROLES (user_id, role_id, assigned_by_user_id) VALUES (12, 4, 1);
INSERT INTO USER_ROLES (user_id, role_id, assigned_by_user_id) VALUES (13, 4, 1);
INSERT INTO USER_ROLES (user_id, role_id, assigned_by_user_id) VALUES (14, 3, 1);
INSERT INTO USER_ROLES (user_id, role_id, assigned_by_user_id) VALUES (15, 3, 2);
INSERT INTO USER_ROLES (user_id, role_id, assigned_by_user_id) VALUES (16, 3, 2);
INSERT INTO USER_ROLES (user_id, role_id, assigned_by_user_id) VALUES (17, 5, 2);
INSERT INTO USER_ROLES (user_id, role_id, assigned_by_user_id) VALUES (18, 5, 2);
INSERT INTO USER_ROLES (user_id, role_id, assigned_by_user_id) VALUES (19, 5, 2);
INSERT INTO USER_ROLES (user_id, role_id, assigned_by_user_id) VALUES (20, 5, 2);

-- ============================================================================
-- 6. PERMISSIONS TABLE
-- ============================================================================
INSERT INTO PERMISSIONS (permission_id, permission_code, permission_name, permission_description, permission_category, permission_resource, action) VALUES (1, 'USER_MANAGE', 'Manage Users', 'Create, edit and delete user accounts', 'Administration', 'User', 'All');
INSERT INTO PERMISSIONS (permission_id, permission_code, permission_name, permission_description, permission_category, permission_resource, action) VALUES (2, 'ROLE_MANAGE', 'Manage Roles', 'Create and modify role definitions', 'Administration', 'Role', 'All');
INSERT INTO PERMISSIONS (permission_id, permission_code, permission_name, permission_description, permission_category, permission_resource, action) VALUES (3, 'PERMISSION_MANAGE', 'Manage Permissions', 'Define system permissions', 'Administration', 'Permission', 'All');
INSERT INTO PERMISSIONS (permission_id, permission_code, permission_name, permission_description, permission_category, permission_resource, action) VALUES (4, 'BRANCH_MANAGE', 'Manage Branches', 'Add and modify library branches', 'Administration', 'Branch', 'All');
INSERT INTO PERMISSIONS (permission_id, permission_code, permission_name, permission_description, permission_category, permission_resource, action) VALUES (5, 'SYSTEM_CONFIG', 'System Configuration', 'Configure system settings', 'System', 'System', 'Update');
INSERT INTO PERMISSIONS (permission_id, permission_code, permission_name, permission_description, permission_category, permission_resource, action) VALUES (6, 'CATALOG_ADD', 'Add Catalog Items', 'Add new materials to catalog', 'Catalog', 'Material', 'Create');
INSERT INTO PERMISSIONS (permission_id, permission_code, permission_name, permission_description, permission_category, permission_resource, action) VALUES (7, 'CATALOG_EDIT', 'Edit Catalog Items', 'Modify existing catalog records', 'Catalog', 'Material', 'Update');
INSERT INTO PERMISSIONS (permission_id, permission_code, permission_name, permission_description, permission_category, permission_resource, action) VALUES (8, 'CATALOG_DELETE', 'Delete Catalog Items', 'Remove materials from catalog', 'Catalog', 'Material', 'Delete');
INSERT INTO PERMISSIONS (permission_id, permission_code, permission_name, permission_description, permission_category, permission_resource, action) VALUES (9, 'INVENTORY_MANAGE', 'Manage Inventory', 'Track and manage physical copies', 'Catalog', 'Copy', 'All');
INSERT INTO PERMISSIONS (permission_id, permission_code, permission_name, permission_description, permission_category, permission_resource, action) VALUES (10, 'CHECKOUT_PROCESS', 'Process Checkouts', 'Check out materials to patrons', 'Circulation', 'Loan', 'Create');
INSERT INTO PERMISSIONS (permission_id, permission_code, permission_name, permission_description, permission_category, permission_resource, action) VALUES (11, 'CHECKIN_PROCESS', 'Process Check-ins', 'Check in returned materials', 'Circulation', 'Loan', 'Update');
INSERT INTO PERMISSIONS (permission_id, permission_code, permission_name, permission_description, permission_category, permission_resource, action) VALUES (12, 'RENEW_PROCESS', 'Process Renewals', 'Renew patron loans', 'Circulation', 'Loan', 'Update');
INSERT INTO PERMISSIONS (permission_id, permission_code, permission_name, permission_description, permission_category, permission_resource, action) VALUES (13, 'RESERVE_MANAGE', 'Manage Reservations', 'Handle hold requests', 'Circulation', 'Reservation', 'All');
INSERT INTO PERMISSIONS (permission_id, permission_code, permission_name, permission_description, permission_category, permission_resource, action) VALUES (14, 'PATRON_ADD', 'Add Patrons', 'Register new library patrons', 'Patrons', 'Patron', 'Create');
INSERT INTO PERMISSIONS (permission_id, permission_code, permission_name, permission_description, permission_category, permission_resource, action) VALUES (15, 'PATRON_EDIT', 'Edit Patrons', 'Modify patron records', 'Patrons', 'Patron', 'Update');
INSERT INTO PERMISSIONS (permission_id, permission_code, permission_name, permission_description, permission_category, permission_resource, action) VALUES (16, 'PATRON_VIEW', 'View Patrons', 'Access patron information', 'Patrons', 'Patron', 'Read');
INSERT INTO PERMISSIONS (permission_id, permission_code, permission_name, permission_description, permission_category, permission_resource, action) VALUES (17, 'FINE_ASSESS', 'Assess Fines', 'Create fines for violations', 'Fines', 'Fine', 'Create');
INSERT INTO PERMISSIONS (permission_id, permission_code, permission_name, permission_description, permission_category, permission_resource, action) VALUES (18, 'FINE_WAIVE', 'Waive Fines', 'Waive or reduce fines', 'Fines', 'Fine', 'Update');
INSERT INTO PERMISSIONS (permission_id, permission_code, permission_name, permission_description, permission_category, permission_resource, action) VALUES (19, 'PAYMENT_PROCESS', 'Process Payments', 'Accept fine payments', 'Fines', 'Fine', 'Update');
INSERT INTO PERMISSIONS (permission_id, permission_code, permission_name, permission_description, permission_category, permission_resource, action) VALUES (20, 'REPORTS_VIEW', 'View Reports', 'Access system reports', 'Reports', 'Report', 'Read');

-- ============================================================================
-- 7. ROLE_PERMISSIONS TABLE
-- ============================================================================
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id) VALUES (1, 1, 1);
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id) VALUES (1, 2, 1);
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id) VALUES (1, 3, 1);
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id) VALUES (1, 4, 1);
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id) VALUES (1, 5, 1);
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id) VALUES (2, 4, 1);
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id) VALUES (2, 6, 1);
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id) VALUES (2, 7, 1);
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id) VALUES (2, 9, 1);
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id) VALUES (2, 14, 1);
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id) VALUES (3, 6, 1);
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id) VALUES (3, 7, 1);
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id) VALUES (3, 9, 1);
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id) VALUES (3, 13, 1);
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id) VALUES (3, 16, 1);
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id) VALUES (4, 6, 1);
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id) VALUES (4, 7, 1);
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id) VALUES (4, 10, 1);
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id) VALUES (4, 11, 1);
INSERT INTO ROLE_PERMISSIONS (role_id, permission_id, granted_by_user_id) VALUES (4, 12, 1);

-- ============================================================================
-- 8. PATRONS TABLE
-- ============================================================================
INSERT INTO PATRONS (patron_id, card_number, first_name, last_name, email, phone, address, date_of_birth, membership_type, registration_date, membership_expiry, registered_branch_id, account_status, total_fines_owed, max_borrow_limit) VALUES (1, 'LIB000001', 'Alice', 'Johnson', 'alice.johnson@email.com', '555-3001', '123 Maple Street, City', TO_DATE('1985-03-15', 'YYYY-MM-DD'), 'Standard', SYSDATE-100, SYSDATE+265, 1, 'Active', 0.00, 10);
INSERT INTO PATRONS (patron_id, card_number, first_name, last_name, email, phone, address, date_of_birth, membership_type, registration_date, membership_expiry, registered_branch_id, account_status, total_fines_owed, max_borrow_limit) VALUES (2, 'LIB000002', 'Bob', 'Williams', 'bob.williams@email.com', '555-3002', '456 Oak Avenue, City', TO_DATE('1990-07-22', 'YYYY-MM-DD'), 'Standard', SYSDATE-95, SYSDATE+270, 1, 'Active', 5.50, 10);
INSERT INTO PATRONS (patron_id, card_number, first_name, last_name, email, phone, address, date_of_birth, membership_type, registration_date, membership_expiry, registered_branch_id, account_status, total_fines_owed, max_borrow_limit) VALUES (3, 'LIB000003', 'Carol', 'Brown', 'carol.brown@email.com', '555-3003', '789 Pine Road, City', TO_DATE('1982-11-30', 'YYYY-MM-DD'), 'Premium', SYSDATE-90, SYSDATE+275, 2, 'Active', 0.00, 20);
INSERT INTO PATRONS (patron_id, card_number, first_name, last_name, email, phone, address, date_of_birth, membership_type, registration_date, membership_expiry, registered_branch_id, account_status, total_fines_owed, max_borrow_limit) VALUES (4, 'LIB000004', 'David', 'Miller', 'david.miller@email.com', '555-3004', '321 Elm Street, City', TO_DATE('1978-05-14', 'YYYY-MM-DD'), 'Standard', SYSDATE-85, SYSDATE+280, 2, 'Active', 12.25, 10);
INSERT INTO PATRONS (patron_id, card_number, first_name, last_name, email, phone, address, date_of_birth, membership_type, registration_date, membership_expiry, registered_branch_id, account_status, total_fines_owed, max_borrow_limit) VALUES (5, 'LIB000005', 'Eva', 'Davis', 'eva.davis@email.com', '555-3005', '654 Birch Lane, City', TO_DATE('1995-09-08', 'YYYY-MM-DD'), 'Student', SYSDATE-80, SYSDATE+285, 3, 'Active', 0.00, 15);
INSERT INTO PATRONS (patron_id, card_number, first_name, last_name, email, phone, address, date_of_birth, membership_type, registration_date, membership_expiry, registered_branch_id, account_status, total_fines_owed, max_borrow_limit) VALUES (6, 'LIB000006', 'Frank', 'Garcia', 'frank.garcia@email.com', '555-3006', '987 Cedar Drive, City', TO_DATE('1988-12-25', 'YYYY-MM-DD'), 'Standard', SYSDATE-75, SYSDATE+290, 3, 'Active', 0.00, 10);
INSERT INTO PATRONS (patron_id, card_number, first_name, last_name, email, phone, address, date_of_birth, membership_type, registration_date, membership_expiry, registered_branch_id, account_status, total_fines_owed, max_borrow_limit) VALUES (7, 'LIB000007', 'Grace', 'Rodriguez', 'grace.rodriguez@email.com', '555-3007', '147 Spruce Court, City', TO_DATE('1992-02-18', 'YYYY-MM-DD'), 'Premium', SYSDATE-70, SYSDATE+295, 4, 'Active', 0.00, 20);
INSERT INTO PATRONS (patron_id, card_number, first_name, last_name, email, phone, address, date_of_birth, membership_type, registration_date, membership_expiry, registered_branch_id, account_status, total_fines_owed, max_borrow_limit) VALUES (8, 'LIB000008', 'Henry', 'Martinez', 'henry.martinez@email.com', '555-3008', '258 Willow Way, City', TO_DATE('1975-08-11', 'YYYY-MM-DD'), 'Standard', SYSDATE-65, SYSDATE+300, 4, 'Active', 8.75, 10);
INSERT INTO PATRONS (patron_id, card_number, first_name, last_name, email, phone, address, date_of_birth, membership_type, registration_date, membership_expiry, registered_branch_id, account_status, total_fines_owed, max_borrow_limit) VALUES (9, 'LIB000009', 'Ivy', 'Hernandez', 'ivy.hernandez@email.com', '555-3009', '369 Aspen Circle, City', TO_DATE('1980-04-03', 'YYYY-MM-DD'), 'Student', SYSDATE-60, SYSDATE+305, 5, 'Active', 0.00, 15);
INSERT INTO PATRONS (patron_id, card_number, first_name, last_name, email, phone, address, date_of_birth, membership_type, registration_date, membership_expiry, registered_branch_id, account_status, total_fines_owed, max_borrow_limit) VALUES (10, 'LIB000010', 'Jack', 'Lopez', 'jack.lopez@email.com', '555-3010', '741 Magnolia Street, City', TO_DATE('1998-06-29', 'YYYY-MM-DD'), 'Child', SYSDATE-55, SYSDATE+310, 5, 'Active', 0.00, 5);
INSERT INTO PATRONS (patron_id, card_number, first_name, last_name, email, phone, address, date_of_birth, membership_type, registration_date, membership_expiry, registered_branch_id, account_status, total_fines_owed, max_borrow_limit) VALUES (11, 'LIB000011', 'Karen', 'Gonzalez', 'karen.gonzalez@email.com', '555-3011', '852 Redwood Avenue, City', TO_DATE('1987-01-12', 'YYYY-MM-DD'), 'Standard', SYSDATE-50, SYSDATE+315, 6, 'Active', 3.25, 10);
INSERT INTO PATRONS (patron_id, card_number, first_name, last_name, email, phone, address, date_of_birth, membership_type, registration_date, membership_expiry, registered_branch_id, account_status, total_fines_owed, max_borrow_limit) VALUES (12, 'LIB000012', 'Leo', 'Wilson', 'leo.wilson@email.com', '555-3012', '963 Sycamore Road, City', TO_DATE('1972-10-07', 'YYYY-MM-DD'), 'Senior', SYSDATE-45, SYSDATE+320, 6, 'Active', 0.00, 10);
INSERT INTO PATRONS (patron_id, card_number, first_name, last_name, email, phone, address, date_of_birth, membership_type, registration_date, membership_expiry, registered_branch_id, account_status, total_fines_owed, max_borrow_limit) VALUES (13, 'LIB000013', 'Mona', 'Anderson', 'mona.anderson@email.com', '555-3013', '159 Palm Lane, City', TO_DATE('1993-03-21', 'YYYY-MM-DD'), 'Premium', SYSDATE-40, SYSDATE+325, 7, 'Active', 0.00, 20);
INSERT INTO PATRONS (patron_id, card_number, first_name, last_name, email, phone, address, date_of_birth, membership_type, registration_date, membership_expiry, registered_branch_id, account_status, total_fines_owed, max_borrow_limit) VALUES (14, 'LIB000014', 'Nathan', 'Thomas', 'nathan.thomas@email.com', '555-3014', '357 Sequoia Drive, City', TO_DATE('1984-07-14', 'YYYY-MM-DD'), 'Standard', SYSDATE-35, SYSDATE+330, 7, 'Active', 15.00, 10);
INSERT INTO PATRONS (patron_id, card_number, first_name, last_name, email, phone, address, date_of_birth, membership_type, registration_date, membership_expiry, registered_branch_id, account_status, total_fines_owed, max_borrow_limit) VALUES (15, 'LIB000015', 'Olivia', 'Taylor', 'olivia.taylor@email.com', '555-3015', '486 Juniper Court, City', TO_DATE('1996-11-28', 'YYYY-MM-DD'), 'Student', SYSDATE-30, SYSDATE+335, 8, 'Active', 0.00, 15);
INSERT INTO PATRONS (patron_id, card_number, first_name, last_name, email, phone, address, date_of_birth, membership_type, registration_date, membership_expiry, registered_branch_id, account_status, total_fines_owed, max_borrow_limit) VALUES (16, 'LIB000016', 'Paul', 'Moore', 'paul.moore@email.com', '555-3016', '579 Hickory Way, City', TO_DATE('1979-05-09', 'YYYY-MM-DD'), 'Standard', SYSDATE-25, SYSDATE+340, 8, 'Active', 0.00, 10);
INSERT INTO PATRONS (patron_id, card_number, first_name, last_name, email, phone, address, date_of_birth, membership_type, registration_date, membership_expiry, registered_branch_id, account_status, total_fines_owed, max_borrow_limit) VALUES (17, 'LIB000017', 'Quinn', 'Jackson', 'quinn.jackson@email.com', '555-3017', '684 Poplar Street, City', TO_DATE('1986-09-02', 'YYYY-MM-DD'), 'VIP', SYSDATE-20, SYSDATE+345, 9, 'Active', 0.00, 50);
INSERT INTO PATRONS (patron_id, card_number, first_name, last_name, email, phone, address, date_of_birth, membership_type, registration_date, membership_expiry, registered_branch_id, account_status, total_fines_owed, max_borrow_limit) VALUES (18, 'LIB000018', 'Rachel', 'White', 'rachel.white@email.com', '555-3018', '795 Dogwood Avenue, City', TO_DATE('1991-12-15', 'YYYY-MM-DD'), 'Standard', SYSDATE-15, SYSDATE+350, 9, 'Active', 7.50, 10);
INSERT INTO PATRONS (patron_id, card_number, first_name, last_name, email, phone, address, date_of_birth, membership_type, registration_date, membership_expiry, registered_branch_id, account_status, total_fines_owed, max_borrow_limit) VALUES (19, 'LIB000019', 'Sam', 'Harris', 'sam.harris@email.com', '555-3019', '816 Chestnut Road, City', TO_DATE('1976-02-08', 'YYYY-MM-DD'), 'Premium', SYSDATE-10, SYSDATE+355, 10, 'Active', 0.00, 20);
INSERT INTO PATRONS (patron_id, card_number, first_name, last_name, email, phone, address, date_of_birth, membership_type, registration_date, membership_expiry, registered_branch_id, account_status, total_fines_owed, max_borrow_limit) VALUES (20, 'LIB000020', 'Tina', 'Clark', 'tina.clark@email.com', '555-3020', '927 Walnut Lane, City', TO_DATE('1989-08-23', 'YYYY-MM-DD'), 'Standard', SYSDATE-5, SYSDATE+360, 10, 'Active', 0.00, 10);

-- ============================================================================
-- 9. STAFF TABLE
-- ============================================================================
INSERT INTO STAFF (staff_id, employee_number, first_name, last_name, email, phone, staff_role, branch_id, hire_date, salary, is_active) VALUES (1, 'EMP001', 'John', 'Johnson', 'john.johnson@citylibrary.org', '555-4001', 'Manager', 1, TO_DATE('2015-03-15', 'YYYY-MM-DD'), 65000.00, 'Y');
INSERT INTO STAFF (staff_id, employee_number, first_name, last_name, email, phone, staff_role, branch_id, hire_date, salary, is_active) VALUES (2, 'EMP002', 'Sarah', 'Smith', 'sarah.smith@citylibrary.org', '555-4002', 'Librarian', 1, TO_DATE('2018-06-20', 'YYYY-MM-DD'), 52000.00, 'Y');
INSERT INTO STAFF (staff_id, employee_number, first_name, last_name, email, phone, staff_role, branch_id, hire_date, salary, is_active) VALUES (3, 'EMP003', 'Michael', 'Davis', 'michael.davis@citylibrary.org', '555-4003', 'Assistant', 1, TO_DATE('2020-01-10', 'YYYY-MM-DD'), 38000.00, 'Y');
INSERT INTO STAFF (staff_id, employee_number, first_name, last_name, email, phone, staff_role, branch_id, hire_date, salary, is_active) VALUES (4, 'EMP004', 'Robert', 'Wilson', 'robert.wilson@citylibrary.org', '555-4004', 'Manager', 2, TO_DATE('2016-08-12', 'YYYY-MM-DD'), 62000.00, 'Y');
INSERT INTO STAFF (staff_id, employee_number, first_name, last_name, email, phone, staff_role, branch_id, hire_date, salary, is_active) VALUES (5, 'EMP005', 'Jennifer', 'Brown', 'jennifer.brown@citylibrary.org', '555-4005', 'Cataloger', 2, TO_DATE('2019-04-05', 'YYYY-MM-DD'), 48000.00, 'Y');
INSERT INTO STAFF (staff_id, employee_number, first_name, last_name, email, phone, staff_role, branch_id, hire_date, salary, is_active) VALUES (6, 'EMP006', 'David', 'Miller', 'david.miller@citylibrary.org', '555-4006', 'Librarian', 2, TO_DATE('2017-11-30', 'YYYY-MM-DD'), 51000.00, 'Y');
INSERT INTO STAFF (staff_id, employee_number, first_name, last_name, email, phone, staff_role, branch_id, hire_date, salary, is_active) VALUES (7, 'EMP007', 'Emily', 'Jones', 'emily.jones@citylibrary.org', '555-4007', 'IT Admin', 3, TO_DATE('2018-09-15', 'YYYY-MM-DD'), 58000.00, 'Y');
INSERT INTO STAFF (staff_id, employee_number, first_name, last_name, email, phone, staff_role, branch_id, hire_date, salary, is_active) VALUES (8, 'EMP008', 'Carlos', 'Garcia', 'carlos.garcia@citylibrary.org', '555-4008', 'Manager', 3, TO_DATE('2014-12-01', 'YYYY-MM-DD'), 64000.00, 'Y');
INSERT INTO STAFF (staff_id, employee_number, first_name, last_name, email, phone, staff_role, branch_id, hire_date, salary, is_active) VALUES (9, 'EMP009', 'Lisa', 'Martin', 'lisa.martin@citylibrary.org', '555-4009', 'Reception', 3, TO_DATE('2021-02-28', 'YYYY-MM-DD'), 35000.00, 'Y');
INSERT INTO STAFF (staff_id, employee_number, first_name, last_name, email, phone, staff_role, branch_id, hire_date, salary, is_active) VALUES (10, 'EMP010', 'Kevin', 'Lee', 'kevin.lee@citylibrary.org', '555-4010', 'Librarian', 4, TO_DATE('2019-07-22', 'YYYY-MM-DD'), 50000.00, 'Y');
INSERT INTO STAFF (staff_id, employee_number, first_name, last_name, email, phone, staff_role, branch_id, hire_date, salary, is_active) VALUES (11, 'EMP011', 'Amanda', 'White', 'amanda.white@citylibrary.org', '555-4011', 'Cataloger', 4, TO_DATE('2018-03-18', 'YYYY-MM-DD'), 47000.00, 'Y');
INSERT INTO STAFF (staff_id, employee_number, first_name, last_name, email, phone, staff_role, branch_id, hire_date, salary, is_active) VALUES (12, 'EMP012', 'Brian', 'Clark', 'brian.clark@citylibrary.org', '555-4012', 'Assistant', 4, TO_DATE('2020-05-09', 'YYYY-MM-DD'), 37000.00, 'Y');
INSERT INTO STAFF (staff_id, employee_number, first_name, last_name, email, phone, staff_role, branch_id, hire_date, salary, is_active) VALUES (13, 'EMP013', 'Maria', 'Lopez', 'maria.lopez@citylibrary.org', '555-4013', 'Manager', 5, TO_DATE('2017-10-14', 'YYYY-MM-DD'), 63000.00, 'Y');
INSERT INTO STAFF (staff_id, employee_number, first_name, last_name, email, phone, staff_role, branch_id, hire_date, salary, is_active) VALUES (14, 'EMP014', 'James', 'Hall', 'james.hall@citylibrary.org', '555-4014', 'IT Admin', 5, TO_DATE('2019-08-26', 'YYYY-MM-DD'), 57000.00, 'Y');
INSERT INTO STAFF (staff_id, employee_number, first_name, last_name, email, phone, staff_role, branch_id, hire_date, salary, is_active) VALUES (15, 'EMP015', 'Sophia', 'Young', 'sophia.young@citylibrary.org', '555-4015', 'Librarian', 5, TO_DATE('2020-12-03', 'YYYY-MM-DD'), 49000.00, 'Y');
INSERT INTO STAFF (staff_id, employee_number, first_name, last_name, email, phone, staff_role, branch_id, hire_date, salary, is_active) VALUES (16, 'EMP016', 'Daniel', 'King', 'daniel.king@citylibrary.org', '555-4016', 'Cataloger', 6, TO_DATE('2018-06-11', 'YYYY-MM-DD'), 46000.00, 'Y');
INSERT INTO STAFF (staff_id, employee_number, first_name, last_name, email, phone, staff_role, branch_id, hire_date, salary, is_active) VALUES (17, 'EMP017', 'Michelle', 'Scott', 'michelle.scott@citylibrary.org', '555-4017', 'Manager', 6, TO_DATE('2016-04-19', 'YYYY-MM-DD'), 61000.00, 'Y');
INSERT INTO STAFF (staff_id, employee_number, first_name, last_name, email, phone, staff_role, branch_id, hire_date, salary, is_active) VALUES (18, 'EMP018', 'Richard', 'Green', 'richard.green@citylibrary.org', '555-4018', 'Assistant', 6, TO_DATE('2021-01-07', 'YYYY-MM-DD'), 36000.00, 'Y');
INSERT INTO STAFF (staff_id, employee_number, first_name, last_name, email, phone, staff_role, branch_id, hire_date, salary, is_active) VALUES (19, 'EMP019', 'Nancy', 'Adams', 'nancy.adams@citylibrary.org', '555-4019', 'Librarian', 7, TO_DATE('2019-09-24', 'YYYY-MM-DD'), 49500.00, 'Y');
INSERT INTO STAFF (staff_id, employee_number, first_name, last_name, email, phone, staff_role, branch_id, hire_date, salary, is_active) VALUES (20, 'EMP020', 'Thomas', 'Parker', 'thomas.parker@citylibrary.org', '555-4020', 'Reception', 7, TO_DATE('2020-03-16', 'YYYY-MM-DD'), 34000.00, 'Y');

-- ============================================================================
-- 10. PUBLISHERS TABLE
-- ============================================================================
INSERT INTO PUBLISHERS (publisher_id, publisher_name, country, website, contact_email, contact_phone) VALUES (1, 'Penguin Random House', 'USA', 'www.penguinrandomhouse.com', 'contact@penguinrandomhouse.com', '555-5001');
INSERT INTO PUBLISHERS (publisher_id, publisher_name, country, website, contact_email, contact_phone) VALUES (2, 'HarperCollins', 'USA', 'www.harpercollins.com', 'info@harpercollins.com', '555-5002');
INSERT INTO PUBLISHERS (publisher_id, publisher_name, country, website, contact_email, contact_phone) VALUES (3, 'Simon & Schuster', 'USA', 'www.simonandschuster.com', 'contact@simonandschuster.com', '555-5003');
INSERT INTO PUBLISHERS (publisher_id, publisher_name, country, website, contact_email, contact_phone) VALUES (4, 'Hachette Livre', 'France', 'www.hachette.com', 'info@hachette.com', '555-5004');
INSERT INTO PUBLISHERS (publisher_id, publisher_name, country, website, contact_email, contact_phone) VALUES (5, 'Macmillan Publishers', 'UK', 'www.macmillan.com', 'contact@macmillan.com', '555-5005');
INSERT INTO PUBLISHERS (publisher_id, publisher_name, country, website, contact_email, contact_phone) VALUES (6, 'Oxford University Press', 'UK', 'www.oup.com', 'info@oup.com', '555-5006');
INSERT INTO PUBLISHERS (publisher_id, publisher_name, country, website, contact_email, contact_phone) VALUES (7, 'Cambridge University Press', 'UK', 'www.cambridge.org', 'contact@cambridge.org', '555-5007');
INSERT INTO PUBLISHERS (publisher_id, publisher_name, country, website, contact_email, contact_phone) VALUES (8, 'Springer Nature', 'Germany', 'www.springernature.com', 'info@springernature.com', '555-5008');
INSERT INTO PUBLISHERS (publisher_id, publisher_name, country, website, contact_email, contact_phone) VALUES (9, 'Elsevier', 'Netherlands', 'www.elsevier.com', 'contact@elsevier.com', '555-5009');
INSERT INTO PUBLISHERS (publisher_id, publisher_name, country, website, contact_email, contact_phone) VALUES (10, 'Wiley', 'USA', 'www.wiley.com', 'info@wiley.com', '555-5010');
INSERT INTO PUBLISHERS (publisher_id, publisher_name, country, website, contact_email, contact_phone) VALUES (11, 'Pearson Education', 'UK', 'www.pearson.com', 'contact@pearson.com', '555-5011');
INSERT INTO PUBLISHERS (publisher_id, publisher_name, country, website, contact_email, contact_phone) VALUES (12, 'McGraw-Hill', 'USA', 'www.mheducation.com', 'info@mheducation.com', '555-5012');
INSERT INTO PUBLISHERS (publisher_id, publisher_name, country, website, contact_email, contact_phone) VALUES (13, 'Cengage Learning', 'USA', 'www.cengage.com', 'contact@cengage.com', '555-5013');
INSERT INTO PUBLISHERS (publisher_id, publisher_name, country, website, contact_email, contact_phone) VALUES (14, 'Bloomsbury', 'UK', 'www.bloomsbury.com', 'info@bloomsbury.com', '555-5014');
INSERT INTO PUBLISHERS (publisher_id, publisher_name, country, website, contact_email, contact_phone) VALUES (15, 'Scholastic', 'USA', 'www.scholastic.com', 'contact@scholastic.com', '555-5015');
INSERT INTO PUBLISHERS (publisher_id, publisher_name, country, website, contact_email, contact_phone) VALUES (16, 'Disney Publishing', 'USA', 'www.disneypublishing.com', 'info@disneypublishing.com', '555-5016');
INSERT INTO PUBLISHERS (publisher_id, publisher_name, country, website, contact_email, contact_phone) VALUES (17, 'Marvel Comics', 'USA', 'www.marvel.com', 'contact@marvel.com', '555-5017');
INSERT INTO PUBLISHERS (publisher_id, publisher_name, country, website, contact_email, contact_phone) VALUES (18, 'DC Comics', 'USA', 'www.dccomics.com', 'info@dccomics.com', '555-5018');
INSERT INTO PUBLISHERS (publisher_id, publisher_name, country, website, contact_email, contact_phone) VALUES (19, 'Image Comics', 'USA', 'www.imagecomics.com', 'contact@imagecomics.com', '555-5019');
INSERT INTO PUBLISHERS (publisher_id, publisher_name, country, website, contact_email, contact_phone) VALUES (20, 'Dark Horse Comics', 'USA', 'www.darkhorse.com', 'info@darkhorse.com', '555-5020');

-- ============================================================================
-- 11. AUTHORS TABLE
-- ============================================================================
INSERT INTO AUTHORS (author_id, first_name, last_name, biography, birth_date, death_date, nationality, website) VALUES (1, 'Stephen', 'King', 'Master of horror and suspense fiction', TO_DATE('1947-09-21', 'YYYY-MM-DD'), NULL, 'American', 'www.stephenking.com');
INSERT INTO AUTHORS (author_id, first_name, last_name, biography, birth_date, death_date, nationality, website) VALUES (2, 'J.K.', 'Rowling', 'Creator of the Harry Potter series', TO_DATE('1965-07-31', 'YYYY-MM-DD'), NULL, 'British', 'www.jkrowling.com');
INSERT INTO AUTHORS (author_id, first_name, last_name, biography, birth_date, death_date, nationality, website) VALUES (3, 'George R.R.', 'Martin', 'Author of A Song of Ice and Fire series', TO_DATE('1948-09-20', 'YYYY-MM-DD'), NULL, 'American', 'www.georgerrmartin.com');
INSERT INTO AUTHORS (author_id, first_name, last_name, biography, birth_date, death_date, nationality, website) VALUES (4, 'Agatha', 'Christie', 'Queen of crime fiction', TO_DATE('1890-09-15', 'YYYY-MM-DD'), TO_DATE('1976-01-12', 'YYYY-MM-DD'), 'British', NULL);
INSERT INTO AUTHORS (author_id, first_name, last_name, biography, birth_date, death_date, nationality, website) VALUES (5, 'J.R.R.', 'Tolkien', 'Creator of Middle-earth', TO_DATE('1892-01-03', 'YYYY-MM-DD'), TO_DATE('1973-09-02', 'YYYY-MM-DD'), 'British', NULL);
INSERT INTO AUTHORS (author_id, first_name, last_name, biography, birth_date, death_date, nationality, website) VALUES (6, 'Jane', 'Austen', 'Classic English novelist', TO_DATE('1775-12-16', 'YYYY-MM-DD'), TO_DATE('1817-07-18', 'YYYY-MM-DD'), 'British', NULL);
INSERT INTO AUTHORS (author_id, first_name, last_name, biography, birth_date, death_date, nationality, website) VALUES (7, 'Ernest', 'Hemingway', 'Nobel Prize-winning novelist', TO_DATE('1899-07-21', 'YYYY-MM-DD'), TO_DATE('1961-07-02', 'YYYY-MM-DD'), 'American', NULL);
INSERT INTO AUTHORS (author_id, first_name, last_name, biography, birth_date, death_date, nationality, website) VALUES (8, 'William', 'Shakespeare', 'Greatest English playwright', TO_DATE('1564-04-26', 'YYYY-MM-DD'), TO_DATE('1616-04-23', 'YYYY-MM-DD'), 'British', NULL);
INSERT INTO AUTHORS (author_id, first_name, last_name, biography, birth_date, death_date, nationality, website) VALUES (9, 'Isaac', 'Asimov', 'Prolific science fiction writer', TO_DATE('1920-01-02', 'YYYY-MM-DD'), TO_DATE('1992-04-06', 'YYYY-MM-DD'), 'American', NULL);
INSERT INTO AUTHORS (author_id, first_name, last_name, biography, birth_date, death_date, nationality, website) VALUES (10, 'Arthur C.', 'Clarke', 'Science fiction visionary', TO_DATE('1917-12-16', 'YYYY-MM-DD'), TO_DATE('2008-03-19', 'YYYY-MM-DD'), 'British', NULL);
INSERT INTO AUTHORS (author_id, first_name, last_name, biography, birth_date, death_date, nationality, website) VALUES (11, 'Frank', 'Herbert', 'Author of Dune series', TO_DATE('1920-10-08', 'YYYY-MM-DD'), TO_DATE('1986-02-11', 'YYYY-MM-DD'), 'American', NULL);
INSERT INTO AUTHORS (author_id, first_name, last_name, biography, birth_date, death_date, nationality, website) VALUES (12, 'Dan', 'Brown', 'Thriller novelist', TO_DATE('1964-06-22', 'YYYY-MM-DD'), NULL, 'American', 'www.danbrown.com');
INSERT INTO AUTHORS (author_id, first_name, last_name, biography, birth_date, death_date, nationality, website) VALUES (13, 'John', 'Grisham', 'Legal thriller author', TO_DATE('1955-02-08', 'YYYY-MM-DD'), NULL, 'American', 'www.johngrisham.com');
INSERT INTO AUTHORS (author_id, first_name, last_name, biography, birth_date, death_date, nationality, website) VALUES (14, 'James', 'Patterson', 'Prolific thriller writer', TO_DATE('1947-03-22', 'YYYY-MM-DD'), NULL, 'American', 'www.jamespatterson.com');
INSERT INTO AUTHORS (author_id, first_name, last_name, biography, birth_date, death_date, nationality, website) VALUES (15, 'Nora', 'Roberts', 'Bestselling romance author', TO_DATE('1950-10-10', 'YYYY-MM-DD'), NULL, 'American', 'www.noraroberts.com');
INSERT INTO AUTHORS (author_id, first_name, last_name, biography, birth_date, death_date, nationality, website) VALUES (16, 'Stephenie', 'Meyer', 'Twilight series author', TO_DATE('1973-12-24', 'YYYY-MM-DD'), NULL, 'American', 'www.stepheniemeyer.com');
INSERT INTO AUTHORS (author_id, first_name, last_name, biography, birth_date, death_date, nationality, website) VALUES (17, 'Suzanne', 'Collins', 'Hunger Games trilogy author', TO_DATE('1962-08-10', 'YYYY-MM-DD'), NULL, 'American', NULL);
INSERT INTO AUTHORS (author_id, first_name, last_name, biography, birth_date, death_date, nationality, website) VALUES (18, 'Rick', 'Riordan', 'Percy Jackson series author', TO_DATE('1964-06-05', 'YYYY-MM-DD'), NULL, 'American', 'www.rickriordan.com');
INSERT INTO AUTHORS (author_id, first_name, last_name, biography, birth_date, death_date, nationality, website) VALUES (19, 'Margaret', 'Atwood', 'Award-winning Canadian author', TO_DATE('1939-11-18', 'YYYY-MM-DD'), NULL, 'Canadian', 'www.margaretatwood.ca');
INSERT INTO AUTHORS (author_id, first_name, last_name, biography, birth_date, death_date, nationality, website) VALUES (20, 'Neil', 'Gaiman', 'Fantasy and graphic novel writer', TO_DATE('1960-11-10', 'YYYY-MM-DD'), NULL, 'British', 'www.neilgaiman.com');

-- ============================================================================
-- 12. GENRES TABLE
-- ============================================================================
INSERT INTO GENRES (genre_id, genre_name, GENRE_DESCRIPTION ) VALUES (1, 'Fiction', 'Imaginative literary works');
INSERT INTO GENRES (genre_id, genre_name, GENRE_DESCRIPTION ) VALUES (2, 'Non-Fiction', 'Factual and informative works');
INSERT INTO GENRES (genre_id, genre_name, GENRE_DESCRIPTION ) VALUES (3, 'Mystery', 'Detective and crime stories');
INSERT INTO GENRES (genre_id, genre_name, GENRE_DESCRIPTION) VALUES (4, 'Science Fiction', 'Speculative fiction based on science');
INSERT INTO GENRES (genre_id, genre_name, GENRE_DESCRIPTION) VALUES (5, 'Fantasy', 'Magic and supernatural elements');
INSERT INTO GENRES (genre_id, genre_name, GENRE_DESCRIPTION) VALUES (6, 'Romance', 'Love and relationship stories');
INSERT INTO GENRES (genre_id, genre_name, GENRE_DESCRIPTION) VALUES (7, 'Horror', 'Fear and suspense stories');
INSERT INTO GENRES (genre_id, genre_name, GENRE_DESCRIPTION) VALUES (8, 'Thriller', 'Suspense and excitement');
INSERT INTO GENRES (genre_id, genre_name, GENRE_DESCRIPTION) VALUES (9, 'Historical Fiction', 'Stories set in historical periods');
INSERT INTO GENRES (genre_id, genre_name, GENRE_DESCRIPTION) VALUES (10, 'Biography', 'Life stories of real people');
INSERT INTO GENRES (genre_id, genre_name, GENRE_DESCRIPTION) VALUES (11, 'History', 'Historical events and periods');
INSERT INTO GENRES (genre_id, genre_name, GENRE_DESCRIPTION) VALUES (12, 'Science', 'Scientific topics and discoveries');
INSERT INTO GENRES (genre_id, genre_name, GENRE_DESCRIPTION) VALUES (13, 'Self-Help', 'Personal development');
INSERT INTO GENRES (genre_id, genre_name, GENRE_DESCRIPTION) VALUES (14, 'Travel', 'Travel guides and experiences');
INSERT INTO GENRES (genre_id, genre_name, GENRE_DESCRIPTION) VALUES (15, 'Cooking', 'Recipes and culinary arts');
INSERT INTO GENRES (genre_id, genre_name, GENRE_DESCRIPTION) VALUES (16, 'Art', 'Visual arts and artists');
INSERT INTO GENRES (genre_id, genre_name, GENRE_DESCRIPTION) VALUES (17, 'Music', 'Music theory and history');
INSERT INTO GENRES (genre_id, genre_name, GENRE_DESCRIPTION) VALUES (18, 'Technology', 'Computers and technology');
INSERT INTO GENRES (genre_id, genre_name, GENRE_DESCRIPTION) VALUES (19, 'Business', 'Business and economics');
INSERT INTO GENRES (genre_id, genre_name, GENRE_DESCRIPTION) VALUES (20, 'Health & Fitness', 'Health and wellness topics');

-- ============================================================================
-- 13. MATERIALS TABLE
-- ============================================================================
INSERT INTO MATERIALS (material_id, title, subtitle, material_type, isbn, issn, publication_year, publisher_id, language, edition, pages, description, dewey_decimal, total_copies, available_copies, is_reference, is_new_release) VALUES (1, 'The Shining', 'A Novel', 'Book', '9780385121675', NULL, 1977, 1, 'English', '1st Edition', 447, 'A family heads to an isolated hotel for the winter where a sinister presence influences the father into violence', '813.54', 5, 3, 'N', 'N');
INSERT INTO MATERIALS (material_id, title, subtitle, material_type, isbn, issn, publication_year, publisher_id, language, edition, pages, description, dewey_decimal, total_copies, available_copies, is_reference, is_new_release) VALUES (2, 'Harry Potter and the Sorcerer''s Stone', NULL, 'Book', '9780590353427', NULL, 1997, 15, 'English', '1st Edition', 309, 'A young wizard discovers his magical heritage on his 11th birthday', '823.914', 8, 5, 'N', 'N');
INSERT INTO MATERIALS (material_id, title, subtitle, material_type, isbn, issn, publication_year, publisher_id, language, edition, pages, description, dewey_decimal, total_copies, available_copies, is_reference, is_new_release) VALUES (3, 'A Game of Thrones', 'A Song of Ice and Fire', 'Book', '9780553103540', NULL, 1996, 1, 'English', '1st Edition', 694, 'Noble families fight for control of the Iron Throne', '813.54', 6, 4, 'N', 'N');
INSERT INTO MATERIALS (material_id, title, subtitle, material_type, isbn, issn, publication_year, publisher_id, language, edition, pages, description, dewey_decimal, total_copies, available_copies, is_reference, is_new_release) VALUES (4, 'Murder on the Orient Express', 'A Hercule Poirot Mystery', 'Book', '9780062693662', NULL, 1934, 2, 'English', 'Reprint', 256, 'Famous detective solves a murder on a stranded train', '823.912', 4, 2, 'N', 'N');
INSERT INTO MATERIALS (material_id, title, subtitle, material_type, isbn, issn, publication_year, publisher_id, language, edition, pages, description, dewey_decimal, total_copies, available_copies, is_reference, is_new_release) VALUES (5, 'The Hobbit', 'There and Back Again', 'Book', '9780547928227', NULL, 1937, 5, 'English', '75th Anniversary', 300, 'A hobbit journeys to reclaim a dwarf kingdom', '823.912', 7, 6, 'N', 'N');
INSERT INTO MATERIALS (material_id, title, subtitle, material_type, isbn, issn, publication_year, publisher_id, language, edition, pages, description, dewey_decimal, total_copies, available_copies, is_reference, is_new_release) VALUES (6, 'Pride and Prejudice', NULL, 'Book', '9780141439518', NULL, 1813, 1, 'English', 'Modern Classic', 432, 'Romantic novel about Elizabeth Bennet and Mr. Darcy', '823.7', 5, 3, 'N', 'N');
INSERT INTO MATERIALS (material_id, title, subtitle, material_type, isbn, issn, publication_year, publisher_id, language, edition, pages, description, dewey_decimal, total_copies, available_copies, is_reference, is_new_release) VALUES (7, 'The Old Man and the Sea', NULL, 'Book', '9780684801223', NULL, 1952, 3, 'English', 'Reprint', 127, 'An old fisherman''s struggle with a giant marlin', '813.52', 4, 2, 'N', 'N');
INSERT INTO MATERIALS (material_id, title, subtitle, material_type, isbn, issn, publication_year, publisher_id, language, edition, pages, description, dewey_decimal, total_copies, available_copies, is_reference, is_new_release) VALUES (8, 'Hamlet', NULL, 'Book', '9780743477123', NULL, 1603, 6, 'English', 'Academic Edition', 342, 'Tragedy of Prince Hamlet seeking revenge', '822.33', 6, 4, 'N', 'N');
INSERT INTO MATERIALS (material_id, title, subtitle, material_type, isbn, issn, publication_year, publisher_id, language, edition, pages, description, dewey_decimal, total_copies, available_copies, is_reference, is_new_release) VALUES (9, 'Foundation', NULL, 'Book', '9780553293357', NULL, 1951, 1, 'English', 'Reprint', 255, 'Galactic empire psychohistorian predicts its fall', '813.54', 5, 3, 'N', 'N');
INSERT INTO MATERIALS (material_id, title, subtitle, material_type, isbn, issn, publication_year, publisher_id, language, edition, pages, description, dewey_decimal, total_copies, available_copies, is_reference, is_new_release) VALUES (10, '2001: A Space Odyssey', NULL, 'Book', '9780451457998', NULL, 1968, 7, 'English', 'Special Edition', 297, 'Humanity finds a mysterious monolith on the moon', '823.914', 4, 2, 'N', 'N');
INSERT INTO MATERIALS (material_id, title, subtitle, material_type, isbn, issn, publication_year, publisher_id, language, edition, pages, description, dewey_decimal, total_copies, available_copies, is_reference, is_new_release) VALUES (11, 'Dune', NULL, 'Book', '9780441172719', NULL, 1965, 8, 'English', 'Anniversary Edition', 412, 'Young Paul Atreides leads desert planet rebellion', '813.54', 6, 4, 'N', 'N');
INSERT INTO MATERIALS (material_id, title, subtitle, material_type, isbn, issn, publication_year, publisher_id, language, edition, pages, description, dewey_decimal, total_copies, available_copies, is_reference, is_new_release) VALUES (12, 'The Da Vinci Code', NULL, 'Book', '9780307474278', NULL, 2003, 1, 'English', '1st Edition', 454, 'Symbologist Robert Langdon solves murder mystery', '813.54', 7, 5, 'N', 'N');
INSERT INTO MATERIALS (material_id, title, subtitle, material_type, isbn, issn, publication_year, publisher_id, language, edition, pages, description, dewey_decimal, total_copies, available_copies, is_reference, is_new_release) VALUES (13, 'The Firm', NULL, 'Book', '9780385410952', NULL, 1991, 1, 'English', 'Reprint', 432, 'Young lawyer discovers his firm''s dark secrets', '813.54', 5, 3, 'N', 'N');
INSERT INTO MATERIALS (material_id, title, subtitle, material_type, isbn, issn, publication_year, publisher_id, language, edition, pages, description, dewey_decimal, total_copies, available_copies, is_reference, is_new_release) VALUES (14, 'Along Came a Spider', NULL, 'Book', '9780446692636', NULL, 1993, 2, 'English', 'Reprint', 435, 'Detective Alex Cross hunts a serial killer', '813.54', 4, 2, 'N', 'N');
INSERT INTO MATERIALS (material_id, title, subtitle, material_type, isbn, issn, publication_year, publisher_id, language, edition, pages, description, dewey_decimal, total_copies, available_copies, is_reference, is_new_release) VALUES (15, 'Vision in White', 'Bride Quartet', 'Book', '9780425227513', NULL, 2009, 9, 'English', '1st Edition', 352, 'Wedding photographer finds love while planning weddings', '813.54', 5, 4, 'N', 'N');
INSERT INTO MATERIALS (material_id, title, subtitle, material_type, isbn, issn, publication_year, publisher_id, language, edition, pages, description, dewey_decimal, total_copies, available_copies, is_reference, is_new_release) VALUES (16, 'Twilight', NULL, 'Book', '9780316015844', NULL, 2005, 10, 'English', '1st Edition', 498, 'Bella Swan falls in love with vampire Edward Cullen', '813.6', 8, 6, 'N', 'N');
INSERT INTO MATERIALS (material_id, title, subtitle, material_type, isbn, issn, publication_year, publisher_id, language, edition, pages, description, dewey_decimal, total_copies, available_copies, is_reference, is_new_release) VALUES (17, 'The Hunger Games', NULL, 'Book', '9780439023481', NULL, 2008, 15, 'English', '1st Edition', 374, 'Teenager fights in televised death match', '813.6', 7, 5, 'N', 'N');
INSERT INTO MATERIALS (material_id, title, subtitle, material_type, isbn, issn, publication_year, publisher_id, language, edition, pages, description, dewey_decimal, total_copies, available_copies, is_reference, is_new_release) VALUES (18, 'The Lightning Thief', 'Percy Jackson and the Olympians', 'Book', '9780786838653', NULL, 2005, 11, 'English', '1st Edition', 377, 'Demigod Percy Jackson discovers his heritage', '813.6', 6, 4, 'N', 'N');
INSERT INTO MATERIALS (material_id, title, subtitle, material_type, isbn, issn, publication_year, publisher_id, language, edition, pages, description, dewey_decimal, total_copies, available_copies, is_reference, is_new_release) VALUES (19, 'The Handmaid''s Tale', NULL, 'Book', '9780385490818', NULL, 1985, 1, 'English', 'Reprint', 311, 'Dystopian tale of women''s oppression', '813.54', 5, 3, 'N', 'N');
INSERT INTO MATERIALS (material_id, title, subtitle, material_type, isbn, issn, publication_year, publisher_id, language, edition, pages, description, dewey_decimal, total_copies, available_copies, is_reference, is_new_release) VALUES (20, 'American Gods', NULL, 'Book', '9780062059888', NULL, 2001, 2, 'English', '10th Anniversary', 465, 'Ex-con Shadow meets ancient gods in modern America', '813.54', 4, 2, 'N', 'N');

-- ============================================================================
-- 14. COPIES TABLE
-- ============================================================================
INSERT INTO COPIES (copy_id, material_id, barcode, branch_id, copy_condition, copy_status, acquisition_date, acquisition_price) VALUES (1, 1, 'BK00100001', 1, 'Good', 'Available', TO_DATE('2020-01-15', 'YYYY-MM-DD'), 12.99);
INSERT INTO COPIES (copy_id, material_id, barcode, branch_id, copy_condition, copy_status, acquisition_date, acquisition_price) VALUES (2, 1, 'BK00100002', 1, 'Fair', 'Checked Out', TO_DATE('2020-01-15', 'YYYY-MM-DD'), 12.99);
INSERT INTO COPIES (copy_id, material_id, barcode, branch_id, copy_condition, copy_status, acquisition_date, acquisition_price) VALUES (3, 1, 'BK00100003', 2, 'Excellent', 'Available', TO_DATE('2020-02-20', 'YYYY-MM-DD'), 12.99);
INSERT INTO COPIES (copy_id, material_id, barcode, branch_id, copy_condition, copy_status, acquisition_date, acquisition_price) VALUES (4, 2, 'BK00200001', 1, 'New', 'Available', TO_DATE('2021-03-10', 'YYYY-MM-DD'), 15.99);
INSERT INTO COPIES (copy_id, material_id, barcode, branch_id, copy_condition, copy_status, acquisition_date, acquisition_price) VALUES (5, 2, 'BK00200002', 1, 'Good', 'Available', TO_DATE('2021-03-10', 'YYYY-MM-DD'), 15.99);
INSERT INTO COPIES (copy_id, material_id, barcode, branch_id, copy_condition, copy_status, acquisition_date, acquisition_price) VALUES (6, 2, 'BK00200003', 3, 'Excellent', 'Checked Out', TO_DATE('2021-04-05', 'YYYY-MM-DD'), 15.99);
INSERT INTO COPIES (copy_id, material_id, barcode, branch_id, copy_condition, copy_status, acquisition_date, acquisition_price) VALUES (7, 3, 'BK00300001', 2, 'Good', 'Available', TO_DATE('2019-11-30', 'YYYY-MM-DD'), 18.99);
INSERT INTO COPIES (copy_id, material_id, barcode, branch_id, copy_condition, copy_status, acquisition_date, acquisition_price) VALUES (8, 3, 'BK00300002', 2, 'Fair', 'Available', TO_DATE('2019-11-30', 'YYYY-MM-DD'), 18.99);
INSERT INTO COPIES (copy_id, material_id, barcode, branch_id, copy_condition, copy_status, acquisition_date, acquisition_price) VALUES (9, 4, 'BK00400001', 1, 'Poor', 'Under Repair', TO_DATE('2018-05-22', 'YYYY-MM-DD'), 9.99);
INSERT INTO COPIES (copy_id, material_id, barcode, branch_id, copy_condition, copy_status, acquisition_date, acquisition_price) VALUES (10, 4, 'BK00400002', 4, 'Good', 'Available', TO_DATE('2020-08-14', 'YYYY-MM-DD'), 9.99);
INSERT INTO COPIES (copy_id, material_id, barcode, branch_id, copy_condition, copy_status, acquisition_date, acquisition_price) VALUES (11, 5, 'BK00500001', 3, 'Excellent', 'Available', TO_DATE('2022-01-08', 'YYYY-MM-DD'), 14.99);
INSERT INTO COPIES (copy_id, material_id, barcode, branch_id, copy_condition, copy_status, acquisition_date, acquisition_price) VALUES (12, 5, 'BK00500002', 3, 'Good', 'Checked Out', TO_DATE('2022-01-08', 'YYYY-MM-DD'), 14.99);
INSERT INTO COPIES (copy_id, material_id, barcode, branch_id, copy_condition, copy_status, acquisition_date, acquisition_price) VALUES (13, 6, 'BK00600001', 1, 'Fair', 'Available', TO_DATE('2017-09-18', 'YYYY-MM-DD'), 8.99);
INSERT INTO COPIES (copy_id, material_id, barcode, branch_id, copy_condition, copy_status, acquisition_date, acquisition_price) VALUES (14, 7, 'BK00700001', 2, 'Good', 'Available', TO_DATE('2019-12-03', 'YYYY-MM-DD'), 10.99);
INSERT INTO COPIES (copy_id, material_id, barcode, branch_id, copy_condition, copy_status, acquisition_date, acquisition_price) VALUES (15, 8, 'BK00800001', 4, 'Excellent', 'Available', TO_DATE('2021-06-25', 'YYYY-MM-DD'), 12.99);
INSERT INTO COPIES (copy_id, material_id, barcode, branch_id, copy_condition, copy_status, acquisition_date, acquisition_price) VALUES (16, 9, 'BK00900001', 3, 'Good', 'Checked Out', TO_DATE('2020-04-11', 'YYYY-MM-DD'), 11.99);
INSERT INTO COPIES (copy_id, material_id, barcode, branch_id, copy_condition, copy_status, acquisition_date, acquisition_price) VALUES (17, 10, 'BK01000001', 1, 'Fair', 'Available', TO_DATE('2018-10-30', 'YYYY-MM-DD'), 13.99);
INSERT INTO COPIES (copy_id, material_id, barcode, branch_id, copy_condition, copy_status, acquisition_date, acquisition_price) VALUES (18, 11, 'BK01100001', 2, 'Excellent', 'Available', TO_DATE('2022-03-15', 'YYYY-MM-DD'), 16.99);
INSERT INTO COPIES (copy_id, material_id, barcode, branch_id, copy_condition, copy_status, acquisition_date, acquisition_price) VALUES (19, 12, 'BK01200001', 4, 'New', 'Available', TO_DATE('2023-01-20', 'YYYY-MM-DD'), 19.99);
INSERT INTO COPIES (copy_id, material_id, barcode, branch_id, copy_condition, copy_status, acquisition_date, acquisition_price) VALUES (20, 13, 'BK01300001', 3, 'Good', 'Available', TO_DATE('2021-07-08', 'YYYY-MM-DD'), 14.99);

-- ============================================================================
-- 15. LOANS TABLE
-- ============================================================================
INSERT INTO LOANS (loan_id, patron_id, copy_id, checkout_date, due_date, return_date, renewal_count, loan_status, staff_id_checkout, staff_id_return) VALUES (1, 1, 2, SYSDATE-15, SYSDATE-1, NULL, 0, 'Overdue', 2, NULL);
INSERT INTO LOANS (loan_id, patron_id, copy_id, checkout_date, due_date, return_date, renewal_count, loan_status, staff_id_checkout, staff_id_return) VALUES (2, 3, 6, SYSDATE-10, SYSDATE+4, NULL, 1, 'Active', 2, NULL);
INSERT INTO LOANS (loan_id, patron_id, copy_id, checkout_date, due_date, return_date, renewal_count, loan_status, staff_id_checkout, staff_id_return) VALUES (3, 5, 12, SYSDATE-7, SYSDATE+7, NULL, 0, 'Active', 3, NULL);
INSERT INTO LOANS (loan_id, patron_id, copy_id, checkout_date, due_date, return_date, renewal_count, loan_status, staff_id_checkout, staff_id_return) VALUES (4, 2, 16, SYSDATE-20, SYSDATE-6, SYSDATE-5, 0, 'Returned', 2, 2);
INSERT INTO LOANS (loan_id, patron_id, copy_id, checkout_date, due_date, return_date, renewal_count, loan_status, staff_id_checkout, staff_id_return) VALUES (5, 4, 9, SYSDATE-25, SYSDATE-11, NULL, 0, 'Overdue', 3, NULL);
INSERT INTO LOANS (loan_id, patron_id, copy_id, checkout_date, due_date, return_date, renewal_count, loan_status, staff_id_checkout, staff_id_return) VALUES (6, 6, 4, SYSDATE-5, SYSDATE+9, NULL, 0, 'Active', 2, NULL);
INSERT INTO LOANS (loan_id, patron_id, copy_id, checkout_date, due_date, return_date, renewal_count, loan_status, staff_id_checkout, staff_id_return) VALUES (7, 8, 7, SYSDATE-12, SYSDATE+2, NULL, 1, 'Active', 3, NULL);
INSERT INTO LOANS (loan_id, patron_id, copy_id, checkout_date, due_date, return_date, renewal_count, loan_status, staff_id_checkout, staff_id_return) VALUES (8, 10, 11, SYSDATE-3, SYSDATE+11, NULL, 0, 'Active', 2, NULL);
INSERT INTO LOANS (loan_id, patron_id, copy_id, checkout_date, due_date, return_date, renewal_count, loan_status, staff_id_checkout, staff_id_return) VALUES (9, 12, 14, SYSDATE-18, SYSDATE-4, SYSDATE-3, 0, 'Returned', 3, 3);
INSERT INTO LOANS (loan_id, patron_id, copy_id, checkout_date, due_date, return_date, renewal_count, loan_status, staff_id_checkout, staff_id_return) VALUES (10, 14, 17, SYSDATE-22, SYSDATE-8, NULL, 0, 'Overdue', 2, NULL);
INSERT INTO LOANS (loan_id, patron_id, copy_id, checkout_date, due_date, return_date, renewal_count, loan_status, staff_id_checkout, staff_id_return) VALUES (11, 16, 19, SYSDATE-8, SYSDATE+6, NULL, 0, 'Active', 3, NULL);
INSERT INTO LOANS (loan_id, patron_id, copy_id, checkout_date, due_date, return_date, renewal_count, loan_status, staff_id_checkout, staff_id_return) VALUES (12, 18, 1, SYSDATE-14, SYSDATE, NULL, 1, 'Active', 2, NULL);
INSERT INTO LOANS (loan_id, patron_id, copy_id, checkout_date, due_date, return_date, renewal_count, loan_status, staff_id_checkout, staff_id_return) VALUES (13, 20, 5, SYSDATE-6, SYSDATE+8, NULL, 0, 'Active', 3, NULL);
INSERT INTO LOANS (loan_id, patron_id, copy_id, checkout_date, due_date, return_date, renewal_count, loan_status, staff_id_checkout, staff_id_return) VALUES (14, 7, 8, SYSDATE-16, SYSDATE-2, SYSDATE-1, 0, 'Returned', 2, 2);
INSERT INTO LOANS (loan_id, patron_id, copy_id, checkout_date, due_date, return_date, renewal_count, loan_status, staff_id_checkout, staff_id_return) VALUES (15, 9, 13, SYSDATE-9, SYSDATE+5, NULL, 0, 'Active', 3, NULL);
INSERT INTO LOANS (loan_id, patron_id, copy_id, checkout_date, due_date, return_date, renewal_count, loan_status, staff_id_checkout, staff_id_return) VALUES (16, 11, 15, SYSDATE-11, SYSDATE+3, NULL, 1, 'Active', 2, NULL);
INSERT INTO LOANS (loan_id, patron_id, copy_id, checkout_date, due_date, return_date, renewal_count, loan_status, staff_id_checkout, staff_id_return) VALUES (17, 13, 18, SYSDATE-4, SYSDATE+10, NULL, 0, 'Active', 3, NULL);
INSERT INTO LOANS (loan_id, patron_id, copy_id, checkout_date, due_date, return_date, renewal_count, loan_status, staff_id_checkout, staff_id_return) VALUES (18, 15, 20, SYSDATE-13, SYSDATE+1, NULL, 0, 'Active', 2, NULL);
INSERT INTO LOANS (loan_id, patron_id, copy_id, checkout_date, due_date, return_date, renewal_count, loan_status, staff_id_checkout, staff_id_return) VALUES (19, 17, 3, SYSDATE-19, SYSDATE-5, SYSDATE-4, 0, 'Returned', 3, 3);
INSERT INTO LOANS (loan_id, patron_id, copy_id, checkout_date, due_date, return_date, renewal_count, loan_status, staff_id_checkout, staff_id_return) VALUES (20, 19, 10, SYSDATE-21, SYSDATE-7, NULL, 0, 'Overdue', 2, NULL);

-- ============================================================================
-- 16. RESERVATIONS TABLE
-- ============================================================================
INSERT INTO RESERVATIONS (reservation_id, material_id, patron_id, reservation_date, notification_date, pickup_deadline, reservation_status, queue_position, fulfilled_by_copy_id, notes) VALUES (1, 1, 2, SYSDATE-5, NULL, NULL, 'Pending', 1, NULL, 'Waiting for available copy');
INSERT INTO RESERVATIONS (reservation_id, material_id, patron_id, reservation_date, notification_date, pickup_deadline, reservation_status, queue_position, fulfilled_by_copy_id, notes) VALUES (2, 2, 4, SYSDATE-3, NULL, NULL, 'Pending', 2, NULL, 'Popular title');
INSERT INTO RESERVATIONS (reservation_id, material_id, patron_id, reservation_date, notification_date, pickup_deadline, reservation_status, queue_position, fulfilled_by_copy_id, notes) VALUES (3, 3, 6, SYSDATE-7, SYSDATE-1, SYSDATE+6, 'Ready', 1, 7, 'Notified patron');
INSERT INTO RESERVATIONS (reservation_id, material_id, patron_id, reservation_date, notification_date, pickup_deadline, reservation_status, queue_position, fulfilled_by_copy_id, notes) VALUES (4, 5, 8, SYSDATE-2, NULL, NULL, 'Pending', 1, NULL, 'First in queue');
INSERT INTO RESERVATIONS (reservation_id, material_id, patron_id, reservation_date, notification_date, pickup_deadline, reservation_status, queue_position, fulfilled_by_copy_id, notes) VALUES (5, 7, 10, SYSDATE-10, SYSDATE-5, SYSDATE, 'Expired', 1, NULL, 'Patron did not pickup');
INSERT INTO RESERVATIONS (reservation_id, material_id, patron_id, reservation_date, notification_date, pickup_deadline, reservation_status, queue_position, fulfilled_by_copy_id, notes) VALUES (6, 9, 12, SYSDATE-4, NULL, NULL, 'Pending', 1, NULL, 'Research material');
INSERT INTO RESERVATIONS (reservation_id, material_id, patron_id, reservation_date, notification_date, pickup_deadline, reservation_status, queue_position, fulfilled_by_copy_id, notes) VALUES (7, 11, 14, SYSDATE-6, NULL, NULL, 'Pending', 2, NULL, 'Academic interest');
INSERT INTO RESERVATIONS (reservation_id, material_id, patron_id, reservation_date, notification_date, pickup_deadline, reservation_status, queue_position, fulfilled_by_copy_id, notes) VALUES (8, 13, 16, SYSDATE-1, NULL, NULL, 'Pending', 1, NULL, 'New reservation');
INSERT INTO RESERVATIONS (reservation_id, material_id, patron_id, reservation_date, notification_date, pickup_deadline, reservation_status, queue_position, fulfilled_by_copy_id, notes) VALUES (9, 15, 18, SYSDATE-8, SYSDATE-3, SYSDATE+4, 'Ready', 1, NULL, 'Awaiting pickup');
INSERT INTO RESERVATIONS (reservation_id, material_id, patron_id, reservation_date, notification_date, pickup_deadline, reservation_status, queue_position, fulfilled_by_copy_id, notes) VALUES (10, 17, 20, SYSDATE-9, SYSDATE-4, SYSDATE+3, 'Fulfilled', 1, 6, 'Successfully loaned');
INSERT INTO RESERVATIONS (reservation_id, material_id, patron_id, reservation_date, notification_date, pickup_deadline, reservation_status, queue_position, fulfilled_by_copy_id, notes) VALUES (11, 2, 1, SYSDATE-12, SYSDATE-7, SYSDATE, 'Cancelled', 1, NULL, 'Patron cancelled');
INSERT INTO RESERVATIONS (reservation_id, material_id, patron_id, reservation_date, notification_date, pickup_deadline, reservation_status, queue_position, fulfilled_by_copy_id, notes) VALUES (12, 4, 3, SYSDATE-11, NULL, NULL, 'Pending', 1, NULL, 'Classic mystery');
INSERT INTO RESERVATIONS (reservation_id, material_id, patron_id, reservation_date, notification_date, pickup_deadline, reservation_status, queue_position, fulfilled_by_copy_id, notes) VALUES (13, 6, 5, SYSDATE-13, SYSDATE-8, SYSDATE-1, 'Expired', 1, NULL, 'Missed deadline');
INSERT INTO RESERVATIONS (reservation_id, material_id, patron_id, reservation_date, notification_date, pickup_deadline, reservation_status, queue_position, fulfilled_by_copy_id, notes) VALUES (14, 8, 7, SYSDATE-14, NULL, NULL, 'Pending', 1, NULL, 'Academic study');
INSERT INTO RESERVATIONS (reservation_id, material_id, patron_id, reservation_date, notification_date, pickup_deadline, reservation_status, queue_position, fulfilled_by_copy_id, notes) VALUES (15, 10, 9, SYSDATE-15, SYSDATE-10, SYSDATE-3, 'Fulfilled', 1, 17, 'Completed');
INSERT INTO RESERVATIONS (reservation_id, material_id, patron_id, reservation_date, notification_date, pickup_deadline, reservation_status, queue_position, fulfilled_by_copy_id, notes) VALUES (16, 12, 11, SYSDATE-16, NULL, NULL, 'Pending', 1, NULL, 'Popular fiction');
INSERT INTO RESERVATIONS (reservation_id, material_id, patron_id, reservation_date, notification_date, pickup_deadline, reservation_status, queue_position, fulfilled_by_copy_id, notes) VALUES (17, 14, 13, SYSDATE-17, SYSDATE-12, SYSDATE-5, 'Fulfilled', 1, NULL, 'Successful');
INSERT INTO RESERVATIONS (reservation_id, material_id, patron_id, reservation_date, notification_date, pickup_deadline, reservation_status, queue_position, fulfilled_by_copy_id, notes) VALUES (18, 16, 15, SYSDATE-18, NULL, NULL, 'Pending', 2, NULL, 'Teen fiction');
INSERT INTO RESERVATIONS (reservation_id, material_id, patron_id, reservation_date, notification_date, pickup_deadline, reservation_status, queue_position, fulfilled_by_copy_id, notes) VALUES (19, 18, 17, SYSDATE-19, SYSDATE-14, SYSDATE-7, 'Fulfilled', 1, 18, 'Picked up');
INSERT INTO RESERVATIONS (reservation_id, material_id, patron_id, reservation_date, notification_date, pickup_deadline, reservation_status, queue_position, fulfilled_by_copy_id, notes) VALUES (20, 20, 19, SYSDATE-20, NULL, NULL, 'Pending', 1, NULL, 'Fantasy novel');

-- ============================================================================
-- 17. FINES TABLE
-- ============================================================================
INSERT INTO FINES (fine_id, patron_id, loan_id, fine_type, amount_due, amount_paid, date_assessed, payment_date, fine_status, assessed_by_staff_id, waived_by_staff_id, waiver_reason, payment_method, notes) VALUES (1, 1, 1, 'Overdue', 5.50, 0.00, SYSDATE-2, NULL, 'Unpaid', 2, NULL, NULL, NULL, '5 days overdue');
INSERT INTO FINES (fine_id, patron_id, loan_id, fine_type, amount_due, amount_paid, date_assessed, payment_date, fine_status, assessed_by_staff_id, waived_by_staff_id, waiver_reason, payment_method, notes) VALUES (2, 2, 4, 'Overdue', 3.25, 3.25, SYSDATE-10, SYSDATE-5, 'Paid', 2, NULL, NULL, 'Cash', 'Paid in full');
INSERT INTO FINES (fine_id, patron_id, loan_id, fine_type, amount_due, amount_paid, date_assessed, payment_date, fine_status, assessed_by_staff_id, waived_by_staff_id, waiver_reason, payment_method, notes) VALUES (3, 4, 5, 'Overdue', 12.25, 0.00, SYSDATE-8, NULL, 'Unpaid', 3, NULL, NULL, NULL, '14 days overdue');
INSERT INTO FINES (fine_id, patron_id, loan_id, fine_type, amount_due, amount_paid, date_assessed, payment_date, fine_status, assessed_by_staff_id, waived_by_staff_id, waiver_reason, payment_method, notes) VALUES (4, 5, NULL, 'Lost Item', 25.00, 25.00, SYSDATE-30, SYSDATE-25, 'Paid', 2, NULL, NULL, 'Credit Card', 'Replacement fee');
INSERT INTO FINES (fine_id, patron_id, loan_id, fine_type, amount_due, amount_paid, date_assessed, payment_date, fine_status, assessed_by_staff_id, waived_by_staff_id, waiver_reason, payment_method, notes) VALUES (5, 8, NULL, 'Damaged Item', 15.00, 10.00, SYSDATE-15, NULL, 'Partially Paid', 3, NULL, NULL, 'Cash', 'Water damage');
INSERT INTO FINES (fine_id, patron_id, loan_id, fine_type, amount_due, amount_paid, date_assessed, payment_date, fine_status, assessed_by_staff_id, waived_by_staff_id, waiver_reason, payment_method, notes) VALUES (6, 10, 10, 'Overdue', 8.75, 0.00, SYSDATE-5, NULL, 'Unpaid', 2, NULL, NULL, NULL, '7 days overdue');
INSERT INTO FINES (fine_id, patron_id, loan_id, fine_type, amount_due, amount_paid, date_assessed, payment_date, fine_status, assessed_by_staff_id, waived_by_staff_id, waiver_reason, payment_method, notes) VALUES (7, 12, NULL, 'Processing Fee', 5.00, 5.00, SYSDATE-20, SYSDATE-18, 'Paid', 3, NULL, NULL, 'Debit Card', 'Card replacement');
INSERT INTO FINES (fine_id, patron_id, loan_id, fine_type, amount_due, amount_paid, date_assessed, payment_date, fine_status, assessed_by_staff_id, waived_by_staff_id, waiver_reason, payment_method, notes) VALUES (8, 14, 10, 'Overdue', 15.00, 0.00, SYSDATE-3, NULL, 'Unpaid', 2, NULL, NULL, NULL, '12 days overdue');
INSERT INTO FINES (fine_id, patron_id, loan_id, fine_type, amount_due, amount_paid, date_assessed, payment_date, fine_status, assessed_by_staff_id, waived_by_staff_id, waiver_reason, payment_method, notes) VALUES (9, 16, NULL, 'Late Fee', 7.50, 7.50, SYSDATE-12, SYSDATE-10, 'Paid', 3, NULL, NULL, 'Cash', 'Renewal late fee');
INSERT INTO FINES (fine_id, patron_id, loan_id, fine_type, amount_due, amount_paid, date_assessed, payment_date, fine_status, assessed_by_staff_id, waived_by_staff_id, waiver_reason, payment_method, notes) VALUES (10, 18, NULL, 'Overdue', 3.25, 0.00, SYSDATE-7, NULL, 'Unpaid', 2, NULL, NULL, NULL, '3 days overdue');
INSERT INTO FINES (fine_id, patron_id, loan_id, fine_type, amount_due, amount_paid, date_assessed, payment_date, fine_status, assessed_by_staff_id, waived_by_staff_id, waiver_reason, payment_method, notes) VALUES (11, 20, 20, 'Overdue', 10.00, 0.00, SYSDATE-4, NULL, 'Unpaid', 3, NULL, NULL, NULL, '8 days overdue');
INSERT INTO FINES (fine_id, patron_id, loan_id, fine_type, amount_due, amount_paid, date_assessed, payment_date, fine_status, assessed_by_staff_id, waived_by_staff_id, waiver_reason, payment_method, notes) VALUES (12, 3, NULL, 'Lost Item', 30.00, 30.00, SYSDATE-25, SYSDATE-20, 'Paid', 2, NULL, NULL, 'Credit Card', 'DVD lost');
INSERT INTO FINES (fine_id, patron_id, loan_id, fine_type, amount_due, amount_paid, date_assessed, payment_date, fine_status, assessed_by_staff_id, waived_by_staff_id, waiver_reason, payment_method, notes) VALUES (13, 6, NULL, 'Damaged Item', 12.00, 12.00, SYSDATE-18, SYSDATE-15, 'Paid', 3, NULL, NULL, 'Cash', 'Torn pages');
INSERT INTO FINES (fine_id, patron_id, loan_id, fine_type, amount_due, amount_paid, date_assessed, payment_date, fine_status, assessed_by_staff_id, waived_by_staff_id, waiver_reason, payment_method, notes) VALUES (14, 7, NULL, 'Overdue', 6.50, 6.50, SYSDATE-14, SYSDATE-12, 'Paid', 2, NULL, NULL, 'Online', 'Online payment');
INSERT INTO FINES (fine_id, patron_id, loan_id, fine_type, amount_due, amount_paid, date_assessed, payment_date, fine_status, assessed_by_staff_id, waived_by_staff_id, waiver_reason, payment_method, notes) VALUES (15, 9, NULL, 'Processing Fee', 3.00, 0.00, SYSDATE-9, NULL, 'Unpaid', 3, NULL, NULL, NULL, 'Reservation fee');
INSERT INTO FINES (fine_id, patron_id, loan_id, fine_type, amount_due, amount_paid, date_assessed, payment_date, fine_status, assessed_by_staff_id, waived_by_staff_id, waiver_reason, payment_method, notes) VALUES (16, 11, NULL, 'Overdue', 4.75, 4.75, SYSDATE-16, SYSDATE-14, 'Paid', 2, NULL, NULL, 'Cash', 'Paid at desk');
INSERT INTO FINES (fine_id, patron_id, loan_id, fine_type, amount_due, amount_paid, date_assessed, payment_date, fine_status, assessed_by_staff_id, waived_by_staff_id, waiver_reason, payment_method, notes) VALUES (17, 13, NULL, 'Late Fee', 8.00, 8.00, SYSDATE-22, SYSDATE-20, 'Paid', 3, NULL, NULL, 'Credit Card', 'Auto-renewal failed');
INSERT INTO FINES (fine_id, patron_id, loan_id, fine_type, amount_due, amount_paid, date_assessed, payment_date, fine_status, assessed_by_staff_id, waived_by_staff_id, waiver_reason, payment_method, notes) VALUES (18, 15, NULL, 'Overdue', 5.25, 0.00, SYSDATE-11, NULL, 'Unpaid', 2, NULL, NULL, NULL, '5 days overdue');
INSERT INTO FINES (fine_id, patron_id, loan_id, fine_type, amount_due, amount_paid, date_assessed, payment_date, fine_status, assessed_by_staff_id, waived_by_staff_id, waiver_reason, payment_method, notes) VALUES (19, 17, NULL, 'Damaged Item', 20.00, 20.00, SYSDATE-28, SYSDATE-25, 'Paid', 3, NULL, NULL, 'Debit Card', 'Cover damage');
INSERT INTO FINES (fine_id, patron_id, loan_id, fine_type, amount_due, amount_paid, date_assessed, payment_date, fine_status, assessed_by_staff_id, waived_by_staff_id, waiver_reason, payment_method, notes) VALUES (20, 19, 20, 'Overdue', 9.00, 0.00, SYSDATE-6, NULL, 'Unpaid', 2, NULL, NULL, NULL, '9 days overdue');

-- ============================================================================
-- 18. MATERIAL_AUTHORS TABLE
-- ============================================================================
INSERT INTO MATERIAL_AUTHORS (material_id, author_id, author_role, author_sequence) VALUES (1, 1, 'Primary Author', 1);
INSERT INTO MATERIAL_AUTHORS (material_id, author_id, author_role, author_sequence) VALUES (2, 2, 'Primary Author', 1);
INSERT INTO MATERIAL_AUTHORS (material_id, author_id, author_role, author_sequence) VALUES (3, 3, 'Primary Author', 1);
INSERT INTO MATERIAL_AUTHORS (material_id, author_id, author_role, author_sequence) VALUES (4, 4, 'Primary Author', 1);
INSERT INTO MATERIAL_AUTHORS (material_id, author_id, author_role, author_sequence) VALUES (5, 5, 'Primary Author', 1);
INSERT INTO MATERIAL_AUTHORS (material_id, author_id, author_role, author_sequence) VALUES (6, 6, 'Primary Author', 1);
INSERT INTO MATERIAL_AUTHORS (material_id, author_id, author_role, author_sequence) VALUES (7, 7, 'Primary Author', 1);
INSERT INTO MATERIAL_AUTHORS (material_id, author_id, author_role, author_sequence) VALUES (8, 8, 'Primary Author', 1);
INSERT INTO MATERIAL_AUTHORS (material_id, author_id, author_role, author_sequence) VALUES (9, 9, 'Primary Author', 1);
INSERT INTO MATERIAL_AUTHORS (material_id, author_id, author_role, author_sequence) VALUES (10, 10, 'Primary Author', 1);
INSERT INTO MATERIAL_AUTHORS (material_id, author_id, author_role, author_sequence) VALUES (11, 11, 'Primary Author', 1);
INSERT INTO MATERIAL_AUTHORS (material_id, author_id, author_role, author_sequence) VALUES (12, 12, 'Primary Author', 1);
INSERT INTO MATERIAL_AUTHORS (material_id, author_id, author_role, author_sequence) VALUES (13, 13, 'Primary Author', 1);
INSERT INTO MATERIAL_AUTHORS (material_id, author_id, author_role, author_sequence) VALUES (14, 14, 'Primary Author', 1);
INSERT INTO MATERIAL_AUTHORS (material_id, author_id, author_role, author_sequence) VALUES (15, 15, 'Primary Author', 1);
INSERT INTO MATERIAL_AUTHORS (material_id, author_id, author_role, author_sequence) VALUES (16, 16, 'Primary Author', 1);
INSERT INTO MATERIAL_AUTHORS (material_id, author_id, author_role, author_sequence) VALUES (17, 17, 'Primary Author', 1);
INSERT INTO MATERIAL_AUTHORS (material_id, author_id, author_role, author_sequence) VALUES (18, 18, 'Primary Author', 1);
INSERT INTO MATERIAL_AUTHORS (material_id, author_id, author_role, author_sequence) VALUES (19, 19, 'Primary Author', 1);
INSERT INTO MATERIAL_AUTHORS (material_id, author_id, author_role, author_sequence) VALUES (20, 20, 'Primary Author', 1);

-- ============================================================================
-- 19. MATERIAL_GENRES TABLE
-- ============================================================================
INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre) VALUES (1, 7, 'Y');
INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre) VALUES (1, 8, 'N');
INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre) VALUES (2, 5, 'Y');
INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre) VALUES (2, 1, 'N');
INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre) VALUES (3, 5, 'Y');
INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre) VALUES (3, 9, 'N');
INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre) VALUES (4, 3, 'Y');
INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre) VALUES (4, 8, 'N');
INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre) VALUES (5, 5, 'Y');
INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre) VALUES (5, 1, 'N');
INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre) VALUES (6, 6, 'Y');
INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre) VALUES (6, 9, 'N');
INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre) VALUES (7, 1, 'Y');
INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre) VALUES (7, 9, 'N');
INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre) VALUES (8, 1, 'Y');
INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre) VALUES (8, 9, 'N');
INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre) VALUES (9, 4, 'Y');
INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre) VALUES (9, 1, 'N');
INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre) VALUES (10, 4, 'Y');
INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre) VALUES (10, 1, 'N');
INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre) VALUES (11, 4, 'Y');
INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre) VALUES (11, 5, 'N');
INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre) VALUES (12, 8, 'Y');
INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre) VALUES (12, 3, 'N');
INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre) VALUES (13, 8, 'Y');
INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre) VALUES (13, 19, 'N');
INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre) VALUES (14, 8, 'Y');
INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre) VALUES (14, 3, 'N');
INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre) VALUES (15, 6, 'Y');
INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre) VALUES (15, 1, 'N');
INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre) VALUES (16, 7, 'Y');
INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre) VALUES (16, 6, 'N');
INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre) VALUES (17, 4, 'Y');
INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre) VALUES (17, 8, 'N');
INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre) VALUES (18, 5, 'Y');
INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre) VALUES (18, 1, 'N');
INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre) VALUES (19, 4, 'Y');
INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre) VALUES (19, 1, 'N');
INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre) VALUES (20, 5, 'Y');
INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre) VALUES (20, 7, 'N');

COMMIT;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Check counts for each table
SELECT 'LIBRARIES' as table_name, COUNT(*) as row_count FROM LIBRARIES
UNION ALL SELECT 'BRANCHES', COUNT(*) FROM BRANCHES
UNION ALL SELECT 'USERS', COUNT(*) FROM USERS
UNION ALL SELECT 'ROLES', COUNT(*) FROM ROLES
UNION ALL SELECT 'USER_ROLES', COUNT(*) FROM USER_ROLES
UNION ALL SELECT 'PERMISSIONS', COUNT(*) FROM PERMISSIONS
UNION ALL SELECT 'ROLE_PERMISSIONS', COUNT(*) FROM ROLE_PERMISSIONS
UNION ALL SELECT 'PATRONS', COUNT(*) FROM PATRONS
UNION ALL SELECT 'STAFF', COUNT(*) FROM STAFF
UNION ALL SELECT 'PUBLISHERS', COUNT(*) FROM PUBLISHERS
UNION ALL SELECT 'AUTHORS', COUNT(*) FROM AUTHORS
UNION ALL SELECT 'GENRES', COUNT(*) FROM GENRES
UNION ALL SELECT 'MATERIALS', COUNT(*) FROM MATERIALS
UNION ALL SELECT 'COPIES', COUNT(*) FROM COPIES
UNION ALL SELECT 'LOANS', COUNT(*) FROM LOANS
UNION ALL SELECT 'RESERVATIONS', COUNT(*) FROM RESERVATIONS
UNION ALL SELECT 'FINES', COUNT(*) FROM FINES
UNION ALL SELECT 'MATERIAL_AUTHORS', COUNT(*) FROM MATERIAL_AUTHORS
UNION ALL SELECT 'MATERIAL_GENRES', COUNT(*) FROM MATERIAL_GENRES;

DBMS_OUTPUT.PUT_LINE('Sample data insertion completed successfully!');
DBMS_OUTPUT.PUT_LINE('20 rows inserted into each table.');