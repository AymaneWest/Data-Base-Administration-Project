# 📚 Sécurité RBAC Oracle pour Système de Gestion de Bibliothèque (LMS)
## 📝 Introduction

Ce projet met en place un modèle RBAC (Role-Based Access Control) pour sécuriser une base de données Oracle utilisée dans un Library Management System (LMS).

Le RBAC est une approche qui attribue les permissions non pas directement aux utilisateurs, mais aux rôles, eux-mêmes liés aux missions métiers.
Ce modèle améliore :

la sécurité (principe du moindre privilège)

la gestion des droits

la séparation des responsabilités

Chaque utilisateur reçoit uniquement les autorisations nécessaires à ses tâches quotidiennes.

# 🔐 Rôles définis dans le système
## 1. ROLE_SYS_ADMIN

Contrôle administratif complet

Gestion des données sensibles

Maintenance, procédures critiques, fonctions système

2. ROLE_DIRECTOR

Accès lecture seule

Consultation des rapports et supervision générale

3. ROLE_CATALOGER

Gestion complète du catalogue :

ajout

modification

suppression de documents

4. ROLE_CIRCULATION_CLERK

Gestion des opérations de circulation :

prêts / retours

réservations

gestion des usagers

paiement d’amendes

5. ROLE_IT_SUPPORT

Support technique

Accès en lecture seule sur la configuration

Exécution limitée de procédures de maintenance batch

# 🛠️ Privilèges GRANT utilisés
## ✔️ Droits EXECUTE sur les procédures PL/SQL

Chaque rôle reçoit uniquement les droits nécessaires :

ROLE_SYS_ADMIN : accès total à toutes les procédures (maintenance, adhésions, circulation, amendes, notifications…).

ROLE_DIRECTOR : uniquement les procédures de reporting et de consultation.

ROLE_CATALOGER : exécution des procédures de gestion du catalogue.

ROLE_CIRCULATION_CLERK : exécution des procédures liées aux prêts, renouvellements, retours, amendes et gestion des usagers.

ROLE_IT_SUPPORT : exécution des tâches techniques batch uniquement.

Cette granularité garantit une séparation stricte des fonctions.

## 🗄️ Privilèges SQL sur les tables
ROLE_SYS_ADMIN

Tous les privilèges (SELECT, INSERT, UPDATE, DELETE)

Sur toutes les tables métier et configuration

ROLE_DIRECTOR

SELECT uniquement

Lecture complète, aucune modification

ROLE_CATALOGER

CRUD complet sur les tables du catalogue

Aucun accès aux tables de prêts ou de personnel

ROLE_CIRCULATION_CLERK

Gestion des usagers et des prêts (INSERT/UPDATE/DELETE là où nécessaire)

Lecture du catalogue

ROLE_IT_SUPPORT

Lecture seule sur les tables de configuration (LIBRARIES, BRANCHES)

Aucun accès en modification

# 🔒 Conclusion

L’implémentation RBAC permet :

une sécurité renforcée

une gestion optimisée des permissions

une séparation stricte des responsabilités

une réduction des risques d’erreurs ou d’accès non autorisés

Ce système constitue une base solide pour un LMS sécurisé et conforme aux meilleures pratiques Oracle.
