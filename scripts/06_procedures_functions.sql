-- ============================================================================
-- LIBRARY MANAGEMENT SYSTEM - COMPLETE PL/SQL PROCEDURES AND FUNCTIONS
-- ============================================================================
-- Author: Abdellah (Student 3) - Complete Edition
-- Date: October 2025
-- Description: All procedures and functions for library operations
-- Version: 3.0 (Complete and Production Ready)
-- ============================================================================

-- ============================================================================
-- SECTION 0: PACKAGE FOR CONSTANTS AND CONFIGURATION
-- ============================================================================

CREATE OR REPLACE PACKAGE pkg_library_config AS
    -- Fine Configuration
    c_DAILY_OVERDUE_FINE CONSTANT NUMBER := 2.00;
    c_MAX_FINE_THRESHOLD CONSTANT NUMBER := 50.00;
    c_MAX_RENEWALS CONSTANT NUMBER := 3;
    
    -- Membership Configuration
    c_MEMBERSHIP_DURATION_MONTHS CONSTANT NUMBER := 12;
    
    -- Loan Duration by Membership Type (in days)
    c_LOAN_PERIOD_VIP CONSTANT NUMBER := 42;
    c_LOAN_PERIOD_PREMIUM CONSTANT NUMBER := 28;
    c_LOAN_PERIOD_CHILD CONSTANT NUMBER := 14;
    c_LOAN_PERIOD_STANDARD CONSTANT NUMBER := 21;
    
    -- Borrow Limits by Membership Type
    c_BORROW_LIMIT_VIP CONSTANT NUMBER := 20;
    c_BORROW_LIMIT_PREMIUM CONSTANT NUMBER := 15;
    c_BORROW_LIMIT_STUDENT CONSTANT NUMBER := 12;
    c_BORROW_LIMIT_CHILD CONSTANT NUMBER := 5;
    c_BORROW_LIMIT_STANDARD CONSTANT NUMBER := 10;
END pkg_library_config;
/

-- ============================================================================
-- SECTION 1: UTILITY FUNCTIONS
-- ============================================================================

-- Function: Check if Patron Exists
CREATE OR REPLACE FUNCTION fn_patron_exists (
    p_patron_id IN NUMBER
) RETURN BOOLEAN IS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM PATRONS WHERE patron_id = p_patron_id;
    RETURN v_count > 0;
EXCEPTION
    WHEN OTHERS THEN RETURN FALSE;
END fn_patron_exists;
/

-- Function: Calculate Loan Period
CREATE OR REPLACE FUNCTION fn_calculate_loan_period (
    p_membership_type IN VARCHAR2
) RETURN NUMBER IS
BEGIN
    RETURN CASE p_membership_type
        WHEN 'VIP' THEN pkg_library_config.c_LOAN_PERIOD_VIP
        WHEN 'Premium' THEN pkg_library_config.c_LOAN_PERIOD_PREMIUM
        WHEN 'Child' THEN pkg_library_config.c_LOAN_PERIOD_CHILD
        ELSE pkg_library_config.c_LOAN_PERIOD_STANDARD
    END;
END fn_calculate_loan_period;
/

-- Function: Calculate Borrow Limit
CREATE OR REPLACE FUNCTION fn_calculate_borrow_limit (
    p_membership_type IN VARCHAR2
) RETURN NUMBER IS
BEGIN
    RETURN CASE p_membership_type
        WHEN 'VIP' THEN pkg_library_config.c_BORROW_LIMIT_VIP
        WHEN 'Premium' THEN pkg_library_config.c_BORROW_LIMIT_PREMIUM
        WHEN 'Student' THEN pkg_library_config.c_BORROW_LIMIT_STUDENT
        WHEN 'Child' THEN pkg_library_config.c_BORROW_LIMIT_CHILD
        ELSE pkg_library_config.c_BORROW_LIMIT_STANDARD
    END;
END fn_calculate_borrow_limit;
/

-- Function: Get Active Loan Count
CREATE OR REPLACE FUNCTION fn_get_active_loan_count (
    p_patron_id IN NUMBER
) RETURN NUMBER IS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM LOANS
    WHERE patron_id = p_patron_id AND loan_status = 'Active';
    RETURN v_count;
EXCEPTION
    WHEN OTHERS THEN RETURN 0;
END fn_get_active_loan_count;
/

-- Function: Calculate Fine Amount
CREATE OR REPLACE FUNCTION fn_calculate_overdue_fine (
    p_due_date IN DATE,  -- le date de routeur prevu 
    p_return_date IN DATE DEFAULT SYSDATE -- la date actuelle
) RETURN NUMBER IS
    v_days_overdue NUMBER;
BEGIN
    v_days_overdue := TRUNC(p_return_date - p_due_date);
    IF v_days_overdue <= 0 THEN
        RETURN 0;
    END IF;
    RETURN v_days_overdue * pkg_library_config.c_DAILY_OVERDUE_FINE;
END fn_calculate_overdue_fine;
/

-- Function: Check Patron Eligibility
CREATE OR REPLACE FUNCTION fn_check_patron_eligibility (
    p_patron_id IN NUMBER,
    p_error_message OUT VARCHAR2
) RETURN BOOLEAN IS
    v_status VARCHAR2(20);
    v_fines_owed NUMBER;
    v_current_loans NUMBER;
    v_max_limit NUMBER;
