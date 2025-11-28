-- ============================================================================
-- LIBRARY MANAGEMENT SYSTEM - COMPLETE TRIGGERS IMPLEMENTATION
-- ============================================================================
-- Author: Database Design Team
-- Date: October 2025
-- Description: All triggers for automatic data integrity and business logic
-- ============================================================================

-- ============================================================================
-- SECTION 1: AUDIT AND LOGGING TRIGGERS
-- ============================================================================

-- Trigger: Log user login attempts
CREATE OR REPLACE TRIGGER trg_user_login_log
BEFORE UPDATE ON USERS
FOR EACH ROW
WHEN (NEW.last_login != OLD.last_login)
BEGIN
    DBMS_OUTPUT.PUT_LINE('User ' || :NEW.username ||' logged in at ' || TO_CHAR(:NEW.last_login, 'DD-MON-YYYY HH24:MI:SS')    );
END trg_user_login_log;
/

-- Trigger: Prevent deletion of active roles
CREATE OR REPLACE TRIGGER trg_prevent_active_role_delete
BEFORE DELETE ON ROLES
FOR EACH ROW
BEGIN
    IF :OLD.is_active = 'Y' THEN
        RAISE_APPLICATION_ERROR(-20701, 'Cannot delete active role: ' || :OLD.role_name || 
                               '. Deactivate first.');
    END IF;
END trg_prevent_active_role_delete;
/

-- Trigger: Audit permission changes
CREATE OR REPLACE TRIGGER trg_audit_permission_changes
AFTER INSERT OR UPDATE OR DELETE ON ROLE_PERMISSIONS
FOR EACH ROW
DECLARE
    v_action VARCHAR2(10);
    v_role_name VARCHAR2(50);
    v_perm_name VARCHAR2(100);
BEGIN
    IF INSERTING THEN
        v_action := 'GRANT';
    ELSIF DELETING THEN
        v_action := 'REVOKE';
    ELSE
        v_action := 'UPDATE';
    END IF;
    
    SELECT role_name INTO v_role_name FROM ROLES WHERE role_id = COALESCE(:NEW.role_id, :OLD.role_id);
    SELECT permission_name INTO v_perm_name FROM PERMISSIONS 
    WHERE permission_id = COALESCE(:NEW.permission_id, :OLD.permission_id);
    
    DBMS_OUTPUT.PUT_LINE(' AUDIT: ' || v_action || ' permission ' || v_perm_name || 
                        ' to role ' || v_role_name);
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END trg_audit_permission_changes;
/

-- ============================================================================
-- SECTION 2: PATRON MANAGEMENT TRIGGERS
-- ============================================================================

