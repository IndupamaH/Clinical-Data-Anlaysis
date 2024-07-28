-- Exploratory Data Analysis 

SELECT *
FROM conditions_staging;

SELECT * 
FROM encounters_staging;

SELECT * 
FROM immunizations_staging;

SELECT * 
FROM patients_staging;

Select * 
	from patients_staging
	where first = 'Latrice';


-------------------understanding the data set--------------------

SELECT COUNT(DISTINCT encounter) FROM immunizations_staging;

SELECT COUNT(DISTINCT encounterclass) FROM encounters_staging;
SELECT COUNT(DISTINCT code) FROM encounters_staging;
SELECT COUNT(DISTINCT code) FROM conditions_staging;
SELECT COUNT(DISTINCT patient) FROM conditions_staging;

-- top 5 common conditions in patient populations
SELECT COUNT(patient), description
FROM conditions_staging
GROUP BY  description
ORDER BY COUNT(patient) Desc
LIMIT 5;
	
SELECT COUNT(patient), description
FROM encounters_staging
GROUP BY description
ORDER BY COUNT(patient) Desc
LIMIT 5;

SELECT COUNT(id), description
FROM encounters_staging
GROUP BY description
ORDER BY COUNT(id) Desc
LIMIT 5;


SELECT COUNT(id), encounterclass
FROM encounters_staging
GROUP BY encounterclass
ORDER BY COUNT(id) Desc
LIMIT 5;

--How does the prevalence of specific conditions change over time?

SELECT 
    year,
    condition_code,
    condition_description,
    COUNT(*) AS prevalence
FROM (
    SELECT 
        EXTRACT(YEAR FROM start) AS year,
        code AS condition_code,
        description AS condition_description
    FROM 
        conditions_staging
) sub
GROUP BY 
    year, 
    condition_code, 
    condition_description
ORDER BY 
    year, condition_code;
    

SELECT 
    year,
    condition_code,
    condition_description,
    COUNT(*) AS prevalence
FROM (
    SELECT 
        EXTRACT(YEAR FROM start) AS year,
        code AS condition_code,
        description AS condition_description
    FROM 
        encounters_staging
) sub
GROUP BY 
    year, 
    condition_code, 
    condition_description
ORDER BY 
    condition_code, year;
-- What is the average duration of different conditions from start date to stop date?
SELECT
	AGE(stop, start) as duration,
	code,
	description
FROM conditions_staging
GROUP BY duration,
	code,
	description
ORDER BY duration desc;

SELECT
	stop - start as duration,
	code,
	description
FROM encounters_staging
GROUP BY duration,
	code,
	description
ORDER BY duration desc;

--conditions by patient demographics - age 
SELECT 
    id, age, 
    CASE 
        WHEN age <= 12 THEN 'Child'
        WHEN age >= 13 AND age <= 19 THEN 'Teen'
        WHEN age >= 20 AND age <= 35 THEN 'Young-Adult'
        WHEN age >= 36 AND age <= 55 THEN 'Middle-Aged'
        WHEN age >= 56 AND age <= 75 THEN 'Older-Adult'
        ELSE 'Senior'
    END AS age_category
FROM (
    SELECT 
        id, DATE_PART('YEAR', AGE(current_date, birthdate)) AS age
    FROM 
        patients_staging );


------------------------------------------
SELECT 
    age_category,
    conditions_staging.description,
	count(*) as counts
FROM (
    SELECT 
        id,
        CASE 
            WHEN DATE_PART('YEAR', AGE(current_date, birthdate)) <= 12 THEN 'Child'
            WHEN DATE_PART('YEAR', AGE(current_date, birthdate)) >= 13 AND DATE_PART('YEAR', AGE(current_date, birthdate)) <= 19 THEN 'Teen'
            WHEN DATE_PART('YEAR', AGE(current_date, birthdate)) >= 20 AND DATE_PART('YEAR', AGE(current_date, birthdate)) <= 35 THEN 'Young-Adult'
            WHEN DATE_PART('YEAR', AGE(current_date, birthdate)) >= 36 AND DATE_PART('YEAR', AGE(current_date, birthdate)) <= 55 THEN 'Middle-Aged'
            WHEN DATE_PART('YEAR', AGE(current_date, birthdate)) >= 56 AND DATE_PART('YEAR', AGE(current_date, birthdate)) <= 75 THEN 'Older-Adult'
            ELSE 'Senior'
        END AS age_category
    FROM 
        patients_staging
) AS age_categories
JOIN 
    conditions_staging 
ON 
    age_categories.id = conditions_staging.patient
Group by age_categories.age_category, 
	conditions_staging.description
order by age_categories.age_category, counts desc;

--conditions by patient demographics - ethnicity

SELECT 
    patients_staging.ethnicity,
    conditions_staging.description,
	count(*) as counts
FROM patients_staging
JOIN 
    conditions_staging 
ON 
    patients_staging.id = conditions_staging.patient
Group by patients_staging.ethnicity, 
	conditions_staging.description
order by patients_staging.ethnicity, counts desc;

--conditions by patient demographics - gender

