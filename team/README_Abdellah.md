# Abdellah - PL/SQL Procedures & Functions
Branch: Abdellah-procedures

## Fichiers
- scripts/06_procedures_functions.sql (42KB, ~3000 lignes)
- team/abdellah_procedures.sql
- tests/test_procedures.sql

## Fonctionnalités (35+)
### Gestion Adhérents (5)
sp_add_patron, sp_update_patron, sp_renew_membership, sp_suspend_patron, sp_reactivate_patron

### Gestion Prêts (4)
sp_checkout_item, sp_checkin_item, sp_renew_loan, sp_declare_item_lost

### Gestion Documents (4)
sp_add_material, sp_add_copy, sp_update_material, sp_delete_material

### Réservations (3)
sp_place_reservation, sp_cancel_reservation, sp_fulfill_reservation

### Amendes (3)
sp_pay_fine, sp_waive_fine, sp_assess_fine

### Fonctions (11)
fn_patron_exists, fn_calculate_loan_period, fn_calculate_borrow_limit, 
fn_get_active_loan_count, fn_calculate_overdue_fine, fn_check_patron_eligibility,
fn_get_patron_statistics, fn_get_overdue_count, fn_calculate_total_fines, 
fn_check_material_availability

### Batch (4)
sp_process_overdue_notifications, sp_expire_memberships, 
sp_cleanup_expired_reservations, sp_generate_daily_report

## Dépendances
1. 01_create_users_roles.sql (Ilyass)
2. 02_grant_privileges.sql (Ilyass)  
3. 03_create_tables.sql (Aymane) ✅

## Tests
sqlplus user/pass @tests/test_procedures.sql

## Status
- [x] Code complet (42KB)
- [x] Tests créés
- [ ] Review équipe
- [ ] Merge main
