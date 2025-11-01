-- ============================================================================
-- LIBRARY MANAGEMENT SYSTEM - DATABASE SCHEMA
-- Oracle SQL Developer - Complete Edition with RBAC
-- ============================================================================
-- Description: Complete DDL script with Role-Based Access Control
-- Author: Aymane (Student 2)
-- Date: October 2025
-- ============================================================================
DROP TABLE FINES CASCADE CONSTRAINTS;
DROP TABLE LOANS CASCADE CONSTRAINTS;
DROP TABLE RESERVATIONS CASCADE CONSTRAINTS;
DROP TABLE MATERIAL_GENRES CASCADE CONSTRAINTS;
DROP TABLE MATERIAL_AUTHORS;
DROP TABLE COPIES CASCADE CONSTRAINTS;
DROP TABLE MATERIALS CASCADE CONSTRAINTS;
DROP TABLE GENRES CASCADE CONSTRAINTS;
DROP TABLE AUTHORS;
DROP TABLE PUBLISHERS CASCADE CONSTRAINTS;
DROP TABLE STAFF CASCADE CONSTRAINTS;
DROP TABLE PATRONS CASCADE CONSTRAINTS;
DROP TABLE USERS CASCADE CONSTRAINTS;
DROP TABLE LIBRARIES CASCADE CONSTRAINTS;
DROP TABLE PERMISSIONS CASCADE CONSTRAINTS;
DROP TABLE ROLE_PERMISSIONS CASCADE CONSTRAINTS;
DROP TABLE BRANCHES CASCADE CONSTRAINTS;
DROP TABLE ROLES CASCADE CONSTRAINTS;
DROP TABLE USER_ROLES CASCADE CONSTRAINTS;
-- ============================================================================
-- SECTION 1: AUTHENTICATION & AUTHORIZATION TABLES
-- ============================================================================

-- ============================================================================
-- 1. USERS TABLE - System Authentication
-- ============================================================================
CREATE TABLE USERS (
    user_id NUMBER PRIMARY KEY,                     -- Unique identifier for each user
    username VARCHAR2(50) NOT NULL UNIQUE,          -- Username used for login, must be unique
    email VARCHAR2(100) NOT NULL UNIQUE,            -- Email address, must also be unique
    password_hash VARCHAR2(255) NOT NULL,           -- Securely hashed password (no plain text)
    first_name VARCHAR2(50),                        -- User’s given name
    last_name VARCHAR2(50),                         -- User’s family name
    is_active VARCHAR2(1) DEFAULT 'Y',              -- Indicates if user is active ('Y' or 'N')
    account_locked VARCHAR2(1) DEFAULT 'N',         -- Locks user after too many failed logins
    last_login DATE,                                -- Date of the user’s most recent login
    last_password_change DATE DEFAULT SYSDATE,      -- Last password update (default: creation date)
    created_date DATE DEFAULT SYSDATE NOT NULL,     -- When the account was created
    CONSTRAINT chk_user_active CHECK (is_active IN ('Y', 'N')),  -- Validate active flag
    CONSTRAINT chk_account_locked CHECK (account_locked IN ('Y', 'N'))  -- Validate lock flag
);

-- Add table-level comment
COMMENT ON TABLE USERS IS 'System users for authentication - includes staff, patrons, and administrators';

-- Add column-level comments for better schema documentation
COMMENT ON COLUMN USERS.user_id IS 'Primary key - unique identifier for each system user';
COMMENT ON COLUMN USERS.username IS 'Unique username used for system login';
COMMENT ON COLUMN USERS.email IS 'Unique user email used for contact and password recovery';
COMMENT ON COLUMN USERS.password_hash IS 'Hashed password for authentication - never store plain text';
COMMENT ON COLUMN USERS.is_active IS 'Y = Active user, N = Inactive account';
COMMENT ON COLUMN USERS.account_locked IS 'Y = Locked due to failed attempts, N = Normal access';
COMMENT ON COLUMN USERS.last_login IS 'Timestamp of the last successful login';
COMMENT ON COLUMN USERS.last_password_change IS 'Date when user last changed password';
COMMENT ON COLUMN USERS.created_date IS 'Account creation timestamp';

-- ============================================================================
-- 2. ROLES TABLE - User Role Categories
-- ============================================================================
CREATE TABLE ROLES (
    role_id NUMBER PRIMARY KEY,                     -- Unique role identifier
    role_code VARCHAR2(30) NOT NULL UNIQUE,         -- Short code for internal reference (e.g., ADMIN)
    role_name VARCHAR2(50) NOT NULL,                -- Human-readable role name (e.g., Librarian)
    role_description VARCHAR2(500),                 -- Longer description of role purpose
    is_active VARCHAR2(1) DEFAULT 'Y',              -- Role status flag ('Y' = active)
    created_date DATE DEFAULT SYSDATE,              -- Date of role creation
    CONSTRAINT chk_role_active CHECK (is_active IN ('Y', 'N'))  -- Validate status
);

COMMENT ON TABLE ROLES IS 'System roles defining user categories and access privileges';

