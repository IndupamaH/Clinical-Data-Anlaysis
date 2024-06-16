SELECT *
FROM conditions_staging;


SELECT * 
FROM encounters_staging;

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


 


