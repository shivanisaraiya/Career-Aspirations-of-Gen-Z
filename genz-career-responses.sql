CREATE DATABASE genzdb;
USE genzdb;


CREATE TABLE career (
    timestamp DATETIME,
    country VARCHAR(255),
    zipcode INT,
    gender VARCHAR(255),
    career_aspiration_factors VARCHAR(255),
    pursue_higher_education_abroad VARCHAR(255),
    work_for_3_years_or_more VARCHAR(255),
    work_for_company_with_unclear_mission VARCHAR(255),
    work_for_company_with_misaligned_mission VARCHAR(255),
    work_for_company_with_no_social_impact INT,
    preferred_working_environment VARCHAR(255),
    preferred_employer VARCHAR(255),
    preferred_learning_environment VARCHAR(255),
    aspirational_career VARCHAR(255),
    ideal_manager_type VARCHAR(255),
    work_setup VARCHAR(255),
    work_for_company_with_recent_layoffs VARCHAR(255),
    work_for_7_years_or_more VARCHAR(255),
    email_address VARCHAR(255),
    expected_salary_first_3_years VARCHAR(255),
    expected_salary_after_5_years VARCHAR(255),
    work_for_company_with_no_remote_policy INT,
    starting_monthly_salary_expectation VARCHAR(255),
    preferred_company_type VARCHAR(255),
    work_for_company_with_abusive_manager VARCHAR(255),
    working_hours_per_day VARCHAR(255),
    required_full_week_break VARCHAR(255),
    factors_for_happy_work_productivity VARCHAR(255),
    workplace_frustrations VARCHAR(255)
);

## LOADING CSV FILE INTO MYSQL
 #Method 1
-- LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/career_aspirations.csv' 
-- INTO TABLE career 
-- FIELDS TERMINATED BY ','
-- IGNORE 1 LINES;

 #Method 2
-- LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/career.csv' 
-- INTO TABLE career
-- FIELDS TERMINATED BY ',' 
-- ENCLOSED BY '"'
-- IGNORE 1 LINES;

## DATA CLEANING
-- SELECT DISTINCT preferred_learning_environment FROM career;

-- UPDATE career 
-- SET preferred_learning_environment = TRIM(preferred_learning_environment);

-- UPDATE career
-- SET work_setup = TRIM(work_setup);


-- ALTER TABLE career_aspirations 
-- ADD COLUMN id INT AUTO_INCREMENT PRIMARY KEY;
-- RENAME TABLE career_aspirations TO career;


# Change Column Datatype from VARCHAR to INT
-- ALTER TABLE career 
-- MODIFY COLUMN work_for_company_with_no_remote_policy INT;  

-- UPDATE career
-- SET preferred_learning_environment = TRIM(preferred_learning_environment)
--   WHERE preferred_learning_environment IS NOT NULL; */
   
--  UPDATE career
--   SET gender = CASE
--      WHEN gender = 'F' THEN 'Female'
--      WHEN gender = 'M' THEN 'Male'
--      WHEN gender = 'Other' THEN 'Transgender'
--   ELSE gender
-- END; 


## DATA CLEANING

## EXPLORATORY DATA ANALYSIS
-- 1) Checking Rows in the Dataset
SELECT COUNT(*) AS Row_Count 
FROM career;

-- 2) Checking the distribution of Countries in our Data
SELECT 
    country AS Country, 
    COUNT(*) AS 'Country Count'
FROM career 
GROUP BY country 
ORDER BY COUNT(*) DESC;

-- 3) Gender Distribution
SELECT 
     gender AS 'Gender',
     SUM(COUNT(*)) OVER() AS 'total count',
     Count(*) AS Count,
     ROUND(COUNT(*)*100/(SELECT COUNT(*) FROM career),2) AS 'Gender Distribution'
FROM career
GROUP BY gender;

-- 4) Distribution of Aspirational Career Choices

SELECT 
      aspirational_career AS 'Career Options', 
      COUNT(*) AS Count,