COMMENT ON COLUMN ROLES.role_id IS 'Primary key - unique identifier for each role';
COMMENT ON COLUMN ROLES.role_code IS 'Unique code for the role (e.g., ADMIN, LIBR, MEMBER)';
COMMENT ON COLUMN ROLES.role_name IS 'Descriptive name for the role';
COMMENT ON COLUMN ROLES.role_description IS 'Text description explaining the purpose of the role';
COMMENT ON COLUMN ROLES.is_active IS 'Y = Active role, N = Deprecated or inactive role';
COMMENT ON COLUMN ROLES.created_date IS 'Date when the role record was created';

-- ============================================================================
-- 3. PERMISSIONS TABLE - Granular Access Rights
-- ============================================================================
CREATE TABLE PERMISSIONS (
    permission_id NUMBER PRIMARY KEY,               -- Unique permission identifier
    permission_code VARCHAR2(50) NOT NULL UNIQUE,   -- Short internal code (e.g., ADD_BOOK)
    permission_name VARCHAR2(100) NOT NULL,         -- Descriptive name (e.g., Add New Book)
    permission_description VARCHAR2(500),           -- Explanation of what the permission allows
    permission_category VARCHAR2(50) NOT NULL,      -- High-level module (e.g., Circulation, Reports)
    permission_resource VARCHAR2(50),               -- Specific resource (e.g., Book, User)
    action VARCHAR2(30),                            -- CRUD operation (Create, Read, Update, Delete)
    is_active VARCHAR2(1) DEFAULT 'Y',              -- Status flag
    created_date DATE DEFAULT SYSDATE,              -- Record creation date
    CONSTRAINT chk_permission_active CHECK (is_active IN ('Y', 'N')),
    CONSTRAINT chk_permission_category CHECK (permission_category IN 
        ('Circulation', 'Catalog', 'Patrons', 'Reports', 'Administration', 'Fines', 'System'))
);

COMMENT ON TABLE PERMISSIONS IS 'Granular permissions that define which actions users or roles can perform';

COMMENT ON COLUMN PERMISSIONS.permission_id IS 'Primary key - unique identifier for each permission';
COMMENT ON COLUMN PERMISSIONS.permission_code IS 'Unique internal code (e.g., VIEW_REPORTS)';
COMMENT ON COLUMN PERMISSIONS.permission_name IS 'Human-readable name of the permission';
COMMENT ON COLUMN PERMISSIONS.permission_description IS 'Detailed description of what this permission allows';
COMMENT ON COLUMN PERMISSIONS.permission_category IS 'Functional area (Circulation, Catalog, etc.)';
COMMENT ON COLUMN PERMISSIONS.permission_resource IS 'Resource affected by this permission (e.g., Book, Fine)';
COMMENT ON COLUMN PERMISSIONS.action IS 'Action type (Create, Read, Update, Delete)';
COMMENT ON COLUMN PERMISSIONS.is_active IS 'Y = Active permission, N = Disabled or legacy permission';
COMMENT ON COLUMN PERMISSIONS.created_date IS 'Date when this permission was defined';
-- ============================================================================
-- 4. USER_ROLES TABLE - Many-to-Many Junction
-- ============================================================================
CREATE TABLE USER_ROLES (
    user_id NUMBER NOT NULL,                        -- Reference to user
    role_id NUMBER NOT NULL,                        -- Reference to role
    assigned_date DATE DEFAULT SYSDATE NOT NULL,    -- When this role was assigned
    assigned_by_user_id NUMBER,                     -- Who assigned the role
    expiry_date DATE,                               -- Optional expiration of this role
    is_active VARCHAR2(1) DEFAULT 'Y',              -- Active flag for role assignment
    CONSTRAINT pk_user_roles PRIMARY KEY (user_id, role_id), -- Composite key (user+role)
    CONSTRAINT fk_ur_user FOREIGN KEY (user_id) REFERENCES USERS(user_id) ON DELETE CASCADE,  -- Remove roles if user deleted
    CONSTRAINT fk_ur_role FOREIGN KEY (role_id) REFERENCES ROLES(role_id),                   -- Role must exist
    CONSTRAINT fk_ur_assigned_by FOREIGN KEY (assigned_by_user_id) REFERENCES USERS(user_id), -- Self-reference (who assigned)
    CONSTRAINT chk_ur_active CHECK (is_active IN ('Y', 'N'))
);

COMMENT ON TABLE USER_ROLES IS 'Junction table - each user can have multiple roles assigned';

COMMENT ON COLUMN USER_ROLES.user_id IS 'Foreign key referencing USERS(user_id)';
COMMENT ON COLUMN USER_ROLES.role_id IS 'Foreign key referencing ROLES(role_id)';
COMMENT ON COLUMN USER_ROLES.assigned_date IS 'Date when role was assigned to user';
COMMENT ON COLUMN USER_ROLES.assigned_by_user_id IS 'User who assigned this role';
COMMENT ON COLUMN USER_ROLES.expiry_date IS 'Date when this role assignment expires';
COMMENT ON COLUMN USER_ROLES.is_active IS 'Y = Active assignment, N = Revoked or expired';

