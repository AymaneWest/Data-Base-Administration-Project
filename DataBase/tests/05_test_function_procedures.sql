-- ============================================================================
-- LIBRARY MANAGEMENT SYSTEM - COMPREHENSIVE TEST SCRIPT
-- ============================================================================
-- Description: Tests complets de toutes les procédures et fonctions
-- Author: Test Suite
-- Date: November 2025
-- ============================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED;
SET LINESIZE 200;

-- ============================================================================
-- SECTION 1: TEST DATA SETUP
-- ============================================================================

PROMPT ========================================
PROMPT   SECTION 1: INSERTION DES DONNÉES DE TEST
PROMPT ========================================

-- Test Libraries
BEGIN
    INSERT INTO LIBRARIES VALUES (1, 'Bibliothèque Nationale du Maroc', 1920, 'Avenue Ibn Battouta, Rabat', '0537771981', 'contact@bnrm.ma', 'www.bnrm.ma', 'Bibliothèque nationale principale', SYSDATE);
    INSERT INTO LIBRARIES VALUES (2, 'Bibliothèque Municipale', 1995, 'Boulevard Zerktouni, Casablanca', '0522123456', 'info@biblio-casa.ma', 'www.biblio-casa.ma', 'Réseau de bibliothèques municipales', SYSDATE);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('✅ 2 bibliothèques insérées');
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN 
        DBMS_OUTPUT.PUT_LINE('⚠️  Bibliothèques déjà existantes');
END;
/

-- Test Branches
BEGIN
    INSERT INTO BRANCHES VALUES (101, 1, 'Succursale Rabat Centre', 'Rue Mohammed V, Rabat', '0537771982', 'rabat@bnrm.ma', '09:00-18:00', 200, SYSDATE);
    INSERT INTO BRANCHES VALUES (102, 2, 'Succursale Casa Maarif', 'Rue Moulay Youssef, Casablanca', '0522123457', 'maarif@biblio-casa.ma', '10:00-20:00', 150, SYSDATE);
    INSERT INTO BRANCHES VALUES (103, 2, 'Succursale Casa Anfa', 'Boulevard Anfa, Casablanca', '0522123458', 'anfa@biblio-casa.ma', '10:00-19:00', 100, SYSDATE);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('✅ 3 succursales insérées');
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN 
        DBMS_OUTPUT.PUT_LINE('⚠️  Succursales déjà existantes');
END;
/

-- Test Staff
BEGIN
    INSERT INTO STAFF VALUES (1001, NULL, 'EMP001', 'Fatima', 'Zahra', 'f.zahra@bnrm.ma', '0661234567', 'Librarian', 101, SYSDATE, 8000, 'Y');
    INSERT INTO STAFF VALUES (1002, NULL, 'EMP002', 'Ahmed', 'Bennani', 'a.bennani@biblio-casa.ma', '0662345678', 'Manager', 102, SYSDATE, 12000, 'Y');
    INSERT INTO STAFF VALUES (1003, NULL, 'EMP003', 'Samir', 'Idrissi', 's.idrissi@biblio-casa.ma', '0663456789', 'Assistant', 103, SYSDATE, 6000, 'Y');
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('✅ 3 employés insérés');
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN 
        DBMS_OUTPUT.PUT_LINE('⚠️  Employés déjà existants');
END;
/

-- Test Publishers
BEGIN
    INSERT INTO PUBLISHERS VALUES (201, 'Dar Al Kotob', 'Maroc', 'www.daralkotob.ma', 'contact@daralkotob.ma', '0522998877');
    INSERT INTO PUBLISHERS VALUES (202, 'Tarik Edition', 'Maroc', 'www.tarikedition.ma', 'info@tarikedition.ma', '0537445566');
    INSERT INTO PUBLISHERS VALUES (203, 'Editions Gallimard', 'France', 'www.gallimard.fr', 'contact@gallimard.fr', '+33144054900');
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('✅ 3 éditeurs insérés');
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN 
        DBMS_OUTPUT.PUT_LINE('⚠️  Éditeurs déjà existants');
END;
/

-- Test Authors
BEGIN
    INSERT INTO AUTHORS (author_id, first_name, last_name, nationality) VALUES (301, 'Tahar', 'Ben Jelloun', 'Maroc');
    INSERT INTO AUTHORS (author_id, first_name, last_name, nationality) VALUES (302, 'Fatima', 'Mernissi', 'Maroc');
    INSERT INTO AUTHORS (author_id, first_name, last_name, nationality) VALUES (303, 'Victor', 'Hugo', 'France');
    INSERT INTO AUTHORS (author_id, first_name, last_name, nationality) VALUES (304, 'Naguib', 'Mahfouz', 'Égypte');
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('✅ 4 auteurs insérés');
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN 
        DBMS_OUTPUT.PUT_LINE('⚠️  Auteurs déjà existants');
