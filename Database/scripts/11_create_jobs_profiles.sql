-- ============================================================================
-- FICHIER 11: 11_create_jobs_profiles.sql
-- OBJECTIF : Créer des profils et des jobs pour l'automatisation
-- ============================================================================

-- 1. Création du profil pour les utilisateurs de l'application (Patrons)
-- Limite les ressources pour éviter les abus
CREATE PROFILE PF_APP_USER LIMIT
    SESSIONS_PER_USER 3
    CPU_PER_SESSION DEFAULT
    CONNECT_TIME 60
    IDLE_TIME 30;

-- 2. Procédure pour mettre à jour les prêts en retard (sera appelée par le Job)
CREATE OR REPLACE PROCEDURE sp_update_overdue_loans AS
BEGIN
    -- Marquer les prêts comme 'Overdue' si la date d'échéance est passée
    UPDATE LOANS
    SET loan_status = 'Overdue'
    WHERE loan_status = 'Active' 
    AND due_date < TRUNC(SYSDATE);

    -- TODO: Logique pour évaluer les amendes automatiquement (simplifiée ici)
    -- On pourrait ajouter une boucle pour insérer dans FINES pour chaque prêt overdue
    
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        -- Log l'erreur (à implémenter si une table de log technique existe, sinon DBMS_OUTPUT)
END;
/

-- 3. Création du Job Oracle Scheduler pour exécuter la mise à jour chaque nuit
BEGIN
    DBMS_SCHEDULER.create_job (
        job_name        => 'JOB_UPDATE_OVERDUE',
        job_type        => 'PLSQL_BLOCK',
        job_action      => 'BEGIN sp_update_overdue_loans; END;',
        start_date      => SYSTIMESTAMP,
        repeat_interval => 'FREQ=DAILY; BYHOUR=1; BYMINUTE=0; BYSECOND=0', -- Tous les jours à 1h du matin
        enabled         => TRUE,
        comments        => 'Met à jour les statuts des prêts en retard chaque nuit'
    );
END;
/
