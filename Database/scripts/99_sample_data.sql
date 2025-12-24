-- ============================================================================
-- Sample Data for Library Management System
-- This script populates the database with sample materials for testing
-- ============================================================================

-- Insert Publishers
INSERT INTO PUBLISHERS (publisher_id, publisher_name, country, website, contact_email)
VALUES (21, 'Penguin Random House', 'USA', 'www.penguinrandomhouse.com', 'contact@penguin.com');

INSERT INTO PUBLISHERS (publisher_id, publisher_name, country, website, contact_email)
VALUES (22, 'HarperCollins', 'USA', 'www.harpercollins.com', 'info@harpercollins.com');

INSERT INTO PUBLISHERS (publisher_id, publisher_name, country, website, contact_email)
VALUES (23, 'Simon & Schuster', 'USA', 'www.simonandschuster.com', 'contact@simonandschuster.com');

-- Insert Authors
INSERT INTO AUTHORS (author_id, first_name, last_name, nationality, birth_date)
VALUES (21, 'George', 'Orwell', 'British', TO_DATE('1903-06-25', 'YYYY-MM-DD'));

INSERT INTO AUTHORS (author_id, first_name, last_name, nationality, birth_date)
VALUES (22, 'Jane', 'Austen', 'British', TO_DATE('1775-12-16', 'YYYY-MM-DD'));

INSERT INTO AUTHORS (author_id, first_name, last_name, nationality, birth_date)
VALUES (23, 'F. Scott', 'Fitzgerald', 'American', TO_DATE('1896-09-24', 'YYYY-MM-DD'));

INSERT INTO AUTHORS (author_id, first_name, last_name, nationality, birth_date)
VALUES (24, 'Harper', 'Lee', 'American', TO_DATE('1926-04-28', 'YYYY-MM-DD'));

INSERT INTO AUTHORS (author_id, first_name, last_name, nationality, birth_date)
VALUES (25, 'J.K.', 'Rowling', 'British', TO_DATE('1965-07-31', 'YYYY-MM-DD'));

INSERT INTO AUTHORS (author_id, first_name, last_name, nationality, birth_date)
VALUES (26, 'J.R.R.', 'Tolkien', 'British', TO_DATE('1892-01-03', 'YYYY-MM-DD'));

-- Insert Genres
INSERT INTO GENRES (genre_id, genre_name, genre_description)
VALUES (21, 'Fiction', 'Literary fiction and novels');

INSERT INTO GENRES (genre_id, genre_name, genre_description)
VALUES (22, 'Science Fiction', 'Speculative fiction based on science');

INSERT INTO GENRES (genre_id, genre_name, genre_description)
VALUES (23, 'Fantasy', 'Magical and fantastical works');

INSERT INTO GENRES (genre_id, genre_name, genre_description)
VALUES (24, 'Classic', 'Timeless literary works');

INSERT INTO GENRES (genre_id, genre_name, genre_description)
VALUES (25, 'Romance', 'Love and relationship stories');

INSERT INTO GENRES (genre_id, genre_name, genre_description)
VALUES (26, 'Dystopian', 'Dark future societies');

-- Insert Materials
INSERT INTO MATERIALS (material_id, title, material_type, isbn, publication_year, publisher_id, language, description, total_copies, available_copies, is_new_release)
VALUES (21, '1984', 'Book', '978-0-452-28423-4', 1949, 1, 'English', 
'A dystopian social science fiction novel and cautionary tale about the dangers of totalitarianism.', 
5, 3, 'N');

INSERT INTO MATERIALS (material_id, title, material_type, isbn, publication_year, publisher_id, language, description, total_copies, available_copies, is_new_release)
VALUES (22, 'Pride and Prejudice', 'Book', '978-0-14-143951-8', 1813, 1, 'English',
'A romantic novel of manners that critiques the British landed gentry at the end of the 18th century.',
4, 4, 'N');

INSERT INTO MATERIALS (material_id, title, material_type, isbn, publication_year, publisher_id, language, description, total_copies, available_copies, is_new_release)
VALUES (23, 'The Great Gatsby', 'Book', '978-0-7432-7356-5', 1925, 2, 'English',
'A tragic love story set in the Jazz Age that explores themes of decadence, idealism, and social upheaval.',
6, 2, 'N');

INSERT INTO MATERIALS (material_id, title, material_type, isbn, publication_year, publisher_id, language, description, total_copies, available_copies, is_new_release)
VALUES (24, 'To Kill a Mockingbird', 'Book', '978-0-06-112008-4', 1960, 2, 'English',
'A gripping tale of racial injustice and childhood innocence in the American South.',
5, 5, 'N');