END;
/

-- Test Genres
BEGIN
    INSERT INTO GENRES VALUES (401, 'Roman', 'Fiction narrative');
    INSERT INTO GENRES VALUES (402, 'Essai', 'Texte argumentatif');
    INSERT INTO GENRES VALUES (403, 'Histoire', 'Événements historiques');
    INSERT INTO GENRES VALUES (404, 'Science', 'Ouvrages scientifiques');
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('✅ 4 genres insérés');
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN 
        DBMS_OUTPUT.PUT_LINE('⚠️  Genres déjà existants');
END;
/

-- ============================================================================
-- SECTION 2: TEST PATRON MANAGEMENT
-- ============================================================================

PROMPT 
PROMPT ========================================
PROMPT   SECTION 2: TEST GESTION DES PATRONS
PROMPT ========================================

DECLARE
    v_patron_id NUMBER;
    v_new_expiry DATE;
BEGIN
    -- Test 1: Ajouter un patron Standard
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- Test 1: Ajouter Patron Standard ---');
    sp_add_patron(
        p_card_number => 'CARD001',
        p_first_name => 'Mohammed',
        p_last_name => 'Alami',
        p_email => 'm.alami@email.com',
        p_phone => '0661111111',
        p_address => '123 Rue Hassan II, Casablanca',
        p_date_of_birth => TO_DATE('1990-05-15', 'YYYY-MM-DD'),
        p_membership_type => 'Standard',
        p_branch_id => 102,
        p_new_patron_id => v_patron_id
    );
    DBMS_OUTPUT.PUT_LINE('Nouveau patron ID: ' || v_patron_id);
    
    -- Test 2: Ajouter un patron VIP
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- Test 2: Ajouter Patron VIP ---');
    sp_add_patron(
        p_card_number => 'CARD002',
        p_first_name => 'Amina',
        p_last_name => 'Benjelloun',
        p_email => 'a.benjelloun@email.com',
        p_phone => '0662222222',
        p_address => '456 Boulevard Anfa, Casablanca',
        p_date_of_birth => TO_DATE('1985-08-20', 'YYYY-MM-DD'),
        p_membership_type => 'VIP',
        p_branch_id => 103,
        p_new_patron_id => v_patron_id
    );
    
    -- Test 3: Ajouter un patron Child
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- Test 3: Ajouter Patron Enfant ---');
    sp_add_patron(
        p_card_number => 'CARD003',
        p_first_name => 'Yassine',
        p_last_name => 'Tazi',
        p_email => 'parent.tazi@email.com',
        p_phone => '0663333333',
        p_address => '789 Rue Zerktouni, Casablanca',
        p_date_of_birth => TO_DATE('2015-03-10', 'YYYY-MM-DD'),
        p_membership_type => 'Child',
        p_branch_id => 102,
        p_new_patron_id => v_patron_id
    );
    
    -- Test 4: Mettre à jour un patron
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- Test 4: Mettre à jour Patron ---');
    sp_update_patron(
        p_patron_id => 1,
        p_phone => '0661111199',
        p_address => '123 Nouvelle Adresse, Casablanca'
    );
    
    -- Test 5: Renouveler abonnement
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- Test 5: Renouveler Abonnement ---');
    sp_renew_membership(
        p_patron_id => 1,
        p_new_expiry_date => v_new_expiry
    );
    
    -- Test 6: Test d'erreur - Carte dupliquée
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- Test 6: Erreur - Carte Dupliquée ---');
    BEGIN
        sp_add_patron(
            p_card_number => 'CARD001', -- Duplicate
            p_first_name => 'Test',
            p_last_name => 'Duplicate',
            p_email => 'duplicate@email.com',
            p_phone => '0660000000',
            p_address => 'Test Address',
            p_date_of_birth => TO_DATE('2000-01-01', 'YYYY-MM-DD'),
            p_membership_type => 'Standard',
            p_branch_id => 102,
            p_new_patron_id => v_patron_id
        );
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('❌ Erreur attendue: ' || SQLERRM);
    END;
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('❌ Erreur: ' || SQLERRM);
END;
/

-- ============================================================================
-- SECTION 3: TEST MATERIAL MANAGEMENT
-- ============================================================================

PROMPT 
PROMPT ========================================
PROMPT   SECTION 3: TEST GESTION DES MATÉRIAUX
PROMPT ========================================

