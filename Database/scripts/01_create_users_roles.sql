-- ============================================================================
-- FICHIER 1: 01_create_users_roles.sql
-- AUTEUR : ait taqmout ilyass (DBA)
-- OBJECTIF : Crée les rôles métier (Staff) et les utilisateurs de test
--            correspondants, conformément à la liste des rôles.
-- ============================================================================
-- Étape 1 : Créer les Rôles "Staff" (les "profils" de la base de données)
ALTER SESSION SET CONTAINER = XEPDB1;
-- Rôle 1: L'administrateur système
CREATE ROLE ROLE_SYS_ADMIN;

-- Rôle 2: Le directeur de la bibliothèque
CREATE ROLE ROLE_DIRECTOR;

-- Rôle 3: Le catalogueur (gère les livres)
CREATE ROLE ROLE_CATALOGER;

-- Rôle 4: L'employé de circulation (gère les prêts/retours)
CREATE ROLE ROLE_CIRCULATION_CLERK;

-- Rôle 5: Le support technique
CREATE ROLE ROLE_IT_SUPPORT;

-- Étape 2 : Créer les Utilisateurs Oracle Fictifs (les "comptes")
CREATE USER user_sysadmin IDENTIFIED BY "SysAdminPass123";
CREATE USER user_director IDENTIFIED BY "DirectorPass123";
CREATE USER user_cataloger IDENTIFIED BY "CatalogPass123";
CREATE USER user_clerk IDENTIFIED BY "ClerkPass123";
CREATE USER user_itsupport IDENTIFIED BY "ITSupportPass123";

-- Étape 3 : Donner le privilège de connexion de base
-- (Nous assignerons ce privilège aux RÔLES, et les utilisateurs
-- hériteront de ce droit en recevant le rôle).
GRANT CREATE SESSION TO ROLE_SYS_ADMIN;
GRANT CREATE SESSION TO ROLE_DIRECTOR;
GRANT CREATE SESSION TO ROLE_CATALOGER;
GRANT CREATE SESSION TO ROLE_CIRCULATION_CLERK;
GRANT CREATE SESSION TO ROLE_IT_SUPPORT;


COMMIT;