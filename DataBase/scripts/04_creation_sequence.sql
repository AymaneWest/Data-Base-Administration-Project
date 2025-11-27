-- ===================================================================
-- SCRIPT DE CREATION DES SEQUENCES (SANS ERREUR SI EXISTE)
-- ===================================================================

-- Séquence pour les patrons
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count 
    FROM user_sequences 
    WHERE sequence_name = 'SEQ_PATRON_ID';

    IF v_count = 0 THEN
        EXECUTE IMMEDIATE 'CREATE SEQUENCE seq_patron_id START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE';
    END IF;
END;
/
-- ---------------------------------------------------------------

-- Séquence pour les prêts (loans)
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count 
    FROM user_sequences 
    WHERE sequence_name = 'SEQ_LOAN_ID';

    IF v_count = 0 THEN
        EXECUTE IMMEDIATE 'CREATE SEQUENCE seq_loan_id START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE';
    END IF;
END;
/
-- ---------------------------------------------------------------

-- Séquence pour les amendes (fines)
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count 
    FROM user_sequences 
    WHERE sequence_name = 'SEQ_FINE_ID';

    IF v_count = 0 THEN
        EXECUTE IMMEDIATE 'CREATE SEQUENCE seq_fine_id START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE';
    END IF;
END;
/
-- ---------------------------------------------------------------

-- Séquence pour les matériels (materials)
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count 
    FROM user_sequences 
    WHERE sequence_name = 'SEQ_MATERIAL_ID';

    IF v_count = 0 THEN
        EXECUTE IMMEDIATE 'CREATE SEQUENCE seq_material_id START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE';
    END IF;
END;
/
-- ---------------------------------------------------------------

-- Séquence pour les copies
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count 
    FROM user_sequences 
    WHERE sequence_name = 'SEQ_COPY_ID';

    IF v_count = 0 THEN
        EXECUTE IMMEDIATE 'CREATE SEQUENCE seq_copy_id START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE';
    END IF;
END;
/
-- ---------------------------------------------------------------

-- Séquence pour les réservations
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count 
    FROM user_sequences 
    WHERE sequence_name = 'SEQ_RESERVATION_ID';

    IF v_count = 0 THEN
        EXECUTE IMMEDIATE 'CREATE SEQUENCE seq_reservation_id START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE';
    END IF;
END;
/
-- ===================================================================
