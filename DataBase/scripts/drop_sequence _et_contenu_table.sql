-- ===========================
-- RESET DES DONNÉES
-- ===========================
DELETE FROM FINES;
DELETE FROM RESERVATIONS;
DELETE FROM LOANS;
DELETE FROM COPIES;
DELETE FROM MATERIALS;
DELETE FROM PATRONS;

DELETE FROM GENRES;
DELETE FROM AUTHORS;
DELETE FROM PUBLISHERS;
DELETE FROM STAFF;
DELETE FROM BRANCHES;
DELETE FROM LIBRARIES;

COMMIT;

-- ===========================
-- RESET DES SEQUENCES
-- ===========================

DROP SEQUENCE seq_patron_id;

DROP SEQUENCE seq_material_id;

DROP SEQUENCE seq_copy_id;

DROP SEQUENCE seq_loan_id;

DROP SEQUENCE seq_reservation_id;

DROP SEQUENCE seq_fine_id;

DROP SEQUENCE seq_library_id;

DROP SEQUENCE seq_branch_id;

DROP SEQUENCE seq_staff_id;

DROP SEQUENCE seq_author_id;

DROP SEQUENCE seq_genre_id;

DROP SEQUENCE seq_publisher_id;


COMMIT;
