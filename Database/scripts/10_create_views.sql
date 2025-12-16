-- ============================================================================
-- FICHIER 10: 10_create_views.sql
-- OBJECTIF : Créer des vues pour les graphiques du tableau de bord
-- ============================================================================

-- Vue pour les statistiques globales du tableau de bord (Admin/Staff)
CREATE OR REPLACE VIEW VIEW_DASHBOARD_STATS AS
SELECT
    (SELECT COUNT(*) FROM PATRONS) AS total_patrons,
    (SELECT COUNT(*) FROM MATERIALS) AS total_materials,
    (SELECT COUNT(*) FROM LOANS WHERE loan_status = 'Active') AS active_loans,
    (SELECT COUNT(*) FROM LOANS WHERE loan_status = 'Overdue') AS overdue_loans,
    (SELECT SUM(amount_due - amount_paid) FROM FINES WHERE fine_status = 'Unpaid') AS outstanding_fines
FROM DUAL;

-- Vue pour l'activité mensuelle des prêts et retours (Derniers 12 mois)
CREATE OR REPLACE VIEW VIEW_MONTHLY_ACTIVITY AS
SELECT
    TO_CHAR(TRUNC(action_date, 'MM'), 'YYYY-MM') AS month_year,
    SUM(CASE WHEN action_type = 'CHECKOUT' THEN 1 ELSE 0 END) AS total_checkouts,
    SUM(CASE WHEN action_type = 'RETURN' THEN 1 ELSE 0 END) AS total_returns
FROM (
    SELECT checkout_date AS action_date, 'CHECKOUT' AS action_type FROM LOANS
    UNION ALL
    SELECT return_date AS action_date, 'RETURN' AS action_type FROM LOANS WHERE return_date IS NOT NULL
)
WHERE action_date >= ADD_MONTHS(SYSDATE, -12)
GROUP BY TRUNC(action_date, 'MM')
ORDER BY TRUNC(action_date, 'MM');

-- Vue pour la répartition des matériaux par type
CREATE OR REPLACE VIEW VIEW_MATERIAL_DISTRIBUTION AS
SELECT material_type, COUNT(*) as count
FROM MATERIALS
GROUP BY material_type;

-- Vue pour les livres les plus populaires (Top 10)
CREATE OR REPLACE VIEW VIEW_POPULAR_BOOKS AS
SELECT * FROM (
    SELECT m.title, COUNT(l.loan_id) as loan_count
    FROM MATERIALS m
    JOIN COPIES c ON m.material_id = c.material_id
    JOIN LOANS l ON c.copy_id = l.copy_id
    GROUP BY m.title
    ORDER BY loan_count DESC
)
WHERE ROWNUM <= 10;