BEGIN
    IF NOT fn_patron_exists(p_patron_id) THEN
        p_error_message := 'Patron not found';
        RETURN FALSE;
    END IF;
    
    SELECT account_status, total_fines_owed, max_borrow_limit
    INTO v_status, v_fines_owed, v_max_limit
    FROM PATRONS WHERE patron_id = p_patron_id;
    
    IF v_status != 'Active' THEN
        p_error_message := 'Account is not active: ' || v_status;
        RETURN FALSE;
    END IF;
    
    IF v_fines_owed > pkg_library_config.c_MAX_FINE_THRESHOLD THEN
        p_error_message := 'Outstanding fines exceed limit: ' || v_fines_owed || ' DH';
        RETURN FALSE;
    END IF;
    
    v_current_loans := fn_get_active_loan_count(p_patron_id);
    IF v_current_loans >= v_max_limit THEN
        p_error_message := 'Borrow limit reached: ' || v_current_loans || '/' || v_max_limit;
        RETURN FALSE;
    END IF;
    
    p_error_message := 'Eligible';
    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        p_error_message := 'Error: ' || SQLERRM;
        RETURN FALSE;
END fn_check_patron_eligibility;
/

-- ============================================================================
-- SECTION 2: PATRON MANAGEMENT PROCEDURES
-- ============================================================================

CREATE OR REPLACE PROCEDURE sp_add_patron (
    p_card_number IN VARCHAR2,
    p_first_name IN VARCHAR2,
    p_last_name IN VARCHAR2,
    p_email IN VARCHAR2,
    p_phone IN VARCHAR2,
    p_address IN VARCHAR2,
    p_date_of_birth IN DATE,
    p_membership_type IN VARCHAR2,
    p_branch_id IN NUMBER,
    p_new_patron_id OUT NUMBER
) AS
    v_membership_expiry DATE; -- stoker date dexperation dun patron
    v_max_borrow_limit NUMBER; -- stocke le nombre maximum de livres que ce patron peut emprunter
BEGIN
    v_membership_expiry := ADD_MONTHS(SYSDATE, pkg_library_config.c_MEMBERSHIP_DURATION_MONTHS);
    v_max_borrow_limit := fn_calculate_borrow_limit(p_membership_type);
    
    INSERT INTO PATRONS (
        patron_id, card_number, first_name, last_name, email, phone, 
        address, date_of_birth, membership_type, registration_date,
        membership_expiry, registered_branch_id, account_status,
        total_fines_owed, max_borrow_limit
    ) VALUES (
        seq_patron_id.NEXTVAL, p_card_number, p_first_name, p_last_name,
        p_email, p_phone, p_address, p_date_of_birth, p_membership_type,
        SYSDATE, v_membership_expiry, p_branch_id, 'Active', 0, v_max_borrow_limit
    ) RETURNING patron_id INTO p_new_patron_id;
    
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('✅ Patron created successfully. ID: ' || p_new_patron_id);
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20101, 'Card number or email already exists');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20102, 'Error creating patron: ' || SQLERRM);
END sp_add_patron;
/

CREATE OR REPLACE PROCEDURE sp_update_patron (
    p_patron_id IN NUMBER,
    p_email IN VARCHAR2 DEFAULT NULL,
    p_phone IN VARCHAR2 DEFAULT NULL,
    p_address IN VARCHAR2 DEFAULT NULL
) AS
BEGIN
    IF NOT fn_patron_exists(p_patron_id) THEN
        RAISE_APPLICATION_ERROR(-20103, 'Patron not found');
    END IF;
    
    UPDATE PATRONS
    SET email = NVL(p_email, email),
        phone = NVL(p_phone, phone),
        address = NVL(p_address, address)
    WHERE patron_id = p_patron_id;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('✅ Patron updated successfully');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20104, 'Error: ' || SQLERRM);
END sp_update_patron;
/
 
 -- renouvellemet d'abonnemet
CREATE OR REPLACE PROCEDURE sp_renew_membership (
    p_patron_id IN NUMBER,
    p_new_expiry_date OUT DATE
) AS
    v_current_expiry DATE;
    v_account_status VARCHAR2(20);
    v_fines_owed NUMBER;
BEGIN
    SELECT membership_expiry, account_status, total_fines_owed
    INTO v_current_expiry, v_account_status, v_fines_owed
    FROM PATRONS WHERE patron_id = p_patron_id;
    
    IF v_account_status = 'Blocked' THEN
        RAISE_APPLICATION_ERROR(-20105, 'Account is blocked');
    END IF;
    
    IF v_fines_owed > 0 THEN
        RAISE_APPLICATION_ERROR(-20106, 'Outstanding fines must be paid: ' || v_fines_owed || ' DH');
    END IF;
    
    IF v_current_expiry > SYSDATE THEN
        p_new_expiry_date := ADD_MONTHS(v_current_expiry, 12);
    ELSE
        p_new_expiry_date := ADD_MONTHS(SYSDATE, 12);
    END IF;
    
    UPDATE PATRONS
    SET membership_expiry = p_new_expiry_date, account_status = 'Active'
    WHERE patron_id = p_patron_id;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('✅ Membership renewed until: ' || TO_CHAR(p_new_expiry_date, 'DD-MON-YYYY'));
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20107, 'Patron not found');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20108, 'Error: ' || SQLERRM);
END sp_renew_membership;
/

CREATE OR REPLACE PROCEDURE sp_suspend_patron (
    p_patron_id IN NUMBER,
    p_reason IN VARCHAR2,
    p_staff_id IN NUMBER
) AS
    v_current_status VARCHAR2(20);
BEGIN
    SELECT account_status INTO v_current_status
    FROM PATRONS WHERE patron_id = p_patron_id;
    
    IF v_current_status IN ('Blocked', 'Suspended') THEN
        RAISE_APPLICATION_ERROR(-20109, 'Account already ' || v_current_status);
    END IF;
    
    UPDATE PATRONS SET account_status = 'Suspended' WHERE patron_id = p_patron_id;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('✅ Patron suspended. Reason: ' || p_reason);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20110, 'Patron not found');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20111, 'Error: ' || SQLERRM);
END sp_suspend_patron;
/

