-- ============================================================================
-- LIBRARY MANAGEMENT SYSTEM - ADMIN STATISTICS & REPORTING PROCEDURES
-- ============================================================================
-- Description: Procédures complètes pour l'interface administrateur
-- Author: Library Management System
-- Date: Novembre 2025
-- Version: 1.0
-- Usage: Ces procédures retournent des curseurs pour le backend
-- ============================================================================

-- ============================================================================
-- SECTION 1: TABLEAU DE BORD PRINCIPAL (DASHBOARD OVERVIEW)
-- ============================================================================

CREATE OR REPLACE PROCEDURE sp_get_admin_dashboard (
    p_branch_id IN NUMBER DEFAULT NULL,
    p_cursor OUT SYS_REFCURSOR
) AS
BEGIN
    OPEN p_cursor FOR
    SELECT 
        -- === STATISTIQUES PATRONS ===
        (SELECT COUNT(*) FROM PATRONS) AS total_patrons,
        (SELECT COUNT(*) FROM PATRONS WHERE account_status = 'Active') AS active_patrons,
        (SELECT COUNT(*) FROM PATRONS WHERE account_status = 'Suspended') AS suspended_patrons,
        (SELECT COUNT(*) FROM PATRONS WHERE account_status = 'Expired') AS expired_patrons,
        (SELECT COUNT(*) FROM PATRONS 
         WHERE TRUNC(registration_date) = TRUNC(SYSDATE)) AS new_patrons_today,
        
        -- === STATISTIQUES EMPRUNTS ===
        (SELECT COUNT(*) FROM LOANS 
         WHERE loan_status = 'Active') AS total_active_loans,
        (SELECT COUNT(*) FROM LOANS 
         WHERE loan_status = 'Active' AND due_date < SYSDATE) AS overdue_loans,
        (SELECT COUNT(*) FROM LOANS 
         WHERE TRUNC(checkout_date) = TRUNC(SYSDATE)) AS checkouts_today,
        (SELECT COUNT(*) FROM LOANS 
         WHERE TRUNC(return_date) = TRUNC(SYSDATE)) AS returns_today,
        (SELECT COUNT(*) FROM LOANS 
         WHERE loan_status = 'Active' 
         AND due_date BETWEEN SYSDATE AND SYSDATE + 3) AS loans_due_soon,
        
        -- === STATISTIQUES MATÉRIAUX ===
        (SELECT COUNT(*) FROM MATERIALS) AS total_materials,
        (SELECT SUM(total_copies) FROM MATERIALS) AS total_copies,
        (SELECT SUM(available_copies) FROM MATERIALS) AS available_copies,
        (SELECT COUNT(*) FROM MATERIALS 
         WHERE is_new_release = 'Y') AS new_releases,
        (SELECT COUNT(*) FROM COPIES 
         WHERE copy_status = 'Lost') AS lost_items,
        (SELECT COUNT(*) FROM COPIES 
         WHERE copy_status = 'Damaged') AS damaged_items,
        
        -- === STATISTIQUES RÉSERVATIONS ===
        (SELECT COUNT(*) FROM RESERVATIONS 
         WHERE reservation_status = 'Pending') AS pending_reservations,
        (SELECT COUNT(*) FROM RESERVATIONS 
         WHERE reservation_status = 'Ready') AS ready_reservations,
        (SELECT COUNT(*) FROM RESERVATIONS 
         WHERE reservation_status = 'Ready' 
         AND pickup_deadline < SYSDATE) AS expired_reservations,
        
        -- === STATISTIQUES AMENDES ===
        (SELECT NVL(SUM(amount_due - amount_paid), 0) 
         FROM FINES 
         WHERE fine_status IN ('Unpaid', 'Partially Paid')) AS total_unpaid_fines,
        (SELECT NVL(SUM(amount_paid), 0) 
         FROM FINES 
         WHERE TRUNC(payment_date) = TRUNC(SYSDATE)) AS fines_collected_today,
        (SELECT COUNT(*) FROM FINES 
         WHERE fine_status = 'Unpaid') AS unpaid_fine_count,
        
        -- === STATISTIQUES SYSTÈME ===
        (SELECT COUNT(*) FROM BRANCHES) AS total_branches,
        (SELECT COUNT(*) FROM STAFF 
         WHERE is_active = 'Y') AS active_staff
    FROM DUAL;
END sp_get_admin_dashboard;
/