-- ============================================================================
-- 5. ROLE_PERMISSIONS TABLE - Many-to-Many Junction
-- ============================================================================
CREATE TABLE ROLE_PERMISSIONS (
    role_id NUMBER NOT NULL,                        -- Role to which permission is granted
    permission_id NUMBER NOT NULL,                  -- Permission being granted
    granted_date DATE DEFAULT SYSDATE NOT NULL,     -- When permission was granted
    granted_by_user_id NUMBER,                      -- Who granted the permission
    CONSTRAINT pk_role_permissions PRIMARY KEY (role_id, permission_id), -- Composite key
    CONSTRAINT fk_rp_role FOREIGN KEY (role_id) REFERENCES ROLES(role_id) ON DELETE CASCADE, -- Remove if role deleted
    CONSTRAINT fk_rp_permission FOREIGN KEY (permission_id) REFERENCES PERMISSIONS(permission_id),
    CONSTRAINT fk_rp_granted_by FOREIGN KEY (granted_by_user_id) REFERENCES USERS(user_id)
);

COMMENT ON TABLE ROLE_PERMISSIONS IS 'Junction table linking roles with permissions they are granted';

COMMENT ON COLUMN ROLE_PERMISSIONS.role_id IS 'Foreign key referencing ROLES(role_id)';
COMMENT ON COLUMN ROLE_PERMISSIONS.permission_id IS 'Foreign key referencing PERMISSIONS(permission_id)';
COMMENT ON COLUMN ROLE_PERMISSIONS.granted_date IS 'Date when permission was granted to role';
COMMENT ON COLUMN ROLE_PERMISSIONS.granted_by_user_id IS 'User who assigned this permission';

-- ============================================================================
-- SECTION 2: LIBRARY OPERATIONAL TABLES
-- ============================================================================
/* ======================================================
   20. CREATE TABLE : LIBRARIES
   ====================================================== */
CREATE TABLE LIBRARIES (
    library_id NUMBER PRIMARY KEY,                            -- Unique ID for each library organization
    library_name VARCHAR2(150) NOT NULL UNIQUE,               -- Name of the library system (must be unique)
    established_year NUMBER(4),                               -- Year when the library was founded
    headquarters_address VARCHAR2(200),                       -- Address of the main administrative office
    phone VARCHAR2(20),                                       -- General contact phone number
    email VARCHAR2(100),                                      -- General contact email
    website VARCHAR2(200),                                    -- Official website (optional)
    library_description VARCHAR2(500),                        -- Short description or mission statement
    created_date DATE DEFAULT SYSDATE                         -- Timestamp when the record was created
);
COMMENT ON TABLE LIBRARIES IS 'Parent library organizations that own and manage one or more branches.';

COMMENT ON COLUMN LIBRARIES.library_id IS 'Primary key identifying each library organization.';
COMMENT ON COLUMN LIBRARIES.library_name IS 'Official name of the library system (e.g., "Library X").';
COMMENT ON COLUMN LIBRARIES.established_year IS 'The year when the library organization was established.';
COMMENT ON COLUMN LIBRARIES.headquarters_address IS 'Main office address of the library organization.';
COMMENT ON COLUMN LIBRARIES.phone IS 'Global contact phone number for the organization.';
COMMENT ON COLUMN LIBRARIES.email IS 'Global contact email for the organization.';
COMMENT ON COLUMN LIBRARIES.website IS 'Website URL of the library system.';
COMMENT ON COLUMN LIBRARIES.library_description IS 'Short description or mission statement of the library.';
COMMENT ON COLUMN LIBRARIES.created_date IS 'Record creation timestamp, defaults to current system date.';
-- ============================================================================
-- 6. BRANCHES TABLE - Library Locations
-- ============================================================================
CREATE TABLE BRANCHES (
    branch_id NUMBER PRIMARY KEY,                             -- Unique ID for each physical branch
    library_id NUMBER NOT NULL,                               -- Foreign key referencing the parent library
    branch_name VARCHAR2(100) NOT NULL,                       -- Name of the branch (e.g., "Casablanca Branch")
    address VARCHAR2(200) NOT NULL,                           -- Physical address of the branch
    phone VARCHAR2(20),                                       -- Branch phone number
    email VARCHAR2(100),                                      -- Branch email address
    opening_hours VARCHAR2(100),                              -- Working hours (e.g., "08:00–20:00")
    branch_capacity NUMBER DEFAULT 50,                        -- Number of visitors/books branch can handle
    created_date DATE DEFAULT SYSDATE,                        -- When this branch record was created

    /* ---- CONSTRAINTS ---- */
    CONSTRAINT fk_branch_library FOREIGN KEY (library_id) 
        REFERENCES LIBRARIES(library_id),                     -- Ensures each branch belongs to a valid library

    CONSTRAINT uq_branch_name_per_library UNIQUE (library_id, branch_name), 
        -- Prevents having two branches with the same name under the same library

    CONSTRAINT chk_branch_capacity CHECK (branch_capacity > 0)              -- Ensures branch capacity is a positive number
);