CREATE OR REPLACE PROCEDURE sp_reactivate_patron (
    p_patron_id IN NUMBER,
    p_staff_id IN NUMBER
) AS
    v_current_status VARCHAR2(20);
    v_fines_owed NUMBER;
BEGIN
    SELECT account_status, total_fines_owed
    INTO v_current_status, v_fines_owed
    FROM PATRONS WHERE patron_id = p_patron_id;
    
    IF v_current_status = 'Active' THEN
        RAISE_APPLICATION_ERROR(-20112, 'Account already active');
    END IF;
    
    IF v_fines_owed > 0 THEN
        RAISE_APPLICATION_ERROR(-20113, 'Outstanding fines must be paid: ' || v_fines_owed || ' DH');
    END IF;
    
    UPDATE PATRONS SET account_status = 'Active' WHERE patron_id = p_patron_id;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('✅ Patron reactivated by staff ID: ' || p_staff_id);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20114, 'Patron not found');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20115, 'Error: ' || SQLERRM);
END sp_reactivate_patron;
/

-- ============================================================================
-- SECTION 3: CIRCULATION PROCEDURES
-- ============================================================================

CREATE OR REPLACE PROCEDURE sp_checkout_item (
    p_patron_id IN NUMBER,
    p_copy_id IN NUMBER,
    p_staff_id IN NUMBER,
    p_loan_id OUT NUMBER
) AS
    v_eligibility_error VARCHAR2(500);
    v_copy_status VARCHAR2(30);
    v_material_id NUMBER;
    v_due_date DATE;
    v_membership_type VARCHAR2(20);
BEGIN
    IF NOT fn_check_patron_eligibility(p_patron_id, v_eligibility_error) THEN
        RAISE_APPLICATION_ERROR(-20201, v_eligibility_error);
    END IF;
    
    SELECT copy_status, material_id INTO v_copy_status, v_material_id
    FROM COPIES WHERE copy_id = p_copy_id;
    
    IF v_copy_status != 'Available' THEN
        RAISE_APPLICATION_ERROR(-20202, 'Copy not available: ' || v_copy_status);
    END IF;
    
    SELECT membership_type INTO v_membership_type
    FROM PATRONS WHERE patron_id = p_patron_id;
    
    v_due_date := SYSDATE + fn_calculate_loan_period(v_membership_type);
    
    INSERT INTO LOANS (
        loan_id, patron_id, copy_id, checkout_date, due_date,
        return_date, renewal_count, loan_status, staff_id_checkout
    ) VALUES (
        seq_loan_id.NEXTVAL, p_patron_id, p_copy_id, SYSDATE, v_due_date,
        NULL, 0, 'Active', p_staff_id
    ) RETURNING loan_id INTO p_loan_id;
    
    UPDATE COPIES SET copy_status = 'Checked Out' WHERE copy_id = p_copy_id;
    UPDATE MATERIALS SET available_copies = available_copies - 1 WHERE material_id = v_material_id;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('✅ Checkout successful. Loan ID: ' || p_loan_id || ', Due: ' || TO_CHAR(v_due_date, 'DD-MON-YYYY'));
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20203, 'Checkout error: ' || SQLERRM);
END sp_checkout_item;
/

CREATE OR REPLACE PROCEDURE sp_checkin_item (
    p_loan_id IN NUMBER,
    p_staff_id IN NUMBER,
    p_fine_assessed OUT NUMBER
) AS
    v_due_date DATE;
    v_patron_id NUMBER;
    v_copy_id NUMBER;
    v_material_id NUMBER;
    v_fine_amount NUMBER := 0;
BEGIN
    SELECT due_date, patron_id, copy_id INTO v_due_date, v_patron_id, v_copy_id
    FROM LOANS WHERE loan_id = p_loan_id AND loan_status = 'Active';
    
    SELECT material_id INTO v_material_id FROM COPIES WHERE copy_id = v_copy_id;
    
    v_fine_amount := fn_calculate_overdue_fine(v_due_date, SYSDATE);
    
    IF v_fine_amount > 0 THEN
        INSERT INTO FINES (
            fine_id, patron_id, loan_id, fine_type, amount_due,
            amount_paid, date_assessed, fine_status, assessed_by_staff_id
        ) VALUES (
            seq_fine_id.NEXTVAL, v_patron_id, p_loan_id, 'Overdue',
            v_fine_amount, 0, SYSDATE, 'Unpaid', p_staff_id
        );
        
        UPDATE PATRONS SET total_fines_owed = total_fines_owed + v_fine_amount
        WHERE patron_id = v_patron_id;
    END IF;
    
    UPDATE LOANS SET return_date = SYSDATE, loan_status = 'Returned', staff_id_return = p_staff_id
    WHERE loan_id = p_loan_id;
    
    UPDATE COPIES SET copy_status = 'Available' WHERE copy_id = v_copy_id;
    UPDATE MATERIALS SET available_copies = available_copies + 1 WHERE material_id = v_material_id;
    
    p_fine_assessed := v_fine_amount;
    
    COMMIT;
    
    IF v_fine_amount > 0 THEN
        DBMS_OUTPUT.PUT_LINE('✅ Returned. Fine: ' || v_fine_amount || ' DH');
    ELSE
        DBMS_OUTPUT.PUT_LINE('✅ Returned on time');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20207, 'Active loan not found');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20208, 'Checkin error: ' || SQLERRM);
END sp_checkin_item;
/

CREATE OR REPLACE PROCEDURE sp_renew_loan (
    p_loan_id IN NUMBER,
    p_new_due_date OUT DATE
) AS
    v_renewal_count NUMBER;
    v_patron_id NUMBER;
    v_copy_id NUMBER;
    v_material_id NUMBER;
    v_reservation_count NUMBER;
    v_fines_owed NUMBER;
