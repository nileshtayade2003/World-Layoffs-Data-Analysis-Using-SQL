-- data cleaning

select * 
from layoffs;

-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Null Values or Blank Values
-- 4. Remove any Columns or rows


-- creating the separate table for performing operation in case any issue happen our raw data should be maintained
create table layoffs_staging
like layoffs;

select * 
from layoffs_staging;

insert into layoffs_staging
select * from layoffs;




######################## 1. removing duplicates

with duplicate_cte as
(
	select * ,
	row_number() over(partition by company ,location,industry, total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num
	from layoffs_staging
)
select * from duplicate_cte where row_num>1
;

select * from layoffs_staging where company = 'cazoo'; -- cross verifying duplicasy


with duplicate_cte as
(
	select * ,
	row_number() over(partition by company ,location,industry, total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num
	from layoffs_staging
)
delete from duplicate_cte where row_num>1
;

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select * 
from layoffs_staging2;

insert into layoffs_staging2
select * ,
row_number() over(partition by company ,location,industry, total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num
from layoffs_staging;
    

select * from layoffs_staging2 where row_num > 1;
delete from layoffs_staging2 where row_num > 1;
select * from layoffs_staging2;


#################################### 2. Standardizing Data
select * from layoffs_staging2;

select company , trim(company)
from layoffs_staging2;

update layoffs_staging2
set company = trim(company);

select distinct industry
from layoffs_staging2
order by 1;

select * from layoffs_staging2
where industry like 'crypto%';

update layoffs_staging2
set industry = 'Crypto'
where industry = 'CryptoCurrency' or industry = 'Crypto Currency'; -- or where industry like 'Crypto%'

select distinct location
from layoffs_staging2
order by 1; -- not an issue with location

select distinct country
from layoffs_staging2
order by 1; -- issue with united states have . at the end

-- update layoffs_staging2
-- set country = 'United States'
-- where country like 'United States%';

-- or 
select distinct country , trim(trailing '.' from country)
from layoffs_staging2
order by 1;

update layoffs_staging2 
set country = trim(trailing '.' from country)
where country like 'United States%';

-- changing data type text to date and also formatting it 
select `date`
from layoffs_staging2;   

select `date`,
str_to_date(`date`,'%m/%d/%Y')  
from layoffs_staging2;   

update layoffs_staging2
set `date` = str_to_date(`date`,'%m/%d/%Y');

select `date`
from layoffs_staging2;

alter table layoffs_staging2
modify column `date` date;                          

select * from layoffs_staging2;

######################### 3. Null Values or Blank Values
select *
from layoffs_staging2
where total_laid_off is null
 and percentage_laid_off is null;
 
-- populating null or blank values with related values
select *
from layoffs_staging2
where industry is null
or industry = '';

select * 
from layoffs_staging2
where company = 'Airbnb';

select t1.industry , t2.industry
from layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
where (t1.industry is null or t1.industry = '') 
and t2.industry is not null;

update layoffs_staging2
set industry = null
where industry = '';

update layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
set t1.industry = t2.industry
where (t1.industry is null) 
and t2.industry is not null;

select * from layoffs_staging2;

######################## 4. Remove any Columns or rows that not needed

select *
from layoffs_staging2
where total_laid_off is null
 and percentage_laid_off is null;
 
delete 
from layoffs_staging2
where total_laid_off is null
 and percentage_laid_off is null;
 
 
 select *
 from layoffs_staging2;
 
 -- droping row_num columns not needed
 alter table layoffs_staging2
 drop column row_num;