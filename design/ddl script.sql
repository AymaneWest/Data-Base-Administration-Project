-- ============================================================================
-- VIEWS FOR COMMON QUERIES
-- ============================================================================

-- View: Currently overdue loans
CREATE OR REPLACE VIEW v_overdue_loans AS
SELECT 
    l.loan_id,
    l.checkout_date,
    l.due_date,
    TRUNC(SYSDATE - l.due_date) AS days_overdue,
    p.patron_id,
    p.first_name || ' ' || p.last_name AS patron_name,
    p.email AS patron_email,
    m.title AS material_title,
    c.barcode AS copy_barcode,
    b.branch_name
FROM LOANS l
JOIN PATRONS p ON l.patron_id = p.patron_id
JOIN COPIES c ON l.copy_id = c.copy_id
JOIN MATERIALS m ON c.material_id = m.material_id
JOIN BRANCHES b ON c.branch_id = b.branch_id
WHERE l.return_date IS NULL 
  AND l.due_date < SYSDATE
  AND l.loan_status = 'Active';

-- View: Material availability
CREATE OR REPLACE VIEW v_material_availability AS
SELECT 
    m.material_id,
    m.title,
    m.material_type,
    m.total_copies,
    m.available_copies,
    COUNT(r.reservation_id) AS reservations_count,
    CASE 
        WHEN m.available_copies > 0 THEN 'Available'
        WHEN COUNT(r.reservation_id) > 0 THEN 'Reserved - Queue: ' || COUNT(r.reservation_id)
        ELSE 'All Checked Out'
    END AS availability_status
FROM MATERIALS m
LEFT JOIN RESERVATIONS r ON m.material_id = r.material_id 
    AND r.reservation_status = 'Pending'
GROUP BY m.material_id, m.title, m.material_type, m.total_copies, m.available_copies;

-- View: Patron borrowing history summary
CREATE OR REPLACE VIEW v_patron_statistics AS
SELECT 
    p.patron_id,
    p.first_name || ' ' || p.last_name AS patron_name,
    p.card_number,
    p.account_status,
    COUNT(l.loan_id) AS total_loans,
    SUM(CASE WHEN l.loan_status = 'Active' THEN 1 ELSE 0 END) AS active_loans,
    SUM(CASE WHEN l.loan_status = 'Overdue' THEN 1 ELSE 0 END) AS overdue_loans,
    p.total_fines_owed,
    COUNT(r.reservation_id) AS active_reservations
FROM PATRONS p
LEFT JOIN LOANS l ON p.patron_id = l.patron_id
LEFT JOIN RESERVATIONS r ON p.patron_id = r.patron_id 
    AND r.reservation_status IN ('Pending', 'Ready')
GROUP BY p.patron_id, p.first_name, p.last_name, p.card_number, 
         p.account_status, p.total_fines_owed;