BEGIN
    SELECT renewal_count, patron_id, copy_id
    INTO v_renewal_count, v_patron_id, v_copy_id
    FROM LOANS WHERE loan_id = p_loan_id AND loan_status = 'Active';
    
    IF v_renewal_count >= pkg_library_config.c_MAX_RENEWALS THEN
        RAISE_APPLICATION_ERROR(-20209, 'Max renewals reached (3)');
    END IF;
    
    SELECT total_fines_owed INTO v_fines_owed FROM PATRONS WHERE patron_id = v_patron_id;
    
    IF v_fines_owed > 0 THEN
        RAISE_APPLICATION_ERROR(-20210, 'Outstanding fines: ' || v_fines_owed || ' DH');
    END IF;
    
    SELECT material_id INTO v_material_id FROM COPIES WHERE copy_id = v_copy_id;
    
    SELECT COUNT(*) INTO v_reservation_count
    FROM RESERVATIONS
    WHERE material_id = v_material_id 
      AND reservation_status = 'Pending'
      AND patron_id != v_patron_id;
    
    IF v_reservation_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20211, 'Item reserved by another patron');
    END IF;
    
    p_new_due_date := SYSDATE + 15 ;
    UPDATE LOANS SET due_date = p_new_due_date, renewal_count = renewal_count + 1
    WHERE loan_id = p_loan_id;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('✅ Loan renewed. New due date: ' || TO_CHAR(p_new_due_date, 'DD-MON-YYYY'));
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20212, 'Active loan not found');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20213, 'Renewal error: ' || SQLERRM);
END sp_renew_loan;
/

CREATE OR REPLACE PROCEDURE sp_declare_item_lost (
    p_loan_id IN NUMBER,
    p_staff_id IN NUMBER,
    p_replacement_cost IN NUMBER
) AS
    v_patron_id NUMBER;
    v_copy_id NUMBER;
    v_material_id NUMBER;
BEGIN
    SELECT patron_id, copy_id INTO v_patron_id, v_copy_id
    FROM LOANS WHERE loan_id = p_loan_id AND loan_status = 'Active';
    
    SELECT material_id INTO v_material_id FROM COPIES WHERE copy_id = v_copy_id;
    
    UPDATE LOANS SET loan_status = 'Lost', return_date = SYSDATE, staff_id_return = p_staff_id
    WHERE loan_id = p_loan_id;
    
    UPDATE COPIES SET copy_status = 'Lost' WHERE copy_id = v_copy_id;
    UPDATE MATERIALS SET total_copies = total_copies - 1 WHERE material_id = v_material_id;
    
    INSERT INTO FINES (
        fine_id, patron_id, loan_id, fine_type, amount_due,
        amount_paid, date_assessed, fine_status, assessed_by_staff_id
    ) VALUES (
        seq_fine_id.NEXTVAL, v_patron_id, p_loan_id, 'Lost Item',
        p_replacement_cost, 0, SYSDATE, 'Unpaid', p_staff_id
    );
    
    UPDATE PATRONS SET total_fines_owed = total_fines_owed + p_replacement_cost
    WHERE patron_id = v_patron_id;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('✅ Item declared lost. Fine: ' || p_replacement_cost || ' DH');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20214, 'Active loan not found');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20215, 'Error: ' || SQLERRM);
END sp_declare_item_lost;
/

-- ============================================================================
-- SECTION 4: MATERIAL MANAGEMENT PROCEDURES
-- ============================================================================

CREATE OR REPLACE PROCEDURE sp_add_material (
    p_title IN VARCHAR2,
    p_subtitle IN VARCHAR2,
    p_material_type IN VARCHAR2,
    p_isbn IN VARCHAR2,
    p_publication_year IN NUMBER,
    p_publisher_id IN NUMBER,
    p_language IN VARCHAR2,
    p_pages IN NUMBER,
    p_description IN CLOB,
    p_total_copies IN NUMBER,
    p_new_material_id OUT NUMBER
) AS
BEGIN
    IF p_material_type NOT IN ('Book', 'DVD', 'Magazine', 'E-book', 'Audiobook', 
                                'Journal', 'Newspaper', 'CD', 'Game') THEN
        RAISE_APPLICATION_ERROR(-20301, 'Invalid material type');
    END IF;
    
    INSERT INTO MATERIALS (
        material_id, title, subtitle, material_type, isbn,
        publication_year, publisher_id, language, pages, description,
        total_copies, available_copies, date_added, is_reference, is_new_release
    ) VALUES (
        seq_material_id.NEXTVAL, p_title, p_subtitle, p_material_type, p_isbn,
        p_publication_year, p_publisher_id, NVL(p_language, 'English'), p_pages,
        p_description, p_total_copies, p_total_copies, SYSDATE, 'N', 'Y'
    ) RETURNING material_id INTO p_new_material_id;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('✅ Material added. ID: ' || p_new_material_id);
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20302, 'ISBN already exists');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20303, 'Error: ' || SQLERRM);
END sp_add_material;
/

CREATE OR REPLACE PROCEDURE sp_add_copy (
    p_material_id IN NUMBER,
    p_barcode IN VARCHAR2,
    p_branch_id IN NUMBER,
    p_acquisition_price IN NUMBER,
    p_new_copy_id OUT NUMBER
) AS
    v_material_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_material_count
    FROM MATERIALS WHERE material_id = p_material_id;
    
    IF v_material_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20304, 'Material not found');
    END IF;
    
    INSERT INTO COPIES (
        copy_id, material_id, barcode, branch_id, copy_condition,
        copy_status, acquisition_date, acquisition_price
    ) VALUES (
        seq_copy_id.NEXTVAL, p_material_id, p_barcode, p_branch_id,
        'New', 'Available', SYSDATE, p_acquisition_price
    ) RETURNING copy_id INTO p_new_copy_id;
    
    UPDATE MATERIALS
    SET total_copies = total_copies + 1, available_copies = available_copies + 1
    WHERE material_id = p_material_id;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('✅ Copy added. ID: ' || p_new_copy_id);
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20305, 'Barcode already exists');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20306, 'Error: ' || SQLERRM);
END sp_add_copy;
/