-- Trigger: Validate patron email on insert/update
CREATE OR REPLACE TRIGGER trg_validate_patron_email
BEFORE INSERT OR UPDATE ON PATRONS
FOR EACH ROW
BEGIN
    IF :NEW.email IS NOT NULL AND NOT REGEXP_LIKE(:NEW.email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$') THEN
        RAISE_APPLICATION_ERROR(-20702, 'Invalid email format: ' || :NEW.email);
    END IF;
    
    IF :NEW.membership_expiry < SYSDATE THEN
        :NEW.account_status := 'Expired';
    END IF;
END trg_validate_patron_email;
/

-- Trigger: Update patron account status when membership expires
CREATE OR REPLACE TRIGGER trg_check_membership_expiry
BEFORE INSERT OR UPDATE ON PATRONS
FOR EACH ROW
BEGIN
    IF :NEW.membership_expiry < SYSDATE AND :NEW.account_status = 'Active' THEN
        :NEW.account_status := 'Expired';
        DBMS_OUTPUT.PUT_LINE(' Patron ' || :NEW.patron_id || ' membership expired');
    END IF;
    
    IF :NEW.total_fines_owed >= 50 AND :NEW.account_status = 'Active' THEN
        :NEW.account_status := 'Suspended';
        DBMS_OUTPUT.PUT_LINE(' Patron ' || :NEW.patron_id || ' suspended due to excessive fines');
    END IF;
END trg_check_membership_expiry;
/

-- Trigger: Prevent modification of locked accounts
CREATE OR REPLACE TRIGGER trg_prevent_locked_patron_update
BEFORE UPDATE ON PATRONS
FOR EACH ROW
BEGIN
    IF :OLD.account_status = 'Blocked' THEN
        RAISE_APPLICATION_ERROR(-20703, 'Cannot modify blocked patron account');
    END IF;
END trg_prevent_locked_patron_update;
/

-- Trigger: Automatically calculate membership expiry date
CREATE OR REPLACE TRIGGER trg_auto_set_membership_expiry
BEFORE INSERT ON PATRONS
FOR EACH ROW
BEGIN
    IF :NEW.membership_expiry IS NULL THEN
        :NEW.membership_expiry := ADD_MONTHS(SYSDATE, 12);
        DBMS_OUTPUT.PUT_LINE(' Membership expiry set to: ' || TO_CHAR(:NEW.membership_expiry, 'DD-MON-YYYY'));
    END IF;
END trg_auto_set_membership_expiry;
/

-- ============================================================================
-- SECTION 3: LOAN AND CIRCULATION TRIGGERS
-- ============================================================================

-- Trigger: Update copy status when loan is created
CREATE OR REPLACE TRIGGER trg_update_copy_on_checkout
AFTER INSERT ON LOANS
FOR EACH ROW
BEGIN
    UPDATE COPIES
    SET copy_status = 'Checked Out'
    WHERE copy_id = :NEW.copy_id;
    
    DBMS_OUTPUT.PUT_LINE('✓ Copy ' || :NEW.copy_id || ' marked as checked out');
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20704, 'Error updating copy status: ' || SQLERRM);
END trg_update_copy_on_checkout;
/

-- Trigger: Update copy status when loan is returned
CREATE OR REPLACE TRIGGER trg_update_copy_on_checkin
AFTER UPDATE ON LOANS
FOR EACH ROW
WHEN (NEW.loan_status = 'Returned' AND OLD.loan_status = 'Active')
BEGIN
    UPDATE COPIES
    SET copy_status = 'Available'
    WHERE copy_id = :NEW.copy_id;
    
    DBMS_OUTPUT.PUT_LINE('Copy ' || :NEW.copy_id || ' marked as available');
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20705, 'Error updating copy status: ' || SQLERRM);
END trg_update_copy_on_checkin;
/

-- Trigger: Prevent checkout to patron with excessive fines
CREATE OR REPLACE TRIGGER trg_check_patron_fines_on_checkout
BEFORE INSERT ON LOANS
FOR EACH ROW
DECLARE
    v_fines NUMBER;
BEGIN
    SELECT total_fines_owed INTO v_fines
    FROM PATRONS WHERE patron_id = :NEW.patron_id;
    
    IF v_fines > 50 THEN
        RAISE_APPLICATION_ERROR(-20706, 'Patron has excessive fines: ' || v_fines || ' DH. Cannot checkout.');
    END IF;
END trg_check_patron_fines_on_checkout;
/

-- Trigger: Validate due date is after checkout date
CREATE OR REPLACE TRIGGER trg_validate_loan_dates
BEFORE INSERT OR UPDATE ON LOANS
FOR EACH ROW
BEGIN
    IF :NEW.due_date <= :NEW.checkout_date THEN
        RAISE_APPLICATION_ERROR(-20707, 'Due date must be after checkout date');
    END IF;
    
    IF :NEW.return_date IS NOT NULL AND :NEW.return_date < :NEW.checkout_date THEN
        RAISE_APPLICATION_ERROR(-20708, 'Return date cannot be before checkout date');
    END IF;
    
    IF :NEW.renewal_count > 5 THEN
        RAISE_APPLICATION_ERROR(-20709, 'Maximum renewals (5) exceeded');
    END IF;
END trg_validate_loan_dates;
/

