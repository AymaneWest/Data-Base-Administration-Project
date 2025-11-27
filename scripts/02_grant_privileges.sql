-- ============================================================================
-- FICHIER 2: 02_grant_privileges.sql
-- AUTEUR :ait taqmout ilyass (DBA)
-- OBJECTIF : Attribue les privilèges granulaires à chaque rôle métier
--            et assigne ces rôles aux utilisateurs de test.
-- ============================================================================

-- ============================================================================
-- === 1. ROLE_SYS_ADMIN ===
-- "Full system access... manages users, roles... Can override."
-- ============================================================================
GRANT ALL PRIVILEGES ON LIBRARIES TO ROLE_SYS_ADMIN;
GRANT ALL PRIVILEGES ON BRANCHES TO ROLE_SYS_ADMIN;
GRANT ALL PRIVILEGES ON PATRONS TO ROLE_SYS_ADMIN;
GRANT ALL PRIVILEGES ON MATERIALS TO ROLE_SYS_ADMIN;
GRANT ALL PRIVILEGES ON COPIES TO ROLE_SYS_ADMIN;
GRANT ALL PRIVILEGES ON LOANS TO ROLE_SYS_ADMIN;
GRANT ALL PRIVILEGES ON RESERVATIONS TO ROLE_SYS_ADMIN;
GRANT ALL PRIVILEGES ON FINES TO ROLE_SYS_ADMIN;
GRANT ALL PRIVILEGES ON STAFF TO ROLE_SYS_ADMIN;
GRANT ALL PRIVILEGES ON USERS TO ROLE_SYS_ADMIN;
-- ... (et toutes les autres tables : AUTHORS, GENRES, etc.)
GRANT ALL PRIVILEGES ON AUTHORS TO ROLE_SYS_ADMIN;
GRANT ALL PRIVILEGES ON PUBLISHERS TO ROLE_SYS_ADMIN;
GRANT ALL PRIVILEGES ON GENRES TO ROLE_SYS_ADMIN;
-- Accès total à TOUT le code PL/SQL
GRANT EXECUTE ON pkg_library_config TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON sp_add_patron TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON sp_checkout_item TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON sp_checkin_item TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON sp_add_material TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON sp_delete_material TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON sp_pay_fine TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON sp_process_overdue_notifications TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON sp_expire_memberships TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON sp_cleanup_expired_reservations TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON sp_test_all_procedures TO ROLE_SYS_ADMIN;
-- (et toutes les autres procédures/fonctions)
GRANT EXECUTE ON fn_patron_exists TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON fn_calculate_loan_period TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON fn_calculate_borrow_limit TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON fn_get_active_loan_count TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON fn_calculate_overdue_fine TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON fn_check_patron_eligibility TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON sp_update_patron TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON sp_renew_membership TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON sp_suspend_patron TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON sp_reactivate_patron TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON sp_renew_loan TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON sp_declare_item_lost TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON sp_add_copy TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON sp_update_material TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON sp_place_reservation TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON sp_cancel_reservation TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON sp_fulfill_reservation TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON sp_waive_fine TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON sp_assess_fine TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON fn_get_patron_statistics TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON fn_get_overdue_count TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON fn_calculate_total_fines TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON fn_check_material_availability TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON sp_generate_daily_report TO ROLE_SYS_ADMIN;

-- ============================================================================
-- === 2. ROLE_DIRECTOR ===
-- "Oversees... generates strategic reports, manages staff."
-- ============================================================================
-- Droit de LECTURE (SELECT) sur toutes les tables pour les rapports.
GRANT SELECT ON LIBRARIES TO ROLE_DIRECTOR;
GRANT SELECT ON BRANCHES TO ROLE_DIRECTOR;
GRANT SELECT ON PATRONS TO ROLE_DIRECTOR;
GRANT SELECT ON MATERIALS TO ROLE_DIRECTOR;
GRANT SELECT ON COPIES TO ROLE_DIRECTOR;
GRANT SELECT ON LOANS TO ROLE_DIRECTOR;
GRANT SELECT ON RESERVATIONS TO ROLE_DIRECTOR;
GRANT SELECT ON FINES TO ROLE_DIRECTOR;
GRANT SELECT ON STAFF TO ROLE_DIRECTOR; -- Peut voir le personnel
GRANT SELECT ON USERS TO ROLE_DIRECTOR;
GRANT SELECT ON AUTHORS TO ROLE_DIRECTOR;
GRANT SELECT ON PUBLISHERS TO ROLE_DIRECTOR;
GRANT SELECT ON GENRES TO ROLE_DIRECTOR;
-- Droit d'EXÉCUTION sur les fonctions/procédures de reporting.
GRANT EXECUTE ON fn_get_patron_statistics TO ROLE_DIRECTOR;
GRANT EXECUTE ON fn_get_overdue_count TO ROLE_DIRECTOR;
GRANT EXECUTE ON fn_calculate_total_fines TO ROLE_DIRECTOR;
GRANT EXECUTE ON sp_generate_daily_report TO ROLE_DIRECTOR;