CREATE OR REPLACE PROCEDURE sp_update_material (
    p_material_id IN NUMBER,
    p_title IN VARCHAR2 DEFAULT NULL,
    p_description IN CLOB DEFAULT NULL,
    p_language IN VARCHAR2 DEFAULT NULL
) AS
    v_material_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_material_count
    FROM MATERIALS WHERE material_id = p_material_id;
    
    IF v_material_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20307, 'Material not found');
    END IF;
    
    UPDATE MATERIALS
    SET title = NVL(p_title, title),
        description = NVL(p_description, description),
        language = NVL(p_language, language)
    WHERE material_id = p_material_id;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('✅ Material updated');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20308, 'Error: ' || SQLERRM);
END sp_update_material;
/

CREATE OR REPLACE PROCEDURE sp_delete_material (
    p_material_id IN NUMBER,
    p_staff_id IN NUMBER
) AS
    v_active_loans NUMBER;
    v_available_copies NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_active_loans
    FROM LOANS l
    JOIN COPIES c ON l.copy_id = c.copy_id
    WHERE c.material_id = p_material_id AND l.loan_status = 'Active';
    
    IF v_active_loans > 0 THEN
        RAISE_APPLICATION_ERROR(-20309, 'Cannot delete: ' || v_active_loans || ' active loan(s)');
    END IF;
    
    DELETE FROM MATERIAL_GENRES WHERE material_id = p_material_id;
    DELETE FROM MATERIAL_AUTHORS WHERE material_id = p_material_id;
    DELETE FROM COPIES WHERE material_id = p_material_id;
    DELETE FROM MATERIALS WHERE material_id = p_material_id;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('✅ Material deleted');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20310, 'Error: ' || SQLERRM);
END sp_delete_material;
/

-- ============================================================================
-- SECTION 5: RESERVATION PROCEDURES
-- ============================================================================

CREATE OR REPLACE PROCEDURE sp_place_reservation (
    p_material_id IN NUMBER,
    p_patron_id IN NUMBER,
    p_reservation_id OUT NUMBER
) AS
    v_available_copies NUMBER;
    v_queue_position NUMBER; -- position dans la file d’attente pour un élément réservé.
    v_patron_status VARCHAR2(20);
BEGIN
    SELECT account_status INTO v_patron_status
    FROM PATRONS WHERE patron_id = p_patron_id;
    
    IF v_patron_status != 'Active' THEN
        RAISE_APPLICATION_ERROR(-20401, 'Account not active');
    END IF;
    
    SELECT available_copies INTO v_available_copies
    FROM MATERIALS WHERE material_id = p_material_id;
    
    IF v_available_copies > 0 THEN
        RAISE_APPLICATION_ERROR(-20402, 'Material available - checkout directly');
    END IF;
    
    SELECT NVL(MAX(queue_position), 0) + 1 INTO v_queue_position 
    FROM RESERVATIONS
    WHERE material_id = p_material_id AND reservation_status = 'Pending';
    
    INSERT INTO RESERVATIONS (
        reservation_id, material_id, patron_id, reservation_date,
        reservation_status, queue_position
    ) VALUES (
        seq_reservation_id.NEXTVAL, p_material_id, p_patron_id, SYSDATE,
        'Pending', v_queue_position
    ) RETURNING reservation_id INTO p_reservation_id;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('✅ Reservation placed. Queue position: ' || v_queue_position);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20403, 'Material or patron not found');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20404, 'Error: ' || SQLERRM);
END sp_place_reservation;
/

CREATE OR REPLACE PROCEDURE sp_cancel_reservation (
    p_reservation_id IN NUMBER,
    p_patron_id IN NUMBER
) AS
    v_reservation_status VARCHAR2(20);
    v_reservation_patron_id NUMBER;
    v_material_id NUMBER;
    v_queue_position NUMBER;
BEGIN
    SELECT reservation_status, patron_id, material_id, queue_position
    INTO v_reservation_status, v_reservation_patron_id, v_material_id, v_queue_position
    FROM RESERVATIONS WHERE reservation_id = p_reservation_id;
    
    IF v_reservation_patron_id != p_patron_id THEN
        RAISE_APPLICATION_ERROR(-20405, 'Reservation belongs to another patron');
    END IF;
    
    IF v_reservation_status NOT IN ('Pending', 'Ready') THEN
        RAISE_APPLICATION_ERROR(-20406, 'Cannot cancel: ' || v_reservation_status);
    END IF;
    
    UPDATE RESERVATIONS SET reservation_status = 'Cancelled'
    WHERE reservation_id = p_reservation_id;
    
    UPDATE RESERVATIONS
    SET queue_position = queue_position - 1
    WHERE material_id = v_material_id 
      AND queue_position > v_queue_position
      AND reservation_status = 'Pending';
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('✅ Reservation cancelled');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20407, 'Reservation not found');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20408, 'Error: ' || SQLERRM);
END sp_cancel_reservation;
/

CREATE OR REPLACE PROCEDURE sp_fulfill_reservation (
    p_reservation_id IN NUMBER,
    p_copy_id IN NUMBER,
    p_staff_id IN NUMBER
) AS
    v_material_id NUMBER;
    v_copy_material_id NUMBER;
    v_reservation_status VARCHAR2(20);
