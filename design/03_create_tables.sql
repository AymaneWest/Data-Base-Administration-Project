-- ============================================================================
-- LIBRARY MANAGEMENT SYSTEM - DATABASE SCHEMA
-- Oracle SQL Developer
-- ============================================================================
-- Description: Complete DDL script for public library management system
-- Author: Mohamed Aymane Chahboune
-- Date: 17 October 2025
-- ============================================================================

-- Clean up existing objects (run only if recreating)
DROP TABLE FINES CASCADE CONSTRAINTS;
DROP TABLE LOANS CASCADE CONSTRAINTS;
DROP TABLE RESERVATIONS CASCADE CONSTRAINTS;
DROP TABLE MATERIAL_GENRES CASCADE CONSTRAINTS;
DROP TABLE MATERIAL_AUTHORS CASCADE CONSTRAINTS;
DROP TABLE COPIES CASCADE CONSTRAINTS;
DROP TABLE MATERIALS CASCADE CONSTRAINTS;
DROP TABLE GENRES CASCADE CONSTRAINTS;
DROP TABLE AUTHORS CASCADE CONSTRAINTS;
DROP TABLE PUBLISHERS CASCADE CONSTRAINTS;
DROP TABLE STAFF CASCADE CONSTRAINTS;
DROP TABLE PATRONS CASCADE CONSTRAINTS;
DROP TABLE BRANCHES CASCADE CONSTRAINTS;

-- ============================================================================
-- 1. BRANCH TABLE - Library Locations
-- ============================================================================
CREATE TABLE BRANCHES (
    branch_id NUMBER PRIMARY KEY,
    branch_name VARCHAR2(100) NOT NULL UNIQUE,
    address VARCHAR2(200) NOT NULL,
    phone VARCHAR2(20),
    email VARCHAR2(100),
    opening_hours VARCHAR2(100),
    capacity NUMBER DEFAULT 50,
    created_date DATE DEFAULT SYSDATE,
    CONSTRAINT chk_capacity CHECK (capacity > 0)
);

-- Add comments for documentation
COMMENT ON TABLE BRANCHES IS 'Physical library locations and branches';
COMMENT ON COLUMN BRANCHES.branch_id IS 'Primary key for branch';
COMMENT ON COLUMN BRANCHES.capacity IS 'Maximum number of patrons the branch can accommodate';

-- ============================================================================
-- 2. PATRON TABLE - Library Members
-- ============================================================================
CREATE TABLE PATRONS (
    patron_id NUMBER PRIMARY KEY,
    card_number VARCHAR2(20) NOT NULL UNIQUE,
    first_name VARCHAR2(50) NOT NULL,
    last_name VARCHAR2(50) NOT NULL,
    email VARCHAR2(100) UNIQUE,
    phone VARCHAR2(20),
    address VARCHAR2(200),
    date_of_birth DATE,
    membership_type VARCHAR2(20) DEFAULT 'Adult',
    registration_date DATE DEFAULT SYSDATE NOT NULL,
    membership_expiry DATE NOT NULL,
    registered_branch_id NUMBER NOT NULL,
    account_status VARCHAR2(20) DEFAULT 'Active',
    total_fines_owed NUMBER(10,2) DEFAULT 0,
    max_borrow_limit NUMBER DEFAULT 1,
    CONSTRAINT fk_patron_branch FOREIGN KEY (registered_branch_id) 
        REFERENCES BRANCHES(branch_id),
    CONSTRAINT chk_membership_type CHECK (membership_type IN ('Adult', 'Child', 'Senior', 'Student', 'Staff')),
    CONSTRAINT chk_account_status CHECK (account_status IN ('Active', 'Expired', 'Suspended', 'Blocked')),
    CONSTRAINT chk_fines_positive CHECK (total_fines_owed >= 0),
    CONSTRAINT chk_borrow_limit CHECK (max_borrow_limit >= 0)
);

