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
SELECT 
	COUNT(patient), 
	description
FROM 
	conditions_staging
GROUP BY  
	description
ORDER BY 
	COUNT(patient) Desc
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
    
-------------------
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
    avg(AGE(stop, start)) AS duration_hours,
    code,
    description
FROM conditions_staging
GROUP BY 
    code,
    description
HAVING avg(AGE(stop, start)) IS NOT NULL
ORDER BY duration_hours DESC;


--conditions by patient demographics - age 
-- categorize ages into several categories
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

--- top 3 counts for each age category 

WITH ranked_conditions AS (
    SELECT 
        age_category,
        conditions_staging.description,
        COUNT(*) AS counts,
        ROW_NUMBER() OVER (PARTITION BY age_category ORDER BY COUNT(*) DESC) AS rank
    FROM (
        SELECT 
            id,
            CASE 
                WHEN DATE_PART('YEAR', AGE(current_date, birthdate)) <= 12 THEN 'Child'
                WHEN DATE_PART('YEAR', AGE(current_date, birthdate)) BETWEEN 13 AND 19 THEN 'Teen'
                WHEN DATE_PART('YEAR', AGE(current_date, birthdate)) BETWEEN 20 AND 35 THEN 'Young-Adult'
                WHEN DATE_PART('YEAR', AGE(current_date, birthdate)) BETWEEN 36 AND 55 THEN 'Middle-Aged'
                WHEN DATE_PART('YEAR', AGE(current_date, birthdate)) BETWEEN 56 AND 75 THEN 'Older-Adult'
                ELSE 'Senior'
            END AS age_category
        FROM 
            patients_staging
    ) AS age_categories
    JOIN 
        conditions_staging 
    ON 
        age_categories.id = conditions_staging.patient
    GROUP BY 
        age_category, 
        conditions_staging.description
)
SELECT 
    age_category,
    description,
    counts
FROM 
    ranked_conditions
WHERE 
    rank <= 2
ORDER BY 
    age_category, 
    counts DESC;


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

-- top 2 counts for each race
WITH ranked_conditions AS (
    SELECT 
        patients_staging.race,
        conditions_staging.description,
        COUNT(*) AS counts,
        ROW_NUMBER() OVER (PARTITION BY patients_staging.race ORDER BY COUNT(*) DESC) AS rank
    FROM 
        patients_staging
    JOIN 
        conditions_staging 
    ON 
        patients_staging.id = conditions_staging.patient
    GROUP BY 
        patients_staging.race, 
        conditions_staging.description
)
SELECT 
    race,
    description,
    counts
FROM 
    ranked_conditions
WHERE 
    rank <= 2
ORDER BY 
    race, 
    counts DESC;

--conditions by patient demographics - county (state= Massachusetts)
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
SELECT 
    ROUND(AVG(base_encounter_cost)::numeric, 2) AS avg_base_encounter_cost, 
    ROUND(AVG(total_claim_cost)::numeric, 2) AS avg_total_claim_cost, 
    ROUND(AVG(payer_coverage)::numeric, 2) AS avg_payer_coverage
FROM 
    encounters_staging;
 		             


--	Which providers are associated with the highest number of encounters?
select count(*), encounterclass, provider
from encounters_staging
group by encounterclass, provider
order by encounterclass, count(*) desc;
------------
SELECT DISTINCT ON (encounterclass) 
    encounterclass, 
    provider, 
    encounter_count
FROM (
    SELECT 
        encounterclass, 
        provider, 
        COUNT(*) AS encounter_count
    FROM 
        encounters_staging
    GROUP BY 
        encounterclass, 
        provider
    ORDER BY 
        encounterclass, 
        encounter_count DESC
) subquery
ORDER BY 
    encounterclass, 
    encounter_count DESC;


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
-- For what conditions people pay the highest total claim cost 

select * from encounters_staging;

select * from conditions_staging;
------------
WITH condition_encounter AS (
    SELECT
        e.patient,
        c.description,
        e.payer,
        e.base_encounter_cost,
        e.total_claim_cost
    FROM 
        conditions_staging c
    JOIN 
        encounters_staging e 
        ON c.patient = e.patient
)
SELECT 
    description,
    ROUND(AVG(base_encounter_cost)::numeric, 2) AS avg_base_encounter_cost,
    ROUND(AVG(total_claim_cost)::numeric, 2) AS avg_total_claim_cost
