# Abdellah - PL/SQL Procedures & Functions
Branch: Abdellah-procedures

Version: 3.0 (Production Ready)

Author: Abdellah (Student 3)

## Fichiers
- scripts/06_procedures_functions.sql (42KB, ~3000 lignes)
- team/abdellah_procedures.sql
- tests/test_procedures.sql

## Fonctionnalités (35+)
# Package: pkg_library_config
Ce package centralise toutes les constantes de configuration utilisées dans les procédures et fonctions du système.
| Constante                      | Type           | Description                                               |
| ------------------------------ | -------------- | --------------------------------------------------------- |
| `c_DAILY_OVERDUE_FINE`         | NUMBER = 2.00  | Amende quotidienne appliquée pour chaque jour de retard.  |
| `c_MAX_FINE_THRESHOLD`         | NUMBER = 50.00 | Montant maximal d’amende avant suspension du compte.      |
| `c_MAX_RENEWALS`               | NUMBER = 3     | Nombre maximal de renouvellements autorisés pour un prêt. |
| `c_MEMBERSHIP_DURATION_MONTHS` | NUMBER = 12    | Durée (en mois) d’un abonnement avant expiration.         |
| `c_LOAN_PERIOD_VIP`            | NUMBER = 42    | Durée d’un prêt pour un membre VIP (en jours).            |
| `c_LOAN_PERIOD_PREMIUM`        | NUMBER = 28    | Durée pour un membre Premium.                             |
| `c_LOAN_PERIOD_CHILD`          | NUMBER = 14    | Durée pour un compte Enfant.                              |
| `c_LOAN_PERIOD_STANDARD`       | NUMBER = 21    | Durée pour un membre Standard.                            |
| `c_BORROW_LIMIT_VIP`           | NUMBER = 20    | Nombre max de prêts pour VIP.                             |
| `c_BORROW_LIMIT_PREMIUM`       | NUMBER = 15    | Nombre max de prêts pour Premium.                         |
| `c_BORROW_LIMIT_STUDENT`       | NUMBER = 12    | Nombre max de prêts pour Étudiant.                        |
| `c_BORROW_LIMIT_CHILD`         | NUMBER = 5     | Nombre max de prêts pour Enfant.                          |
| `c_BORROW_LIMIT_STANDARD`      | NUMBER = 10    | Nombre max de prêts pour Standard.                        |

# Utility Functions
| **Fonction**                                                | **Rôle**                | **Description**                                                            |
| ----------------------------------------------------------- | ----------------------- | -------------------------------------------------------------------------- |
| `fn_patron_exists(p_patron_id)`                             | Vérifier existence      | Retourne `TRUE` si le patron existe dans la table `PATRONS`.               |
| `fn_calculate_loan_period(p_membership_type)`               | Calcul durée de prêt    | Retourne la durée de prêt selon le type d’abonnement du patron.            |
| `fn_calculate_borrow_limit(p_membership_type)`              | Calcul limite d’emprunt | Retourne le nombre maximum de livres que le patron peut emprunter.         |
| `fn_get_active_loan_count(p_patron_id)`                     | Nombre de prêts actifs  | Retourne le nombre total de prêts **toujours actifs** pour ce patron.      |
| `fn_calculate_overdue_fine(p_due_date, p_return_date)`      | Calcul amende de retard | Calcule l’amende : *jours de retard × `c_DAILY_OVERDUE_FINE`*.             |
| `fn_check_patron_eligibility(p_patron_id, p_error_message)` | Vérifier éligibilité    | Vérifie que le patron est actif, sans dettes, et sous la limite d’emprunt. |

# Patron Management Procedures
| Procédure              | Description                                                                                                                                                                                                                     |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `sp_add_patron`        | Ajoute un nouveau membre dans la base. Calcule automatiquement la date d’expiration (12 mois après l’inscription) et fixe la limite d’emprunt selon le type d’abonnement. Le compte est créé actif sans amendes.                |
| `sp_update_patron`     | Met à jour les coordonnées d’un membre (email, téléphone, adresse). Si un champ n’est pas renseigné, l’ancienne valeur est conservée. Vérifie que le membre existe avant modification.                                          |
| `sp_renew_membership`  | Renouvelle l’abonnement d’un membre pour 12 mois supplémentaires. Refuse le renouvellement si le compte est bloqué ou s’il reste des amendes impayées. Prolonge depuis la date d’expiration actuelle si elle est encore valide. |
| `sp_suspend_patron`    | Suspend un membre en changeant son statut à `Suspended`. Refuse si le compte est déjà suspendu ou bloqué. Enregistre la raison de la suspension.                                                                                |
| `sp_reactivate_patron` | Réactive un membre après le paiement de toutes ses dettes. Le statut passe à `Active` si le compte n’est plus bloqué et qu’aucune amende n’est due.                                                                             |