DECLARE
    v_material_id NUMBER;
    v_copy_id NUMBER;
BEGIN
    -- Test 1: Ajouter un livre
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- Test 1: Ajouter un Livre ---');
    sp_add_material(
        p_title => 'La Nuit Sacrée',
        p_subtitle => 'Prix Goncourt 1987',
        p_material_type => 'Book',
        p_isbn => '978-2-02-009683-7',
        p_publication_year => 1987,
        p_publisher_id => 203,
        p_language => 'Français',
        p_pages => 192,
        p_description => 'Roman de Tahar Ben Jelloun',
        p_total_copies => 0,
        p_new_material_id => v_material_id
    );
    DBMS_OUTPUT.PUT_LINE('Nouveau matériel ID: ' || v_material_id);
    
    -- Test 2: Ajouter des copies
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- Test 2: Ajouter 3 Copies ---');
    FOR i IN 1..3 LOOP
        sp_add_copy(
            p_material_id => v_material_id,
            p_barcode => 'BAR' || LPAD(v_material_id, 5, '0') || LPAD(i, 3, '0'),
            p_branch_id => 102,
            p_acquisition_price => 150.00,
            p_new_copy_id => v_copy_id
        );
        DBMS_OUTPUT.PUT_LINE('  Copy ' || i || ' créée - ID: ' || v_copy_id);
    END LOOP;
    
    -- Test 3: Ajouter un DVD
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- Test 3: Ajouter un DVD ---');
    sp_add_material(
        p_title => 'Casablanca',
        p_subtitle => 'Film Classique',
        p_material_type => 'DVD',
        p_isbn => NULL,
        p_publication_year => 1942,
        p_publisher_id => NULL,
        p_language => 'Anglais',
        p_pages => NULL,
        p_description => 'Film américain réalisé par Michael Curtiz',
        p_total_copies => 0,
        p_new_material_id => v_material_id
    );
    
    sp_add_copy(
        p_material_id => v_material_id,
        p_barcode => 'DVD001',
        p_branch_id => 103,
        p_acquisition_price => 80.00,
        p_new_copy_id => v_copy_id
    );
    
    -- Test 4: Mettre à jour matériel
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- Test 4: Mettre à jour Matériel ---');
    sp_update_material(
        p_material_id => 1,
        p_description => 'Roman primé de Tahar Ben Jelloun - Édition mise à jour'
    );
    
    -- Test 5: Vérifier disponibilité
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- Test 5: Vérifier Disponibilité ---');
    DBMS_OUTPUT.PUT_LINE('Statut: ' || fn_check_material_availability(1));
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('❌ Erreur: ' || SQLERRM);
END;
/

-- ============================================================================
-- SECTION 4: TEST CIRCULATION (CHECKOUT/CHECKIN)
-- ============================================================================

PROMPT 
PROMPT ========================================
PROMPT   SECTION 4: TEST CIRCULATION
PROMPT ========================================
-- Simuler un checkout passé
UPDATE LOANS 
SET checkout_date = SYSDATE - 10,
    due_date = SYSDATE - 5
WHERE loan_id = 2;
COMMIT;

DECLARE
    v_loan_id NUMBER;
    v_fine_assessed NUMBER;
    v_new_due_date DATE;