COMMENT ON TABLE PATRONS IS 'Registered library members who can borrow materials';
COMMENT ON COLUMN PATRONS.card_number IS 'Unique library card barcode number';
COMMENT ON COLUMN PATRONS.membership_type IS 'Type of membership: Adult, Child, Senior, Student, Staff';
COMMENT ON COLUMN PATRONS.account_status IS 'Current status: Active, Expired, Suspended, Blocked';

-- ============================================================================
-- 3. STAFF TABLE - Library Employees
-- ============================================================================
CREATE TABLE STAFF (
    staff_id NUMBER PRIMARY KEY,
    employee_number VARCHAR2(20) NOT NULL UNIQUE,
    first_name VARCHAR2(50) NOT NULL,
    last_name VARCHAR2(50) NOT NULL,
    email VARCHAR2(100) NOT NULL UNIQUE,
    phone VARCHAR2(20),
    role VARCHAR2(30) NOT NULL,
    branch_id NUMBER NOT NULL,
    hire_date DATE DEFAULT SYSDATE NOT NULL,
    salary NUMBER(10,2),
    is_active VARCHAR2(1) DEFAULT 'Y',
    CONSTRAINT fk_staff_branch FOREIGN KEY (branch_id) 
        REFERENCES BRANCHES(branch_id),
    CONSTRAINT chk_staff_role CHECK (role IN ('Librarian', 'Assistant', 'Manager', 'Cataloger', 'IT Admin')),
    CONSTRAINT chk_is_active CHECK (is_active IN ('Y', 'N')),
    CONSTRAINT chk_salary_positive CHECK (salary > 0)
);

COMMENT ON TABLE STAFF IS 'Library employees who manage operations';
COMMENT ON COLUMN STAFF.role IS 'Job role: Librarian, Assistant, Manager, Cataloger, IT Admin';

-- ============================================================================
-- 4. PUBLISHER TABLE - Publishing Companies
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
-- 5. AUTHOR TABLE - Material Creators
-- ============================================================================
CREATE TABLE AUTHORS (
    author_id NUMBER PRIMARY KEY,
    first_name VARCHAR2(50),
    last_name VARCHAR2(50) NOT NULL,
    full_name VARCHAR2(100) GENERATED ALWAYS AS (first_name || ' ' || last_name),
    biography CLOB,
    birth_date DATE,
    death_date DATE,
    nationality VARCHAR2(50),
    website VARCHAR2(100)
);

COMMENT ON TABLE AUTHORS IS 'Authors and creators of library materials';
COMMENT ON COLUMN AUTHORS.full_name IS 'Virtual column combining first and last name';

-- ============================================================================
-- 6. GENRE TABLE - Subject Classifications
-- ============================================================================
CREATE TABLE GENRES (
    genre_id NUMBER PRIMARY KEY,
    genre_name VARCHAR2(50) NOT NULL UNIQUE,
    description VARCHAR2(500),
    parent_genre_id NUMBER,
    CONSTRAINT fk_parent_genre FOREIGN KEY (parent_genre_id) 
        REFERENCES GENRES(genre_id)
);

COMMENT ON TABLE GENRES IS 'Subject classifications and genres for materials';
COMMENT ON COLUMN GENRES.parent_genre_id IS 'For hierarchical genre structure (e.g., Mystery under Fiction)';