-- Trigger: Prevent checkout if patron has too many active loans
CREATE OR REPLACE TRIGGER trg_check_borrow_limit_on_checkout
BEFORE INSERT ON LOANS
FOR EACH ROW
DECLARE
    v_active_loans NUMBER;
    v_max_limit NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_active_loans
    FROM LOANS
    WHERE patron_id = :NEW.patron_id AND loan_status = 'Active';
    
    SELECT max_borrow_limit INTO v_max_limit
    FROM PATRONS WHERE patron_id = :NEW.patron_id;
    
    IF v_active_loans >= v_max_limit THEN
        RAISE_APPLICATION_ERROR(-20710, 'Borrow limit reached: ' || v_active_loans || '/' || v_max_limit);
    END IF;
END trg_check_borrow_limit_on_checkout;
/

-- Trigger: Prevent checkout of reference materials
CREATE OR REPLACE TRIGGER trg_prevent_reference_checkout
BEFORE INSERT ON LOANS
FOR EACH ROW
DECLARE
    v_is_reference VARCHAR2(1);
BEGIN
    SELECT is_reference INTO v_is_reference
    FROM MATERIALS
    WHERE material_id = (SELECT material_id FROM COPIES WHERE copy_id = :NEW.copy_id);
    
    IF v_is_reference = 'Y' THEN
        RAISE_APPLICATION_ERROR(-20711, 'Reference materials cannot be checked out');
    END IF;
END trg_prevent_reference_checkout;
/

-- Trigger: Mark loan as overdue when due date passes
CREATE OR REPLACE TRIGGER trg_mark_overdue_loans
BEFORE UPDATE ON LOANS
FOR EACH ROW
BEGIN
    IF :NEW.loan_status = 'Active' AND :NEW.due_date < SYSDATE AND :OLD.loan_status = 'Active' THEN
        :NEW.loan_status := 'Overdue';
        DBMS_OUTPUT.PUT_LINE(' Loan ' || :NEW.loan_id || ' marked as overdue');
    END IF;
END trg_mark_overdue_loans;
/

-- ============================================================================
-- SECTION 4: MATERIAL AND COPY MANAGEMENT TRIGGERS
-- ============================================================================

-- Trigger: Validate material type on insert/update
CREATE OR REPLACE TRIGGER trg_validate_material_type
BEFORE INSERT OR UPDATE ON MATERIALS
FOR EACH ROW
BEGIN
    IF :NEW.material_type NOT IN ('Book', 'DVD', 'Magazine', 'E-book', 'Audiobook', 
                                   'Journal', 'Newspaper', 'CD', 'Game') THEN
        RAISE_APPLICATION_ERROR(-20712, 'Invalid material type: ' || :NEW.material_type);
    END IF;
    
    IF :NEW.available_copies > :NEW.total_copies THEN
        RAISE_APPLICATION_ERROR(-20713, 'Available copies cannot exceed total copies');
    END IF;
END trg_validate_material_type;
/

-- Trigger: Prevent deletion of materials with active loans
CREATE OR REPLACE TRIGGER trg_prevent_material_delete_with_loans
BEFORE DELETE ON MATERIALS
FOR EACH ROW
DECLARE
    v_active_loans NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_active_loans
    FROM LOANS l
    JOIN COPIES c ON l.copy_id = c.copy_id
    WHERE c.material_id = :OLD.material_id AND l.loan_status IN ('Active', 'Overdue');
    
    IF v_active_loans > 0 THEN
        RAISE_APPLICATION_ERROR(-20714, 'Cannot delete material with active loans: ' || v_active_loans);
    END IF;
END trg_prevent_material_delete_with_loans;
/