-- ============================================================================
-- SECTION 2: DÉTAILS COMPLETS D'UN PATRON
-- ============================================================================

CREATE OR REPLACE PROCEDURE sp_get_patron_details (
    p_patron_id IN NUMBER,
    p_info_cursor OUT SYS_REFCURSOR,
    p_loans_cursor OUT SYS_REFCURSOR,
    p_fines_cursor OUT SYS_REFCURSOR,
    p_reservations_cursor OUT SYS_REFCURSOR
) AS
BEGIN
    -- === INFORMATIONS DE BASE DU PATRON ===
    OPEN p_info_cursor FOR
    SELECT 
        p.patron_id,
        p.card_number,
        p.first_name || ' ' || p.last_name AS full_name,
        p.email,
        p.phone,
        p.address,
        p.date_of_birth,
        FLOOR(MONTHS_BETWEEN(SYSDATE, p.date_of_birth) / 12) AS age,
        p.membership_type,
        p.registration_date,
        p.membership_expiry,
        CASE 
            WHEN p.membership_expiry < SYSDATE THEN 'EXPIRED'
            WHEN p.membership_expiry < SYSDATE + 30 THEN 'EXPIRES_SOON'
            ELSE 'ACTIVE'
        END AS membership_status,
        TRUNC(p.membership_expiry - SYSDATE) AS days_until_expiry,
        p.account_status,
        p.total_fines_owed,
        p.max_borrow_limit,
        b.branch_name AS registered_branch,
        (SELECT COUNT(*) FROM LOANS 
         WHERE patron_id = p.patron_id 
         AND loan_status = 'Active') AS current_loans,
        (SELECT COUNT(*) FROM LOANS 
         WHERE patron_id = p.patron_id) AS total_loans_history,
        (SELECT COUNT(*) FROM RESERVATIONS 
         WHERE patron_id = p.patron_id 
         AND reservation_status = 'Pending') AS active_reservations
    FROM PATRONS p
    LEFT JOIN BRANCHES b ON p.registered_branch_id = b.branch_id
    WHERE p.patron_id = p_patron_id;
    
    -- === EMPRUNTS ACTIFS ET HISTORIQUE ===
    OPEN p_loans_cursor FOR
    SELECT 
        l.loan_id,
        m.title,
        m.material_type,
        c.barcode,
        l.checkout_date,
        l.due_date,
        l.return_date,
        l.renewal_count,
        l.loan_status,
        CASE 
            WHEN l.return_date IS NULL AND l.due_date < SYSDATE 
            THEN TRUNC(SYSDATE - l.due_date)
            ELSE 0
        END AS days_overdue,
        CASE 
            WHEN l.return_date IS NULL AND l.due_date >= SYSDATE 
            THEN TRUNC(l.due_date - SYSDATE)
            ELSE NULL
        END AS days_remaining,
        b.branch_name,
        s.first_name || ' ' || s.last_name AS checkout_staff
    FROM LOANS l
    JOIN COPIES c ON l.copy_id = c.copy_id
    JOIN MATERIALS m ON c.material_id = m.material_id
    LEFT JOIN BRANCHES b ON c.branch_id = b.branch_id
    LEFT JOIN STAFF s ON l.staff_id_checkout = s.staff_id
    WHERE l.patron_id = p_patron_id
    ORDER BY l.checkout_date DESC
    FETCH FIRST 20 ROWS ONLY;
    
    -- === AMENDES ===
    OPEN p_fines_cursor FOR
    SELECT 
        f.fine_id,
        f.fine_type,
        f.amount_due,
        f.amount_paid,
        f.amount_due - f.amount_paid AS balance,
        f.date_assessed,
        f.payment_date,
        f.fine_status,
        f.payment_method,
        TRUNC(SYSDATE - f.date_assessed) AS days_unpaid,
        m.title AS related_material
    FROM FINES f
    LEFT JOIN LOANS l ON f.loan_id = l.loan_id
    LEFT JOIN COPIES c ON l.copy_id = c.copy_id
    LEFT JOIN MATERIALS m ON c.material_id = m.material_id
    WHERE f.patron_id = p_patron_id
    ORDER BY f.date_assessed DESC;
    
    -- === RÉSERVATIONS ===
    OPEN p_reservations_cursor FOR
    SELECT 
        r.reservation_id,
        m.title,
        m.material_type,
        r.reservation_date,
        r.reservation_status,
        r.queue_position,
        r.notification_date,
        r.pickup_deadline,
        CASE 
            WHEN r.reservation_status = 'Ready' 
            AND r.pickup_deadline IS NOT NULL 
            THEN TRUNC(r.pickup_deadline - SYSDATE)
            ELSE NULL
        END AS days_to_pickup
    FROM RESERVATIONS r
    JOIN MATERIALS m ON r.material_id = m.material_id
    WHERE r.patron_id = p_patron_id
    ORDER BY r.reservation_date DESC;