-- 🔹 COMMENTING ON TABLE AND COLUMNS
COMMENT ON TABLE BRANCHES IS 'Physical locations (branches) of each library organization.';

COMMENT ON COLUMN BRANCHES.branch_id IS 'Primary key identifying each library branch.';
COMMENT ON COLUMN BRANCHES.library_id IS 'Foreign key referencing LIBRARIES.library_id.';
COMMENT ON COLUMN BRANCHES.branch_name IS 'Name of the specific branch within the library system.';
COMMENT ON COLUMN BRANCHES.address IS 'Physical street address of the branch.';
COMMENT ON COLUMN BRANCHES.phone IS 'Branch contact phone number.';
COMMENT ON COLUMN BRANCHES.email IS 'Branch contact email address.';
COMMENT ON COLUMN BRANCHES.opening_hours IS 'Branch opening hours (e.g., 08:00–20:00).';
COMMENT ON COLUMN BRANCHES.branch_capacity IS 'Maximum number of visitors/books the branch can handle at once.';
COMMENT ON COLUMN BRANCHES.created_date IS 'Date when the branch record was created.';

-- ============================================================================
-- 8. PATRONS TABLE - Library Members
-- ============================================================================
/*******************************************************************************************
    DESCRIPTION   : Defines the PATRONS table for the Library Management System.
                    This table stores information about all registered users of the library,
                    including members and visitors. Each patron is linked to a branch and may
                    have different membership types, borrowing limits, and account statuses.
*******************************************************************************************/

CREATE TABLE PATRONS (
    patron_id NUMBER PRIMARY KEY,                     -- Unique identifier for each patron (primary key)
    
    card_number VARCHAR2(20) NOT NULL UNIQUE,         -- Library card number or barcode used for identification
    
    first_name VARCHAR2(50) NOT NULL,                 -- Patron's first name (required for identification)
    last_name VARCHAR2(50) NOT NULL,                  -- Patron's last name (required for identification)
    
    email VARCHAR2(100) UNIQUE,                       -- Optional unique email (used for notifications or login)
    phone VARCHAR2(20),                               -- Optional contact phone number
    address VARCHAR2(200),                            -- Home or mailing address of the patron
    
    date_of_birth DATE,                               -- Patron's date of birth (useful for age-based memberships)
    
    membership_type VARCHAR2(20) DEFAULT 'Standard',  -- Defines membership category (e.g., Standard, VIP, Student, etc.)
    
    registration_date DATE DEFAULT SYSDATE NOT NULL,  -- Date when the patron registered (auto-fills with current date)
    membership_expiry DATE NOT NULL,                  -- Expiration date of membership (when privileges end)
    
    registered_branch_id NUMBER NOT NULL,             -- Branch ID where the patron registered
                                                      
    account_status VARCHAR2(20) DEFAULT 'Active',     -- Current account status (Active, Expired, etc.)
    
    total_fines_owed NUMBER(10,2) DEFAULT 0,          -- Total unpaid fines or fees owed by the patron
    
    max_borrow_limit NUMBER DEFAULT 10,               -- Maximum number of books/items patron can borrow at once
    
    /* ==================== CONSTRAINTS ==================== */
    
    CONSTRAINT fk_patron_branch FOREIGN KEY (registered_branch_id) 
        REFERENCES BRANCHES(branch_id),               -- Enforces link between patron and the branch where they are registered

    CONSTRAINT chk_membership_type CHECK (membership_type IN 
        ('Visitor /Guest', 'Standard', 'Adult', 'VIP', 'Premium', 'Child', 'Senior', 'Student', 'Staff')),
        -- Restricts membership_type to predefined categories to maintain consistency
    
    CONSTRAINT chk_account_status CHECK (account_status IN 
        ('Active', 'Expired', 'Suspended', 'Blocked')),
        -- Ensures account_status is valid and prevents invalid text values
    
    CONSTRAINT chk_fines_positive CHECK (total_fines_owed >= 0),
        -- Prevents negative fine values (a patron can owe money, but not have negative balance)
    
    CONSTRAINT chk_borrow_limit CHECK (max_borrow_limit > 0)
        -- Ensures each patron has a valid borrowing limit greater than zero
);

-- ======================================================
--  COMMENTS ON TABLE AND COLUMNS (Oracle-style metadata)
-- ======================================================

COMMENT ON TABLE PATRONS IS 'Registered library patrons (members or visitors) who can borrow or access library resources.';