BEGIN
    SELECT material_id, reservation_status
    INTO v_material_id, v_reservation_status
    FROM RESERVATIONS WHERE reservation_id = p_reservation_id;
    
    IF v_reservation_status != 'Pending' THEN
        RAISE_APPLICATION_ERROR(-20409, 'Reservation not pending');
    END IF;
    
    SELECT material_id INTO v_copy_material_id
    FROM COPIES WHERE copy_id = p_copy_id;
    
    IF v_material_id != v_copy_material_id THEN
        RAISE_APPLICATION_ERROR(-20410, 'Copy does not match reserved material');
    END IF;
    
    UPDATE RESERVATIONS
    SET reservation_status = 'Ready',
        fulfilled_by_copy_id = p_copy_id,
        notification_date = SYSDATE,
        pickup_deadline = SYSDATE + 3
    WHERE reservation_id = p_reservation_id;
    
    UPDATE COPIES SET copy_status = 'Reserved' WHERE copy_id = p_copy_id;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('✅ Reservation fulfilled. Pickup deadline: ' || TO_CHAR(SYSDATE + 3, 'DD-MON-YYYY'));
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20411, 'Reservation or copy not found');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20412, 'Error: ' || SQLERRM);
END sp_fulfill_reservation;
/

-- ============================================================================
-- SECTION 6: FINE MANAGEMENT PROCEDURES
-- ============================================================================

CREATE OR REPLACE PROCEDURE sp_pay_fine (
    p_fine_id IN NUMBER,
    p_payment_amount IN NUMBER,
    p_payment_method IN VARCHAR2,
    p_staff_id IN NUMBER
) AS
    v_amount_due NUMBER;
    v_amount_paid NUMBER;
    v_patron_id NUMBER;
    v_remaining_balance NUMBER;
BEGIN
    SELECT amount_due, amount_paid, patron_id
    INTO v_amount_due, v_amount_paid, v_patron_id
    FROM FINES WHERE fine_id = p_fine_id;
    
    v_remaining_balance := v_amount_due - v_amount_paid;
    
    IF p_payment_amount <= 0 THEN
        RAISE_APPLICATION_ERROR(-20501, 'Payment must be positive');
    END IF;
    
    IF p_payment_amount > v_remaining_balance THEN
        RAISE_APPLICATION_ERROR(-20502, 'Payment exceeds balance: ' || v_remaining_balance || ' DH');
    END IF;
    
    UPDATE FINES
    SET amount_paid = amount_paid + p_payment_amount,
        payment_method = p_payment_method,
        fine_status = CASE 
            WHEN (amount_paid + p_payment_amount) >= amount_due THEN 'Paid'
            ELSE 'Partially Paid'
        END,
        payment_date = CASE 
            WHEN (amount_paid + p_payment_amount) >= amount_due THEN SYSDATE
            ELSE payment_date
        END
    WHERE fine_id = p_fine_id;
    
    UPDATE PATRONS
    SET total_fines_owed = GREATEST(0, total_fines_owed - p_payment_amount)
    WHERE patron_id = v_patron_id;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('✅ Payment processed: ' || p_payment_amount || ' DH. Remaining: ' || 
        TO_CHAR(v_remaining_balance - p_payment_amount, '999.99') || ' DH');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20503, 'Fine not found');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20504, 'Error: ' || SQLERRM);
END sp_pay_fine;
/

CREATE OR REPLACE PROCEDURE sp_waive_fine (
    p_fine_id IN NUMBER,
    p_waiver_reason IN VARCHAR2,
    p_staff_id IN NUMBER
) AS
    v_amount_due NUMBER;
    v_amount_paid NUMBER;
    v_patron_id NUMBER;
    v_waived_amount NUMBER;
BEGIN
    IF LENGTH(TRIM(p_waiver_reason)) < 10 THEN
        RAISE_APPLICATION_ERROR(-20505, 'Waiver reason must be at least 10 characters');
    END IF;
    
    SELECT amount_due, amount_paid, patron_id
    INTO v_amount_due, v_amount_paid, v_patron_id
    FROM FINES WHERE fine_id = p_fine_id;
    
    v_waived_amount := v_amount_due - v_amount_paid;
    
    IF v_waived_amount <= 0 THEN
        RAISE_APPLICATION_ERROR(-20506, 'Fine already paid');
    END IF;
    
    UPDATE FINES
    SET fine_status = 'Waived',
        waived_by_staff_id = p_staff_id,
        waiver_reason = p_waiver_reason,
        payment_date = SYSDATE
    WHERE fine_id = p_fine_id;
    
    UPDATE PATRONS
    SET total_fines_owed = GREATEST(0, total_fines_owed - v_waived_amount)
    WHERE patron_id = v_patron_id;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('✅ Fine waived: ' || v_waived_amount || ' DH. Reason: ' || p_waiver_reason);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20507, 'Fine not found');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20508, 'Error: ' || SQLERRM);
END sp_waive_fine;
/

CREATE OR REPLACE PROCEDURE sp_assess_fine (
    p_patron_id IN NUMBER,
    p_loan_id IN NUMBER DEFAULT NULL,
    p_fine_type IN VARCHAR2,
    p_amount IN NUMBER,
    p_staff_id IN NUMBER,
    p_fine_id OUT NUMBER
) AS
BEGIN
    IF p_amount <= 0 THEN
        RAISE_APPLICATION_ERROR(-20509, 'Fine amount must be positive');
    END IF;
    
    IF p_fine_type NOT IN ('Overdue', 'Lost Item', 'Damaged Item', 'Processing Fee', 'Late Fee', 'Other') THEN
        RAISE_APPLICATION_ERROR(-20510, 'Invalid fine type');
    END IF;
    
    INSERT INTO FINES (
        fine_id, patron_id, loan_id, fine_type, amount_due,
        amount_paid, date_assessed, fine_status, assessed_by_staff_id
    ) VALUES (
        seq_fine_id.NEXTVAL, p_patron_id, p_loan_id, p_fine_type,
        p_amount, 0, SYSDATE, 'Unpaid', p_staff_id
    ) RETURNING fine_id INTO p_fine_id;
    
    UPDATE PATRONS
    SET total_fines_owed = total_fines_owed + p_amount
    WHERE patron_id = p_patron_id;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('✅ Fine assessed: ' || p_amount || ' DH (' || p_fine_type || ')');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20511, 'Error: ' || SQLERRM);