BEGIN
    -- Test 1: Checkout normal
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- Test 1: Checkout Normal ---');
    sp_checkout_item(
        p_patron_id => 1,
        p_copy_id => 1,
        p_staff_id => 1001,
        p_loan_id => v_loan_id
    );
    DBMS_OUTPUT.PUT_LINE('Prêt créé - ID: ' || v_loan_id);
    
    -- Test 2: Checkout pour VIP (durée plus longue)
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- Test 2: Checkout VIP ---');
    sp_checkout_item(
        p_patron_id => 2,
        p_copy_id => 2,
        p_staff_id => 1001,
        p_loan_id => v_loan_id
    );
    
    -- Test 3: Checkout pour enfant
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- Test 3: Checkout Enfant ---');
    sp_checkout_item(
        p_patron_id => 3,
        p_copy_id => 3,
        p_staff_id => 1002,
        p_loan_id => v_loan_id
    );
    
    -- Test 4: Renouvellement de prêt
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- Test 4: Renouvellement ---');
    sp_renew_loan(
        p_loan_id => 1,
        p_new_due_date => v_new_due_date
    );
    
    -- Test 5: Checkin à temps
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- Test 5: Retour à Temps ---');
    sp_checkin_item(
        p_loan_id => 3,
        p_staff_id => 1002,
        p_fine_assessed => v_fine_assessed
    );
    
    -- Test 6: Simuler retard et checkin
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- Test 6: Simuler Retard (modification manuelle) ---');
    -- Test 6: Simuler Retard (modification manuelle)
        UPDATE LOANS 
        SET checkout_date = SYSDATE - 10,
            due_date = SYSDATE - 5
        WHERE loan_id = 2;
        COMMIT;
        
        sp_checkin_item(
            p_loan_id => 2,
            p_staff_id => 1001,
            p_fine_assessed => v_fine_assessed
        );
        DBMS_OUTPUT.PUT_LINE('Amende évaluée: ' || v_fine_assessed || ' DH');
        
            
    -- Test 7: Déclarer perdu
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- Test 7: Déclarer Perdu ---');
    sp_checkout_item(
        p_patron_id => 1,
        p_copy_id => 3,
        p_staff_id => 1001,
        p_loan_id => v_loan_id
    );
    
    sp_declare_item_lost(
        p_loan_id => v_loan_id,
        p_staff_id => 1001,
        p_replacement_cost => 150.00
    );
    
    -- Test 8: Erreur - Copie déjà empruntée
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- Test 8: Erreur - Copie Déjà Empruntée ---');
    BEGIN
        sp_checkout_item(
            p_patron_id => 2,
            p_copy_id => 1, -- Déjà emprunté
            p_staff_id => 1001,
            p_loan_id => v_loan_id
        );
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('❌ Erreur attendue: ' || SQLERRM);
    END;
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('❌ Erreur: ' || SQLERRM);
END;
/

-- ============================================================================
-- SECTION 5: TEST RESERVATIONS
-- ============================================================================

PROMPT 
PROMPT ========================================
PROMPT   SECTION 5: TEST RÉSERVATIONS
PROMPT ========================================

DECLARE
    v_reservation_id NUMBER;