-- Trigger: Update available copies when copy status changes
CREATE OR REPLACE TRIGGER trg_sync_material_copy_count
AFTER UPDATE ON COPIES
FOR EACH ROW
WHEN (NEW.copy_status != OLD.copy_status)
DECLARE
    v_available_count NUMBER;
    v_total_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_available_count
    FROM COPIES
    WHERE material_id = :NEW.material_id AND copy_status = 'Available';
    
    SELECT COUNT(*) INTO v_total_count
    FROM COPIES
    WHERE material_id = :NEW.material_id;
    
    UPDATE MATERIALS
    SET available_copies = v_available_count,
        total_copies = v_total_count
    WHERE material_id = :NEW.material_id;
    
    DBMS_OUTPUT.PUT_LINE(' Material copy count updated');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(' Error syncing copy count: ' || SQLERRM);
END trg_sync_material_copy_count;
/

-- Trigger: Validate copy condition on insert/update
CREATE OR REPLACE TRIGGER trg_validate_copy_condition
BEFORE INSERT OR UPDATE ON COPIES
FOR EACH ROW
BEGIN
    IF :NEW.copy_condition NOT IN ('New', 'Excellent', 'Good', 'Fair', 'Poor', 'Damaged') THEN
        RAISE_APPLICATION_ERROR(-20715, 'Invalid copy condition: ' || :NEW.copy_condition);
    END IF;
    
    IF :NEW.copy_status NOT IN ('Available', 'Checked Out', 'Reserved', 'In Transit', 
                               'Lost', 'Damaged', 'Under Repair', 'Withdrawn') THEN
        RAISE_APPLICATION_ERROR(-20716, 'Invalid copy status: ' || :NEW.copy_status);
    END IF;
END trg_validate_copy_condition;
/

-- Trigger: Prevent checkout of damaged/lost copies
CREATE OR REPLACE TRIGGER trg_prevent_damaged_checkout
BEFORE INSERT ON LOANS
FOR EACH ROW
DECLARE
    v_copy_status VARCHAR2(30);
    v_copy_condition VARCHAR2(20);
BEGIN
    SELECT copy_status, copy_condition INTO v_copy_status, v_copy_condition
    FROM COPIES WHERE copy_id = :NEW.copy_id;
    
    IF v_copy_status IN ('Damaged', 'Lost', 'Under Repair') THEN
        RAISE_APPLICATION_ERROR(-20717, 'Cannot checkout: Copy status is ' || v_copy_status);
    END IF;
    
    IF v_copy_condition IN ('Poor', 'Damaged') THEN
        RAISE_APPLICATION_ERROR(-20718, 'Cannot checkout: Copy condition is ' || v_copy_condition);
    END IF;
END trg_prevent_damaged_checkout;
/

-- ============================================================================
-- SECTION 5: RESERVATION TRIGGERS
-- ============================================================================

-- Trigger: Validate reservation dates
CREATE OR REPLACE TRIGGER trg_validate_reservation_dates
BEFORE INSERT OR UPDATE ON RESERVATIONS
FOR EACH ROW
BEGIN
    IF :NEW.notification_date IS NOT NULL AND :NEW.notification_date < :NEW.reservation_date THEN
        RAISE_APPLICATION_ERROR(-20719, 'Notification date cannot be before reservation date');
    END IF;
    
    IF :NEW.pickup_deadline IS NOT NULL AND :NEW.pickup_deadline < :NEW.notification_date THEN
        RAISE_APPLICATION_ERROR(-20720, 'Pickup deadline must be after notification date');
    END IF;
END trg_validate_reservation_dates;
/

-- Trigger: Prevent duplicate active reservations for same patron-material
CREATE OR REPLACE TRIGGER trg_prevent_duplicate_reservations
BEFORE INSERT ON RESERVATIONS
FOR EACH ROW
DECLARE
    v_duplicate_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_duplicate_count
    FROM RESERVATIONS
    WHERE material_id = :NEW.material_id
      AND patron_id = :NEW.patron_id
      AND reservation_status IN ('Pending', 'Ready');
    
    IF v_duplicate_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20721, 'Patron already has an active reservation for this material');
    END IF;
END trg_prevent_duplicate_reservations;
/