END sp_assess_fine;
/

-- ============================================================================
-- SECTION 7: REPORTING FUNCTIONS
-- ============================================================================

CREATE OR REPLACE FUNCTION fn_get_patron_statistics (
    p_patron_id IN NUMBER
) RETURN VARCHAR2 IS
    v_stats VARCHAR2(1000);
    v_active_loans NUMBER;
    v_overdue_loans NUMBER;
    v_total_fines NUMBER;
    v_reservations NUMBER;
BEGIN
    SELECT 
        fn_get_active_loan_count(p_patron_id),
        (SELECT COUNT(*) FROM LOANS l 
         WHERE l.patron_id = p_patron_id 
           AND l.loan_status = 'Active' 
           AND l.due_date < SYSDATE),
        total_fines_owed,
        (SELECT COUNT(*) FROM RESERVATIONS 
         WHERE patron_id = p_patron_id 
           AND reservation_status = 'Pending')
    INTO v_active_loans, v_overdue_loans, v_total_fines, v_reservations
    FROM PATRONS WHERE patron_id = p_patron_id;
    
    v_stats := 'Active Loans: ' || v_active_loans || 
               ', Overdue: ' || v_overdue_loans ||
               ', Fines: ' || v_total_fines || ' DH' ||
               ', Reservations: ' || v_reservations;
    
    RETURN v_stats;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'Patron not found';
    WHEN OTHERS THEN
        RETURN 'Error retrieving statistics';
END fn_get_patron_statistics;
/

CREATE OR REPLACE FUNCTION fn_get_overdue_count (
    p_branch_id IN NUMBER DEFAULT NULL
) RETURN NUMBER IS
    v_count NUMBER;
BEGIN
    IF p_branch_id IS NULL THEN
        SELECT COUNT(*) INTO v_count
        FROM LOANS
        WHERE loan_status = 'Active' AND due_date < SYSDATE;
    ELSE
        SELECT COUNT(*) INTO v_count
        FROM LOANS l
        JOIN COPIES c ON l.copy_id = c.copy_id
        WHERE l.loan_status = 'Active' 
          AND l.due_date < SYSDATE
          AND c.branch_id = p_branch_id;
    END IF;
    
    RETURN v_count;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
END fn_get_overdue_count;
/

CREATE OR REPLACE FUNCTION fn_calculate_total_fines (
    p_patron_id IN NUMBER DEFAULT NULL
) RETURN NUMBER IS
    v_total NUMBER;
BEGIN
    IF p_patron_id IS NULL THEN
        SELECT NVL(SUM(amount_due - amount_paid), 0) INTO v_total
        FROM FINES WHERE fine_status IN ('Unpaid', 'Partially Paid');
    ELSE
        SELECT NVL(SUM(amount_due - amount_paid), 0) INTO v_total
        FROM FINES 
        WHERE patron_id = p_patron_id 
          AND fine_status IN ('Unpaid', 'Partially Paid');
    END IF;
    
    RETURN v_total;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
END fn_calculate_total_fines;
/

CREATE OR REPLACE FUNCTION fn_check_material_availability (
    p_material_id IN NUMBER
) RETURN VARCHAR2 IS
    v_total NUMBER;
    v_available NUMBER;
    v_status VARCHAR2(100);
BEGIN
    SELECT total_copies, available_copies
    INTO v_total, v_available
    FROM MATERIALS WHERE material_id = p_material_id;
    
    IF v_available > 0 THEN
        v_status := 'Available (' || v_available || '/' || v_total || ' copies)';
    ELSE
        v_status := 'All checked out (0/' || v_total || ')';
    END IF;
    
    RETURN v_status;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'Material not found';
    WHEN OTHERS THEN
        RETURN 'Error checking availability';
END fn_check_material_availability;
/

-- ============================================================================
-- SECTION 8: BATCH OPERATIONS PROCEDURES
-- ============================================================================

CREATE OR REPLACE PROCEDURE sp_process_overdue_notifications AS
    v_count NUMBER := 0;
    CURSOR c_overdue IS
        SELECT l.loan_id, l.patron_id, p.email, p.first_name, l.due_date,
               m.title, TRUNC(SYSDATE - l.due_date) AS days_overdue
        FROM LOANS l
        JOIN PATRONS p ON l.patron_id = p.patron_id
        JOIN COPIES c ON l.copy_id = c.copy_id
        JOIN MATERIALS m ON c.material_id = m.material_id
        WHERE l.loan_status = 'Active' AND l.due_date < SYSDATE;
BEGIN
    FOR rec IN c_overdue LOOP
        DBMS_OUTPUT.PUT_LINE('📧 Notification: ' || rec.email || ' - ' || 
                           rec.title || ' overdue by ' || rec.days_overdue || ' days');
        v_count := v_count + 1;
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('✅ Processed ' || v_count || ' overdue notifications');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('❌ Error: ' || SQLERRM);
END sp_process_overdue_notifications;
/

CREATE OR REPLACE PROCEDURE sp_expire_memberships AS
    v_count NUMBER := 0;
BEGIN
    UPDATE PATRONS
    SET account_status = 'Expired'
    WHERE membership_expiry < SYSDATE
      AND account_status = 'Active';
    
    v_count := SQL%ROWCOUNT;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('✅ Expired ' || v_count || ' membership(s)');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20601, 'Error: ' || SQLERRM);
