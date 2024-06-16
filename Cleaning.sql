-- ctrl + - + /for comment multiple
-- DATA CLEANING 

-- CREATE TABLE conditions_staging
-- AS TABLE conditions;

-- CREATE TABLE encounters_staging
-- AS TABLE encounters;

-- CREATE TABLE immunizations_staging
-- AS TABLE immunizations;

-- CREATE TABLE patients_staging
-- AS TABLE patients;

-------------------------------------------------------------------------------------------
-- 1. Remove duplicates


-- check for duplicates in conditions_staging
SELECT * 
FROM conditions_staging;

SELECT start, stop, patient, encounter, code, description, COUNT(*) AS count_num
FROM conditions_staging
GROUP BY start, stop, patient, encounter, code, description
HAVING COUNT(*) > 1;
-- no duplicates in conditions_staging

-- check for duplicates in encounters_staging
SELECT * 
FROM encounters_staging;

SELECT id, start, stop, patient, COUNT(*) AS count_num
FROM encounters_staging
GROUP BY id, start, stop, patient
HAVING COUNT(*) > 1;
-- no duplicates in encounters_staging

-- check for duplicates in immunizations_staging
SELECT * 
FROM immunizations_staging;

SELECT date, patient, encounter,description, COUNT(*) AS count_num
FROM immunizations_staging
GROUP BY date, patient, encounter, description
HAVING COUNT(*) > 1;
-- no duplicates in immunizations_staging


------------------------------------------------------------------------------------------
-- 2. Standardize the data
SELECT code
FROM conditions_staging
-- ICD9 code is used to denote the conditions

-- some of the values in code column in condition table have v infront of the number. 
SELECT *
FROM conditions_staging 
WHERE code like 'V%'
-- we don't want to delete the V because it represents a special type of condition
-- UPDATE conditions_staging
-- SET code = SUBSTRING(code FROM 2)
-- WHERE code LIKE 'V%';

-- UPDATE conditions_staging
-- SET code = REGEXP_REPLACE(code, '^V', '')
-- WHERE code LIKE 'V%';

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'conditions_staging' AND column_name = 'stop';

SELECT *
FROM encounters_staging;

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'encounters_staging' AND column_name = 'stop';

SELECT *
FROM immunizations_staging;

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'immunizations_staging' AND column_name = 'date';

SELECT DISTINCT description
FROM immunizations_staging;


SELECT *
FROM patients_staging;

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'patients_staging' AND column_name = 'deathdate';

UPDATE patients_staging
SET county = REPLACE(county, 'County', '')
WHERE county ILIKE '%County%';


-- 3. Null and blanck values

SELECT *
FROM conditions_staging
WHERE stop IS NULL;

-- null values only in stop column in conditions_staging

SELECT *
FROM encounters_staging
WHERE reasoncode IS NULL;

-- null values in reasoncode column

SELECT *
FROM immunizations_staging
WHERE date IS NULL;

-- no null values in immunizations_staging table

SELECT *
FROM patients_staging
WHERE mrn IS NULL;

-- null values in the columns deathdate, drivers, passport, prefix, suffix, maiden, marital, fips,

-- For now I will not delete the null values. Because the purpose of the analysis is to build a dashboard. 
-- Null values can be filtered out in the data visualization application. 
-- For applying machine learning algorithms, deleting the null values or filling them with existing is necessary. 

