# Bouzid Mouad - PL/SQL Triggers & Data Integrity
Branch: Bouzid-triggers

Version: 1.0 (Production Ready)

Author: Bouzid Mouad (Student 4)

## Fichiers
- scripts/07_triggers_complete.sql (45KB, ~2500 lignes)
- team/bouzid_triggers.sql
- tests/test_triggers.sql

## Fonctionnalités (40+)

---

# SECTION 1: Audit & Logging Triggers
Triggers qui enregistrent et suivent les modifications système.

| Trigger | Rôle | Description |
| --- | --- | --- |
| `trg_user_login_log` | Audit Authentification | Enregistre chaque connexion d'utilisateur avec horodatage. Utile pour le suivi des accès au système. |
| `trg_prevent_active_role_delete` | Validation | Empêche la suppression de rôles actifs. Force la désactivation avant suppression pour maintenir l'intégrité des données. |
| `trg_audit_permission_changes` | Audit Permissions | Enregistre chaque modification de permissions (attribution/révocation). Trace qui a changé quelles permissions. |

---

# SECTION 2: Patron Management Triggers
Triggers pour la gestion et validation des profils de membres.

| Trigger | Rôle | Description |
| --- | --- | --- |
| `trg_validate_patron_email` | Validation Email | Valide le format email lors de l'ajout/modification de membre. Empêche les adresses email malformées. |
| `trg_check_membership_expiry` | Gestion Expiration | Marque automatiquement le compte comme "Expired" si la date d'expiration est passée. Suspend aussi si amendes > 50 DH. |
| `trg_prevent_locked_patron_update` | Protection Compte | Empêche toute modification d'un compte membre bloqué ("Blocked" status). Protège les comptes verrouillés. |
| `trg_auto_set_membership_expiry` | Automatisation | Fixe automatiquement la date d'expiration à 12 mois si non renseignée lors de l'inscription. |

---

# SECTION 3: Loan & Circulation Triggers
Triggers pour la gestion des prêts et validation des emprunts.

| Trigger | Rôle | Description |
| --- | --- | --- |
| `trg_update_copy_on_checkout` | Synchronisation Copie | Met à jour le statut de la copie à "Checked Out" après création d'un prêt. Assure la cohérence des statuts. |
| `trg_update_copy_on_checkin` | Synchronisation Copie | Remet la copie à "Available" après retour et marquage du prêt comme "Returned". |
| `trg_check_patron_fines_on_checkout` | Validation Prêt | Empêche l'emprunt si le membre a des amendes > 50 DH. Protège la bibliothèque des mauvais payeurs. |
| `trg_validate_loan_dates` | Validation Dates | Vérifie que due_date > checkout_date et return_date >= checkout_date. Empêche les dates illogiques et renouvellements > 5. |
| `trg_check_borrow_limit_on_checkout` | Limite Prêts | Empêche l'emprunt si le membre a atteint sa limite de prêts simultanés (selon membership_type). |
| `trg_prevent_reference_checkout` | Règle Métier | Empêche l'emprunt de documents marqués "reference only" (is_reference = 'Y'). Ceux-ci ne quittent pas la bibliothèque. |
| `trg_mark_overdue_loans` | Marquage Auto | Marque un prêt comme "Overdue" si la date d'échéance est dépassée. Facilite le suivi des retards. |

---

# SECTION 4: Material & Copy Management Triggers
Triggers pour la gestion du catalogue et des copies.

| Trigger | Rôle | Description |
| --- | --- | --- |
| `trg_validate_material_type` | Validation Type | Valide que material_type est dans la liste autorisée (Book, DVD, Magazine, etc.). Refuse les types invalides. |
| `trg_prevent_material_delete_with_loans` | Protection Données | Empêche la suppression d'un document s'il a des prêts actifs ou en retard. Maintient l'intégrité référentielle. |
| `trg_sync_material_copy_count` | Synchronisation Auto | Met à jour automatiquement total_copies et available_copies dans MATERIALS quand le statut d'une copie change. Garde les compteurs à jour. |
| `trg_validate_copy_condition` | Validation État | Valide que copy_condition et copy_status sont valides (New, Good, Damaged, etc.). Refuse les valeurs non reconnues. |
| `trg_prevent_damaged_checkout` | Règle Métier | Empêche l'emprunt si la copie est Damaged, Lost ou Under Repair. Protège les usagers et la collection. |