-- ============================================================================
-- 7. MATERIAL TABLE - Library Catalog Items
-- ============================================================================
CREATE TABLE MATERIALS (
    material_id NUMBER PRIMARY KEY,
    title VARCHAR2(200) NOT NULL,
    subtitle VARCHAR2(200),
    material_type VARCHAR2(30) NOT NULL,
    isbn VARCHAR2(20),
    issn VARCHAR2(20),
    publication_year NUMBER(4),
    publisher_id NUMBER,
    language VARCHAR2(30) DEFAULT 'English',
    edition VARCHAR2(50),
    pages NUMBER,
    description CLOB,
    dewey_decimal VARCHAR2(20),
    total_copies NUMBER DEFAULT 0,
    available_copies NUMBER DEFAULT 0,
    date_added DATE DEFAULT SYSDATE NOT NULL,
    is_reference VARCHAR2(1) DEFAULT 'N',
    CONSTRAINT fk_material_publisher FOREIGN KEY (publisher_id) 
        REFERENCES PUBLISHERS(publisher_id),
    CONSTRAINT chk_material_type CHECK (material_type IN 
        ('Book', 'DVD', 'Magazine', 'E-book', 'Audiobook', 'Journal', 'Newspaper', 'CD', 'Game')),
    CONSTRAINT chk_copies_consistent CHECK (available_copies <= total_copies),
    CONSTRAINT chk_copies_positive CHECK (total_copies >= 0 AND available_copies >= 0),
    CONSTRAINT chk_is_reference CHECK (is_reference IN ('Y', 'N'))
);

COMMENT ON TABLE MATERIALS IS 'Catalog of all library materials (intellectual works)';
COMMENT ON COLUMN MATERIALS.material_type IS 'Type: Book, DVD, Magazine, E-book, Audiobook, etc.';
COMMENT ON COLUMN MATERIALS.is_reference IS 'Y = Cannot be checked out, N = Can be borrowed';

-- ============================================================================
-- 8. COPY TABLE - Physical/Digital Instances
-- ============================================================================
CREATE TABLE COPIES (
    copy_id NUMBER PRIMARY KEY,
    material_id NUMBER NOT NULL,
    barcode VARCHAR2(50) NOT NULL UNIQUE,
    branch_id NUMBER NOT NULL,
    copy_condition VARCHAR2(20) DEFAULT 'Good',
    copy_status VARCHAR2(30) DEFAULT 'Available',
    acquisition_date DATE DEFAULT SYSDATE,
    acquisition_price NUMBER(10,2),
    last_maintenance_date DATE,
    notes VARCHAR2(500),
    CONSTRAINT fk_copy_material FOREIGN KEY (material_id) 
        REFERENCES MATERIALS(material_id) ON DELETE CASCADE,
    CONSTRAINT fk_copy_branch FOREIGN KEY (branch_id) 
        REFERENCES BRANCHES(branch_id),
    CONSTRAINT chk_copy_condition CHECK (copy_condition IN 
        ('New', 'Excellent', 'Good', 'Fair', 'Poor', 'Damaged')),
    CONSTRAINT chk_copy_status CHECK (copy_status IN 
        ('Available', 'Checked Out', 'Reserved', 'In Transit', 'Lost', 'Damaged', 'Under Repair', 'Withdrawn'))
);

COMMENT ON TABLE COPIES IS 'Physical or digital instances of materials that can be borrowed';
COMMENT ON COLUMN COPIES.copy_status IS 'Current status: Available, Checked Out, Reserved, Lost, etc.';

-- ============================================================================
-- 9. LOAN TABLE - Borrowing Transactions
-- ============================================================================
CREATE TABLE LOANS (
    loan_id NUMBER PRIMARY KEY,
    patron_id NUMBER NOT NULL,
    copy_id NUMBER NOT NULL,
    checkout_date DATE DEFAULT SYSDATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE,
    renewal_count NUMBER DEFAULT 0,
    loan_status VARCHAR2(20) DEFAULT 'Active',
    staff_id_checkout NUMBER NOT NULL,
    staff_id_return NUMBER,
    notes VARCHAR2(500),
    CONSTRAINT fk_loan_patron FOREIGN KEY (patron_id) 
        REFERENCES PATRONS(patron_id),
    CONSTRAINT fk_loan_copy FOREIGN KEY (copy_id) 
        REFERENCES COPIES(copy_id),
    CONSTRAINT fk_loan_staff_checkout FOREIGN KEY (staff_id_checkout) 
        REFERENCES STAFF(staff_id),
    CONSTRAINT fk_loan_staff_return FOREIGN KEY (staff_id_return) 
        REFERENCES STAFF(staff_id),
    CONSTRAINT chk_loan_status CHECK (loan_status IN 
        ('Active', 'Returned', 'Overdue', 'Lost')),
    CONSTRAINT chk_renewal_count CHECK (renewal_count >= 0 AND renewal_count <= 3),
    CONSTRAINT chk_dates_logical CHECK (due_date >= checkout_date),
    CONSTRAINT chk_return_logical CHECK (return_date IS NULL OR return_date >= checkout_date)
);