END sp_get_patron_details;
/

-- ============================================================================
-- SECTION 3: ALERTES - EMPRUNTS QUI EXPIRENT BIENTÔT
-- ============================================================================

CREATE OR REPLACE PROCEDURE sp_get_expiring_loans (
    p_days_ahead IN NUMBER DEFAULT 3,
    p_branch_id IN NUMBER DEFAULT NULL,
    p_cursor OUT SYS_REFCURSOR
) AS
BEGIN
    OPEN p_cursor FOR
    SELECT 
        l.loan_id,
        p.patron_id,
        p.card_number,
        p.first_name || ' ' || p.last_name AS patron_name,
        p.email,
        p.phone,
        m.title,
        m.material_type,
        c.barcode,
        l.checkout_date,
        l.due_date,
        TRUNC(l.due_date - SYSDATE) AS days_until_due,
        l.renewal_count,
        CASE 
            WHEN l.renewal_count >= 3 THEN 'NO_RENEWAL'
            WHEN EXISTS (
                SELECT 1 FROM RESERVATIONS 
                WHERE material_id = c.material_id 
                AND reservation_status = 'Pending'
            ) THEN 'RESERVED'
            ELSE 'CAN_RENEW'
        END AS renewal_status,
        b.branch_name,
        CASE 
            WHEN TRUNC(l.due_date - SYSDATE) = 0 THEN 'DUE_TODAY'
            WHEN TRUNC(l.due_date - SYSDATE) = 1 THEN 'DUE_TOMORROW'
            ELSE 'DUE_SOON'
        END AS alert_level
    FROM LOANS l
    JOIN PATRONS p ON l.patron_id = p.patron_id
    JOIN COPIES c ON l.copy_id = c.copy_id
    JOIN MATERIALS m ON c.material_id = m.material_id
    LEFT JOIN BRANCHES b ON c.branch_id = b.branch_id
    WHERE l.loan_status = 'Active'
      AND l.due_date BETWEEN SYSDATE AND SYSDATE + p_days_ahead
      AND (p_branch_id IS NULL OR c.branch_id = p_branch_id)
    ORDER BY l.due_date ASC, p.last_name;
END sp_get_expiring_loans;
/

-- ============================================================================
-- SECTION 4: RAPPORT DES AMENDES
-- ============================================================================

CREATE OR REPLACE PROCEDURE sp_get_fines_report (
    p_status_filter IN VARCHAR2 DEFAULT 'ALL',
    p_branch_id IN NUMBER DEFAULT NULL,
    p_date_from IN DATE DEFAULT NULL,
    p_date_to IN DATE DEFAULT SYSDATE,
    p_cursor OUT SYS_REFCURSOR
) AS
BEGIN
    OPEN p_cursor FOR
    SELECT 
        f.fine_id,
        p.patron_id,
        p.card_number,
        p.first_name || ' ' || p.last_name AS patron_name,
        p.email,
        f.fine_type,
        f.amount_due,
        f.amount_paid,
        f.amount_due - f.amount_paid AS balance,
        f.date_assessed,
        f.payment_date,
        f.fine_status,
        f.payment_method,
        TRUNC(SYSDATE - f.date_assessed) AS days_since_assessed,
        CASE 
            WHEN f.fine_status = 'Unpaid' 
            AND TRUNC(SYSDATE - f.date_assessed) > 30 THEN 'OVERDUE'
            WHEN f.fine_status = 'Unpaid' THEN 'PENDING'
            WHEN f.fine_status = 'Paid' THEN 'PAID'
            ELSE f.fine_status
        END AS status_indicator,
        m.title AS related_material,
        b.branch_name,
        s_assess.first_name || ' ' || s_assess.last_name AS assessed_by,
        s_waive.first_name || ' ' || s_waive.last_name AS waived_by,
        f.waiver_reason
    FROM FINES f
    JOIN PATRONS p ON f.patron_id = p.patron_id
    LEFT JOIN LOANS l ON f.loan_id = l.loan_id
    LEFT JOIN COPIES c ON l.copy_id = c.copy_id
    LEFT JOIN MATERIALS m ON c.material_id = m.material_id
    LEFT JOIN BRANCHES b ON c.branch_id = b.branch_id
    LEFT JOIN STAFF s_assess ON f.assessed_by_staff_id = s_assess.staff_id
    LEFT JOIN STAFF s_waive ON f.waived_by_staff_id = s_waive.staff_id
    WHERE (p_status_filter = 'ALL' OR f.fine_status = p_status_filter)
      AND (p_branch_id IS NULL OR c.branch_id = p_branch_id)
      AND (p_date_from IS NULL OR f.date_assessed >= p_date_from)
      AND f.date_assessed <= p_date_to
    ORDER BY f.date_assessed DESC, f.amount_due DESC;