INSERT INTO MATERIALS (material_id, title, material_type, isbn, publication_year, publisher_id, language, description, total_copies, available_copies, is_new_release)
VALUES (25, 'Harry Potter and the Philosopher''s Stone', 'Book', '978-0-7475-3269-9', 1997, 3, 'English',
'The first novel in the Harry Potter series, following a young wizard''s journey at Hogwarts School.',
8, 6, 'Y');

INSERT INTO MATERIALS (material_id, title, material_type, isbn, publication_year, publisher_id, language, description, total_copies, available_copies, is_new_release)
VALUES (26, 'The Lord of the Rings', 'Book', '978-0-618-00222-1', 1954, 1, 'English',
'An epic high-fantasy novel that follows the quest to destroy the One Ring.',
7, 0, 'N');

INSERT INTO MATERIALS (material_id, title, material_type, isbn, publication_year, publisher_id, language, description, total_copies, available_copies, is_new_release)
VALUES (27, 'The Hobbit', 'Book', '978-0-547-92822-7', 1937, 1, 'English',
'A fantasy novel about Bilbo Baggins'' adventure with dwarves to reclaim their mountain home.',
5, 4, 'N');

INSERT INTO MATERIALS (material_id, title, material_type, isbn, publication_year, publisher_id, language, description, total_copies, available_copies, is_new_release)
VALUES (28, 'Animal Farm', 'Book', '978-0-452-28424-1', 1945, 1, 'English',
'An allegorical novella reflecting events leading up to the Russian Revolution and the Stalin era.',
4, 3, 'N');

-- Link Materials to Authors
INSERT INTO MATERIAL_AUTHORS (material_id, author_id, author_role, author_sequence)
VALUES (21, 21, 'Primary Author', 1);

INSERT INTO MATERIAL_AUTHORS (material_id, author_id, author_role, author_sequence)
VALUES (22, 22, 'Primary Author', 1);

INSERT INTO MATERIAL_AUTHORS (material_id, author_id, author_role, author_sequence)
VALUES (23, 23, 'Primary Author', 1);

INSERT INTO MATERIAL_AUTHORS (material_id, author_id, author_role, author_sequence)
VALUES (24, 24, 'Primary Author', 1);

INSERT INTO MATERIAL_AUTHORS (material_id, author_id, author_role, author_sequence)
VALUES (25, 25, 'Primary Author', 1);

INSERT INTO MATERIAL_AUTHORS (material_id, author_id, author_role, author_sequence)
VALUES (26, 23, 'Primary Author', 1);

INSERT INTO MATERIAL_AUTHORS (material_id, author_id, author_role, author_sequence)
VALUES (27, 21, 'Primary Author', 1);

INSERT INTO MATERIAL_AUTHORS (material_id, author_id, author_role, author_sequence)
VALUES (28, 21, 'Primary Author', 1);

-- Link Materials to Genres
INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre)
VALUES (21, 23, 'Y');

INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre)
VALUES (21, 21, 'N');

INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre)
VALUES (22, 24, 'Y');

INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre)
VALUES (22, 25, 'N');

INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre)
VALUES (23, 24, 'Y');

INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre)
VALUES (23, 21, 'N');

INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre)
VALUES (24, 24, 'Y');

INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre)
VALUES (24, 21, 'N');

INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre)
VALUES (25, 23, 'Y');

INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre)
VALUES (26, 23, 'Y');

INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre)
VALUES (26, 21, 'N');

INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre)
VALUES (27, 23, 'Y');

INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre)
VALUES (28, 21, 'Y');

INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre)
VALUES (28, 21, 'N');

-- Add copies for branch 1 (assuming branch 1 exists)
-- You'll need to adjust branch_id based on your actual branches
INSERT INTO COPIES (copy_id, material_id, barcode, branch_id, copy_condition, copy_status, acquisition_price)
SELECT 
    ROWNUM,
    m.material_id,
    'BC' || LPAD(TO_CHAR(ROWNUM), 8, '0'),
    1, -- Branch ID (adjust as needed)
    'Good',
    CASE WHEN ROWNUM <= m.available_copies THEN 'Available' ELSE 'Checked Out' END,
    15.99
FROM MATERIALS m
CROSS JOIN (SELECT LEVEL FROM DUAL CONNECT BY LEVEL <= 10) -- Generates rows for each material
WHERE ROWNUM <= (SELECT SUM(total_copies) FROM MATERIALS);

COMMIT;