COMMENT ON COLUMN PATRONS.patron_id IS 'Unique identifier for each patron; serves as the primary key.';
COMMENT ON COLUMN PATRONS.card_number IS 'Unique library card number or barcode assigned to the patron.';
COMMENT ON COLUMN PATRONS.first_name IS 'Patron''s given name (required).';
COMMENT ON COLUMN PATRONS.last_name IS 'Patron''s family name (required).';
COMMENT ON COLUMN PATRONS.email IS 'Unique email address used for account recovery and notifications.';
COMMENT ON COLUMN PATRONS.phone IS 'Optional contact phone number.';
COMMENT ON COLUMN PATRONS.address IS 'Residential or mailing address of the patron.';
COMMENT ON COLUMN PATRONS.date_of_birth IS 'Date of birth of the patron; used for age-specific plans or eligibility.';
COMMENT ON COLUMN PATRONS.membership_type IS 'Membership category (e.g., Visitor/Guest, Standard, Student, VIP, etc.).';
COMMENT ON COLUMN PATRONS.registration_date IS 'Date when the patron registered in the library system.';
COMMENT ON COLUMN PATRONS.membership_expiry IS 'Date when the patron''s membership privileges expire.';
COMMENT ON COLUMN PATRONS.registered_branch_id IS 'Foreign key linking to BRANCHES table indicating the patron''s registration branch.';
COMMENT ON COLUMN PATRONS.account_status IS 'Current state of the account: Active, Expired, Suspended, or Blocked.';
COMMENT ON COLUMN PATRONS.total_fines_owed IS 'Total amount of unpaid fines or fees owed by the patron.';
COMMENT ON COLUMN PATRONS.max_borrow_limit IS 'Maximum number of books or materials a patron can borrow simultaneously.';

-- ============================================================================
-- 9. STAFF TABLE - Library Employees
-- ============================================================================
-- Table: STAFF
-- Description: Stores information about all library employees who manage daily operations.

CREATE TABLE STAFF (
    staff_id NUMBER PRIMARY KEY, -- Unique identifier for each staff member
    employee_number VARCHAR2(20) NOT NULL UNIQUE, -- Internal employee number, must be unique
    first_name VARCHAR2(50) NOT NULL, -- Staff member's first name
    last_name VARCHAR2(50) NOT NULL, -- Staff member's last name
    email VARCHAR2(100) NOT NULL UNIQUE, -- Work email, must be unique
    phone VARCHAR2(20), -- Optional contact phone number
    staff_role VARCHAR2(30) NOT NULL, -- Role or position of the staff in the library (e.g., Librarian, IT Admin)
    branch_id NUMBER NOT NULL, -- Branch where the staff works
    hire_date DATE DEFAULT SYSDATE NOT NULL, -- Hiring date (defaults to current date)
    salary NUMBER(10,2), -- Monthly or yearly salary
    is_active VARCHAR2(1) DEFAULT 'Y', -- Indicates if staff member is currently active (Y/N)

    -- Foreign key to link staff with their assigned branch
    CONSTRAINT fk_staff_branch FOREIGN KEY (branch_id) REFERENCES BRANCHES(branch_id),

    -- Check constraints for data validity
    CONSTRAINT chk_staff_role CHECK (staff_role IN 
        ('Librarian', 'Assistant', 'Manager', 'Cataloger', 'IT Admin', 'Reception', 'Admin')),
    CONSTRAINT chk_is_active CHECK (is_active IN ('Y', 'N')),
    CONSTRAINT chk_salary_positive CHECK (salary > 0)
);

-- Comments to document table and columns
COMMENT ON TABLE STAFF IS 'Library employees who manage operations and services in each branch';
COMMENT ON COLUMN STAFF.staff_id IS 'Primary key identifying each staff member';
COMMENT ON COLUMN STAFF.employee_number IS 'Unique employee number for internal HR tracking';
COMMENT ON COLUMN STAFF.staff_role IS 'Role: Librarian, Assistant, Manager, Cataloger, IT Admin, etc.';
COMMENT ON COLUMN STAFF.is_active IS 'Indicates if staff member is currently active (Y/N)';
COMMENT ON COLUMN STAFF.salary IS 'Monthly or annual salary, must be positive';
COMMENT ON COLUMN STAFF.branch_id IS 'Branch where the staff member works';


-- ============================================================================
-- 10. PUBLISHERS TABLE - Publishing Companies
-- ============================================================================
CREATE TABLE PUBLISHERS (
    publisher_id NUMBER PRIMARY KEY,
    publisher_name VARCHAR2(100) NOT NULL UNIQUE,
    country VARCHAR2(50),
    website VARCHAR2(100),
    contact_email VARCHAR2(100),
    contact_phone VARCHAR2(20)
);

COMMENT ON TABLE PUBLISHERS IS 'Publishing companies that publish materials';

-- ============================================================================
-- 11. AUTHORS TABLE - Material Creators
-- ============================================================================
CREATE TABLE AUTHORS (
    author_id NUMBER PRIMARY KEY,
    first_name VARCHAR2(50),
    last_name VARCHAR2(50) NOT NULL,
    full_name VARCHAR2(150) GENERATED ALWAYS AS (first_name || ' ' || last_name),
    biography CLOB,
    birth_date DATE,
    death_date DATE,
    nationality VARCHAR2(50),
    website VARCHAR2(100)
);

COMMENT ON TABLE AUTHORS IS 'Authors and creators of library materials';