-- ============================================================================
-- === 3. ROLE_CATALOGER ===
-- "Specialist in catalog management - adds new materials, updates metadata..."
-- ============================================================================
-- Droits de LECTURE et MODIFICATION sur les tables du catalogue.
GRANT SELECT, INSERT, UPDATE, DELETE ON MATERIALS TO ROLE_CATALOGER;
GRANT SELECT, INSERT, UPDATE, DELETE ON AUTHORS TO ROLE_CATALOGER;
GRANT SELECT, INSERT, UPDATE, DELETE ON PUBLISHERS TO ROLE_CATALOGER;
GRANT SELECT, INSERT, UPDATE, DELETE ON GENRES TO ROLE_CATALOGER;
GRANT SELECT, INSERT, UPDATE, DELETE ON MATERIAL_AUTHORS TO ROLE_CATALOGER;
GRANT SELECT, INSERT, UPDATE, DELETE ON MATERIAL_GENRES TO ROLE_CATALOGER;
GRANT SELECT, INSERT, UPDATE, DELETE ON COPIES TO ROLE_CATALOGER;
-- Droit d'EXÉCUTION sur les procédures de catalogue.
GRANT EXECUTE ON sp_add_material TO ROLE_CATALOGER;
GRANT EXECUTE ON sp_update_material TO ROLE_CATALOGER;
GRANT EXECUTE ON sp_add_copy TO ROLE_CATALOGER;
-- (Note: Pas d'accès à PATRONS, LOANS, FINES, ou STAFF)

-- ============================================================================
-- === 4. ROLE_CIRCULATION_CLERK ===
-- "Handles day-to-day circulation - checkouts, returns, holds, patron services."
-- ============================================================================
-- Droits de LECTURE et MODIFICATION sur les tables de circulation.
GRANT SELECT, INSERT, UPDATE, DELETE ON LOANS TO ROLE_CIRCULATION_CLERK;
GRANT SELECT, INSERT, UPDATE, DELETE ON RESERVATIONS TO ROLE_CIRCULATION_CLERK;
GRANT SELECT, INSERT, UPDATE, DELETE ON FINES TO ROLE_CIRCULATION_CLERK;
-- Gère les usagers (Patrons)
GRANT SELECT, INSERT, UPDATE ON PATRONS TO ROLE_CIRCULATION_CLERK;
-- A besoin de VOIR le catalogue pour travailler
GRANT SELECT ON MATERIALS TO ROLE_CIRCULATION_CLERK;
GRANT SELECT ON COPIES TO ROLE_CIRCULATION_CLERK;
-- Droit d'EXÉCUTION sur toutes les procédures de circulation.
GRANT EXECUTE ON fn_patron_exists TO ROLE_CIRCULATION_CLERK;
GRANT EXECUTE ON fn_calculate_loan_period TO ROLE_CIRCULATION_CLERK;
GRANT EXECUTE ON fn_calculate_borrow_limit TO ROLE_CIRCULATION_CLERK;
GRANT EXECUTE ON fn_get_active_loan_count TO ROLE_CIRCULATION_CLERK;
GRANT EXECUTE ON fn_calculate_overdue_fine TO ROLE_CIRCULATION_CLERK;
GRANT EXECUTE ON fn_check_patron_eligibility TO ROLE_CIRCULATION_CLERK;
GRANT EXECUTE ON sp_add_patron TO ROLE_CIRCULATION_CLERK;
GRANT EXECUTE ON sp_update_patron TO ROLE_CIRCULATION_CLERK;
GRANT EXECUTE ON sp_renew_membership TO ROLE_CIRCULATION_CLERK;
GRANT EXECUTE ON sp_suspend_patron TO ROLE_CIRCULATION_CLERK;
GRANT EXECUTE ON sp_reactivate_patron TO ROLE_CIRCULATION_CLERK;
GRANT EXECUTE ON sp_checkout_item TO ROLE_CIRCULATION_CLERK;
GRANT EXECUTE ON sp_checkin_item TO ROLE_CIRCULATION_CLERK;
GRANT EXECUTE ON sp_renew_loan TO ROLE_CIRCULATION_CLERK;
GRANT EXECUTE ON sp_declare_item_lost TO ROLE_CIRCULATION_CLERK;
GRANT EXECUTE ON sp_place_reservation TO ROLE_CIRCULATION_CLERK;
GRANT EXECUTE ON sp_cancel_reservation TO ROLE_CIRCULATION_CLERK;
GRANT EXECUTE ON sp_fulfill_reservation TO ROLE_CIRCULATION_CLERK;
GRANT EXECUTE ON sp_pay_fine TO ROLE_CIRCULATION_CLERK;
GRANT EXECUTE ON sp_waive_fine TO ROLE_CIRCULATION_CLERK;
GRANT EXECUTE ON sp_assess_fine TO ROLE_CIRCULATION_CLERK;
GRANT EXECUTE ON fn_check_material_availability TO ROLE_CIRCULATION_CLERK;

-- ============================================================================
-- === 5. ROLE_IT_SUPPORT ===
-- "Technical support - manages system, Limited business data access."
-- ============================================================================
-- Accès LECTURE aux tables de configuration.
GRANT SELECT ON LIBRARIES TO ROLE_IT_SUPPORT;
GRANT SELECT ON BRANCHES TO ROLE_IT_SUPPORT;
-- Droit d'EXÉCUTION sur les tâches de maintenance "batch" (par lot).
GRANT EXECUTE ON sp_process_overdue_notifications TO ROLE_IT_SUPPORT;
GRANT EXECUTE ON sp_expire_memberships TO ROLE_IT_SUPPORT;
GRANT EXECUTE ON sp_cleanup_expired_reservations TO ROLE_IT_SUPPORT;
-- (Note: Pas d'accès à PATRONS, LOANS, FINES, ou STAFF)

-- ============================================================================
-- Étape 3 : Assigner les Rôles (profils) aux Utilisateurs de test
-- ============================================================================

GRANT ROLE_SYS_ADMIN TO user_sysadmin;
GRANT ROLE_DIRECTOR TO user_director;
GRANT ROLE_CATALOGER TO user_cataloger;
GRANT ROLE_CIRCULATION_CLERK TO user_clerk;
GRANT ROLE_IT_SUPPORT TO user_itsupport;
commit;

--=============================================================================
--AUTRE FINCTION:CREER PAR AYMAN
--=============================================================================


-- ROLE_SYS_ADMIN : Accès complet aux fonctions et procédures
GRANT EXECUTE ON fn_hash_password TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON fn_verify_password TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON fn_has_permission TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON fn_has_role TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON fn_get_user_roles TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON fn_is_session_valid TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON fn_get_session_user_id TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON fn_get_session_remaining_time TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON fn_is_user_active TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON fn_is_account_locked TO ROLE_SYS_ADMIN;

GRANT EXECUTE ON sp_authenticate_user TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON sp_logout_user TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON sp_change_password TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON sp_validate_session TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON sp_check_user_permission TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON sp_assign_role_to_user TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON sp_revoke_role_from_user TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON sp_clean_expired_sessions TO ROLE_SYS_ADMIN;

-- ROLE_DIRECTOR : Accès aux fonctions/fonctions liées aux rapports et sessions

GRANT EXECUTE ON fn_has_permission TO ROLE_DIRECTOR;
GRANT EXECUTE ON fn_has_role TO ROLE_DIRECTOR;
GRANT EXECUTE ON fn_get_user_roles TO ROLE_DIRECTOR;

-- ROLE_CATALOGER : Accès limité aux fonctions liées à gestion utilisateurs/sessions
GRANT EXECUTE ON fn_has_permission TO ROLE_CATALOGER;
GRANT EXECUTE ON fn_has_role TO ROLE_CATALOGER;

-- ROLE_CIRCULATION_CLERK : Accès aux fonctions utilisées pour validation des prêts et usagers
GRANT EXECUTE ON fn_has_permission TO ROLE_CIRCULATION_CLERK;
GRANT EXECUTE ON fn_has_role TO ROLE_CIRCULATION_CLERK;
GRANT EXECUTE ON fn_is_user_active TO ROLE_CIRCULATION_CLERK;
GRANT EXECUTE ON fn_is_account_locked TO ROLE_CIRCULATION_CLERK;

GRANT EXECUTE ON sp_authenticate_user TO ROLE_CIRCULATION_CLERK;
GRANT EXECUTE ON sp_logout_user TO ROLE_CIRCULATION_CLERK;
GRANT EXECUTE ON sp_change_password TO ROLE_CIRCULATION_CLERK;
GRANT EXECUTE ON sp_validate_session TO ROLE_CIRCULATION_CLERK;
GRANT EXECUTE ON sp_check_user_permission TO ROLE_CIRCULATION_CLERK;

-- ROLE_IT_SUPPORT : Accès aux procédures de session et permission pour maintenance
GRANT EXECUTE ON fn_has_permission TO ROLE_IT_SUPPORT;
GRANT EXECUTE ON fn_has_role TO ROLE_IT_SUPPORT;
GRANT EXECUTE ON fn_is_session_valid TO ROLE_IT_SUPPORT;
GRANT EXECUTE ON sp_clean_expired_sessions TO ROLE_IT_SUPPORT;
COMMIT;

