README - Sécurité RBAC Oracle pour Système de Gestion de Bibliothèque (LMS)
Introduction au projet et au RBAC
Ce projet vise à sécuriser une base de données Oracle destinée à la gestion d'une bibliothèque (LMS) en implémentant le modèle de Contrôle d’Accès Basé sur les Rôles (RBAC). Le RBAC est une méthode éprouvée pour gérer les droits d’accès : chaque utilisateur se voit attribuer un ou plusieurs rôles qui définissent précisément ses permissions. Contrairement à l’attribution directe de droits aux utilisateurs, RBAC facilite la gestion des privilèges en regroupant les autorisations par fonction métier.

RBAC respecte le principe de moindre privilège : un utilisateur ne peut accéder qu’aux ressources nécessaires à ses tâches. Cela renforce la sécurité en limitant les risques d’accès non autorisé ou d’erreur.

Description des rôles
ROLE_SYS_ADMIN : Administration complète et gestion critique des données sensibles, procédures et fonctions de maintenance.

ROLE_DIRECTOR : Accès en lecture seule pour élaboration de rapports et supervision.

ROLE_CATALOGER : Gestion complète du catalogue (ajout, mise à jour, suppression des documents).

ROLE_CIRCULATION_CLERK : Gestion des prêts, retours, réservations, usagers, et paiement des amendes.

ROLE_IT_SUPPORT : Support technique avec accès en lecture sur la configuration et droits sur procédures batch de maintenance.

Explications des commandes GRANT utilisées
Privilèges d’exécution (EXECUTE) sur fonctions et procédures PL/SQL
Les rôles se voient accorder uniquement les droits EXECUTE nécessaires sur les procédures et fonctions correspondant à leurs responsabilités :

ROLE_SYS_ADMIN a un accès total à toutes les procédures critiques : suppression de documents, notifications, circulation, gestion des adhésions, rapports, amendes, etc.

ROLE_DIRECTOR exécute uniquement les fonctions et procédures liées au reporting pour superviser sans modifier.

ROLE_CATALOGER peut exécuter les procédures de gestion du catalogue uniquement.

ROLE_CIRCULATION_CLERK dispose des droits pour gérer les prêts, retours, renouvellements, paiements d'amendes, et gestion des usagers.

ROLE_IT_SUPPORT est limité aux procédures de maintenance technique batch.

Cette granularité garantit une séparation claire et sécurisée des fonctions.

Privilèges SQL sur tables
Le rôle ROLE_SYS_ADMIN reçoit la totalité des privilèges (SELECT, INSERT, UPDATE, DELETE) sur toutes les tables métier et configuration, pour la gestion intégrale.

ROLE_DIRECTOR bénéficie uniquement des droits SELECT, assurant un accès en lecture seule conforme à la supervision.

ROLE_CATALOGER a des droits complets (CRUD) sur les tables du catalogue, mais aucun accès aux prêts ou personnel.

ROLE_CIRCULATION_CLERK gère les données relatives aux prêts et usagers avec droits d’écriture adaptés, et peut lire le catalogue.

ROLE_IT_SUPPORT peut uniquement lire les tables de configuration (LIBRARIES, BRANCHES), sans modification possible.

Ce découpage évite les conflits et garantit la sécurité des informations critiques.