-- Trigger: Update queue position when reservation is cancelled
CREATE OR REPLACE TRIGGER trg_update_queue_on_cancel
AFTER UPDATE ON RESERVATIONS
FOR EACH ROW
WHEN (NEW.reservation_status = 'Cancelled' AND OLD.reservation_status IN ('Pending', 'Ready'))
BEGIN
    UPDATE RESERVATIONS
    SET queue_position = queue_position - 1
    WHERE material_id = :NEW.material_id
      AND queue_position > :OLD.queue_position
      AND reservation_status = 'Pending';
    
    DBMS_OUTPUT.PUT_LINE('Queue positions updated');
END trg_update_queue_on_cancel;
/

-- Trigger: Prevent expired reservation fulfillment
CREATE OR REPLACE TRIGGER trg_prevent_expired_reservation_fulfill
BEFORE UPDATE ON RESERVATIONS
FOR EACH ROW
BEGIN
    IF :NEW.reservation_status = 'Fulfilled' THEN
        IF :OLD.reservation_status = 'Expired' OR :OLD.pickup_deadline < SYSDATE THEN
            RAISE_APPLICATION_ERROR(-20722, 'Cannot fulfill expired reservation');
        END IF;
    END IF;
END trg_prevent_expired_reservation_fulfill;
/

-- ============================================================================
-- SECTION 6: FINE MANAGEMENT TRIGGERS
-- ============================================================================

-- Trigger: Validate fine amounts
CREATE OR REPLACE TRIGGER trg_validate_fine_amounts
BEFORE INSERT OR UPDATE ON FINES
FOR EACH ROW
BEGIN
    IF :NEW.amount_due < 0 THEN
        RAISE_APPLICATION_ERROR(-20723, 'Fine amount cannot be negative');
    END IF;
    
    IF :NEW.amount_paid < 0 THEN
        RAISE_APPLICATION_ERROR(-20724, 'Paid amount cannot be negative');
    END IF;
    
    IF :NEW.amount_paid > :NEW.amount_due THEN
        RAISE_APPLICATION_ERROR(-20725, 'Paid amount cannot exceed total fine');
    END IF;
    
    IF :NEW.fine_type NOT IN ('Overdue', 'Lost Item', 'Damaged Item', 'Processing Fee', 'Late Fee', 'Other') THEN
        RAISE_APPLICATION_ERROR(-20726, 'Invalid fine type: ' || :NEW.fine_type);
    END IF;
END trg_validate_fine_amounts;
/

-- Trigger: Auto-update fine status based on payment
CREATE OR REPLACE TRIGGER trg_auto_update_fine_status
BEFORE INSERT OR UPDATE ON FINES
FOR EACH ROW
BEGIN
    IF :NEW.amount_paid = :NEW.amount_due THEN
        :NEW.fine_status := 'Paid';
        :NEW.payment_date := SYSDATE;
    ELSIF :NEW.amount_paid > 0 THEN
        :NEW.fine_status := 'Partially Paid';
    ELSIF :NEW.fine_status IS NULL THEN
        :NEW.fine_status := 'Unpaid';
    END IF;
END trg_auto_update_fine_status;
/

-- Trigger: Update patron fine total when fine is created
CREATE OR REPLACE TRIGGER trg_update_patron_fines_on_insert
AFTER INSERT ON FINES
FOR EACH ROW
BEGIN
    UPDATE PATRONS
    SET total_fines_owed = total_fines_owed + :NEW.amount_due
    WHERE patron_id = :NEW.patron_id;
    
    DBMS_OUTPUT.PUT_LINE('Patron fine total updated');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(' Error updating patron fines: ' || SQLERRM);
END trg_update_patron_fines_on_insert;
/

-- Trigger: Update patron fine total when fine payment is made
CREATE OR REPLACE TRIGGER trg_update_patron_fines_on_payment
AFTER UPDATE ON FINES
FOR EACH ROW
WHEN (NEW.amount_paid > OLD.amount_paid)
DECLARE
    v_payment_amount NUMBER;
