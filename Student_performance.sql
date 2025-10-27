-- STEP 1: create a working copy of the data 


SELECT * FROM `Student_performance`.`studentsperformance (1)`
LIMIT 10; 

SELECT * 


CREATE TABLE SP LIKE `Student_performance`.`studentsperformance (1)`;
SELECT * FROM SP;

INSERT SP
SELECT *
FROM `Student_performance`.`studentsperformance (1)`;

-- STEP 2: Remove duplicate 

WITH duplicate_cte AS (
    SELECT *,
		  ROW_NUMBER () OVER(
               PARTITION BY  gender, `race/ethnicity`, 
                         `parental level of education`, lunch, 
                         `test preparation course`, 
                         `math score`, `reading score`, `writing score`
					) AS rn 
				FROM SP
	)
    DELETE FROM SP 
    WHERE gender IN (
        SELECT gender FROM duplicate_cte WHERE rn > 1
        ); 
          
                
      SELECT 
    gender, `race/ethnicity`, `parental level of education`, lunch,
    `test preparation course`, `math score`, `reading score`, `writing score`,
    COUNT(*) AS nb
FROM SP
GROUP BY 
    gender, `race/ethnicity`, `parental level of education`, lunch,
    `test preparation course`, `math score`, `reading score`, `writing score`
HAVING COUNT(*) > 1;
                      
-- no duplicates 

-- STEP 3: Standardize categorical values 
 

UPDATE SP
SET
    gender = TRIM(LOWER(gender)),
    `parental level of education` = TRIM(LOWER(`parental level of education`)),
    lunch = TRIM(LOWER(lunch)),
    `test preparation course` = TRIM(LOWER(`test preparation course`));
-- applicable only on text, there is no need to use it on math score and reading score.


-- STEP 4: Handle nulls and blanks 
UPDATE SP
SET `test preparation course` = 'unknown'
WHERE `test preparation course` IS NULL OR `test preparation course` = '';

-- STEP 5: EDA
--  identify key factors influencing student exam performance based on various factors such as gender, 
-- race, parental education level, lunch type, etc. 

-- 1. student behavior 
-- Try to understand whether being male or female influences academic performance.
-- Does race or ethnicity play a role? What about family background, such as parental education level, lunch type (which can indicate household income), and participation in test preparation courses (linked to educational culture)?
-- Who performs best in math? In reading? In writing?
-- What type of student tends to succeed, and why?
-- Why do some students underperform?
-- What are the highest overall performances, and what are they attributed to?


-- 1.Average global scores and average score by student 
SELECT 
ROUND(AVG(`math score`), 2) AS avg_math, 
ROUND(AVG(`reading score`), 2) AS avg_reading, 
ROUND(AVG(`writing score`), 2) AS avg_writing 
FROM SP;



-- it seems like in reading there is better grades 69.17; maths has the lowest grades 66.09. Maths is the most complicated grade 
SELECT *,
    ROUND((`math score` + `reading score` + `writing score`) / 3, 2) AS average_score
FROM SP
ORDER BY average_score DESC
LIMIT 10;
-- the best students 

SELECT *,
    ROUND((`math score` + `reading score` + `writing score`) / 3, 2) AS average_score
FROM SP
ORDER BY average_score ASC
LIMIT 10;

-- the weakest students 
SELECT *, 
      ROUND((`math score`+ `reading score`+ `writing score`) /3, 2) AS average_score
FROM SP; 


-- 2.Gender analysis 

SELECT 
gender, 
ROUND(AVG(`math score`), 2) AS avg_math, 
ROUND(AVG(`reading score`), 2) AS avg_reading, 
ROUND(AVG(`writing score`), 2) AS avg_writing 
FROM SP
GROUP BY gender; 

-- Female students appear to be more successful overall, with higher average scores in reading (72.61) and writing (72.47). However, they have a lower average score in math compared to male students.

-- 3. race analysis 

SELECT
`race/ethnicity`,
ROUND(AVG(`math score`), 2) AS avg_math, 
ROUND(AVG(`reading score`), 2) AS avg_reading, 
ROUND(AVG(`writing score`), 2) AS avg_writing 
FROM SP
GROUP BY `race/ethnicity`; 
-- we can see the avg in each categories of different races

SELECT 
    `race/ethnicity`,
    ROUND(AVG((`math score` + `reading score` + `writing score`) / 3), 2) AS avg_overall_score
FROM SP
GROUP BY `race/ethnicity`;
-- we have the overall average score by race. the group E has the best average with 72.75; the group A has the lowest average with 62.99

-- 4. parental level of education

SELECT 
 `parental level of education`,
 ROUND(AVG((`math score` + `reading score` + `writing score`)/3), 2) AS avg_overall_score
 FROM SP
 GROUP BY `parental level of education`;
 
 -- The higher the level of education of the parent the higher the score and results of the student will be 
 
 -- 5. lunch 
 
 SELECT 
 lunch,
 ROUND(AVG((`math score` + `reading score` + `writing score`)/3), 2) AS avg_overall_score
 FROM SP
 GROUP BY lunch;
 
 -- those who have a standard lunch have a better average overall score. 70.84 against 62.20 when it's free or reduced. It is a big gap
 
 -- This suggests that family income may play a significant role in student performance.
 
 
 