END sp_get_fines_report;
/

-- ============================================================================
-- SECTION 5: MATÉRIAUX LES PLUS POPULAIRES
-- ============================================================================

CREATE OR REPLACE PROCEDURE sp_get_popular_materials (
    p_top_n IN NUMBER DEFAULT 10,
    p_material_type IN VARCHAR2 DEFAULT NULL,
    p_period_days IN NUMBER DEFAULT 30,
    p_cursor OUT SYS_REFCURSOR
) AS
BEGIN
    OPEN p_cursor FOR
    SELECT * FROM (
        SELECT 
            m.material_id,
            m.title,
            m.subtitle,
            m.material_type,
            m.isbn,
            m.publication_year,
            pub.publisher_name,
            COUNT(l.loan_id) AS total_loans,
            COUNT(DISTINCT l.patron_id) AS unique_borrowers,
            m.total_copies,
            m.available_copies,
            ROUND(
                (m.total_copies - m.available_copies) / 
                NULLIF(m.total_copies, 0) * 100, 2
            ) AS utilization_rate,
            ROUND(
                COUNT(l.loan_id) / NULLIF(m.total_copies, 0), 2
            ) AS loans_per_copy,
            MAX(l.checkout_date) AS last_checkout,
            CASE 
                WHEN m.available_copies = 0 THEN 'ALL_CHECKED_OUT'
                WHEN m.available_copies <= 2 THEN 'LOW_STOCK'
                ELSE 'AVAILABLE'
            END AS availability_status,
            (SELECT COUNT(*) FROM RESERVATIONS 
             WHERE material_id = m.material_id 
             AND reservation_status = 'Pending') AS pending_reservations
        FROM MATERIALS m
        LEFT JOIN PUBLISHERS pub ON m.publisher_id = pub.publisher_id
        LEFT JOIN COPIES c ON m.material_id = c.material_id
        LEFT JOIN LOANS l ON c.copy_id = l.copy_id 
            AND l.checkout_date >= SYSDATE - p_period_days
        WHERE (p_material_type IS NULL OR m.material_type = p_material_type)
        GROUP BY 
            m.material_id, m.title, m.subtitle, m.material_type, 
            m.isbn, m.publication_year, pub.publisher_name, 
            m.total_copies, m.available_copies
        ORDER BY total_loans DESC, unique_borrowers DESC
    )
    WHERE ROWNUM <= p_top_n;
END sp_get_popular_materials;
/

-- ============================================================================
-- SECTION 6: PERFORMANCE PAR BRANCHE
-- ============================================================================