--   (SELECT COUNT(*) FROM career) as total_rows
      SUM(COUNT(*)) OVER () AS total_rows
FROM 
    career
GROUP BY 
     aspirational_career
ORDER BY 
     count DESC;

-- 5) Salary expectation for 3 Years Experience 
SELECT 
      expected_salary_first_3_years AS 'Expected Salary 3 Years Experience', 
      CONCAT(ROUND(COUNT(*)* 100/(SELECT COUNT(*) FROM CAREER),2),'%') AS Percentage
FROM career 
GROUP BY expected_salary_first_3_years
ORDER BY Percentage DESC;

-- 6) Salary expectation for 5 Years Experience
SELECT 
      expected_salary_after_5_years, 
      ROUND(COUNT(*)* 100/(SELECT COUNT(*) FROM CAREER),2) AS Percentage
FROM career 
GROUP BY expected_salary_after_5_years;

-- 7) Starting monthly salary expectations by Gender

SELECT 
    gender,
    ROUND(AVG(
        (CAST(SUBSTRING_INDEX(REPLACE(starting_monthly_salary_expectation, 'k', ''), ' to ', 1) AS UNSIGNED) +
         CAST(SUBSTRING_INDEX(REPLACE(starting_monthly_salary_expectation, 'k', ''), ' to ', -1) AS UNSIGNED)) / 2
    ) * 1000, 2) AS avg_starting_salary
FROM career
WHERE starting_monthly_salary_expectation NOT LIKE 'Nil' 
GROUP BY gender
ORDER BY gender;


-- 8) Top 5 Preferred Work Setups? 
SELECT 
    work_setup, 
    COUNT(*) AS preference_count, 
    ROUND((COUNT(*)/(SELECT COUNT(*) FROM career)*100),2) AS Preference_percentage
FROM 
   career
-- WHERE work_setup LIKE '%,%'
GROUP BY 
   work_setup
LIMIT 5;



## MISSION ASPIRATIONS
-- 1. Are Gen Z more likely to avoid abusive managers if they prioritize social impact? 

WITH categorized_data AS (
    SELECT
        CASE
            WHEN work_for_company_with_no_social_impact BETWEEN 1 AND 4 THEN 'Reject'
            WHEN work_for_company_with_no_social_impact BETWEEN 7 AND 10 THEN 'Accept'
            ELSE 'Neutral'
        END AS `Social Impact over Abusive Manager`
    FROM career
    WHERE work_for_company_with_abusive_manager = 'No'
)

SELECT
    `Social Impact over Abusive Manager`,
    COUNT(*) AS Count,
    ROUND((COUNT(*) * 100.0) / SUM(COUNT(*)) OVER(), 2) AS Percentage
FROM categorized_data
GROUP BY `Social Impact over Abusive Manager`
ORDER BY Percentage DESC;


-- 2. Percentage of respondents willing and not willing to work for abusive managers 

SELECT 
    CASE 
        WHEN work_for_company_with_abusive_manager = 'No' THEN 'Avoid Abusive Managers'
        WHEN work_for_company_with_abusive_manager = 'Yes' THEN 'Work for Abusive Managers'
    END AS category,
    COUNT(*) AS count,
    CONCAT(ROUND((COUNT(*) * 100.0) / (SELECT COUNT(*) FROM career 
    WHERE work_for_company_with_abusive_manager NOT LIKE '%Nil%'), 2), '%') AS percentage
FROM career
WHERE work_for_company_with_abusive_manager IN ('No', 'Yes')
GROUP BY category;


 
 -- 3. What is the factor count and percentage for happy productivity align with those 
        willing to stay 3+ years despite layoffs? 

