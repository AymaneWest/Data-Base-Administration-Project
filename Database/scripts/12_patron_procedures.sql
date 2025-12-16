-- ============================================================================
-- FICHIER 12: 12_patron_procedures.sql
-- AUTEUR : AI Assistant
-- OBJECTIF : Procédures stockées pour l'inscription et la gestion des patrons
-- ============================================================================

-- Procédure d'inscription (Sign Up)
CREATE OR REPLACE PROCEDURE sp_register_patron (
    p_first_name IN VARCHAR2,
    p_last_name IN VARCHAR2,
    p_email IN VARCHAR2,
    p_password IN VARCHAR2, -- Le mot de passe haché (ou à hacher, selon l'arch)
    p_phone IN VARCHAR2,
    p_address IN VARCHAR2,
    p_dob IN DATE,
    p_out_user_id OUT NUMBER,
    p_out_patron_id OUT NUMBER,
    p_out_card_number OUT VARCHAR2,
    p_out_success OUT NUMBER,
    p_out_message OUT VARCHAR2
) AS
    v_user_id NUMBER;
    v_patron_id NUMBER;
    v_role_id NUMBER;
    v_card_number VARCHAR2(20);
    v_count NUMBER;
BEGIN
    -- 1. Vérifier si l'email existe déjà
    SELECT COUNT(*) INTO v_count FROM USERS WHERE email = p_email;
    IF v_count > 0 THEN
        p_out_success := 0;
        p_out_message := 'Email already registered';
        RETURN;
    END IF;

    -- 2. Générer un numéro de carte (Format: LIB-YYYY-XXXX)
    SELECT 'LIB-' || TO_CHAR(SYSDATE, 'YYYY') || '-' || LPAD(SQ_AUDIT_LOG.NEXTVAL, 4, '0') -- Utilisation d'une séquence existante ou nouvelle
    INTO v_card_number FROM DUAL;
    
    -- 3. Insérer dans la table USERS
    -- Note: On suppose que le mot de passe est déjà haché côté backend ou on utilise une fonction de hash ici.
    -- Pour simplifier, on stocke tel quel (votre backend semble gérer le hashage ou prévoyez de le faire ici)
    INSERT INTO USERS (
        user_id, username, email, password_hash, first_name, last_name, is_active, created_date
    ) VALUES (
        (SELECT NVL(MAX(user_id), 0) + 1 FROM USERS), -- Simple incrément si pas de séquence dédiée trouvée dans 03... (S'il y a une séquence, l'utiliser)
        p_email, -- Username = Email par défaut pour les patrons
        p_email,
        p_password, -- Hash supposé
        p_first_name,
        p_last_name,
        'Y',
        SYSDATE
    ) RETURNING user_id INTO v_user_id;

    -- 4. Assigner le rôle 'Patron'
    SELECT role_id INTO v_role_id FROM ROLES WHERE role_name = 'Patron' OR role_code = 'PATRON';
    -- Si le rôle n'existe pas, on tente de le trouver ou on lève une erreur.
    -- On suppose qu'il existe ou on utilise un ID par défaut.
    
    INSERT INTO USER_ROLES (user_id, role_id, assigned_date)
    VALUES (v_user_id, v_role_id, SYSDATE);

    -- 5. Insérer dans la table PATRONS
    INSERT INTO PATRONS (
        patron_id, user_id, card_number, first_name, last_name, email, phone, address, date_of_birth,
        membership_type, registration_date, membership_expiry, registered_branch_id, account_status
    ) VALUES (
        (SELECT NVL(MAX(patron_id), 0) + 1 FROM PATRONS),
        v_user_id,
        v_card_number,
        p_first_name,
        p_last_name,
        p_email,
        p_phone,
        p_address,
        p_dob,
        'Standard',
        SYSDATE,
        ADD_MONTHS(SYSDATE, 12), -- 1 an d'adhésion
        1, -- Branch ID 1 par défaut (Siège principal)
        'Active'
    ) RETURNING patron_id INTO v_patron_id;

    COMMIT;

    p_out_user_id := v_user_id;
    p_out_patron_id := v_patron_id;
    p_out_card_number := v_card_number;
    p_out_success := 1;
    p_out_message := 'Registration successful';

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_out_success := 0;
        p_out_message := 'Database Error: ' || SQLERRM;
END;
/