CREATE OR REPLACE PROCEDURE sp_get_branch_performance (
    p_date_from IN DATE DEFAULT TRUNC(SYSDATE, 'MM'),
    p_date_to IN DATE DEFAULT SYSDATE,
    p_cursor OUT SYS_REFCURSOR
) AS
BEGIN
    OPEN p_cursor FOR
    SELECT 
        b.branch_id,
        b.branch_name,
        b.address,
        b.phone,
        b.branch_capacity,
        
        -- Personnel
        (SELECT COUNT(*) FROM STAFF 
         WHERE branch_id = b.branch_id 
         AND is_active = 'Y') AS active_staff,
        
        -- Patrons
        (SELECT COUNT(*) FROM PATRONS 
         WHERE registered_branch_id = b.branch_id) AS total_patrons,
        (SELECT COUNT(*) FROM PATRONS 
         WHERE registered_branch_id = b.branch_id 
         AND account_status = 'Active') AS active_patrons,
        
        -- Copies
        (SELECT COUNT(*) FROM COPIES 
         WHERE branch_id = b.branch_id) AS total_copies,
        (SELECT COUNT(*) FROM COPIES 
         WHERE branch_id = b.branch_id 
         AND copy_status = 'Available') AS available_copies,
        
        -- Emprunts dans la période
        (SELECT COUNT(*) 
         FROM LOANS l 
         JOIN COPIES c ON l.copy_id = c.copy_id 
         WHERE c.branch_id = b.branch_id 
         AND l.checkout_date BETWEEN p_date_from AND p_date_to) AS period_checkouts,
        
        -- Emprunts actifs actuellement
        (SELECT COUNT(*) 
         FROM LOANS l 
         JOIN COPIES c ON l.copy_id = c.copy_id 
         WHERE c.branch_id = b.branch_id 
         AND l.loan_status = 'Active') AS current_active_loans,
        
        -- En retard
        (SELECT COUNT(*) 
         FROM LOANS l 
         JOIN COPIES c ON l.copy_id = c.copy_id 
         WHERE c.branch_id = b.branch_id 
         AND l.loan_status = 'Active' 
         AND l.due_date < SYSDATE) AS overdue_items,
        
        -- Taux d'utilisation
        ROUND(
            (SELECT COUNT(*) FROM COPIES 
             WHERE branch_id = b.branch_id 
             AND copy_status != 'Available') /
            NULLIF((SELECT COUNT(*) FROM COPIES 
                    WHERE branch_id = b.branch_id), 0) * 100, 2
        ) AS utilization_percentage,
        
        -- Amendes impayées
        (SELECT NVL(SUM(amount_due - amount_paid), 0)
         FROM FINES f
         JOIN PATRONS p ON f.patron_id = p.patron_id
         WHERE p.registered_branch_id = b.branch_id
         AND f.fine_status IN ('Unpaid', 'Partially Paid')) AS unpaid_fines
        
    FROM BRANCHES b
    ORDER BY b.branch_name;
END sp_get_branch_performance;
/

-- ============================================================================
-- SECTION 7: ALERTES RÉSERVATIONS EXPIRANTES
-- ============================================================================

CREATE OR REPLACE PROCEDURE sp_get_expiring_reservations (
    p_branch_id IN NUMBER DEFAULT NULL,
    p_cursor OUT SYS_REFCURSOR
) AS
BEGIN
    OPEN p_cursor FOR
    SELECT 
        r.reservation_id,
        p.patron_id,
        p.card_number,
        p.first_name || ' ' || p.last_name AS patron_name,
        p.email,
        p.phone,
        m.title,
        m.material_type,
        r.reservation_date,
        r.notification_date,
        r.pickup_deadline,
        TRUNC(r.pickup_deadline - SYSDATE) AS days_until_expiry,
        c.barcode AS reserved_copy,
        b.branch_name,
        CASE 
            WHEN TRUNC(r.pickup_deadline - SYSDATE) <= 0 THEN 'EXPIRED'
            WHEN TRUNC(r.pickup_deadline - SYSDATE) = 1 THEN 'EXPIRES_TOMORROW'
            ELSE 'EXPIRES_SOON'
        END AS alert_status
    FROM RESERVATIONS r
    JOIN PATRONS p ON r.patron_id = p.patron_id
    JOIN MATERIALS m ON r.material_id = m.material_id
    LEFT JOIN COPIES c ON r.fulfilled_by_copy_id = c.copy_id
    LEFT JOIN BRANCHES b ON c.branch_id = b.branch_id
    WHERE r.reservation_status = 'Ready'
      AND r.pickup_deadline IS NOT NULL
      AND (p_branch_id IS NULL OR c.branch_id = p_branch_id)
    ORDER BY r.pickup_deadline ASC;
END sp_get_expiring_reservations;
/

-- ============================================================================
-- SECTION 8: RAPPORT D'ACTIVITÉ QUOTIDIENNE
-- ============================================================================

