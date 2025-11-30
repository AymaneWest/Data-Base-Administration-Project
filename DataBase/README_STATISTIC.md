# 📚 Library Management System – Stored Procedures Documentation

Version : 1.0
Date : Novembre 2025
Base de données : Oracle PL/SQL

## 📑 Table of Contents

1.Admin Dashboard

2.Patron Details

3.Expiring Loans

4.Fines Report

5.Popular Materials

6.Branch Performance

7.Expiring Reservations

8.Daily Activity Report

9.Membership Statistics

10.At-Risk Patrons

11.Monthly Statistics

12.Usage Notes

13.Examples

## 1️⃣ Admin Dashboard
### Procedure : *sp_get_admin_dashboard*

| Élément        | Description                                                                |
| -------------- | -------------------------------------------------------------------------- |
| **Objectif**   | Vue d’ensemble des statistiques de la bibliothèque                         |
| **Paramètres** | `p_branch_id` (OPTIONNEL), `p_cursor` (OUT)                                |
| **Retourne**   | Statistiques patrons, emprunts, matériaux, réservations, amendes, branches |

#### Données retournées

| Élément        | Description                                                                |
| -------------- | -------------------------------------------------------------------------- |
| **Objectif**   | Vue d’ensemble des statistiques de la bibliothèque                         |
| **Paramètres** | `p_branch_id` (OPTIONNEL), `p_cursor` (OUT)                                |
| **Retourne**   | Statistiques patrons, emprunts, matériaux, réservations, amendes, branches |

#### Données retournées

| Catégorie    | Champs                                                                                   |
| ------------ | ---------------------------------------------------------------------------------------- |
| Patrons      | total_patrons, active_patrons, suspended_patrons, expired_patrons, new_patrons_today     |
| Emprunts     | total_active_loans, overdue_loans, checkouts_today, returns_today, loans_due_soon        |
| Matériaux    | total_materials, total_copies, available_copies, new_releases, lost_items, damaged_items |
| Réservations | pending_reservations, ready_reservations, expired_reservations                           |
| Amendes      | total_unpaid_fines, fines_collected_today, unpaid_fine_count                             |
| Système      | total_branches, active_staff                                                             |


## 2️⃣ Patron Details

### Procedure : *sp_get_patron_details*

| Élément        | Description                          |
| -------------- | ------------------------------------ |
| **Objectif**   | Informations complètes sur un patron |
| **Paramètres** | `p_patron_id`, 4 curseurs OUT        |
| **Curseurs**   | info, loans, fines, reservations     |

#### Résumé des curseurs

| Curseur                   | Contenu                                                    |
| ------------------------- | ---------------------------------------------------------- |
| **p_info_cursor**         | données personnelles, abonnement, amendes, emprunts actifs |
| **p_loans_cursor**        | 20 derniers emprunts, retards, renouvellements             |
| **p_fines_cursor**        | amendes, montants, statuts                                 |
| **p_reservations_cursor** | réservations, notifications, dates limite                  |


## 3️⃣ Expiring Loans

#### Procedure : *sp_get_expiring_loans*

| Élément                   | Description                               |
| ------------------------- | ----------------------------------------- |
| **Objectif**              | Emprunts arrivant à expiration            |
| **Paramètres**            | `p_days_ahead`, `p_branch_id`, `p_cursor` |
| **Alerte**                | Due Today, Tomorrow, Soon                 |
| **Statut renouvellement** | NO_RENEWAL, RESERVED, CAN_RENEW           |


## 4️⃣ Fines Report

### Procedure : *sp_get_fines_report*

| Élément        | Description                                       |
| -------------- | ------------------------------------------------- |
| **Objectif**   | Rapport filtré des amendes                        |
| **Paramètres** | Filtre statut, branche, dates                     |
| **Retourne**   | Montants, types, statuts, employés, date paiement |


## 5️⃣ Popular Materials

### Procedure : *sp_get_popular_materials*

| Élément        | Description                                              |
| -------------- | -------------------------------------------------------- |
| **Objectif**   | Identifier les matériaux les plus empruntés              |
| **Paramètres** | top_n, type, période                                     |
| **Retourne**   | Statistiques d’emprunt, copies dispo, taux d'utilisation |


## 7️⃣ Expiring Reservations

### Procedure : *sp_get_expiring_reservations*

| Élément        | Description                                 |
| -------------- | ------------------------------------------- |
| **Objectif**   | Réservations prêtes et proches d’expiration |
| **Alerte**     | EXPIRED, EXPIRES_TOMORROW, EXPIRES_SOON     |
| **Paramètres** | Branch_id, cursor                           |


## 8️⃣ Daily Activity Report

### Procedure : *sp_get_daily_activity*
| Activité         | Contenu                |
| ---------------- | ---------------------- |
| NEW_PATRONS      | nouvelles inscriptions |
| CHECKOUTS        | emprunts effectués     |
| RETURNS          | retours                |
| NEW_RESERVATIONS | réservations           |
| FINES_COLLECTED  | montants collectés     |
| FINES_ASSESSED   | amendes évaluées       |


## 9️⃣ Membership Statistics

### Procedure : *sp_get_membership_stats*

| Élément  | Description                              |
| -------- | ---------------------------------------- |
| Objectif | Stats par type d’abonnement              |
| Retourne | membres, emprunts, amendes, réservations |


## 🔟 At-Risk Patrons

### Procedure : *sp_get_at_risk_patrons*

| Élément    | Description                                                            |
| ---------- | ---------------------------------------------------------------------- |
| Objectif   | Patrons problématiques                                                 |
| Score      | basé sur retards + amendes + items perdus                              |
| Catégories | BLOCKED, SUSPENDED, LOST_ITEMS, HIGH_FINES, MULTIPLE_OVERDUE, LOW_RISK |


## 1️⃣1️⃣ Monthly Statistics

### Procedure : sp_get_monthly_stats
| Métrique        | Description  |
| --------------- | ------------ |
| CHECKOUTS       | emprunts     |
| RETURNS         | retours      |
| NEW_PATRONS     | inscriptions |
| FINES_ASSESSED  | amendes      |
| FINES_COLLECTED | paiements    |


## 1️⃣2️⃣ Usage Notes

| Sujet       | Description                                        |
| ----------- | -------------------------------------------------- |
| Nommage     | préfixe `sp_`, paramètres `p_`, curseurs `_cursor` |
| Erreurs     | gérer côté application                             |
| Performance | indexes, jointures optimisées                      |
| Sécurité    | vérifier les permissions applicatives              |
| REF CURSOR  | à fermer côté application                          |

