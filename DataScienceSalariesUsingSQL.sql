
/*
Name: Richard Lee

Chosen Data Set: Levels_Fyi_Salary_Data.csv

Reason for Choosing Data Set: The whole purpose of me pursuing the 
Master's Degree was to land a job as a Data Scientist and I was
curious about the salaries of that position which is why I chose
this data set.
*/

-- PART 1: Creating the Table and Importing the Data

CREATE TABLE levels_fyi_salary_data (
    timestamp TIMESTAMP,
    company VARCHAR(255),
    level VARCHAR(255),
    title VARCHAR(255),
    totalyearlycompensation INTEGER,
    location VARCHAR(255),
    yearsofexperience FLOAT,
    yearsatcompany FLOAT,
    tag VARCHAR(255),
    basesalary FLOAT,
    stockgrantvalue FLOAT,
    bonus FLOAT,
    gender VARCHAR(255),
    otherdetails TEXT,
    cityid INTEGER,
    dmaid VARCHAR(255),
    rowNumber INTEGER,
    Masters_Degree INTEGER,
    Bachelors_Degree INTEGER,
    Doctorate_Degree INTEGER,
    Highschool INTEGER,
    Some_College INTEGER,
    Race_Asian INTEGER,
    Race_White INTEGER,
    Race_Two_Or_More INTEGER,
    Race_Black INTEGER,
    Race_Hispanic INTEGER,
    Race VARCHAR(255),
    Education VARCHAR(255)
);

COPY levels_fyi_salary_data
FROM 'C:\Users\Public\Levels_Fyi_Salary_Data.csv'
WITH (FORMAT CSV,HEADER);

SELECT * FROM levels_fyi_salary_data LIMIT 100;

-- PART 2: Cleaning

-- Step 1: Create a backup of the imported table. It basically copies the table I just created.
CREATE TABLE levels_fyi_salary_data_backup AS
SELECT * FROM levels_fyi_salary_data;

-- Step 2: Create a duplicate column. It creates another copy of 'title'.
ALTER TABLE levels_fyi_salary_data ADD COLUMN title_duplicate VARCHAR(255);
UPDATE levels_fyi_salary_data SET title_duplicate = title;

-- Step 3: Handle missing data in 'tag' column by setting them as NULL. The missing data was 'NA'.
UPDATE levels_fyi_salary_data
SET tag = NULL
WHERE tag = 'NA';

-- Step 4: Handle missing data in 'gender' column by setting them to 'Not Provided'. The missing data was 'NA'.
UPDATE levels_fyi_salary_data
SET gender = 'Not Provided'
WHERE gender = 'NA';

-- Step 5 Update values in 'location' column to remove ', United States' to make it stay consistent 
-- other values that do not have 'United States'.  For example, I want to update 'Monroe, LA, United States' 
-- to 'Monroe, LA'.
UPDATE levels_fyi_salary_data
SET location = REPLACE(location, ', United States', '')
WHERE location LIKE '%, United States%';

-- Step 6: Update values in 'company' column to make sure all companies are capitalized. For example, 
-- I noticed some companies like Microsoft were spelled either 'Microsoft' or 'MICROSOFT' and I want
-- every single company to be capitalized to stay consistent.
UPDATE levels_fyi_salary_data
SET company = UPPER(company);

-- Step 7: A valuable method not used in this assignment is handling outliers. Outliers can distort the 
-- results of the data analysis and statistical modeling and improve the quality of the dataset.

-- Calculate Q1, Q3, IQR, and Median for totalyearlycompensation
WITH Stats AS (
    SELECT 
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY totalyearlycompensation) AS Q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY totalyearlycompensation) AS Q3,
        PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY totalyearlycompensation) AS Median
    FROM levels_fyi_salary_data
)
-- Replace outliers with median value
UPDATE levels_fyi_salary_data
SET totalyearlycompensation = (SELECT Median FROM Stats)
WHERE totalyearlycompensation < (SELECT Q1 - 1.5 * (Q3 - Q1) FROM Stats) OR 
      totalyearlycompensation > (SELECT Q3 + 1.5 * (Q3 - Q1) FROM Stats);