COMMENT ON TABLE LOANS IS 'Records of material borrowing transactions';
COMMENT ON COLUMN LOANS.staff_id_checkout IS 'Staff member who processed the checkout';
COMMENT ON COLUMN LOANS.staff_id_return IS 'Staff member who processed the return';
COMMENT ON COLUMN LOANS.renewal_count IS 'Number of times this loan has been renewed';

-- ============================================================================
-- 10. RESERVATION TABLE - Hold Requests
-- ============================================================================
CREATE TABLE RESERVATIONS (
    reservation_id NUMBER PRIMARY KEY,
    material_id NUMBER NOT NULL,
    patron_id NUMBER NOT NULL,
    reservation_date DATE DEFAULT SYSDATE NOT NULL,
    notification_date DATE,
    pickup_deadline DATE,
    reservation_status VARCHAR2(20) DEFAULT 'Pending',
    queue_position NUMBER,
    fulfilled_by_copy_id NUMBER,
    notes VARCHAR2(500),
    CONSTRAINT fk_reservation_material FOREIGN KEY (material_id) 
        REFERENCES MATERIALS(material_id),
    CONSTRAINT fk_reservation_patron FOREIGN KEY (patron_id) 
        REFERENCES PATRONS(patron_id),
    CONSTRAINT fk_reservation_copy FOREIGN KEY (fulfilled_by_copy_id) 
        REFERENCES COPIES(copy_id),
    CONSTRAINT chk_reservation_status CHECK (reservation_status IN 
        ('Pending', 'Ready', 'Fulfilled', 'Expired', 'Cancelled')),
    CONSTRAINT chk_queue_position CHECK (queue_position > 0)
);

COMMENT ON TABLE RESERVATIONS IS 'Patron reservations and hold requests for materials';
COMMENT ON COLUMN RESERVATIONS.queue_position IS 'Position in waiting queue for this material';
COMMENT ON COLUMN RESERVATIONS.pickup_deadline IS 'Date by which patron must pick up reserved item';

-- ============================================================================
-- 11. FINE TABLE - Penalties and Charges
-- ============================================================================
CREATE TABLE FINES (
    fine_id NUMBER PRIMARY KEY,
    loan_id NUMBER NOT NULL,
    patron_id NUMBER NOT NULL,
    fine_type VARCHAR2(30) NOT NULL,
    amount_due NUMBER(10,2) NOT NULL,
    amount_paid NUMBER(10,2) DEFAULT 0,
    date_assessed DATE DEFAULT SYSDATE NOT NULL,
    payment_date DATE,
    fine_status VARCHAR2(20) DEFAULT 'Unpaid',
    waived_by_staff_id NUMBER,
    waiver_reason VARCHAR2(500),
    notes VARCHAR2(500),
    CONSTRAINT fk_fine_loan FOREIGN KEY (loan_id) 
        REFERENCES LOANS(loan_id),
    CONSTRAINT fk_fine_patron FOREIGN KEY (patron_id) 
        REFERENCES PATRONS(patron_id),
    CONSTRAINT fk_fine_waived_by FOREIGN KEY (waived_by_staff_id) 
        REFERENCES STAFF(staff_id),
    CONSTRAINT chk_fine_type CHECK (fine_type IN 
        ('Overdue', 'Lost Item', 'Damaged Item', 'Processing Fee', 'Replacement')),
    CONSTRAINT chk_fine_status CHECK (fine_status IN 
        ('Unpaid', 'Partially Paid', 'Paid', 'Waived')),
    CONSTRAINT chk_fine_amounts CHECK (amount_due >= 0 AND amount_paid >= 0 AND amount_paid <= amount_due)
);