CREATE OR REPLACE PROCEDURE sp_get_daily_activity (
    p_date IN DATE DEFAULT TRUNC(SYSDATE),
    p_branch_id IN NUMBER DEFAULT NULL,
    p_cursor OUT SYS_REFCURSOR
) AS
BEGIN
    OPEN p_cursor FOR
    SELECT 
        'NEW_PATRONS' AS activity_type,
        COUNT(*) AS count,
        NULL AS total_amount
    FROM PATRONS
    WHERE TRUNC(registration_date) = p_date
      AND (p_branch_id IS NULL OR registered_branch_id = p_branch_id)
    
    UNION ALL
    
    SELECT 
        'CHECKOUTS' AS activity_type,
        COUNT(*) AS count,
        NULL AS total_amount
    FROM LOANS l
    JOIN COPIES c ON l.copy_id = c.copy_id
    WHERE TRUNC(l.checkout_date) = p_date
      AND (p_branch_id IS NULL OR c.branch_id = p_branch_id)
    
    UNION ALL
    
    SELECT 
        'RETURNS' AS activity_type,
        COUNT(*) AS count,
        NULL AS total_amount
    FROM LOANS l
    JOIN COPIES c ON l.copy_id = c.copy_id
    WHERE TRUNC(l.return_date) = p_date
      AND (p_branch_id IS NULL OR c.branch_id = p_branch_id)
    
    UNION ALL
    
    SELECT 
        'NEW_RESERVATIONS' AS activity_type,
        COUNT(*) AS count,
        NULL AS total_amount
    FROM RESERVATIONS
    WHERE TRUNC(reservation_date) = p_date
    
    UNION ALL
    
    SELECT 
        'FINES_COLLECTED' AS activity_type,
        COUNT(*) AS count,
        SUM(amount_paid) AS total_amount
    FROM FINES
    WHERE TRUNC(payment_date) = p_date
      AND fine_status IN ('Paid', 'Partially Paid')
    
    UNION ALL
    
    SELECT 
        'FINES_ASSESSED' AS activity_type,
        COUNT(*) AS count,
        SUM(amount_due) AS total_amount
    FROM FINES
    WHERE TRUNC(date_assessed) = p_date;
END sp_get_daily_activity;
/

-- ============================================================================
-- SECTION 9: STATISTIQUES PAR TYPE D'ABONNEMENT
-- ============================================================================

CREATE OR REPLACE PROCEDURE sp_get_membership_stats (
    p_cursor OUT SYS_REFCURSOR
) AS
BEGIN
    OPEN p_cursor FOR
    SELECT 
        p.membership_type,
        COUNT(*) AS total_members,
        SUM(CASE WHEN p.account_status = 'Active' 
            THEN 1 ELSE 0 END) AS active_members,
        SUM(CASE WHEN p.account_status = 'Expired' 
            THEN 1 ELSE 0 END) AS expired_members,
        
        -- Emprunts totaux
        (SELECT COUNT(*) 
         FROM LOANS l 
         WHERE l.patron_id IN (
             SELECT patron_id FROM PATRONS 
             WHERE membership_type = p.membership_type
         )) AS total_loans,
        
        -- Emprunts actifs
        (SELECT COUNT(*) 
         FROM LOANS l 
         WHERE l.patron_id IN (
             SELECT patron_id FROM PATRONS 
             WHERE membership_type = p.membership_type
         ) AND l.loan_status = 'Active') AS active_loans,
        
        -- Amendes totales
        NVL(SUM(p.total_fines_owed), 0) AS total_fines_owed,
        ROUND(AVG(p.total_fines_owed), 2) AS avg_fines_per_member,
        
        -- Réservations actives
        (SELECT COUNT(*) 
         FROM RESERVATIONS r 
         WHERE r.patron_id IN (
             SELECT patron_id FROM PATRONS 
             WHERE membership_type = p.membership_type
         ) AND r.reservation_status = 'Pending') AS active_reservations
        
    FROM PATRONS p
    GROUP BY p.membership_type
    ORDER BY total_members DESC;
END sp_get_membership_stats;
/

-- ============================================================================
-- SECTION 10: PATRONS À RISQUE
-- ============================================================================

