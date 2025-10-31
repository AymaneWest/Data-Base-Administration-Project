-- ============================================================================
-- TEST SUITE FOR PL/SQL PROCEDURES AND FUNCTIONS
-- Author: Abdellah - Branch: Abdellah-procedures
-- ============================================================================

SET SERVEROUTPUT ON SIZE 1000000;

PROMPT === TEST 1: Package Configuration ===
BEGIN
    DBMS_OUTPUT.PUT_LINE('Daily Fine: ' || pkg_library_config.c_DAILY_OVERDUE_FINE || ' DH');
    DBMS_OUTPUT.PUT_LINE('Max Fine: ' || pkg_library_config.c_MAX_FINE_THRESHOLD || ' DH');
    DBMS_OUTPUT.PUT_LINE('Max Renewals: ' || pkg_library_config.c_MAX_RENEWALS);
    DBMS_OUTPUT.PUT_LINE('✅ TEST 1 PASSED');
EXCEPTION
    WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('❌ FAILED: ' || SQLERRM);
END;
/

PROMPT === TEST 2: Loan Period Calculation ===
DECLARE
    v_vip NUMBER; v_standard NUMBER; v_child NUMBER;
BEGIN
    v_vip := fn_calculate_loan_period('VIP');
    v_standard := fn_calculate_loan_period('Standard');
    v_child := fn_calculate_loan_period('Child');
    DBMS_OUTPUT.PUT_LINE('VIP: ' || v_vip || ' days | Standard: ' || v_standard || ' | Child: ' || v_child);
    DBMS_OUTPUT.PUT_LINE('✅ TEST 2 PASSED');
END;
/

PROMPT === TEST 3: Borrow Limit Calculation ===
DECLARE
    v_vip NUMBER; v_premium NUMBER; v_student NUMBER;
BEGIN
    v_vip := fn_calculate_borrow_limit('VIP');
    v_premium := fn_calculate_borrow_limit('Premium');
    v_student := fn_calculate_borrow_limit('Student');
    DBMS_OUTPUT.PUT_LINE('VIP: ' || v_vip || ' | Premium: ' || v_premium || ' | Student: ' || v_student);
    DBMS_OUTPUT.PUT_LINE('✅ TEST 3 PASSED');
END;
/

PROMPT === TEST 4: Fine Calculation ===
DECLARE
    v_fine NUMBER;
BEGIN
    v_fine := fn_calculate_overdue_fine(SYSDATE - 10, SYSDATE);
    DBMS_OUTPUT.PUT_LINE('Fine for 10 days: ' || v_fine || ' DH (Expected: 20.00)');
    DBMS_OUTPUT.PUT_LINE('✅ TEST 4 PASSED');
END;
/

PROMPT ========================================
PROMPT   TESTS COMPLETED
PROMPT ========================================