BEGIN
    v_payment_amount := :NEW.amount_paid - :OLD.amount_paid;
    
    UPDATE PATRONS
    SET total_fines_owed = GREATEST(0, total_fines_owed - v_payment_amount)
    WHERE patron_id = :NEW.patron_id;
    
    DBMS_OUTPUT.PUT_LINE(' Patron fine balance updated: -' || v_payment_amount || ' DH');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(' Error updating patron fines: ' || SQLERRM);
END trg_update_patron_fines_on_payment;
/

-- Trigger: Prevent fine modification when fully paid
CREATE OR REPLACE TRIGGER trg_prevent_paid_fine_modification
BEFORE UPDATE ON FINES
FOR EACH ROW
BEGIN
    IF :OLD.fine_status = 'Paid' AND :NEW.amount_paid < :OLD.amount_paid THEN
        RAISE_APPLICATION_ERROR(-20727, 'Cannot modify paid fine');
    END IF;
END trg_prevent_paid_fine_modification;
/

-- ============================================================================
-- SECTION 7: STAFF MANAGEMENT TRIGGERS
-- ============================================================================

-- Trigger: Validate staff salary
CREATE OR REPLACE TRIGGER trg_validate_staff_salary
BEFORE INSERT OR UPDATE ON STAFF
FOR EACH ROW
BEGIN
    IF :NEW.salary IS NOT NULL AND :NEW.salary <= 0 THEN
        RAISE_APPLICATION_ERROR(-20728, 'Salary must be positive');
    END IF;
    
    IF :NEW.staff_role NOT IN ('Librarian', 'Assistant', 'Manager', 'Cataloger', 'IT Admin', 'Reception', 'Admin') THEN
        RAISE_APPLICATION_ERROR(-20729, 'Invalid staff role: ' || :NEW.staff_role);
    END IF;
END trg_validate_staff_salary;
/

-- Trigger: Prevent deletion of staff with active loans
CREATE OR REPLACE TRIGGER trg_prevent_staff_delete_with_activity
BEFORE DELETE ON STAFF
FOR EACH ROW
DECLARE
    v_checkout_count NUMBER;
    v_return_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_checkout_count
    FROM LOANS WHERE staff_id_checkout = :OLD.staff_id;
    
    SELECT COUNT(*) INTO v_return_count
    FROM LOANS WHERE staff_id_return = :OLD.staff_id;
    
    IF v_checkout_count > 0 OR v_return_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20730, 'Cannot delete staff member with transaction history');
    END IF;
END trg_prevent_staff_delete_with_activity;
/

-- ============================================================================
-- SECTION 8: BRANCH MANAGEMENT TRIGGERS
-- ============================================================================

-- Trigger: Validate branch capacity
CREATE OR REPLACE TRIGGER trg_validate_branch_capacity
BEFORE INSERT OR UPDATE ON BRANCHES
FOR EACH ROW
BEGIN
    IF :NEW.branch_capacity <= 0 THEN
        RAISE_APPLICATION_ERROR(-20731, 'Branch capacity must be positive');
    END IF;
    
    IF LENGTH(TRIM(:NEW.branch_name)) < 3 THEN
        RAISE_APPLICATION_ERROR(-20732, 'Branch name must be at least 3 characters');
    END IF;
END trg_validate_branch_capacity;
/

-- Trigger: Prevent deletion of branch with assigned patrons
CREATE OR REPLACE TRIGGER trg_prevent_branch_delete_with_patrons
BEFORE DELETE ON BRANCHES
FOR EACH ROW
DECLARE
    v_patron_count NUMBER;
    v_staff_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_patron_count
    FROM PATRONS WHERE registered_branch_id = :OLD.branch_id;
    
    SELECT COUNT(*) INTO v_staff_count
    FROM STAFF WHERE branch_id = :OLD.branch_id;
    
    IF v_patron_count > 0 OR v_staff_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20733, 'Cannot delete branch with patrons or staff');
    END IF;
END trg_prevent_branch_delete_with_patrons;
/

-- ============================================================================
-- SECTION 9: DATA INTEGRITY TRIGGERS
-- ============================================================================