SELECT 
    patients_staging.gender,
    conditions_staging.description,
	count(*) as counts
FROM patients_staging
JOIN 
    conditions_staging 
ON 
    patients_staging.id = conditions_staging.patient
Group by patients_staging.gender, 
	conditions_staging.description
order by patients_staging.gender, counts desc;

--all are female

--conditions by patient demographics - race
SELECT 
    patients_staging.race,
    conditions_staging.description,
	count(*) as counts
FROM patients_staging
JOIN 
    conditions_staging 
ON 
    patients_staging.id = conditions_staging.patient
Group by patients_staging.race, 
	conditions_staging.description
order by patients_staging.race, counts desc;

--conditions by patient demographics - county (all are Massachusetts)
SELECT 
    patients_staging.county,
    conditions_staging.description,
	count(*) as counts
FROM patients_staging
JOIN 
    conditions_staging 
ON 
    patients_staging.id = conditions_staging.patient
Group by patients_staging.county, 
	conditions_staging.description
order by counts desc;

--	What are the average base encounter costs and total claim costs?
select avg(base_encounter_cost), avg(total_claim_cost), avg(payer_coverage) from encounters_staging;


--	Which providers are associated with the highest number of encounters?
select count(*), encounterclass, provider
from encounters_staging
group by encounterclass, provider
order by encounterclass, count(*) desc;

--	How do total claim costs vary across different provider?
SELECT 
    ROUND(AVG(total_claim_cost)::numeric, 2) AS average_total_claim_cost,
    provider
FROM 
    encounters_staging
GROUP BY 
    provider
ORDER BY 
    average_total_claim_cost DESC
LIMIT 
    10;




-------------------------------------------------------------------------



SELECT COUNT(patient)
	, encounter
FROM conditions_staging;

-- get distinct encounterclass
SELECT DISTINCT encounterclass
FROM encounters_staging;
--snf = skilled nursing facilities

-- inpatient encounters 
SELECT * 
FROM encounters_staging
WHERE encounterclass = 'inpatient';

-- inpatient encounters that are admitted to ICU
SELECT * 
FROM encounters_staging
WHERE encounterclass = 'inpatient' 
	AND description = 'ICU Admission';

-- inpatient encounters that are admitted to ICU in 2023
SELECT * 
FROM encounters_staging
WHERE encounterclass = 'inpatient' 
	AND description = 'ICU Admission'
    AND stop >= '2023-01-01 00:00';

--Ambulatory or outpatient 
SELECT * 
FROM encounters_staging
WHERE encounterclass in ('outpatient', 'ambulatory');

------------------------------------------------------------------------------
SELECT * 
FROM conditions_staging;

-- how many occurances of each condition described in description in this patients population 
-- display only the cases having occurances higher than 2000
SELECT description
	,COUNT(*)        
FROM conditions_staging
GROUP BY description
HAVING COUNT(*) > 2000
ORDER BY COUNT(*) DESC;


---------------------------------------------------------------------------------------
-- patients from Boston
SELECT * 
FROM patients_staging
WHERE city = 'Boston';

--all patients who have been diagnosed with Chronic Kidney disease - codes (585.1, 585.2, 585.3, 585.4)
SELECT * 
FROM conditions_staging
WHERE code in ('585.1',' 585.2', '585.3', '585.4');

-- number of patients per each city that does not include the city 'Boston' with at least 100 patients 
-- from that city
SELECT city, COUNT(*) as num_of_patients
FROM patients_staging
WHERE city != 'Boston'
GROUP BY city 
HAVING COUNT(*) >= 100
ORDER BY COUNT(*) DESC;

-- get patient's first, last names and immunization descriptions
	
SELECT pat.id
	, pat.first
	, pat.last
	, imm.description
FROM patients_staging AS pat
iNNER JOIN immunizations_staging AS imm
	ON pat.id = imm.patient;

-- get the immunizations records for the patient named Adelina

SELECT pat.id
	, pat.first
	, pat.last
	, imm.description
FROM patients_staging AS pat
iNNER JOIN immunizations_staging AS imm
	ON pat.id = imm.patient
    AND pat.first = 'Adelina'

-- Analysis: Amswer the following questions 

-- How long do patients typically spend in the hospital?

SELECT 
    AVG(EXTRACT(EPOCH FROM (stop - start)) / 60) AS average_time_spent_minutes,
    AVG(EXTRACT(EPOCH FROM (stop - start)) / 3600) AS average_time_spent_hours
FROM 
    encounters_staging;

-- start and stop dates in coditions_staging table are the date the condition was first recorded 
-- and end date when the conditions were cured 
-- SELECT 
--     (stop - start) AS average_time_spent_days
-- FROM 
--     conditions_staging;



-- average time spent at the hospital for each encounter class
SELECT 
    AVG(EXTRACT(EPOCH FROM (stop - start)) / 60) AS average_time_spent_minutes,
    AVG(EXTRACT(EPOCH FROM (stop - start)) / 3600) AS average_time_spent_hours,
	encounterclass
FROM 
    encounters_staging
GROUP BY encounterclass
ORDER BY average_time_spent_hours asc;

