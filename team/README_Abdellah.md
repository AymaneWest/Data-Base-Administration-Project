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
| Fonction                                                    | Rôle                     | Description                                               |
| ----------------------------------------------------------- | ------------------------ | --------------------------------------------------------- |
| `fn_patron_exists(p_patron_id)`                             | Vérifie existence        | Retourne `TRUE` si le patron existe.                      |
| `fn_calculate_loan_period(p_membership_type)`               | Calcule durée de prêt    | Retourne la durée du prêt selon le type d’abonnement.     |
| `fn_calculate_borrow_limit(p_membership_type)`              | Calcule limite d’emprunt | Donne le nombre maximum de prêts autorisés.               |
| `fn_get_active_loan_count(p_patron_id)`                     | Compte les prêts actifs  | Nombre total de prêts non retournés.                      |
| `fn_calculate_overdue_fine(p_due_date, p_return_date)`      | Calcule amende           | Multiplie les jours de retard par `c_DAILY_OVERDUE_FINE`. |
| `fn_check_patron_eligibility(p_patron_id, p_error_message)` | Vérifie éligibilité      | Vérifie statut actif, dettes, et limites d’emprunt.       |

# Patron Management Procedures
| Procédure              | Description                                               |
| ---------------------- | --------------------------------------------------------- |
| `sp_add_patron`        | Ajoute un nouveau membre avec date d’expiration calculée. |
| `sp_update_patron`     | Met à jour les coordonnées d’un membre.                   |
| `sp_renew_membership`  | Renouvelle l’abonnement pour 12 mois supplémentaires.     |
| `sp_suspend_patron`    | Suspend un membre et met à jour son statut.               |
| `sp_reactivate_patron` | Réactive un membre après paiement des dettes.             |

# Circulation Procedures (Loans)
| Procédure              | Description                                                    |
| ---------------------- | -------------------------------------------------------------- |
| `sp_checkout_item`     | Enregistre un emprunt (prêt d’un exemplaire).                  |
| `sp_checkin_item`      | Enregistre un retour et calcule l’amende éventuelle.           |
| `sp_renew_loan`        | Prolonge la durée du prêt si conditions remplies.              |
| `sp_declare_item_lost` | Déclare un exemplaire perdu et crée une amende correspondante. |

# Material Management Procedures
| Procédure            | Description                                                      |
| -------------------- | ---------------------------------------------------------------- |
| `sp_add_material`    | Ajoute un nouveau document dans le catalogue.                    |
| `sp_add_copy`        | Ajoute une copie physique ou numérique d’un document.            |
| `sp_update_material` | Met à jour le titre, la langue ou la description d’un document.  |
| `sp_delete_material` | Supprime un document (et ses copies) s’il n’a pas de prêt actif. |

# Reservation Procedures
| Procédure                | Description                                             |
| ------------------------ | ------------------------------------------------------- |
| `sp_place_reservation`   | Crée une réservation si aucune copie n’est disponible.  |
| `sp_cancel_reservation`  | Annule une réservation et réorganise la file d’attente. |
| `sp_fulfill_reservation` | Marque une réservation comme prête à être retirée.      |

# Fine Management Procedures
| Procédure        | Description                                          |
| ---------------- | ---------------------------------------------------- |
| `sp_pay_fine`    | Enregistre un paiement total ou partiel d’amende.    |
| `sp_waive_fine`  | Annule une amende manuellement par le personnel.     |
| `sp_assess_fine` | Crée une amende manuelle (perte, dégradation, etc.). |

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