-- Trigger: Ensure sequence of timestamps
CREATE OR REPLACE TRIGGER trg_validate_timestamp_sequence
BEFORE INSERT OR UPDATE ON LOANS
FOR EACH ROW
BEGIN
    IF :NEW.checkout_date > :NEW.due_date THEN
        RAISE_APPLICATION_ERROR(-20734, 'Checkout date must be before due date');
    END IF;
    
    IF :NEW.return_date IS NOT NULL THEN
        IF :NEW.return_date < :NEW.checkout_date THEN
            RAISE_APPLICATION_ERROR(-20735, 'Return date must be after checkout date');
        END IF;
    END IF;
END trg_validate_timestamp_sequence;
/

-- Trigger: Prevent negative quantities
CREATE OR REPLACE TRIGGER trg_prevent_negative_quantities
BEFORE INSERT OR UPDATE ON MATERIALS
FOR EACH ROW
BEGIN
    IF :NEW.total_copies < 0 OR :NEW.available_copies < 0 THEN
        RAISE_APPLICATION_ERROR(-20736, 'Copy quantities cannot be negative');
    END IF;
END trg_prevent_negative_quantities;
/

-- Trigger: Auto-update modified timestamp
CREATE OR REPLACE TRIGGER trg_auto_timestamp
BEFORE UPDATE ON USERS
FOR EACH ROW
BEGIN
    IF :NEW.last_password_change IS NULL THEN
        :NEW.last_password_change := SYSDATE;
    END IF;
END trg_auto_timestamp;
/

-- ============================================================================
-- SECTION 10: BUSINESS LOGIC TRIGGERS
-- ============================================================================

-- Trigger: Generate automatic fine on overdue return
CREATE OR REPLACE TRIGGER trg_auto_assess_overdue_fine
AFTER UPDATE ON LOANS
FOR EACH ROW
WHEN (NEW.loan_status = 'Returned' AND OLD.loan_status = 'Active')
DECLARE
    v_days_overdue NUMBER;
    v_fine_amount NUMBER;
    v_existing_fine NUMBER;
BEGIN
    IF :NEW.return_date > :NEW.due_date THEN
        v_days_overdue := TRUNC(:NEW.return_date - :NEW.due_date);
        v_fine_amount := v_days_overdue * 2.00;
        
        SELECT COUNT(*) INTO v_existing_fine
        FROM FINES
        WHERE loan_id = :NEW.loan_id AND fine_type = 'Overdue';
        
        IF v_existing_fine = 0 THEN
            INSERT INTO FINES (
                fine_id, patron_id, loan_id, fine_type, amount_due,
                amount_paid, date_assessed, fine_status, assessed_by_staff_id
            ) VALUES (
                seq_fine_id.NEXTVAL, :NEW.patron_id, :NEW.loan_id, 'Overdue',
                v_fine_amount, 0, SYSDATE, 'Unpaid', :NEW.staff_id_return
            );
            
            UPDATE PATRONS
            SET total_fines_owed = total_fines_owed + v_fine_amount
            WHERE patron_id = :NEW.patron_id;
            
            DBMS_OUTPUT.PUT_LINE(' Overdue fine of ' || v_fine_amount || ' DH assessed');
        END IF;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(' Error assessing overdue fine: ' || SQLERRM);
END trg_auto_assess_overdue_fine;
/

-- Trigger: Notify when material becomes available
CREATE OR REPLACE TRIGGER trg_notify_on_availability
AFTER UPDATE ON COPIES
FOR EACH ROW
WHEN (NEW.copy_status = 'Available' AND OLD.copy_status = 'Checked Out')
DECLARE
    v_pending_reservation NUMBER;
    v_patron_email VARCHAR2(100);