END sp_expire_memberships;
/

CREATE OR REPLACE PROCEDURE sp_cleanup_expired_reservations AS
    v_count NUMBER := 0;
BEGIN
    UPDATE RESERVATIONS
    SET reservation_status = 'Expired'
    WHERE reservation_status = 'Ready'
      AND pickup_deadline < SYSDATE;
    
    v_count := SQL%ROWCOUNT;
    
    UPDATE COPIES
    SET copy_status = 'Available'
    WHERE copy_id IN (
        SELECT fulfilled_by_copy_id
        FROM RESERVATIONS
        WHERE reservation_status = 'Expired'
          AND fulfilled_by_copy_id IS NOT NULL
    );
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('✅ Cleaned up ' || v_count || ' expired reservation(s)');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20602, 'Error: ' || SQLERRM);
END sp_cleanup_expired_reservations;
/

CREATE OR REPLACE PROCEDURE sp_generate_daily_report (
    p_branch_id IN NUMBER DEFAULT NULL
) AS
    v_checkouts NUMBER;
    v_returns NUMBER;
    v_new_patrons NUMBER;
    v_overdue NUMBER;
    v_total_fines NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_checkouts
    FROM LOANS
    WHERE TRUNC(checkout_date) = TRUNC(SYSDATE)
      AND (p_branch_id IS NULL OR copy_id IN (SELECT copy_id FROM COPIES WHERE branch_id = p_branch_id));
    
    SELECT COUNT(*) INTO v_returns
    FROM LOANS
    WHERE TRUNC(return_date) = TRUNC(SYSDATE)
      AND (p_branch_id IS NULL OR copy_id IN (SELECT copy_id FROM COPIES WHERE branch_id = p_branch_id));
    
    SELECT COUNT(*) INTO v_new_patrons
    FROM PATRONS
    WHERE TRUNC(registration_date) = TRUNC(SYSDATE)
      AND (p_branch_id IS NULL OR registered_branch_id = p_branch_id);
    
    v_overdue := fn_get_overdue_count(p_branch_id);
    v_total_fines := fn_calculate_total_fines();
    
    DBMS_OUTPUT.PUT_LINE('📊 DAILY REPORT - ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY'));
    DBMS_OUTPUT.PUT_LINE('=====================================');
    DBMS_OUTPUT.PUT_LINE('Checkouts today: ' || v_checkouts);
    DBMS_OUTPUT.PUT_LINE('Returns today: ' || v_returns);
    DBMS_OUTPUT.PUT_LINE('New patrons: ' || v_new_patrons);
    DBMS_OUTPUT.PUT_LINE('Overdue items: ' || v_overdue);
    DBMS_OUTPUT.PUT_LINE('Total unpaid fines: ' || v_total_fines || ' DH');
    DBMS_OUTPUT.PUT_LINE('=====================================');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('❌ Error generating report: ' || SQLERRM);
END sp_generate_daily_report;
/

-- ============================================================================
-- SECTION 9: TESTING PROCEDURES
-- ============================================================================

CREATE OR REPLACE PROCEDURE sp_test_all_procedures AS
    v_patron_id NUMBER;
    v_material_id NUMBER;
    v_copy_id NUMBER;
    v_loan_id NUMBER;
    v_reservation_id NUMBER;
    v_fine_assessed NUMBER;
    v_new_due_date DATE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('🧪 TESTING ALL PROCEDURES');
    DBMS_OUTPUT.PUT_LINE('=====================================');
    
    -- Test 1: Add Patron
    BEGIN
        sp_add_patron(
            'TEST001', 'Test', 'User', 'test@library.org', '555-1234',
            '123 Test St', TO_DATE('1990-01-01', 'YYYY-MM-DD'),
            'Standard', 1, v_patron_id
        );
        DBMS_OUTPUT.PUT_LINE('✓ Test 1 PASSED: Add Patron');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('✗ Test 1 FAILED: ' || SQLERRM);
    END;
    
    DBMS_OUTPUT.PUT_LINE('=====================================');
    DBMS_OUTPUT.PUT_LINE('✅ Testing complete!');
END sp_test_all_procedures;
/

-- ============================================================================
-- END OF COMPLETE PL/SQL CODE 
-- ============================================================================

COMMIT;

-- ============================================================================
-- USAGE EXAMPLES
-- ============================================================================

/*
-- Example 1: Add a new patron
DECLARE
    v_patron_id NUMBER;
BEGIN
    sp_add_patron(
        p_card_number => 'CARD001',
        p_first_name => 'Abdellah',
        p_last_name => 'Dlimi',
        p_email => 'abdellahdlimi@email.com',
        p_phone => '0612345678',
        p_address => '123 Rue el houda, agadir',
        p_date_of_birth => TO_DATE('2004-09-30', 'YYYY-MM-DD'),
        p_membership_type => 'Standard',
        p_branch_id => 1,
        p_new_patron_id => v_patron_id
    );
END;
/

-- Example 2: Checkout an item
DECLARE
    v_loan_id NUMBER;
BEGIN
    sp_checkout_item(
        p_patron_id => 1001,
        p_copy_id => 1,
        p_staff_id => 1,
        p_loan_id => v_loan_id
    );
END;
/

-- Example 3: Return an item
DECLARE
    v_fine NUMBER;
BEGIN
    sp_checkin_item(
        p_loan_id => 10001,
        p_staff_id => 1,
        p_fine_assessed => v_fine
    );
    DBMS_OUTPUT.PUT_LINE('Fine assessed: ' || v_fine);
END;
/

-- Example 4: Get patron statistics
SELECT fn_get_patron_statistics(1001) FROM DUAL;

-- Example 5: Generate daily report
BEGIN
    sp_generate_daily_report(p_branch_id => 1);
END;
/
*/