-- ============================================================================
-- 12. GENRES TABLE - Subject Classifications
-- ============================================================================
CREATE TABLE GENRES (
    genre_id NUMBER PRIMARY KEY,
    genre_name VARCHAR2(50) NOT NULL UNIQUE,
    genre_description VARCHAR2(500),
    parent_genre_id NUMBER,
    CONSTRAINT fk_parent_genre FOREIGN KEY (parent_genre_id) REFERENCES GENRES(genre_id)
);

COMMENT ON TABLE GENRES IS 'Subject classifications and genres for materials';

-- ============================================================================
-- 13. MATERIALS TABLE - Library Catalog Items
-- ============================================================================
-- Table: MATERIALS
-- Description: Contains details about all items available in the library catalog, such as books, DVDs, journals, etc.

CREATE TABLE MATERIALS (
    material_id NUMBER PRIMARY KEY, -- Unique ID for each material
    title VARCHAR2(200) NOT NULL, -- Main title of the material
    subtitle VARCHAR2(200), -- Optional subtitle
    material_type VARCHAR2(30) NOT NULL, -- Type of material (Book, DVD, etc.)
    isbn VARCHAR2(20), -- International Standard Book Number
    issn VARCHAR2(20), -- International Standard Serial Number (for journals/magazines)
    publication_year NUMBER(4), -- Year of publication
    publisher_id NUMBER, -- References the publisher of the material
    language VARCHAR2(30) DEFAULT 'English', -- Language of the material
    edition VARCHAR2(50), -- Edition information
    pages NUMBER, -- Number of pages (if applicable)
    description CLOB, -- Detailed description or abstract
    dewey_decimal VARCHAR2(20), -- Classification code (Dewey Decimal System)
    total_copies NUMBER DEFAULT 0, -- Total number of copies available in all branches
    available_copies NUMBER DEFAULT 0, -- Number of copies currently available for borrowing
    date_added DATE DEFAULT SYSDATE NOT NULL, -- Date the item was added to catalog
    is_reference VARCHAR2(1) DEFAULT 'N', -- Indicates if material is reference-only (not borrowable)
    is_new_release VARCHAR2(1) DEFAULT 'N', -- Marks if material is a new release

    -- Relationships
    CONSTRAINT fk_material_publisher FOREIGN KEY (publisher_id) REFERENCES PUBLISHERS(publisher_id),

    -- Check constraints
    CONSTRAINT chk_material_type CHECK (material_type IN 
        ('Book', 'DVD', 'Magazine', 'E-book', 'Audiobook', 'Journal', 'Newspaper', 'CD', 'Game')),
    CONSTRAINT chk_copies_consistent CHECK (available_copies <= total_copies),
    CONSTRAINT chk_copies_positive CHECK (total_copies >= 0 AND available_copies >= 0),
    CONSTRAINT chk_is_reference CHECK (is_reference IN ('Y', 'N')),
    CONSTRAINT chk_is_new_release CHECK (is_new_release IN ('Y', 'N'))
);

COMMENT ON TABLE MATERIALS IS 'Catalog of all library materials including books, DVDs, journals, etc.';
COMMENT ON COLUMN MATERIALS.material_type IS 'Specifies type of material (Book, DVD, etc.)';
COMMENT ON COLUMN MATERIALS.is_reference IS 'Y if item is reference-only (cannot be borrowed)';
COMMENT ON COLUMN MATERIALS.is_new_release IS 'Y if recently published or newly added';
COMMENT ON COLUMN MATERIALS.total_copies IS 'Total number of copies owned by the library';
COMMENT ON COLUMN MATERIALS.available_copies IS 'Number of copies currently available to borrow';


-- ============================================================================
-- 14. COPIES TABLE - Physical/Digital Instances
-- ============================================================================
-- Table: COPIES
-- Description: Represents physical or digital copies of each material, distributed across library branches.
CREATE TABLE COPIES (
    copy_id NUMBER PRIMARY KEY, -- Unique identifier for each copy
    material_id NUMBER NOT NULL, -- Material to which this copy belongs
    barcode VARCHAR2(50) NOT NULL UNIQUE, -- Unique barcode identifier for physical tracking
    branch_id NUMBER NOT NULL, -- Branch where this copy is located
    copy_condition VARCHAR2(20) DEFAULT 'Good', -- Physical condition of the copy
    copy_status VARCHAR2(30) DEFAULT 'Available', -- Availability status
    acquisition_date DATE DEFAULT SYSDATE, -- Date the copy was acquired
    acquisition_price NUMBER(10,2), -- Purchase or acquisition cost
    last_maintenance_date DATE, -- Last date when the copy was maintained or repaired

    -- Foreign keys
    CONSTRAINT fk_copy_material FOREIGN KEY (material_id) REFERENCES MATERIALS(material_id) ON DELETE CASCADE,
    CONSTRAINT fk_copy_branch FOREIGN KEY (branch_id) REFERENCES BRANCHES(branch_id),

    -- Check constraints
    CONSTRAINT chk_copy_condition CHECK (copy_condition IN 
        ('New', 'Excellent', 'Good', 'Fair', 'Poor', 'Damaged')),
    CONSTRAINT chk_copy_status CHECK (copy_status IN 
        ('Available', 'Checked Out', 'Reserved', 'In Transit', 'Lost', 'Damaged', 'Under Repair', 'Withdrawn'))
);