# Circulation Procedures (Loans)
| Procédure              | Description                                                                                                                                                                                          |
| ---------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `sp_checkout_item`     | Enregistre un emprunt pour un membre éligible. Vérifie que la copie est disponible, calcule la date de retour selon le type d’abonnement, et met à jour les tables `LOANS`, `COPIES` et `MATERIALS`. |
| `sp_checkin_item`      | Enregistre le retour d’un exemplaire. Calcule automatiquement l’amende de retard si nécessaire, met à jour le prêt comme “Returned” et rend la copie disponible.                                     |
| `sp_renew_loan`        | Prolonge la durée d’un prêt actif. Vérifie que le nombre maximum de renouvellements (3) n’est pas atteint, qu’aucune réservation n’existe et qu’aucune amende n’est due.                             |
| `sp_declare_item_lost` | Déclare une copie perdue et crée une amende correspondant au coût de remplacement. Le prêt est marqué comme “Lost” et la copie est retirée du stock disponible.                                      |


# Material Management Procedures
| Procédure            | Description                                                                                                                                 |
| -------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| `sp_add_material`    | Ajoute un nouveau document (livre, DVD, etc.) dans le catalogue avec ses informations et le nombre total de copies disponibles.             |
| `sp_add_copy`        | Ajoute une nouvelle copie d’un document existant. Vérifie que le document existe et met à jour le total et le nombre de copies disponibles. |
| `sp_update_material` | Met à jour les informations d’un document (titre, langue, description). Les valeurs non renseignées ne sont pas modifiées.                  |
| `sp_delete_material` | Supprime un document et ses copies associées uniquement s’il n’a aucun prêt actif. Supprime aussi les liens avec les auteurs et les genres. |


# Reservation Procedures
| Procédure                | Description                                                                                                                      |
| ------------------------ | -------------------------------------------------------------------------------------------------------------------------------- |
| `sp_place_reservation`   | Crée une réservation pour un document uniquement si aucune copie n’est disponible. Attribue une position dans la file d’attente. |
| `sp_cancel_reservation`  | Annule une réservation active et ajuste la position des autres membres dans la file d’attente.                                   |
| `sp_fulfill_reservation` | Marque une réservation comme prête à être retirée (`Ready`). Lie la réservation à une copie et fixe une date limite de retrait.  |


# Fine Management Procedures
| Procédure        | Description                                                                                                                                      |
| ---------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| `sp_pay_fine`    | Enregistre un paiement d’amende total ou partiel. Met à jour le statut de l’amende (`Paid` ou `Partially Paid`) et réduit le total dû du membre. |
| `sp_waive_fine`  | Annule (remet) une amende après validation par le personnel. Exige une raison d’au moins 10 caractères.                                          |
| `sp_assess_fine` | Crée une nouvelle amende manuelle (retard, perte, dégradation, etc.) et l’ajoute au solde du membre.                                             |


# Batch Procedures (Automatisation)
| Procédure                              | Description                                                                                                                                                                                       |
| -------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **`sp_process_overdue_notifications`** | Parcourt tous les prêts dont la date d’échéance est dépassée et envoie une notification de retard au lecteur concerné. Peut aussi appliquer automatiquement l’état “Overdue” aux prêts concernés. |
| **`sp_expire_memberships`**            | Identifie les adhésions arrivées à expiration (`membership_expiry <  SYSDATE`) et change leur statut de compte en `Expired`. Cela empêche tout nouvel emprunt jusqu’au renouvellement.             |
| **`sp_cleanup_expired_reservations`**  | Supprime ou marque comme `Expired` toutes les réservations dont la `pickup_deadline` est dépassée, afin de libérer les exemplaires bloqués inutilement.                                           |
| **`sp_generate_daily_report`**         | Produit un rapport global quotidien contenant le nombre total de prêts, retours, réservations, et amendes générées pendant la journée. Peut être utilisé pour le reporting interne.               |


# 🧩 Dépendances
1 - 01_create_users_roles.sql – création des utilisateurs et rôles (Ilyass)

2 - 02_grant_privileges.sql – attribution des privilèges (Ilyass)

3 - 03_create_tables.sql – création des tables (Aymane) ✅

# ✅ Tests 
Exécuter :
   # sqlplus user/pass @tests/test_procedures.sql

# 📊 Statut du module
   Code complet et documenté
   
   Tests unitaires écrits
   
   Revue par l’équipe
   
   Fusion avec main
