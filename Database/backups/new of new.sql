SELECT 
    m.material_id,
    m.title,
    m.subtitle,
    m.material_type,
    m.isbn,
    m.publication_year,
    m.language,
    MAX(DBMS_LOB.SUBSTR(m.description, 4000, 1)) AS description,
    m.total_copies,
    m.available_copies,
    m.is_reference,
    m.is_new_release,
    m.date_added,
    p.publisher_name,
    LISTAGG(DISTINCT a.first_name || ' ' || a.last_name, ', ') WITHIN GROUP (ORDER BY ma.author_sequence) AS authors,
    LISTAGG(DISTINCT g.genre_name, ', ') WITHIN GROUP (ORDER BY g.genre_name) AS genres,
    COUNT(DISTINCT CASE WHEN c.copy_status = 'Available' THEN c.copy_id END) AS available_count,
    COUNT(DISTINCT CASE WHEN c.copy_status = 'Checked Out' THEN c.copy_id END) AS checked_out_count,
    COUNT(DISTINCT CASE WHEN c.copy_status = 'Reserved' THEN c.copy_id END) AS reserved_count
FROM MATERIALS m
LEFT JOIN PUBLISHERS p ON m.publisher_id = p.publisher_id
LEFT JOIN MATERIAL_AUTHORS ma ON m.material_id = ma.material_id
LEFT JOIN AUTHORS a ON ma.author_id = a.author_id
LEFT JOIN MATERIAL_GENRES mg ON m.material_id = mg.material_id
LEFT JOIN GENRES g ON mg.genre_id = g.genre_id
LEFT JOIN COPIES c ON m.material_id = c.material_id
WHERE 1=1
GROUP BY 
    m.material_id,
    m.title,
    m.subtitle,
    m.material_type,
    m.isbn,
    m.publication_year,
    m.language,
    m.total_copies,
    m.available_copies,
    m.is_reference,
    m.is_new_release,
    m.date_added,
    p.publisher_name;