COMMENT ON TABLE COPIES IS 'Physical or digital instances of materials that can be borrowed or referenced';
COMMENT ON COLUMN COPIES.copy_condition IS 'Describes the physical condition of the copy';
COMMENT ON COLUMN COPIES.copy_status IS 'Current availability status of the copy';


-- ============================================================================
-- 15. LOANS TABLE - Borrowing Transactions
-- ============================================================================
-- Table: LOANS
-- Description: Tracks all transactions when a patron borrows or returns a library copy.

CREATE TABLE LOANS (
    loan_id NUMBER PRIMARY KEY, -- Unique ID for each loan transaction
    patron_id NUMBER NOT NULL, -- Patron who borrowed the copy
    copy_id NUMBER NOT NULL, -- Borrowed copy ID
    checkout_date DATE DEFAULT SYSDATE NOT NULL, -- When the copy was checked out
    due_date DATE NOT NULL, -- When the copy is due for return
    return_date DATE, -- Actual return date (if returned)
    renewal_count NUMBER DEFAULT 0, -- Number of times the loan has been renewed
    loan_status VARCHAR2(20) DEFAULT 'Active', -- Current loan status
    staff_id_checkout NUMBER NOT NULL, -- Staff who processed checkout
    staff_id_return NUMBER, -- Staff who processed return (nullable)

    -- Foreign keys
    CONSTRAINT fk_loan_patron FOREIGN KEY (patron_id) REFERENCES PATRONS(patron_id),
    CONSTRAINT fk_loan_copy FOREIGN KEY (copy_id) REFERENCES COPIES(copy_id),
    CONSTRAINT fk_loan_staff_checkout FOREIGN KEY (staff_id_checkout) REFERENCES STAFF(staff_id),
    CONSTRAINT fk_loan_staff_return FOREIGN KEY (staff_id_return) REFERENCES STAFF(staff_id),

    -- Logical constraints
    CONSTRAINT chk_loan_status CHECK (loan_status IN ('Active', 'Returned', 'Overdue', 'Lost')),
    CONSTRAINT chk_renewal_count CHECK (renewal_count >= 0 AND renewal_count <= 5),
    CONSTRAINT chk_dates_logical CHECK (due_date >= checkout_date),
    CONSTRAINT chk_return_logical CHECK (return_date IS NULL OR return_date >= checkout_date)
);

COMMENT ON TABLE LOANS IS 'Records of material borrowing and return transactions';
COMMENT ON COLUMN LOANS.loan_status IS 'Active, Returned, Overdue, or Lost';
COMMENT ON COLUMN LOANS.renewal_count IS 'Number of renewals (max 5)';


-- ============================================================================
-- 16. RESERVATIONS TABLE - Hold Requests
-- ============================================================================
-- Table: RESERVATIONS
-- Description: Manages reservations or hold requests made by patrons for unavailable materials.

CREATE TABLE RESERVATIONS (
    reservation_id NUMBER PRIMARY KEY, -- Unique ID for each reservation
    material_id NUMBER NOT NULL, -- Material being reserved
    patron_id NUMBER NOT NULL, -- Patron who placed the reservation
    reservation_date DATE DEFAULT SYSDATE NOT NULL, -- Date reservation was made
    notification_date DATE, -- When patron was notified that item is available
    pickup_deadline DATE, -- Deadline for patron to pick up reserved item
    reservation_status VARCHAR2(20) DEFAULT 'Pending', -- Current reservation status
    queue_position NUMBER, -- Patron's position in reservation queue
    fulfilled_by_copy_id NUMBER, -- Copy ID assigned to fulfill the reservation
    notes VARCHAR2(500), -- Additional remarks

    -- Relationships
    CONSTRAINT fk_reservation_material FOREIGN KEY (material_id) REFERENCES MATERIALS(material_id),
    CONSTRAINT fk_reservation_patron FOREIGN KEY (patron_id) REFERENCES PATRONS(patron_id),
    CONSTRAINT fk_reservation_copy FOREIGN KEY (fulfilled_by_copy_id) REFERENCES COPIES(copy_id),

    -- Data validation
    CONSTRAINT chk_reservation_status CHECK (reservation_status IN 
        ('Pending', 'Ready', 'Fulfilled', 'Expired', 'Cancelled')),
    CONSTRAINT chk_queue_position CHECK (queue_position > 0)
);

COMMENT ON TABLE RESERVATIONS IS 'Manages patron reservations and hold queues for unavailable materials';
COMMENT ON COLUMN RESERVATIONS.queue_position IS 'Position of the patron in reservation queue';
COMMENT ON COLUMN RESERVATIONS.reservation_status IS 'Reservation progress (Pending, Ready, Fulfilled, etc.)';


-- ============================================================================
-- 17. FINES TABLE - Simplified Penalties
-- ============================================================================
-- Table: FINES
-- Description: Tracks monetary penalties for overdue, lost, or damaged materials.