SELECT 
    factors_for_happy_work_productivity AS 'Workplace Productivity Factors', 
     COUNT(*) AS 'Respondant Count',
    -- SUM(COUNT(*)) OVER () as 'Total Count',
    CONCAT(ROUND((COUNT(*) / 
          (SELECT COUNT(*) FROM career 
           WHERE work_for_3_years_or_more = 'Yes' 
           AND work_for_company_with_recent_layoffs = 'Yes'
           AND factors_for_happy_work_productivity NOT LIKE '%Nil%')) * 100, 2),'%') AS Percentage
FROM career
WHERE work_for_3_years_or_more = 'Yes'
AND work_for_company_with_recent_layoffs = 'Yes' 
AND factors_for_happy_work_productivity NOT LIKE '%Nil%' 
GROUP BY factors_for_happy_work_productivity
ORDER BY 'Respondant Count' DESC ;

-- 4. How many Gen Z individuals are willing to work for a company with no social impact? 

SELECT 
    work_for_company_with_no_social_impact, 
    COUNT(*) AS 'count of respondents',
     SUM(COUNT(*)) OVER () AS 'total count of respondents'
FROM career
-- WHERE work_for_company_with_no_social_impact IN (7,8,9,10)
GROUP BY work_for_company_with_no_social_impact 
ORDER BY COUNT(*) DESC, work_for_company_with_no_social_impact DESC;


## MANAGER ASPIRATIONS
-- 1. Top 5 Workplace Frustrations of GenZ based on the Company Type? (MANAGER ASPIRATIONS)

WITH ranked_frustrations AS (
    SELECT 
        workplace_frustrations,
        preferred_company_type,
        COUNT(*) AS total_count,
        RANK() OVER (PARTITION BY workplace_frustrations ORDER BY  COUNT(*) DESC) AS `rank`
    FROM career
    WHERE 
        workplace_frustrations NOT LIKE '%Nil%' 
        AND preferred_company_type NOT LIKE '%Nil%'
    GROUP BY 
        workplace_frustrations, preferred_company_type
)

SELECT 
    workplace_frustrations,
    preferred_company_type,
    total_count
FROM ranked_frustrations
WHERE `rank` = 1;

-- 2.  Type of work environment preferred by top 5 career options    

WITH career_totals AS (
    SELECT 
        aspirational_career, 
        COUNT(*) AS total_count
    FROM career
    WHERE aspirational_career IS NOT NULL
    GROUP BY aspirational_career
    ORDER BY total_count DESC
    LIMIT 5
)
SELECT 
    c.aspirational_career AS 'Aspiring Career', 
    c.preferred_working_environment AS 'Work Environment', 
     COUNT(*) AS 'Total Count'
FROM 
   career c
JOIN 
   career_totals ct 
ON 
   c.aspirational_career = ct.aspirational_career
WHERE 
   c.preferred_working_environment IS NOT NULL
GROUP BY 
   c.aspirational_career, c.preferred_working_environment
ORDER BY 
   ct.total_count DESC;

-- 3. Can Work Productivity Factors be Influenced by the type of Employer? (MANAGER ASPIRATIONS)

WITH RankedFactors AS (
    SELECT 
        preferred_employer AS 'Employer Type',
        factors_for_happy_work_productivity AS 'Top Productivity Factor',
        COUNT(*) AS Count,
        RANK() OVER (PARTITION BY preferred_employer ORDER BY COUNT(*) DESC) AS `rank`
    FROM career
    WHERE factors_for_happy_work_productivity != 'Nil'
    GROUP BY preferred_employer, factors_for_happy_work_productivity
)

SELECT 
    `Employer Type`,
    `Top Productivity Factor`,
    Count
FROM RankedFactors
WHERE `rank` = 1
ORDER BY count DESC;

-- 4.  Is there a relationship between preferred learning environment and willingness to work long-term (3+ years)? 

