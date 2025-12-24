-- Quick test script to verify materials data and query
-- Run this to check if the backend SQL query will work

SET SERVEROUTPUT ON;

-- Test 1: Check if materials exist
SELECT COUNT(*) as total_materials FROM MATERIALS;

-- Test 2: Test the exact query used by backend (simplified)
SELECT DISTINCT
    m.material_id,
    m.title,
    m.subtitle,
    m.material_type,
    m.isbn,
    m.publication_year,
    m.language,
    m.description,
    m.total_copies,
    m.available_copies,
    m.is_reference,
    m.is_new_release
FROM MATERIALS m
WHERE ROWNUM <= 5;

-- Test 3: Check if LISTAGG works for authors
SELECT 
    m.material_id,
    m.title,
    LISTAGG(a.first_name || ' ' || a.last_name, ', ') WITHIN GROUP (ORDER BY ma.author_sequence) as authors
FROM MATERIALS m
LEFT JOIN MATERIAL_AUTHORS ma ON m.material_id = ma.material_id
LEFT JOIN AUTHORS a ON ma.author_id = a.author_id
GROUP BY m.material_id, m.title
WHERE ROWNUM <= 3;

-- Test 4: Full backend query (first 3 rows)
SELECT DISTINCT
    m.material_id,
    m.title,
    m.subtitle,
    LISTAGG(DISTINCT a.first_name || ' ' || a.last_name, ', ') WITHIN GROUP (ORDER BY a.last_name) as authors,
    LISTAGG(DISTINCT g.genre_name, ', ') WITHIN GROUP (ORDER BY g.genre_name) as genres,
    m.material_type,
    m.isbn,
    m.publication_year,
    m.available_copies,
    m.total_copies,
    m.is_new_release,
    p.publisher_name
FROM MATERIALS m
LEFT JOIN MATERIAL_AUTHORS ma ON m.material_id = ma.material_id
LEFT JOIN AUTHORS a ON ma.author_id = a.author_id
LEFT JOIN MATERIAL_GENRES mg ON m.material_id = mg.material_id
LEFT JOIN GENRES g ON mg.genre_id = g.genre_id
LEFT JOIN PUBLISHERS p ON m.publisher_id = p.publisher_id
GROUP BY 
    m.material_id, m.title, m.subtitle, m.material_type,
    m.isbn, m.publication_year, m.available_copies,
    m.total_copies, m.is_new_release, p.publisher_name
WHERE ROWNUM <= 3;
