-- Add cover_image column to MATERIALS table
-- Run this script in SQL Developer or SQLPlus

ALTER TABLE PROJET_ADMIN.MATERIALS ADD (
  cover_image VARCHAR2(255) DEFAULT NULL
);

-- Update existing materials with cover image paths
-- This assumes your material_ids are 1-29
UPDATE PROJET_ADMIN.MATERIALS 
SET cover_image = '/covers/' || material_id || '.jpg'
WHERE material_id BETWEEN 1 AND 29;
rollback;
COMMIT;

-- Verify the update
SELECT material_id, title, cover_image 
FROM PROJET_ADMIN.MATERIALS 
WHERE material_id BETWEEN 1 AND 29
ORDER BY material_id;