---

# SECTION 5: Reservation Triggers
Triggers pour la gestion des réservations et files d'attente.

| Trigger | Rôle | Description |
| --- | --- | --- |
| `trg_validate_reservation_dates` | Validation Dates | Vérifie que pickup_deadline > notification_date > reservation_date. Empêche les dates illogiques. |
| `trg_prevent_duplicate_reservations` | Unicité | Empêche un membre de réserver deux fois le même document. Une seule réservation active par (patron, material). |
| `trg_update_queue_on_cancel` | Gestion File | Réduit automatiquement queue_position des autres réservations quand l'une est annulée. Maintient la cohérence de la file. |
| `trg_prevent_expired_reservation_fulfill` | Validation Expiration | Empêche de marquer comme "Ready" une réservation expirée ou dont le délai de retrait est dépassé. |

---

# SECTION 6: Fine Management Triggers
Triggers pour la gestion des amendes et paiements.

| Trigger | Rôle | Description |
| --- | --- | --- |
| `trg_validate_fine_amounts` | Validation Montants | Valide que amount_due et amount_paid >= 0 et amount_paid <= amount_due. Refuse les montants illogiques. |
| `trg_auto_update_fine_status` | Automatisation Statut | Met à jour automatiquement fine_status selon le paiement (Unpaid → Partially Paid → Paid). Pas d'intervention manuelle requise. |
| `trg_update_patron_fines_on_insert` | Sync Patron | Ajoute le montant de la nouvelle amende au total_fines_owed du membre. Maintient le solde à jour. |
| `trg_update_patron_fines_on_payment` | Sync Paiement | Réduit total_fines_owed du membre après chaque paiement d'amende. Reflète immédiatement le paiement. |
| `trg_prevent_paid_fine_modification` | Protection | Empêche de réduire une amende déjà payée. Protège l'intégrité financière. |

---

# SECTION 7: Staff Management Triggers
Triggers pour la gestion du personnel.

| Trigger | Rôle | Description |
| --- | --- | --- |
| `trg_validate_staff_salary` | Validation Salaire | Valide que salary > 0 et staff_role est autorisé (Librarian, Manager, etc.). Refuse les valeurs invalides. |
| `trg_prevent_staff_delete_with_activity` | Protection Historique | Empêche la suppression d'un personnel qui a un historique de transactions (checkouts/returns). Archive plutôt que supprime. |

---

# SECTION 8: Branch Management Triggers
Triggers pour la gestion des branches.

| Trigger | Rôle | Description |
| --- | --- | --- |
| `trg_validate_branch_capacity` | Validation Capacité | Valide que branch_capacity > 0 et branch_name a au moins 3 caractères. Refuse les valeurs invalides. |
| `trg_prevent_branch_delete_with_patrons` | Protection Branche | Empêche la suppression d'une branche qui a des membres ou du personnel assigné. |

---

# SECTION 9: Data Integrity Triggers
Triggers pour garantir l'intégrité générale des données.

| Trigger | Rôle | Description |
| --- | --- | --- |
| `trg_validate_timestamp_sequence` | Validation Chronologie | Valide la séquence logique des timestamps (checkout < due < return). Prévient les anomalies temporelles. |
| `trg_prevent_negative_quantities` | Validation Quantités | Empêche les quantités négatives dans total_copies et available_copies. Mantient l'cohérence des stocks. |
| `trg_auto_timestamp` | Automatisation Horodatage | Met à jour automatiquement last_password_change lors de modifications utilisateur. Trace les changements. |

---

# SECTION 10: Business Logic Triggers
Triggers implémentant la logique métier complexe du système.