COMMENT ON TABLE FINES IS 'Financial penalties for overdue, lost, or damaged items';
COMMENT ON COLUMN FINES.fine_type IS 'Type: Overdue, Lost Item, Damaged Item, Processing Fee, Replacement';

-- ============================================================================
-- 12. MATERIAL_AUTHORS TABLE - Junction Table (M:N)
-- ============================================================================
CREATE TABLE MATERIAL_AUTHORS (
    material_id NUMBER NOT NULL,
    author_id NUMBER NOT NULL,
    author_role VARCHAR2(30) DEFAULT 'Primary Author',
    author_sequence NUMBER DEFAULT 1,
    CONSTRAINT pk_material_authors PRIMARY KEY (material_id, author_id),
    CONSTRAINT fk_mat_auth_material FOREIGN KEY (material_id) 
        REFERENCES MATERIALS(material_id) ON DELETE CASCADE,
    CONSTRAINT fk_mat_auth_author FOREIGN KEY (author_id) 
        REFERENCES AUTHORS(author_id) ON DELETE CASCADE,
    CONSTRAINT chk_author_role CHECK (author_role IN 
        ('Primary Author', 'Co-Author', 'Contributor', 'Editor', 'Translator', 'Illustrator'))
);

COMMENT ON TABLE MATERIAL_AUTHORS IS 'Junction table linking materials to their authors (M:N relationship)';
COMMENT ON COLUMN MATERIAL_AUTHORS.author_role IS 'Role of author: Primary, Co-Author, Contributor, Editor, etc.';
COMMENT ON COLUMN MATERIAL_AUTHORS.author_sequence IS 'Order of authors (1st, 2nd, 3rd)';

-- ============================================================================
-- 13. MATERIAL_GENRES TABLE - Junction Table (M:N)
-- ============================================================================
CREATE TABLE MATERIAL_GENRES (
    material_id NUMBER NOT NULL,
    genre_id NUMBER NOT NULL,
    is_primary_genre VARCHAR2(1) DEFAULT 'N',
    CONSTRAINT pk_material_genres PRIMARY KEY (material_id, genre_id),
    CONSTRAINT fk_mat_gen_material FOREIGN KEY (material_id) 
        REFERENCES MATERIALS(material_id) ON DELETE CASCADE,
    CONSTRAINT fk_mat_gen_genre FOREIGN KEY (genre_id) 
        REFERENCES GENRES(genre_id) ON DELETE CASCADE,
    CONSTRAINT chk_is_primary_genre CHECK (is_primary_genre IN ('Y', 'N'))
);

COMMENT ON TABLE MATERIAL_GENRES IS 'Junction table linking materials to genres (M:N relationship)';
COMMENT ON COLUMN MATERIAL_GENRES.is_primary_genre IS 'Y if this is the primary genre for the material';

-- ============================================================================
-- INDEXES FOR PERFORMANCE OPTIMIZATION
-- ============================================================================

-- Patron indexes
CREATE INDEX idx_patron_card ON PATRONS(card_number);
CREATE INDEX idx_patron_email ON PATRONS(email);
CREATE INDEX idx_patron_status ON PATRONS(account_status);
CREATE INDEX idx_patron_branch ON PATRONS(registered_branch_id);

-- Material indexes
CREATE INDEX idx_material_title ON MATERIALS(UPPER(title));
CREATE INDEX idx_material_type ON MATERIALS(material_type);
CREATE INDEX idx_material_isbn ON MATERIALS(isbn);
CREATE INDEX idx_material_publisher ON MATERIALS(publisher_id);

-- Copy indexes
CREATE INDEX idx_copy_barcode ON COPIES(barcode);
CREATE INDEX idx_copy_material ON COPIES(material_id);
CREATE INDEX idx_copy_branch ON COPIES(branch_id);
CREATE INDEX idx_copy_status ON COPIES(copy_status);

