GRANT EXECUTE ON sp_checkout_item TO user_sysadmin;
GRANT EXECUTE ON sp_checkout_item TO user_patron;

SELECT owner FROM all_objects 
WHERE object_name = 'SP_CHECKOUT_ITEM' 
AND object_type = 'PROCEDURE';
INSERT INTO projet_admin.FINES (fine_id, patron_id, loan_id, fine_type, amount_due, amount_paid, date_assessed, payment_date, fine_status, assessed_by_staff_id, waived_by_staff_id, waiver_reason, payment_method, notes) VALUES (1, 32, 12, 'Overdue', 5.50, 0.00, SYSDATE-2, NULL, 'Unpaid', 2, NULL, NULL, NULL, '5 days overdue');
commit;
rollback;
select * from projet_admin.loans where copy_id=18;
INSERT INTO projet_admin.LOANS (loan_id, patron_id, copy_id, checkout_date, due_date, return_date, renewal_count, loan_status, staff_id_checkout, staff_id_return) VALUES (32, 1, 2, SYSDATE-15, SYSDATE-1, NULL, 0, 'Overdue', 2, NULL);