CREATE TABLE FINES (
    fine_id NUMBER PRIMARY KEY, -- Unique fine ID
    patron_id NUMBER NOT NULL, -- Patron being fined
    loan_id NUMBER, -- Related loan (if applicable)
    fine_type VARCHAR2(30) NOT NULL, -- Type of fine
    amount_due NUMBER(10,2) NOT NULL, -- Total fine amount
    amount_paid NUMBER(10,2) DEFAULT 0, -- Amount paid so far
    date_assessed DATE DEFAULT SYSDATE NOT NULL, -- When fine was assessed
    payment_date DATE, -- Date of payment
    fine_status VARCHAR2(20) DEFAULT 'Unpaid', -- Payment status
    assessed_by_staff_id NUMBER, -- Staff who assessed fine
    waived_by_staff_id NUMBER, -- Staff who waived fine (if any)
    waiver_reason VARCHAR2(500), -- Explanation for waived fines
    payment_method VARCHAR2(30), -- Payment mode
    notes VARCHAR2(500), -- Optional comments or details

    -- Relationships
    CONSTRAINT fk_fine_patron FOREIGN KEY (patron_id) REFERENCES PATRONS(patron_id),
    CONSTRAINT fk_fine_loan FOREIGN KEY (loan_id) REFERENCES LOANS(loan_id),
    CONSTRAINT fk_fine_assessed_by FOREIGN KEY (assessed_by_staff_id) REFERENCES STAFF(staff_id),
    CONSTRAINT fk_fine_waived_by FOREIGN KEY (waived_by_staff_id) REFERENCES STAFF(staff_id),

    -- Data integrity
    CONSTRAINT chk_fine_type CHECK (fine_type IN 
        ('Overdue', 'Lost Item', 'Damaged Item', 'Processing Fee', 'Late Fee', 'Other')),
    CONSTRAINT chk_fine_status CHECK (fine_status IN 
        ('Unpaid', 'Partially Paid', 'Paid', 'Waived', 'Cancelled')),
    CONSTRAINT chk_fine_amounts CHECK (amount_due >= 0 AND amount_paid >= 0 AND amount_paid <= amount_due),
    CONSTRAINT chk_payment_method CHECK (payment_method IS NULL OR payment_method IN 
        ('Cash', 'Credit Card', 'Debit Card', 'Check', 'Online', 'Waived'))
);

COMMENT ON TABLE FINES IS 'Tracks fines and penalties for overdue or damaged materials';
COMMENT ON COLUMN FINES.fine_type IS 'Specifies reason for fine (Overdue, Lost Item, etc.)';
COMMENT ON COLUMN FINES.fine_status IS 'Indicates payment status of fine (Paid, Unpaid, Waived, etc.)';
COMMENT ON COLUMN FINES.amount_due IS 'Total fine assessed to patron';
COMMENT ON COLUMN FINES.amount_paid IS 'Amount already paid by patron';
COMMENT ON COLUMN FINES.payment_method IS 'Mode of payment used by patron';


-- ============================================================================
-- 18. MATERIAL_AUTHORS TABLE - Junction Table (M:N)
-- ============================================================================
CREATE TABLE MATERIAL_AUTHORS (
    material_id NUMBER NOT NULL,
    author_id NUMBER NOT NULL,
    author_role VARCHAR2(30) DEFAULT 'Primary Author',
    author_sequence NUMBER DEFAULT 1,
    CONSTRAINT pk_material_authors PRIMARY KEY (material_id, author_id),
    CONSTRAINT fk_mat_auth_material FOREIGN KEY (material_id) REFERENCES MATERIALS(material_id) ON DELETE CASCADE,
    CONSTRAINT fk_mat_auth_author FOREIGN KEY (author_id) REFERENCES AUTHORS(author_id) ON DELETE CASCADE,
    CONSTRAINT chk_author_role CHECK (author_role IN 
        ('Primary Author', 'Co-Author', 'Contributor', 'Editor', 'Translator', 'Illustrator'))
);

COMMENT ON TABLE MATERIAL_AUTHORS IS 'Junction table linking materials to their authors (M:N relationship)';

-- ============================================================================
-- 19. MATERIAL_GENRES TABLE - Junction Table (M:N)
-- ============================================================================
CREATE TABLE MATERIAL_GENRES (
    material_id NUMBER NOT NULL,
    genre_id NUMBER NOT NULL,
    is_primary_genre VARCHAR2(1) DEFAULT 'N',
    CONSTRAINT pk_material_genres PRIMARY KEY (material_id, genre_id),
    CONSTRAINT fk_mat_gen_material FOREIGN KEY (material_id) REFERENCES MATERIALS(material_id) ON DELETE CASCADE,
    CONSTRAINT fk_mat_gen_genre FOREIGN KEY (genre_id) REFERENCES GENRES(genre_id) ON DELETE CASCADE,
    CONSTRAINT chk_is_primary_genre CHECK (is_primary_genre IN ('Y', 'N'))
);

COMMENT ON TABLE MATERIAL_GENRES IS 'Junction table linking materials to genres (M:N relationship)';

-- ============================================================================
-- END OF SCRIPT
-- ============================================================================