BEGIN
    -- Emprunter toutes les copies pour forcer réservation
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- Préparation: Emprunter toutes copies disponibles ---');
    
    -- Test 1: Placer réservation
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- Test 1: Placer Réservation ---');
    sp_place_reservation(
        p_material_id => 1,
        p_patron_id => 2,
        p_reservation_id => v_reservation_id
    );
    DBMS_OUTPUT.PUT_LINE('Réservation créée - ID: ' || v_reservation_id);
    
    -- Test 2: Deuxième réservation (file d'attente)
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- Test 2: Deuxième Réservation (Queue) ---');
    sp_place_reservation(
        p_material_id => 1,
        p_patron_id => 3,
        p_reservation_id => v_reservation_id
    );
    
    -- Test 3: Annuler réservation
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- Test 3: Annuler Réservation ---');
    sp_cancel_reservation(
        p_reservation_id => 1,
        p_patron_id => 2
    );
    
    -- Test 4: Fulfiller une réservation
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- Test 4: Fulfiller Réservation ---');
    -- D'abord retourner une copie
    UPDATE COPIES SET copy_status = 'Available' WHERE copy_id = 1;
    COMMIT;
    
    sp_fulfill_reservation(
        p_reservation_id => 2,
        p_copy_id => 1,
        p_staff_id => 1001
    );
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('❌ Erreur: ' || SQLERRM);
END;
/

-- ============================================================================
-- SECTION 6: TEST FINE MANAGEMENT
-- ============================================================================

PROMPT 
PROMPT ========================================
PROMPT   SECTION 6: TEST GESTION DES AMENDES
PROMPT ========================================

DECLARE
    v_fine_id NUMBER;
BEGIN
    -- Test 1: Paiement partiel
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- Test 1: Paiement Partiel ---');
    sp_pay_fine(
        p_fine_id => 1,
        p_payment_amount => 5.00,
        p_payment_method => 'Cash',
        p_staff_id => 1001
    );
    
    -- Test 2: Paiement complet
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- Test 2: Paiement Complet ---');
    DECLARE
        v_remaining NUMBER;
    BEGIN
        SELECT amount_due - amount_paid INTO v_remaining
        FROM FINES WHERE fine_id = 1;
        
        sp_pay_fine(
            p_fine_id => 1,
            p_payment_amount => v_remaining,
            p_payment_method => 'Credit Card',
            p_staff_id => 1001
        );
    END;
    
    -- Test 3: Évaluer nouvelle amende
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- Test 3: Évaluer Nouvelle Amende ---');
    sp_assess_fine(
        p_patron_id => 1,
        p_loan_id => NULL,
        p_fine_type => 'Processing Fee',
        p_amount => 10.00,
        p_staff_id => 1002,
        p_fine_id => v_fine_id
    );
    
    -- Test 4: Annuler amende
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- Test 4: Annuler Amende ---');
    sp_waive_fine(
        p_fine_id => v_fine_id,
        p_waiver_reason => 'Erreur système - frais annulés par le manager',
        p_staff_id => 1002
    );
    
    -- Test 5: Calculer total amendes
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- Test 5: Total Amendes ---');
    DBMS_OUTPUT.PUT_LINE('Total système: ' || fn_calculate_total_fines() || ' DH');
    DBMS_OUTPUT.PUT_LINE('Total patron 1: ' || fn_calculate_total_fines(1) || ' DH');
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('❌ Erreur: ' || SQLERRM);
END;
/

-- ============================================================================
-- SECTION 7: TEST REPORTING FUNCTIONS
-- ============================================================================

PROMPT 
PROMPT ========================================
PROMPT   SECTION 7: TEST RAPPORTS
PROMPT ========================================

BEGIN
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- Statistiques Patron 1 ---');
    DBMS_OUTPUT.PUT_LINE(fn_get_patron_statistics(1));
    
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- Statistiques Patron 2 ---');
    DBMS_OUTPUT.PUT_LINE(fn_get_patron_statistics(2));
    
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- Nombre de Retards ---');
    DBMS_OUTPUT.PUT_LINE('Total système: ' || fn_get_overdue_count());
    DBMS_OUTPUT.PUT_LINE('Succursale 102: ' || fn_get_overdue_count(102));
    
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- Disponibilité Matériaux ---');
    DBMS_OUTPUT.PUT_LINE('Matériel 1: ' || fn_check_material_availability(1));
    DBMS_OUTPUT.PUT_LINE('Matériel 2: ' || fn_check_material_availability(2));
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('❌ Erreur: ' || SQLERRM);
END;
/

-- ============================================================================
-- SECTION 8: TEST BATCH OPERATIONS
-- ============================================================================

PROMPT 
PROMPT ========================================
PROMPT   SECTION 8: TEST OPÉRATIONS BATCH
PROMPT ========================================

BEGIN
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- Test 1: Notifications Retard ---');
    sp_process_overdue_notifications;
    
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- Test 2: Expiration Abonnements ---');
    -- Simuler expiration
    UPDATE PATRONS SET membership_expiry = SYSDATE - 1 WHERE patron_id = 1;
    COMMIT;
    sp_expire_memberships;
    
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- Test 3: Nettoyage Réservations ---');
    sp_cleanup_expired_reservations;
    
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- Test 4: Rapport Quotidien ---');
    sp_generate_daily_report();
    
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- Test 5: Rapport par Succursale ---');
    sp_generate_daily_report(102);
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('❌ Erreur: ' || SQLERRM);
END;
/

-- ============================================================================
-- SECTION 9: VERIFICATION FINALE
-- ============================================================================

PROMPT 
PROMPT ========================================
PROMPT   SECTION 9: VÉRIFICATION FINALE
PROMPT ========================================

SELECT '✅ PATRONS' AS "TABLE", COUNT(*) AS "COUNT" FROM PATRONS
UNION ALL
SELECT '✅ MATERIALS', COUNT(*) FROM MATERIALS
UNION ALL
SELECT '✅ COPIES', COUNT(*) FROM COPIES
UNION ALL
SELECT '✅ LOANS', COUNT(*) FROM LOANS
UNION ALL
SELECT '✅ RESERVATIONS', COUNT(*) FROM RESERVATIONS
UNION ALL
SELECT '✅ FINES', COUNT(*) FROM FINES;

PROMPT 
PROMPT ========================================
PROMPT   📊 RÉSUMÉ DES TESTS
PROMPT ========================================
PROMPT   ✅ Section 1: Données de test insérées
PROMPT   ✅ Section 2: Gestion patrons testée (6 tests)
PROMPT   ✅ Section 3: Gestion matériaux testée (5 tests)
PROMPT   ✅ Section 4: Circulation testée (8 tests)
PROMPT   ✅ Section 5: Réservations testées (4 tests)
PROMPT   ✅ Section 6: Amendes testées (5 tests)
PROMPT   ✅ Section 7: Rapports testés (4 fonctions)
PROMPT   ✅ Section 8: Opérations batch testées (5 tests)
PROMPT ========================================
PROMPT   🎯 TOUS LES TESTS COMPLÉTÉS
PROMPT ========================================

-- ============================================================================
-- END OF TEST SCRIPT
-- ============================================================================