-- 5.test preparation course

 
SELECT 
 `test preparation course`,
 ROUND(AVG((`math score` + `reading score` + `writing score`)/3), 2) AS avg_overall_score
 FROM SP
 GROUP BY `test preparation course`;
 
 -- Unsurprisingly, students who completed the test preparation course performed better, with an average score of 72.67 compared to 65.04 for those who did not prepare.
 -- Is it link to the other category, maybe the culture, the way of living of 
 
 -- 7. who has the best results in maths, reading, writing 
 
 SELECT *
FROM SP
ORDER BY (`math score` + `reading score` + `writing score`) DESC
LIMIT 10;

-- This confirms that the group E has the best scores... 

-- Analysis of student with the lowest score 

SELECT *
FROM SP
WHERE `math score` < 50 OR `reading score` < 50 OR `writing score` < 50
ORDER BY (`math score` + `reading score` + `writing score`) ASC
LIMIT 10;

-- the number of student that havent completed their test prepartion course

SELECT 
COUNT(*) AS nb_students_no_prep
FROM SP
WHERE `test preparation course` = "none";
-- 642 is the number of students that have not completed their courses 

SELECT 
COUNT(*) AS nb_students_no_prep
FROM SP
WHERE `test preparation course` = "completed";
-- 358 is the number of student that have completed their courses 


-- How many of them has more than 60 in all the categories 
SELECT 
COUNT(*) AS nb_students_no_prep
FROM SP
WHERE `test preparation course` = "none"
	AND `math score` > 60
    AND `reading score`> 60
    AND `writing score`> 60;
   -- 330 students succeded to have more than 60 in all the categories => More than half of them; so the idea received that if they don't complete their preparation course they will not succeed is not "entirely" true.
   
   -- 8. let's dive into this and have a clear understanding of the parent's level of education, lunch type, races, to understand why these students succeeded and have a clear understanding of the failure factor 
   
   
    SELECT 
  `parental level of education`,
  `lunch`,
  COUNT(*) AS nb_students
FROM SP
WHERE 
  `test preparation course` = 'none'
  AND `math score` > 60
  AND `reading score` > 60
  AND `writing score` > 60
GROUP BY 
  `parental level of education`, 
  `lunch`, 
  `race/ethnicity`
ORDER BY nb_students DESC;
-- it gives us an idea but there is too many rows, it is harder to understand
-- I will analyse it one by one


 SELECT 
  `parental level of education`,
  COUNT(*) AS nb_students
FROM SP
WHERE 
  `test preparation course` = 'none'
  AND `math score` > 60
  AND `reading score` > 60
  AND `writing score` > 60
GROUP BY 
  `parental level of education`
ORDER BY nb_students DESC;

-- majority of those that succeed their exam have parents that went above high school
-- students performance seems to be linked to the level of education that the parents have. It is an indicator of succes and high performance.
-- I chose a score threshold of 60 because it generally represents a satisfactory or passing performance.
-- The goal is to focus on students who perform well in order to better understand the factors that contribute to their success—such as gender, ethnicity, parental education, lunch type (as a proxy for socioeconomic status), or test preparation.
-- This threshold helps distinguish between high and low performers and identify meaningful patterns.

SELECT 
  `lunch`,
  COUNT(*) AS nb_students
FROM SP
WHERE 
  `lunch`  = "free/reduced"
  AND `math score` > 60
  AND `reading score` > 60
  AND `writing score` > 60
GROUP BY 
  `lunch`
ORDER BY nb_students DESC;
-- only 146 students achieved a score over 60 in the 3 categories on 1000 students. 

SELECT 
  `lunch`,
  COUNT(*) AS nb_students
FROM SP
WHERE 
  `lunch`  = "free/reduced"
  AND `math score` < 60
  AND `reading score` < 60
  AND `writing score` < 60
GROUP BY 
  `lunch`
ORDER BY nb_students DESC;
-- 108 of the students had a score lower than 60 in all 3 categories 

SELECT *,
    ROUND((`math score` + `reading score` + `writing score`) / 3, 2) AS average_score
FROM SP
ORDER BY average_score ASC;

-- The weakest students have free ou reduced lunch, the family has a big impact on the student's performance


--  Does a good score in maths means a good score in every categories ?

SELECT *,
    ROUND((`math score` ), 2) AS average_score
FROM SP
ORDER BY average_score DESC;


SELECT 
COUNT(*) AS total_good_in_all
FROM SP
WHERE  `math score` > 60
    AND `reading score`> 60
    AND `writing score`> 60;
    
    SELECT 
    COUNT(*) AS total_good_in_math
FROM SP
WHERE `math score` > 60;

-- Proportion d'élèves bons en maths qui sont aussi bons partout
-- = total_good_in_all / total_good_in_math = 579/661 = 0.87= 87 %



SELECT * 
FROM SP; 
















