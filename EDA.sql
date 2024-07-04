--this is EDA and updated on computer 

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
	
-- updated to check git ub 

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

