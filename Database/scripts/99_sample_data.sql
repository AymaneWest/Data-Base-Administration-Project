-- ============================================================================
-- Sample Data for Library Management System
-- This script populates the database with sample materials for testing
-- ============================================================================

-- Insert Publishers
INSERT INTO PUBLISHERS (publisher_id, publisher_name, country, website, contact_email)
VALUES (1, 'Penguin Random House', 'USA', 'www.penguinrandomhouse.com', 'contact@penguin.com');

INSERT INTO PUBLISHERS (publisher_id, publisher_name, country, website, contact_email)
VALUES (2, 'HarperCollins', 'USA', 'www.harpercollins.com', 'info@harpercollins.com');

INSERT INTO PUBLISHERS (publisher_id, publisher_name, country, website, contact_email)
VALUES (3, 'Simon & Schuster', 'USA', 'www.simonandschuster.com', 'contact@simonandschuster.com');

-- Insert Authors
INSERT INTO AUTHORS (author_id, first_name, last_name, nationality, birth_date)
VALUES (1, 'George', 'Orwell', 'British', TO_DATE('1903-06-25', 'YYYY-MM-DD'));

INSERT INTO AUTHORS (author_id, first_name, last_name, nationality, birth_date)
VALUES (2, 'Jane', 'Austen', 'British', TO_DATE('1775-12-16', 'YYYY-MM-DD'));

INSERT INTO AUTHORS (author_id, first_name, last_name, nationality, birth_date)
VALUES (3, 'F. Scott', 'Fitzgerald', 'American', TO_DATE('1896-09-24', 'YYYY-MM-DD'));

INSERT INTO AUTHORS (author_id, first_name, last_name, nationality, birth_date)
VALUES (4, 'Harper', 'Lee', 'American', TO_DATE('1926-04-28', 'YYYY-MM-DD'));

INSERT INTO AUTHORS (author_id, first_name, last_name, nationality, birth_date)
VALUES (5, 'J.K.', 'Rowling', 'British', TO_DATE('1965-07-31', 'YYYY-MM-DD'));

INSERT INTO AUTHORS (author_id, first_name, last_name, nationality, birth_date)
VALUES (6, 'J.R.R.', 'Tolkien', 'British', TO_DATE('1892-01-03', 'YYYY-MM-DD'));

-- Insert Genres
INSERT INTO GENRES (genre_id, genre_name, genre_description)
VALUES (1, 'Fiction', 'Literary fiction and novels');

INSERT INTO GENRES (genre_id, genre_name, genre_description)
VALUES (2, 'Science Fiction', 'Speculative fiction based on science');

INSERT INTO GENRES (genre_id, genre_name, genre_description)
VALUES (3, 'Fantasy', 'Magical and fantastical works');

INSERT INTO GENRES (genre_id, genre_name, genre_description)
VALUES (4, 'Classic', 'Timeless literary works');

INSERT INTO GENRES (genre_id, genre_name, genre_description)
VALUES (5, 'Romance', 'Love and relationship stories');

INSERT INTO GENRES (genre_id, genre_name, genre_description)
VALUES (6, 'Dystopian', 'Dark future societies');

-- Insert Materials
INSERT INTO MATERIALS (material_id, title, material_type, isbn, publication_year, publisher_id, language, description, total_copies, available_copies, is_new_release)
VALUES (1, '1984', 'Book', '978-0-452-28423-4', 1949, 1, 'English', 
'A dystopian social science fiction novel and cautionary tale about the dangers of totalitarianism.', 
5, 3, 'N');

INSERT INTO MATERIALS (material_id, title, material_type, isbn, publication_year, publisher_id, language, description, total_copies, available_copies, is_new_release)
VALUES (2, 'Pride and Prejudice', 'Book', '978-0-14-143951-8', 1813, 1, 'English',
'A romantic novel of manners that critiques the British landed gentry at the end of the 18th century.',
4, 4, 'N');

INSERT INTO MATERIALS (material_id, title, material_type, isbn, publication_year, publisher_id, language, description, total_copies, available_copies, is_new_release)
VALUES (3, 'The Great Gatsby', 'Book', '978-0-7432-7356-5', 1925, 2, 'English',
'A tragic love story set in the Jazz Age that explores themes of decadence, idealism, and social upheaval.',
6, 2, 'N');

