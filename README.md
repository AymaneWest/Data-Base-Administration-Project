Projet d'Administration de Base de Données Oracle : Système de Gestion de Bibliothèque
Ce projet met en œuvre la conception et la gestion de la sécurité d'une base de données Oracle pour un système de gestion de bibliothèque (LMS).

L'objectif principal est de sécuriser la base de données en utilisant un modèle de Contrôle d'Accès Basé sur les Rôles (RBAC). Ce README documente la stratégie de sécurité, les rôles définis et les privilèges accordés.

Stratégie de Sécurité : Le Principe de Moindre Privilège
Notre politique de sécurité est basée sur le Principe de Moindre Privilège.

Cela signifie que chaque utilisateur de la base de données dispose uniquement des permissions (privilèges) strictement nécessaires pour accomplir ses tâches professionnelles, et pas plus.

Un employé aux prêts (CIRCULATION DESK CLERK) peut enregistrer un retour de livre, mais ne peut absolument pas voir les salaires (STAFF) ou supprimer un livre du catalogue (MATERIALS).

Un directeur (LIBRARY DIRECTOR) peut lire tous les rapports, mais ne peut pas modifier les données de prêts.

Rôles de la Base de Données (Le "Staff")
Nous avons défini 5 rôles "Employés" (Staff) dans la base de données Oracle. Chaque rôle correspond à un profil métier précis.

1. ROLE_SYS_ADMIN (Administrateur Système)
Description : Accès total au système. Gère les utilisateurs, les rôles, la configuration et toutes les fonctions administratives.

Privilèges : ALL PRIVILEGES (tous les droits) sur toutes les tables et EXECUTE (exécution) sur toutes les procédures et fonctions. C'est le seul rôle qui peut :

Voir et modifier les tables USERS (mots de passe) et STAFF (salaires).

Exécuter sp_delete_material pour supprimer un livre.

Lancer les tâches de maintenance "batch" (sp_process_overdue_notifications, sp_expire_memberships).

2. ROLE_DIRECTOR (Directeur de la Bibliothèque)
Description : Supervise toutes les opérations, génère des rapports stratégiques et gère le personnel.

Privilèges : Accès en Lecture Seule (SELECT) sur toutes les tables pour la supervision et les rapports.

Peut SELECT sur STAFF pour voir les informations du personnel.

Peut EXECUTE uniquement les fonctions et procédures de reporting (ex: fn_get_patron_statistics, sp_generate_daily_report).

NE PEUT PAS modifier, insérer ou supprimer des données.

3. ROLE_CATALOGER (Catalogueur)
Description : Spécialiste de la gestion du catalogue. Ajoute de nouveaux livres, met à jour les métadonnées et gère les classifications.

Privilèges : Droits de modification complets (SELECT, INSERT, UPDATE, DELETE) uniquement sur les tables liées au catalogue :

MATERIALS, COPIES, AUTHORS, PUBLISHERS, GENRES, etc.

Privilèges d'Exécution : EXECUTE sur les procédures de catalogue (sp_add_material, sp_update_material, sp_add_copy).

Accès Restreint : N'a aucun accès aux tables LOANS, FINES, PATRONS ou STAFF.

4. ROLE_CIRCULATION_CLERK (Employé au Bureau de Prêt)
Description : Gère les opérations de circulation quotidiennes : prêts, retours, réservations et service de base aux usagers.

Privilèges : C'est le rôle opérationnel principal.

Contrôle Total (SELECT, INSERT, UPDATE, DELETE) sur LOANS, RESERVATIONS, FINES.

Contrôle Partiel (SELECT, INSERT, UPDATE) sur PATRONS (Usagers).

Lecture Seule (SELECT) sur MATERIALS et COPIES pour rechercher des livres.

Privilèges d'Exécution : EXECUTE sur toutes les procédures de circulation (ex: sp_checkout_item, sp_checkin_item, sp_add_patron, sp_pay_fine, etc.).

Accès Restreint : N'a aucun accès aux tables STAFF ou USERS.