-- Loan indexes
CREATE INDEX idx_loan_patron ON LOANS(patron_id);
CREATE INDEX idx_loan_copy ON LOANS(copy_id);
CREATE INDEX idx_loan_status ON LOANS(loan_status);
CREATE INDEX idx_loan_due_date ON LOANS(due_date);
CREATE INDEX idx_loan_checkout_date ON LOANS(checkout_date);

-- Reservation indexes
CREATE INDEX idx_reservation_material ON RESERVATIONS(material_id);
CREATE INDEX idx_reservation_patron ON RESERVATIONS(patron_id);
CREATE INDEX idx_reservation_status ON RESERVATIONS(reservation_status);
CREATE INDEX idx_reservation_queue ON RESERVATIONS(queue_position);

-- Fine indexes
CREATE INDEX idx_fine_patron ON FINES(patron_id);
CREATE INDEX idx_fine_loan ON FINES(loan_id);
CREATE INDEX idx_fine_status ON FINES(fine_status);

-- Author/Genre indexes
CREATE INDEX idx_author_last_name ON AUTHORS(last_name);
CREATE INDEX idx_genre_name ON GENRES(genre_name);

-- ============================================================================
-- SEQUENCES FOR AUTO-INCREMENT PRIMARY KEYS
-- ============================================================================

CREATE SEQUENCE seq_branch_id START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_patron_id START WITH 1001 INCREMENT BY 1;
CREATE SEQUENCE seq_staff_id START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_publisher_id START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_author_id START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_genre_id START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_material_id START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_copy_id START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_loan_id START WITH 10001 INCREMENT BY 1;
CREATE SEQUENCE seq_reservation_id START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_fine_id START WITH 1 INCREMENT BY 1;


-- ============================================================================
-- SAMPLE DATA INSERT STATEMENTS (Optional - for testing)
-- ============================================================================

-- Insert sample branches
INSERT INTO BRANCHES (branch_id, branch_name, address, phone, email, opening_hours, capacity)
VALUES (seq_branch_id.NEXTVAL, 'Downtown Main Library', '123 Main St, City Center', '555-0101', 'downtown@library.org', 'Mon-Fri: 9AM-8PM, Sat-Sun: 10AM-6PM', 200);

INSERT INTO BRANCHES (branch_id, branch_name, address, phone, email, opening_hours, capacity)
VALUES (seq_branch_id.NEXTVAL, 'Riverside Branch', '456 River Rd, Riverside', '555-0102', 'riverside@library.org', 'Mon-Fri: 10AM-6PM, Sat: 10AM-4PM', 100);

INSERT INTO BRANCHES (branch_id, branch_name, address, phone, email, opening_hours, capacity)
VALUES (seq_branch_id.NEXTVAL, 'Northside Branch', '789 North Ave, Northside', '555-0103', 'northside@library.org', 'Mon-Fri: 10AM-6PM, Sat: 10AM-4PM', 80);

-- Insert sample genres
INSERT INTO GENRES (genre_id, genre_name, description)
VALUES (seq_genre_id.NEXTVAL, 'Fiction', 'Literary works of imaginative narration');

INSERT INTO GENRES (genre_id, genre_name, description)
VALUES (seq_genre_id.NEXTVAL, 'Non-Fiction', 'Factual and informative works');

INSERT INTO GENRES (genre_id, genre_name, description)
VALUES (seq_genre_id.NEXTVAL, 'Mystery', 'Detective and crime fiction');

INSERT INTO GENRES (genre_id, genre_name, description)
VALUES (seq_genre_id.NEXTVAL, 'Science Fiction', 'Speculative fiction based on science and technology');

INSERT INTO GENRES (genre_id, genre_name, description)
VALUES (seq_genre_id.NEXTVAL, 'Biography', 'Life stories of real people');

COMMIT;

-- ============================================================================
-- END OF SCRIPT
-- ============================================================================