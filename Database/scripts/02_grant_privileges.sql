-- ============================================================================
-- FICHIER 2: 02_grant_privileges.sql
-- AUTEUR :ait taqmout ilyass (DBA)
-- OBJECTIF : Attribue les privilèges granulaires à chaque rôle métier
--            et assigne ces rôles aux utilisateurs de test.
-- ============================================================================

-- Configuration et Utilitaires
GRANT EXECUTE ON pkg_library_config TO ROLE_SYS_ADMIN;

-- Gestion des Patrons
GRANT EXECUTE ON sp_add_patron TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON sp_update_patron TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON sp_renew_membership TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON sp_suspend_patron TO ROLE_SYS_ADMIN; -- Droit critique
GRANT EXECUTE ON sp_reactivate_patron TO ROLE_SYS_ADMIN;

-- Circulation
GRANT EXECUTE ON sp_checkout_item TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON sp_checkin_item TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON sp_renew_loan TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON sp_declare_item_lost TO ROLE_SYS_ADMIN;

-- Matériel (Catalogue)
GRANT EXECUTE ON sp_add_material TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON sp_add_copy TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON sp_update_material TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON sp_delete_material TO ROLE_SYS_ADMIN; -- Droit critique

-- Réservations
GRANT EXECUTE ON sp_place_reservation TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON sp_cancel_reservation TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON sp_fulfill_reservation TO ROLE_SYS_ADMIN;

-- Amendes
GRANT EXECUTE ON sp_assess_fine TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON sp_pay_fine TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON sp_waive_fine TO ROLE_SYS_ADMIN; -- Droit critique (Annulation)

-- Batchs & Maintenance
GRANT EXECUTE ON sp_process_overdue_notifications TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON sp_expire_memberships TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON sp_cleanup_expired_reservations TO ROLE_SYS_ADMIN;

-- Reporting (Tous les rapports)
GRANT EXECUTE ON sp_get_admin_dashboard TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON sp_get_patron_details TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON sp_get_branch_performance TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON sp_get_daily_activity TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON sp_get_at_risk_patrons TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON sp_generate_daily_report TO ROLE_SYS_ADMIN;

-- Sécurité & Auth (Administration des rôles)
GRANT EXECUTE ON sp_authenticate_user TO ROLE_SYS_ADMIN;
GRANT EXECUTE ON sp_assign_role_to_user TO ROLE_SYS_ADMIN; -- Critique
GRANT EXECUTE ON sp_revoke_role_from_user TO ROLE_SYS_ADMIN; -- Critique
GRANT EXECUTE ON sp_authenticate_and_get_oracle_user TO ROLE_SYS_ADMIN;

-- ============================================================================
-- 2. ROLE_DIRECTOR (Directeur de la bibliothèque)
-- Description : Rapports stratégiques, gestion des litiges (amendes, suspensions)
-- ============================================================================

-- Accès aux rapports stratégiques (Dashboard, Stats)
GRANT EXECUTE ON sp_get_admin_dashboard TO ROLE_DIRECTOR;
GRANT EXECUTE ON sp_get_branch_performance TO ROLE_DIRECTOR;
GRANT EXECUTE ON sp_get_membership_stats TO ROLE_DIRECTOR;
GRANT EXECUTE ON sp_get_monthly_stats TO ROLE_DIRECTOR;
GRANT EXECUTE ON sp_get_popular_materials TO ROLE_DIRECTOR;
GRANT EXECUTE ON sp_get_fines_report TO ROLE_DIRECTOR;
GRANT EXECUTE ON sp_get_at_risk_patrons TO ROLE_DIRECTOR;
GRANT EXECUTE ON sp_generate_daily_report TO ROLE_DIRECTOR;

-- Actions sensibles sur les Patrons (Suspension / Réactivation)
GRANT EXECUTE ON sp_suspend_patron TO ROLE_DIRECTOR;
GRANT EXECUTE ON sp_reactivate_patron TO ROLE_DIRECTOR;