FROM 
    condition_encounter
GROUP BY 
    description
ORDER BY 
    avg_total_claim_cost DESC;


-- what provider has the highest average payer coverage
	   
SELECT * from encounters_staging;

SELECT 
	provider, 
	ROUND(AVG(payer_coverage)::numeric, 2) AS avg_payer_coverage
FROM
	encounters_staging
GROUP BY 
	provider
ORDER BY 
	avg_payer_coverage DESC;


-- most common encounterclass

SELECT 
    COUNT(*) AS encounter_count, 
    encounterclass
FROM 
    encounters_staging
GROUP BY 
    encounterclass
ORDER BY 
    encounter_count DESC;

--	How do encounter costs differ by encounter class?

SELECT 
    COUNT(*) AS encounter_count, 
    encounterclass, 
    AVG(base_encounter_cost) AS avg_base_cost, 
    AVG(total_claim_cost) AS avg_total_claim_cost
FROM 
    encounters_staging
GROUP BY 
    encounterclass
ORDER BY 
    avg_base_cost DESC, 
    avg_total_claim_cost DESC, 
    encounter_count DESC;


--	What are the most common reason codes for encounters?
select encounterclass, reasoncode, count(*)
from encounters_staging
group by reasoncode, encounterclass
order by encounterclass, count(*) desc;

WITH encounter_counts AS (
    SELECT encounterclass, reasoncode, COUNT(*) AS cnt
    FROM encounters_staging
    GROUP BY reasoncode, encounterclass
)
SELECT encounterclass, reasoncode, cnt
FROM encounter_counts
WHERE (encounterclass, cnt) IN (
    SELECT encounterclass, MAX(cnt)
    FROM encounter_counts
    GROUP BY encounterclass
);


--	How do costs and encounter durations vary by reason code?
SELECT
	reasoncode, 
	AVG(base_encounter_cost) as avg_base_cost, 
    AVG(total_claim_cost) as avg_total_claim_cost
FROM 
	encounters_staging
GROUP BY 
	reasoncode
ORDER BY 
	avg_base_cost DESC,
	avg_total_claim_cost DESC;

---most common immunization rates for different vaccines 
SELECT 
	COUNT(*) AS counts,
	description
FROM 
	immunizations_staging
GROUP BY 
	description
ORDER BY 
	counts DESC;

--What are the immunization rates for different vaccines in last year?
SELECT  
    EXTRACT(YEAR FROM date) AS year, 
    description, 
    COUNT(*) AS count
FROM 
    immunizations_staging
WHERE 
    EXTRACT(YEAR FROM date) = 2023
GROUP BY 
    description, year
ORDER BY 
    count(*) desc, description;

select distinct description from immunizations_staging;
-------------------------------------------------------------------------
select * from immunizations_staging;

SELECT description, count(*)
FROM conditions_staging
where patient not in (select distinct patient from immunizations_staging)
group by description
order by count(*) desc;

SELECT description, count(*)
FROM conditions_staging
group by description
order by count(*) desc;

--immunizations and demographics -age
SELECT 
    age_category,
    immunizations_staging.description,
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
    immunizations_staging 
ON 
    age_categories.id = immunizations_staging.patient
Group by age_categories.age_category, 
	immunizations_staging.description
order by age_categories.age_category, counts desc;
--- age a different approah 
WITH age_groups AS (
    SELECT 
        id,
        CASE 
            WHEN DATE_PART('YEAR', AGE(current_date, birthdate)) <= 12 THEN 'Child'
            WHEN DATE_PART('YEAR', AGE(current_date, birthdate)) >= 13 AND DATE_PART('YEAR', AGE(current_date, birthdate)) <= 19 THEN 'Teen'
            WHEN DATE_PART('YEAR', AGE(current_date, birthdate)) >= 20 AND DATE_PART('YEAR', AGE(current_date, birthdate)) <= 35 THEN 'Young-Adult'
            WHEN DATE_PART('YEAR', AGE(current_date, birthdate)) >= 36 AND DATE_PART('YEAR', AGE(current_date, birthdate)) <= 55 THEN 'Middle-Aged'
            WHEN DATE_PART('YEAR', AGE(current_date, birthdate)) >= 56 AND DATE_PART('YEAR', AGE(current_date, birthdate)) <= 75 THEN 'Older-Adult'
            ELSE 'Senior'
        END AS age_group
    FROM 
        patients_staging
),
vaccine_counts AS (
    SELECT 
        age_groups.age_group,
        immunizations.description,
        COUNT(*) AS count
    FROM 
        immunizations
    JOIN 
        age_groups ON immunizations.patient = age_groups.id
    GROUP BY 
        age_groups.age_group,
        immunizations.description
),
ranked_vaccine_counts AS (
    SELECT 
        age_group,
        description,
        count,
        ROW_NUMBER() OVER (PARTITION BY age_group ORDER BY count DESC) AS rank
    FROM 
        vaccine_counts
)
SELECT 
    age_group,
    description,
    count