BEGIN
    SELECT COUNT(*) INTO v_pending_reservation
    FROM RESERVATIONS
    WHERE material_id = :NEW.material_id AND reservation_status = 'Pending';
    
    IF v_pending_reservation > 0 THEN
        SELECT patron_id INTO v_patron_email
        FROM RESERVATIONS
        WHERE material_id = :NEW.material_id 
          AND reservation_status = 'Pending'
          AND queue_position = 1;
        
        DBMS_OUTPUT.PUT_LINE('NOTIFICATION: Material available for patron ' || v_patron_email);
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END trg_notify_on_availability;
/

-- Trigger: Block patron when fines exceed threshold
CREATE OR REPLACE TRIGGER trg_auto_block_patron_excessive_fines
AFTER UPDATE ON PATRONS
FOR EACH ROW
WHEN (NEW.total_fines_owed > 100 AND OLD.total_fines_owed <= 100)
BEGIN
    UPDATE PATRONS
    SET account_status = 'Blocked'
    WHERE patron_id = :NEW.patron_id;
    
    DBMS_OUTPUT.PUT_LINE('ALERT: Patron ' || :NEW.patron_id || ' blocked due to excessive fines (>' || 100 || ' DH)');
END trg_auto_block_patron_excessive_fines;
/

-- Trigger: Auto-renew new release flag after 30 days
CREATE OR REPLACE TRIGGER trg_update_release_flag
BEFORE UPDATE ON MATERIALS
FOR EACH ROW
BEGIN
    IF :OLD.is_new_release = 'Y' AND SYSDATE > :OLD.date_added + 30 THEN
        :NEW.is_new_release := 'N';
        DBMS_OUTPUT.PUT_LINE('New release flag removed from material ' || :NEW.material_id);
    END IF;
END trg_update_release_flag;
/

-- Trigger: Prevent user account deletion if associated with transactions
CREATE OR REPLACE TRIGGER trg_prevent_user_delete_with_activity
BEFORE DELETE ON USERS
FOR EACH ROW
DECLARE
    v_staff_count NUMBER;
    v_fine_count NUMBER;
BEGIN
        
    SELECT COUNT(*) INTO v_fine_count FROM FINES 
    WHERE assessed_by_staff_id = :OLD.user_id OR waived_by_staff_id = :OLD.user_id;
    
    IF v_fine_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20737, 'Cannot delete user with associated fines');
    END IF;
END trg_prevent_user_delete_with_activity;
/

-- ============================================================================
-- SECTION 11: TRIGGER MANAGEMENT PROCEDURES
-- ============================================================================

CREATE OR REPLACE PROCEDURE sp_disable_all_triggers AS
BEGIN
    DBMS_OUTPUT.PUT_LINE('⏸️ Disabling all triggers...');
    
    FOR trg IN (SELECT trigger_name FROM user_triggers WHERE table_name IN 
        ('USERS', 'ROLES', 'ROLE_PERMISSIONS', 'PATRONS', 'LOANS', 'COPIES', 
         'MATERIALS', 'RESERVATIONS', 'FINES', 'STAFF', 'BRANCHES')) LOOP
        EXECUTE IMMEDIATE 'ALTER TRIGGER ' || trg.trigger_name || ' DISABLE';
    END LOOP;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('All triggers disabled');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(' Error: ' || SQLERRM);
END sp_disable_all_triggers;
/

CREATE OR REPLACE PROCEDURE sp_enable_all_triggers AS
BEGIN
    DBMS_OUTPUT.PUT_LINE(' Enabling all triggers...');
    
    FOR trg IN (SELECT trigger_name FROM user_triggers WHERE table_name IN 
        ('USERS', 'ROLES', 'ROLE_PERMISSIONS', 'PATRONS', 'LOANS', 'COPIES', 
         'MATERIALS', 'RESERVATIONS', 'FINES', 'STAFF', 'BRANCHES')) LOOP
        EXECUTE IMMEDIATE 'ALTER TRIGGER ' || trg.trigger_name || ' ENABLE';
    END LOOP;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE(' All triggers enabled');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(' Error: ' || SQLERRM);
END sp_enable_all_triggers;
/

-- ============================================================================
-- END OF TRIGGERS IMPLEMENTATION
-- ============================================================================

COMMIT;