-- Gestion sensible des finances (Annulation d'amendes)
GRANT EXECUTE ON sp_waive_fine TO ROLE_DIRECTOR;

-- Consultation (Lecture seule via les procédures de recherche/détails)
GRANT EXECUTE ON sp_get_patron_details TO ROLE_DIRECTOR;
GRANT EXECUTE ON fn_get_patron_statistics TO ROLE_DIRECTOR;

-- ============================================================================
-- 3. ROLE_CATALOGER (Le Catalogueur)
-- Description : Gestion complète de l'inventaire (Livres, Copies)
-- ============================================================================

-- CRUD Matériel (Ajout, Modification, Suppression)
GRANT EXECUTE ON sp_add_material TO ROLE_CATALOGER;
GRANT EXECUTE ON sp_update_material TO ROLE_CATALOGER;
GRANT EXECUTE ON sp_delete_material TO ROLE_CATALOGER;
GRANT EXECUTE ON sp_add_copy TO ROLE_CATALOGER;

-- Consultation des disponibilités
GRANT EXECUTE ON fn_check_material_availability TO ROLE_CATALOGER;
GRANT EXECUTE ON sp_get_popular_materials TO ROLE_CATALOGER; -- Pour analyser les besoins

-- Vérification des réservations (pour savoir si un livre peut être supprimé)
GRANT EXECUTE ON sp_get_expiring_reservations TO ROLE_CATALOGER;

-- ============================================================================
-- 4. ROLE_CIRCULATION_CLERK (Employé de circulation)
-- Description : Front-office, gestion des prêts, retours et patrons
-- ============================================================================

-- Configuration (Lecture pour les règles de prêt)
GRANT EXECUTE ON pkg_library_config TO ROLE_CIRCULATION_CLERK;

-- Gestion basique des Patrons (Inscription, Mise à jour)
GRANT EXECUTE ON sp_add_patron TO ROLE_CIRCULATION_CLERK;
GRANT EXECUTE ON sp_update_patron TO ROLE_CIRCULATION_CLERK;
GRANT EXECUTE ON sp_renew_membership TO ROLE_CIRCULATION_CLERK;
GRANT EXECUTE ON sp_get_patron_details TO ROLE_CIRCULATION_CLERK;
GRANT EXECUTE ON fn_check_patron_eligibility TO ROLE_CIRCULATION_CLERK;

-- Opérations de Prêt / Retour
GRANT EXECUTE ON sp_checkout_item TO ROLE_CIRCULATION_CLERK;
GRANT EXECUTE ON sp_checkin_item TO ROLE_CIRCULATION_CLERK;
GRANT EXECUTE ON sp_renew_loan TO ROLE_CIRCULATION_CLERK;
GRANT EXECUTE ON sp_declare_item_lost TO ROLE_CIRCULATION_CLERK;

-- Réservations
GRANT EXECUTE ON sp_place_reservation TO ROLE_CIRCULATION_CLERK;
GRANT EXECUTE ON sp_cancel_reservation TO ROLE_CIRCULATION_CLERK;
GRANT EXECUTE ON sp_fulfill_reservation TO ROLE_CIRCULATION_CLERK;
GRANT EXECUTE ON sp_get_expiring_reservations TO ROLE_CIRCULATION_CLERK;

-- Gestion quotidienne des amendes (Paiement et création, PAS d'annulation)
GRANT EXECUTE ON sp_pay_fine TO ROLE_CIRCULATION_CLERK;
GRANT EXECUTE ON sp_assess_fine TO ROLE_CIRCULATION_CLERK;

-- Alertes opérationnelles
GRANT EXECUTE ON sp_get_expiring_loans TO ROLE_CIRCULATION_CLERK;

-- ============================================================================
-- 5. ROLE_IT_SUPPORT (Support Technique)
-- Description : Gestion des accès, sessions, debug et batchs
-- ============================================================================

-- Authentification et Sécurité
GRANT EXECUTE ON sp_authenticate_user TO ROLE_IT_SUPPORT;
GRANT EXECUTE ON sp_logout_user TO ROLE_IT_SUPPORT;
GRANT EXECUTE ON sp_change_password TO ROLE_IT_SUPPORT;
GRANT EXECUTE ON sp_validate_session TO ROLE_IT_SUPPORT;
GRANT EXECUTE ON sp_clean_expired_sessions TO ROLE_IT_SUPPORT;
GRANT EXECUTE ON sp_check_user_permission TO ROLE_IT_SUPPORT;

-- Exécution des Batchs (Traitements par lots)
GRANT EXECUTE ON sp_process_overdue_notifications TO ROLE_IT_SUPPORT;
GRANT EXECUTE ON sp_expire_memberships TO ROLE_IT_SUPPORT;
GRANT EXECUTE ON sp_cleanup_expired_reservations TO ROLE_IT_SUPPORT;

-- Vues techniques (si besoin de créer des vues sur les tables de logs)
-- GRANT SELECT ON AUDIT_LOG TO ROLE_IT_SUPPORT; -- (Si la table est accessible)