-- Data Cleaning

-- 1. Remove Duplicates        
-- 2. Standardize The (الحروف Spelling لوفي اي مشاكل في)
-- 3. Null Values Or Blank Values
-- 4. Remove Any Columns That Are Unnecessary

CREATE TABLE layoffs_demo
LIKE layoffs;

SELECT *
FROM layoffs_demo;

INSERT layoffs_demo
SELECT *
FROM layoffs;

select *
from layoffs_demo;

select * ,
row_number() over(partition by company ,  location , industry , total_laid_off , percentage_laid_off , `date` , stage , country , funds_raised_millions) AS row_num
FROM layoffs_demo;

-- Using Temporary Table To Visualize The Data

with duplicate_cte AS (
select * ,
row_number() over(
partition by company ,  location , industry , total_laid_off , percentage_laid_off , `date` , stage , country , funds_raised_millions) AS row_num
FROM layoffs_demo
)



-- Reviewing The Duplicates

select *
from duplicate_cte
WHERE row_num >1;


-- Creating Another Table And Add A row_num Column To Use it Removing Duplicates

CREATE TABLE `layoffs_demo2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- inserting the data in the table

INSERT into layoffs_demo2
select * ,
row_number() over(partition by company , location , industry , total_laid_off , percentage_laid_off , `date` , stage , country , funds_raised_millions ) AS row_num
FROM layoffs_demo;

select*
from layoffs_demo2
where row_num > 2;

-- Deleting Duplicates

DELETE
from layoffs_demo2
WHERE row_num >2;

-- Removing Duplicates Done :)

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- 2. Standardizing The Data -----> It's that finding issues in the data and just fixing it

SELECT *
FROM  layoffs_demo2;

-- هتلاقي في مسافة في اول صفين و ده ممكن يعملنا مشكلة قدام فلازم نخلي كل البيانات ماشية بنفس الرتم

select company , trim(company)
from layoffs_demo2;

update layoffs_demo2
set company = trim(company);

select distinct * 
from layoffs_demo2
where industry LIKE 'Crypto%';

update layoffs_demo2
set industry = 'Crypto'
where industry like 'Crypto%';

select *
from layoffs_demo2
where country LIKE 'United States';

update layoffs_demo2
set country = trim(trailing '.' from country)  -- Removing the dot in the last
where country LIKE 'United Stat%';

select `date`,
str_to_date(`date` , '%m/%d/%Y') as `date`
from layoffs_demo2;

update layoffs_demo2
set `date` = str_to_date(`date` , '%m/%d/%Y');

select *
from layoffs_demo2;

alter table layoffs_demo2
modify column `date` date;

-- Standardizing The Date Done :)

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- 3. Null Values Or Blank Values

select * 
from layoffs_demo2
where total_laid_off is null
and percentage_laid_off is null;

select *
from layoffs_demo2
where industry is null
or industry = '';

select *
from layoffs_demo2
where company LIKE 'bally%';

update layoffs_demo2
set industry = null
where industry = '';

select * 
from layoffs_demo2 t1
join layoffs_demo2 t2
on t1.company = t2.company
where (t1.industry is null or t1.industry = '')
and t2.industry is not null;

update layoffs_demo2 t1
join layoffs_demo2 t2
on t1.company = t2.company
set t1.industry = t2.industry
where t1.industry is null
and t2.industry is not null;

select *
from layoffs_demo2
where company = 'Airbnb';

select *
from layoffs_demo2
where total_laid_off is null
and percentage_laid_off is null;

-- Null Values Or Blank Values Done :) 

-- -- -- -- -- -- -- -- -- --- -- --- -- -- --- -- -- --- -- -- --- -- -- -- -- -- -- -- -- -- -- -- --

-- 4. Deleting Unnecessary Columns

alter Table layoffs_demo2
drop column row_num;

select *
from layoffs_demo2
where total_laid_off is null
AND percentage_laid_off is null;

DELETE
from layoffs_demo2
where total_laid_off is null
AND percentage_laid_off is null;


-- Deleting Unnecessary Columns Done :)

select *
from layoffs_demo2;

select max(total_laid_off) , max(percentage_laid_off)
from layoffs_demo2;

select company , sum(total_laid_off)
from layoffs_demo2
group by company
order by 2 desc;