CREATE OR REPLACE PROCEDURE sp_get_at_risk_patrons (
    p_branch_id IN NUMBER DEFAULT NULL,
    p_cursor OUT SYS_REFCURSOR
) AS
BEGIN
    OPEN p_cursor FOR
    SELECT 
        p.patron_id,
        p.card_number,
        p.first_name || ' ' || p.last_name AS patron_name,
        p.email,
        p.phone,
        p.membership_type,
        p.account_status,
        
        -- Emprunts en retard
        (SELECT COUNT(*) 
         FROM LOANS 
         WHERE patron_id = p.patron_id 
         AND loan_status = 'Active' 
         AND due_date < SYSDATE) AS overdue_items,
        
        -- Jours de retard maximum
        (SELECT MAX(TRUNC(SYSDATE - due_date))
         FROM LOANS 
         WHERE patron_id = p.patron_id 
         AND loan_status = 'Active' 
         AND due_date < SYSDATE) AS max_days_overdue,
        
        -- Amendes
        p.total_fines_owed,
        
        -- Amendes impayées (nombre)
        (SELECT COUNT(*) 
         FROM FINES 
         WHERE patron_id = p.patron_id 
         AND fine_status = 'Unpaid') AS unpaid_fine_count,
        
        -- Items perdus
        (SELECT COUNT(*) 
         FROM LOANS 
         WHERE patron_id = p.patron_id 
         AND loan_status = 'Lost') AS lost_items,
        
        -- Score de risque
        (
            COALESCE((SELECT COUNT(*) 
             FROM LOANS 
             WHERE patron_id = p.patron_id 
             AND loan_status = 'Active' 
             AND due_date < SYSDATE), 0) * 10
            +
            COALESCE(p.total_fines_owed / 10, 0)
            +
            COALESCE((SELECT COUNT(*) 
             FROM LOANS 
             WHERE patron_id = p.patron_id 
             AND loan_status = 'Lost'), 0) * 50
        ) AS risk_score,
        
        -- Catégorie de risque
        CASE 
            WHEN p.account_status = 'Blocked' THEN 'BLOCKED'
            WHEN p.account_status = 'Suspended' THEN 'SUSPENDED'
            WHEN EXISTS (
                SELECT 1 FROM LOANS 
                WHERE patron_id = p.patron_id 
                AND loan_status = 'Lost'
            ) THEN 'LOST_ITEMS'
            WHEN p.total_fines_owed > 100 THEN 'HIGH_FINES'
            WHEN (SELECT COUNT(*) FROM LOANS 
                  WHERE patron_id = p.patron_id 
                  AND loan_status = 'Active' 
                  AND due_date < SYSDATE) > 3 
                THEN 'MULTIPLE_OVERDUE'
            WHEN p.total_fines_owed > 50 THEN 'MODERATE_FINES'
            ELSE 'LOW_RISK'
        END AS risk_category
        
    FROM PATRONS p
    WHERE (p_branch_id IS NULL OR p.registered_branch_id = p_branch_id)
    ORDER BY risk_score DESC;
END sp_get_at_risk_patrons;
/

-- ============================================================================
-- SECTION 11: STATISTIQUES MENSUELLES
-- ============================================================================

CREATE OR REPLACE PROCEDURE sp_get_monthly_stats (
    p_month IN NUMBER DEFAULT EXTRACT(MONTH FROM SYSDATE),
    p_year IN NUMBER DEFAULT EXTRACT(YEAR FROM SYSDATE),
    p_cursor OUT SYS_REFCURSOR
) AS
    v_start_date DATE;
    v_end_date DATE;
BEGIN
    v_start_date := TO_DATE('01-' || p_month || '-' || p_year, 'DD-MM-YYYY');
    v_end_date := LAST_DAY(v_start_date);
    
    OPEN p_cursor FOR
        SELECT 'CHECKOUTS' AS metric,
               COUNT(*) AS count_value
        FROM LOANS 
        WHERE checkout_date BETWEEN v_start_date AND v_end_date
        
        UNION ALL
        
        SELECT 'RETURNS' AS metric,
               COUNT(*)
        FROM LOANS
        WHERE return_date BETWEEN v_start_date AND v_end_date
        
        UNION ALL
        
        SELECT 'NEW_PATRONS' AS metric,
               COUNT(*)
        FROM PATRONS
        WHERE registration_date BETWEEN v_start_date AND v_end_date
        
        UNION ALL
        
        SELECT 'FINES_ASSESSED' AS metric,
               COUNT(*)
        FROM FINES
        WHERE date_assessed BETWEEN v_start_date AND v_end_date
        
        UNION ALL
        
        SELECT 'FINES_COLLECTED' AS metric,
               COUNT(*)
        FROM FINES
        WHERE payment_date BETWEEN v_start_date AND v_end_date;
END sp_get_monthly_stats;
/