INSERT INTO MATERIALS (material_id, title, material_type, isbn, publication_year, publisher_id, language, description, total_copies, available_copies, is_new_release)
VALUES (4, 'To Kill a Mockingbird', 'Book', '978-0-06-112008-4', 1960, 2, 'English',
'A gripping tale of racial injustice and childhood innocence in the American South.',
5, 5, 'N');

INSERT INTO MATERIALS (material_id, title, material_type, isbn, publication_year, publisher_id, language, description, total_copies, available_copies, is_new_release)
VALUES (5, 'Harry Potter and the Philosopher''s Stone', 'Book', '978-0-7475-3269-9', 1997, 3, 'English',
'The first novel in the Harry Potter series, following a young wizard''s journey at Hogwarts School.',
8, 6, 'Y');

INSERT INTO MATERIALS (material_id, title, material_type, isbn, publication_year, publisher_id, language, description, total_copies, available_copies, is_new_release)
VALUES (6, 'The Lord of the Rings', 'Book', '978-0-618-00222-1', 1954, 1, 'English',
'An epic high-fantasy novel that follows the quest to destroy the One Ring.',
7, 0, 'N');

INSERT INTO MATERIALS (material_id, title, material_type, isbn, publication_year, publisher_id, language, description, total_copies, available_copies, is_new_release)
VALUES (7, 'The Hobbit', 'Book', '978-0-547-92822-7', 1937, 1, 'English',
'A fantasy novel about Bilbo Baggins'' adventure with dwarves to reclaim their mountain home.',
5, 4, 'N');

INSERT INTO MATERIALS (material_id, title, material_type, isbn, publication_year, publisher_id, language, description, total_copies, available_copies, is_new_release)
VALUES (8, 'Animal Farm', 'Book', '978-0-452-28424-1', 1945, 1, 'English',
'An allegorical novella reflecting events leading up to the Russian Revolution and the Stalin era.',
4, 3, 'N');

-- Link Materials to Authors
INSERT INTO MATERIAL_AUTHORS (material_id, author_id, author_role, author_sequence)
VALUES (1, 1, 'Primary Author', 1);

INSERT INTO MATERIAL_AUTHORS (material_id, author_id, author_role, author_sequence)
VALUES (2, 2, 'Primary Author', 1);

INSERT INTO MATERIAL_AUTHORS (material_id, author_id, author_role, author_sequence)
VALUES (3, 3, 'Primary Author', 1);

INSERT INTO MATERIAL_AUTHORS (material_id, author_id, author_role, author_sequence)
VALUES (4, 4, 'Primary Author', 1);

INSERT INTO MATERIAL_AUTHORS (material_id, author_id, author_role, author_sequence)
VALUES (5, 5, 'Primary Author', 1);

INSERT INTO MATERIAL_AUTHORS (material_id, author_id, author_role, author_sequence)
VALUES (6, 6, 'Primary Author', 1);

INSERT INTO MATERIAL_AUTHORS (material_id, author_id, author_role, author_sequence)
VALUES (7, 6, 'Primary Author', 1);

INSERT INTO MATERIAL_AUTHORS (material_id, author_id, author_role, author_sequence)
VALUES (8, 1, 'Primary Author', 1);

-- Link Materials to Genres
INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre)
VALUES (1, 6, 'Y');

INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre)
VALUES (1, 2, 'N');

INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre)
VALUES (2, 4, 'Y');

INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre)
VALUES (2, 5, 'N');

INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre)
VALUES (3, 4, 'Y');

INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre)
VALUES (3, 1, 'N');

INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre)
VALUES (4, 4, 'Y');

INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre)
VALUES (4, 1, 'N');

INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre)
VALUES (5, 3, 'Y');

INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre)
VALUES (6, 3, 'Y');

INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre)
VALUES (6, 1, 'N');

INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre)
VALUES (7, 3, 'Y');

INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre)
VALUES (8, 6, 'Y');

INSERT INTO MATERIAL_GENRES (material_id, genre_id, is_primary_genre)
VALUES (8, 1, 'N');

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