| Trigger | Rôle | Description |
| --- | --- | --- |
| `trg_auto_assess_overdue_fine` | Amende Automatique | Crée automatiquement une amende lors du retour en retard. Calcul: jours_retard × 2.00 DH/jour. Exécute après checkin_item. |
| `trg_notify_on_availability` | Notification Auto | Envoie une notification quand un livre réservé devient disponible. Identifie le premier réservant en queue. |
| `trg_auto_block_patron_excessive_fines` | Blocage Auto | Bloque automatiquement un membre si total_fines_owed > 100 DH. Prévient les accumulations excessives de dettes. |
| `trg_update_release_flag` | Maintenance Catalogue | Retire le flag "is_new_release" après 30 jours. Maintient automatiquement la pertinence du catalogue. |
| `trg_prevent_user_delete_with_activity` | Protection Audit | Empêche la suppression d'utilisateurs ayant un historique de transactions (amendes traitées, etc.). |

---

# 📊 Tableau Récapitulatif des Triggers

| Catégorie | Nombre | Rôle Principal |
| --- | --- | --- |
| **Audit & Logging** | 3 | Traçabilité et conformité |
| **Patron Management** | 4 | Validation et gestion des membres |
| **Loan & Circulation** | 7 | Gestion des emprunts et validations |
| **Material & Copy** | 5 | Intégrité du catalogue |
| **Reservations** | 4 | Gestion files d'attente |
| **Fine Management** | 5 | Paiements et amendes |
| **Staff Management** | 2 | Gestion du personnel |
| **Branch Management** | 2 | Gestion des branches |
| **Data Integrity** | 3 | Validation générale |
| **Business Logic** | 5 | Règles métier complexes |
| **TOTAL** | **40** | **Système complet** |

---

# 🧬 Dépendances

1. **01_create_users_roles.sql** – Création des utilisateurs et rôles (Ilyass)

2. **02_grant_privileges.sql** – Attribution des privilèges (Ilyass)

3. **03_create_tables.sql** – Création des tables (Aymane) ✅

4. **06_procedures_functions.sql** – Procédures et fonctions (Abdellah) ✅

5. **07_triggers_complete.sql** – Triggers et logique de validation (Bouzid Mouad) ✅

---

# ✅ Ordre d'Exécution Recommandé

1. Exécuter les fichiers dans l'ordre de création
2. Les triggers dépendent des tables existantes
3. Les procédures peuvent appeler les triggers indirectement via les contraintes
4. Tester chaque module isolément avant intégration

---

# 🧪 Tests

Exécuter :
```
sqlplus user/pass @tests/test_triggers.sql
```

Fichiers de test disponibles :
- `tests/test_audit_triggers.sql` – Tests des triggers d'audit
- `tests/test_circulation_triggers.sql` – Tests des triggers de prêts
- `tests/test_fine_triggers.sql` – Tests des triggers d'amendes
- `tests/test_data_integrity.sql` – Tests d'intégrité des données

---

# 📋 Statut du Module

✅ Code complet et documenté

✅ 40+ triggers implémentés

✅ Tests unitaires écrits

✅ Revue par l'équipe

✅ Fusion avec main

---

# 🔑 Points Clés des Triggers

## Avantages Principales

- **Automatisation** : Les règles métier exécutées automatiquement
- **Intégrité** : Validation des données avant insertion/modification
- **Traçabilité** : Audit complet de toutes les opérations importantes
- **Cohérence** : Synchronisation automatique entre tables liées
- **Performance** : Logique côté serveur, pas d'allers-retours applicatifs

## Bonnes Pratiques Appliquées

- Triggers AFTER pour les modifications côté données
- Triggers BEFORE pour les validations préalables
- Gestion d'exceptions appropriée
- Noms de triggers clairs et explicites (`trg_action_target`)
- Documentation inline complète
- Pas de triggers recursifs (risque de cascade infinie)

---

# 📞 Contact & Support

Pour toute question ou modification :
- **Author** : Bouzid Mouad
- **Email** : bouzid.mouad@school.edu
- **GitHub Branch** : Bouzid-triggers
- **Status** : Production Ready v1.0