FROM 
    ranked_vaccine_counts
WHERE 
    rank <= 3
ORDER BY 
    age_group,
    rank;


--immunizations and demographics -race -- count of cases for each description for each race
SELECT 
    patients_staging.race,
    immunizations_staging.description,
	count(*) as counts
FROM patients_staging
JOIN 
    immunizations_staging 
ON 
    patients_staging.id = immunizations_staging.patient
Group by patients_staging.race, 
	immunizations_staging.description
order by patients_staging.race, counts desc;

--top 3 descriptions with highest counts for each race 

WITH vaccine_counts AS (
    SELECT patients_staging.race,
           immunizations.description,
           COUNT(*) AS count
    FROM immunizations
    JOIN patients_staging ON immunizations.patient = patients_staging.id
    GROUP BY patients_staging.race,
             immunizations.description
),
ranked_vaccine_counts AS (
    SELECT race,
           description,
           count,
           ROW_NUMBER() OVER (PARTITION BY race ORDER BY count DESC) AS rank
    FROM vaccine_counts
)
SELECT race,
       description,
       count
FROM ranked_vaccine_counts
WHERE rank <= 3
ORDER BY race,
         rank;

---------------------

--o	Is there any correlation between certain immunizations and the occurrence or severity of specific conditions?

WITH immunizations_conditions AS (
    SELECT 
        i.patient,
        i.code AS immunization_code,
        i.description AS immunization_description,
        c.code AS condition_code,
        c.description AS condition_description
    FROM 
        immunizations_staging i
    JOIN 
        conditions_staging c ON i.patient = c.patient
	WHERE 
        i.description <> 'Seasonal Flu Vaccine'
)
SELECT 
    immunization_code,
    immunization_description,
    condition_code,
    condition_description,
    COUNT(*) AS occurrence_count
FROM 
    immunizations_conditions
GROUP BY 
    immunization_code,
    immunization_description,
    condition_code,
    condition_description
ORDER BY 
    occurrence_count DESC;




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
    ROUND(AVG(EXTRACT(EPOCH FROM (stop - start)) / 60),1) AS average_time_spent_minutes,
    ROUND(AVG(EXTRACT(EPOCH FROM (stop - start)) / 3600),1) AS average_time_spent_hours,
	encounterclass
FROM 
    encounters_staging
GROUP BY encounterclass
ORDER BY average_time_spent_hours DESC;


----Percentage of patients for each encounterclass who spend time higher than the average time 

WITH avg_time_spent AS (
    SELECT encounterclass,
           ROUND(AVG(EXTRACT(EPOCH FROM (stop - start)) / 3600), 1) AS avg_time_spent_hours,
	       COUNT(patient) AS total_patients
    FROM encounters_staging
    GROUP BY encounterclass
),
patient_time_spent AS (
    SELECT patient,
           encounterclass,
    EXTRACT(EPOCH FROM (stop - start)) / 3600 AS time_spent_hours
    FROM encounters_staging
),
patients_above_avg AS (
    SELECT pts.encounterclass,
           COUNT(pts.patient) AS count_of_patients_above_avg
    FROM patient_time_spent pts
    JOIN avg_time_spent ats 
    ON pts.encounterclass = ats.encounterclass
    WHERE pts.time_spent_hours > ats.avg_time_spent_hours
    GROUP BY pts.encounterclass
)
SELECT 
    p.encounterclass,
    ats.total_patients,
    p.count_of_patients_above_avg,
    ROUND((p.count_of_patients_above_avg::numeric / ats.total_patients) * 100, 2) AS percentage_above_avg
FROM patients_above_avg p
JOIN avg_time_spent ats 
ON p.encounterclass = ats.encounterclass
ORDER BY percentage_above_avg DESC;