SELECT 
    preferred_learning_environment,
    COUNT(*) AS total_responses,
    SUM(CASE WHEN work_for_3_years_or_more = 'Yes' THEN 1 ELSE 0 END) AS willing_to_stay_3_years,
    ROUND(
        (SUM(CASE WHEN work_for_3_years_or_more = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 
        2
    ) AS percentage_willing_to_stay
FROM 
    career
GROUP BY 
    preferred_learning_environment
ORDER BY 
    percentage_willing_to_stay DESC;

-- 5.  For employees willing to stay 3+ years at the same company, 
--     what is their preferred order of work setups?   

SELECT 
    work_setup,
    COUNT(*) AS employees_willing_to_stay_longterm,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS percentage_of_total_retained
FROM 
    career
WHERE 
    work_for_3_years_or_more = 'Yes'
GROUP BY 
    work_setup
ORDER BY 
    employees_willing_to_stay_longterm DESC;


##LEARNING ASPIRATIONS
-- 1. What percentage of respondents want to study abroad, and how does this compare to those needing sponsorship or not pursuing it? 

SELECT 
    pursue_higher_education_abroad AS 'interested in higher education abroad?', 
    COUNT(*) AS count,
    CONCAT(ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM career)),2),'%') AS percentage
FROM career
GROUP BY pursue_higher_education_abroad;

-- 2. What is the Percentage of Respondents interested in Pursuing Higher Education Abroad? 

SELECT 
    gender, 
    ROUND(
        (COUNT(*) * 100) / 
        (SELECT COUNT(*) FROM career WHERE pursue_higher_education_abroad = 'yes'), 
        2) AS percentage
FROM career  
WHERE pursue_higher_education_abroad = 'yes' 
GROUP BY gender; 

 -- 3. What are the respondents' top 5 most common career aspirations, 
--     based on the number of responses who are also interested in higher education abroad?  
   
SELECT 
        aspirational_career AS 'Top 5 Career Choices', 
        COUNT(*) AS total_responses 
FROM 
      career
WHERE 
       pursue_higher_education_abroad = 'yes'
GROUP BY 
       aspirational_career 
ORDER BY 
         COUNT(*) DESC 
LIMIT 5;

-- 4. Do higher salary expectations align with a preference for remote work? (LEARNING ASPIRATIONS)

SELECT
    preferred_working_environment AS 'Preferred Work Setup',
    ROUND((COUNT(*) * 100.0) / (SELECT COUNT(*) FROM career), 2) AS 'Respondent Percentage',
    ROUND(AVG(
        (CAST(SUBSTRING_INDEX(REPLACE(expected_salary_after_5_years, 'k', ''), ' to ', 1) AS UNSIGNED) +
         CAST(SUBSTRING_INDEX(REPLACE(expected_salary_after_5_years, 'k', ''), ' to ', -1) AS UNSIGNED)) / 2
    ) * 1000, 2) AS '5 years monthly salary'
    
FROM career
-- WHERE preferred_working_environment  = 'Remote'-- IS NOT NULL AND preferred_working_environment <> ''
GROUP BY preferred_working_environment
ORDER BY '5 years expected salary' DESC;

-- 5. How can Career Choice influence learning environment among Gen Z ?
WITH career_influence_learn_env AS (
SELECT 
    aspirational_career AS `Career Options`, 
    preferred_learning_environment AS `Mode of Learning`, 
    RANK() OVER (PARTITION BY aspirational_career ORDER BY COUNT(*) DESC) AS rn,
    COUNT(*) AS Responses
FROM 
   career
WHERE 
   preferred_learning_environment IS NOT NULL
GROUP BY 
   aspirational_career, 
   preferred_learning_environment
ORDER BY 
   Responses DESC )

SELECT
     `Career Options`, 
     `Mode of Learning`, 
   Responses AS `Max Responses`
FROM 
    career_influence_learn_env 
WHERE 
    rn=1
ORDER BY 
    `Max Responses` DESC;
    
    -- ---------------------------------
SELECT aspirational_career, preferred_learning_environment, COUNT(*) AS count
FROM career
WHERE preferred_learning_environment IS NOT NULL
GROUP BY aspirational_career, preferred_learning_environment
ORDER BY count DESC;