5. ROLE_IT_SUPPORT (Support Technique)
Description : Gère la maintenance technique du système avec un accès limité aux données métier.

Privilèges :

Lecture Seule (SELECT) sur les tables de configuration (LIBRARIES, BRANCHES).

Privilèges d'Exécution : EXECUTE uniquement sur les procédures de maintenance "batch" (ex: sp_expire_memberships, sp_cleanup_expired_reservations).

Accès Restreint : N'a aucun accès aux données sensibles (PATRONS, LOANS, FINES, STAFF).

🛑 Rôles "Clients" vs. "Staff" : L'Interdiction de Rôles Clients
Ce projet fait une distinction fondamentale entre les employés (Staff) et les clients (Patrons, Guests).

Employés (Staff) : Ce sont les utilisateurs ROLE_SYS_ADMIN, ROLE_DIRECTOR, ROLE_CATALOGER, etc. Ils ont de vrais comptes utilisateurs Oracle (user_sysadmin, user_clerk...) car ils utilisent le "back-office" de l'application et ont besoin de privilèges directs sur la base de données.

Clients (Patrons, Guests) : Ces rôles (PATRON (STANDARD), GUEST/VISITOR, etc.) ne sont pas et ne doivent jamais être des utilisateurs ou des rôles dans la base de données Oracle.

Note de Sécurité Fondamentale : Il est interdit de créer un utilisateur Oracle (CREATE USER) pour chaque client de la bibliothèque.

Pourquoi ?

Faille de Sécurité Massive : Donner à des milliers d'utilisateurs externes (le public) un accès direct à la base de données est une faille de sécurité majeure. Chaque compte client deviendrait une cible d'attaque potentielle.

Ingérable (Problème d'Échelle) : Il est techniquement impossible de gérer 10 000, 50 000, ou 1 million de comptes utilisateurs Oracle. La gestion des connexions, des mots de passe et des sessions épuiserait les ressources du serveur.

La Bonne Architecture : Le Compte de Service
La sécurité des clients est gérée au niveau applicatif, et non au niveau de la base de données.

Le Site Web (ou l'application mobile) se connecte à la base de données en utilisant UN SEUL compte de service (par exemple, APP_WEB).

Ce compte APP_WEB reçoit un rôle Oracle (comme ROLE_CIRCULATION_CLERK) qui lui donne les permissions nécessaires pour travailler au nom des clients (ex: exécuter sp_place_reservation, sp_pay_fine, etc.).

C'est le code du site web (Java, Python, PHP...) qui gère la logique "métier" :

Il vérifie le mot de passe du client (stocké dans la table PATRONS).

Il vérifie son membership_type ("VIP", "STANDARD").

Il décide ensuite s'il doit afficher le bouton "Réserver" ou non.

Fichiers de Script SQL (Livrables de l'Étudiant 1)
Ce dépôt contient les scripts de sécurité SQL suivants, qui doivent être exécutés par un administrateur (SYS ou SYSTEM) :

1. 01_create_users_roles.sql
Objectif : Crée les 5 rôles métier "Staff" (ex: ROLE_SYS_ADMIN) et les 5 utilisateurs de test (ex: user_sysadmin).

Action : Exécute CREATE ROLE et CREATE USER.

2. 02_grant_privileges.sql
Objectif : C'est le cœur de la sécurité. Il attribue toutes les permissions (privilèges) aux rôles et lie les rôles aux utilisateurs.

Action :

GRANT (sur les Tables) : Donne les droits SELECT, INSERT, UPDATE aux rôles sur les tables de l'Étudiant 2.

GRANT (sur le PL/SQL) : Donne les droits EXECUTE aux rôles sur les procédures/fonctions de l'Étudiant 3.

GRANT (Rôle à Utilisateur) : Assigne les rôles aux utilisateurs (ex: GRANT ROLE_SYS_ADMIN TO user_sysadmin;).

(Note : Les scripts de l'Étudiant 4 (Triggers, Gestion des Erreurs) sont attendus. Si de nouvelles procédures sont ajoutées, le fichier 02_grant_privileges.sql devra être mis à jour).
