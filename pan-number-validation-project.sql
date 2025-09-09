
-- PAN Number Validation Project using SQL --


-- Create table to hold the pan number dataset
create table stg_pan_numbers_dataset (
	pan_number text
);

-- Query the data
select * from stg_pan_numbers_dataset;

-- Import the data by clicking import and upload the data into table

-- Query the data again
select * from stg_pan_numbers_dataset;


-- Data Cleaning and Preprocessing -- 


-- Identify and handle missing data:
select * from stg_pan_numbers_dataset
where pan_number is null;


-- Check for duplicates
select pan_number, count(1)
from stg_pan_numbers_dataset
group by pan_number
having count(1) > 1;


-- Handle leading/trailing spaces
select * from stg_pan_numbers_dataset
where pan_number <> trim(pan_number);


-- Correct letter case
select * from stg_pan_numbers_dataset
where pan_number <> upper(pan_number);


-- Cleaned PAN Numbers
select distinct upper(trim(pan_number)) as pan_number
from stg_pan_numbers_dataset
where pan_number is not null
and trim(pan_number) <> '';


-- PAN Format Validation --

-- Function to check if adjacent characters are the same -- "WUFAR0132H" => 'WUFAR' (we will send first 5 chars)
create or replace function fn_to_check_adjacent_chars(p_str	text)
returns boolean
language plpgsql
as $$
begin
	for i in 1 .. (length(p_str) - 1)
	loop
		-- (str, starting_index, take_one_str at a time)
		if substring(p_str, i, 1) = substring(p_str, i+1, 1)
		then
			return true;  -- the characters are adjacent;
		end if;
	end loop;
	return false; -- none of the character adjacent to each other ware the same 
end;
$$

-- Now check the function is actually working on test data or not
-- false case
select fn_to_check_adjacent_chars('WUFAR');

-- true case
select fn_to_check_adjacent_chars('WUAAR');


-- Function to check if sequencial characters are exists is not like 'ABCDE'
create or replace function fn_check_sequencial_chars(p_str text)
returns boolean
language plpgsql
as $$
begin
	for i in 1 .. (length(p_str) - 1)
	loop
		if ascii(substring(p_str, i+1, 1)) - ascii(substring(p_str, i, 1)) <> 1
		then
			return false; -- string does not form a sequence
		end if;
	end loop;
	return true; -- string is forming a sequence
end;
$$

select ascii('B');

-- Now check if the function is working or not
select fn_check_sequencial_chars('AXDGE');

select fn_check_sequencial_chars('ABCDE');


-- Regular expression to validate the pattern or structure of PAN Numbers -- AAAAA1234A
select *
from stg_pan_numbers_dataset
where pan_number ~ '^[A-Z]{5}[0-9]{4}[A-Z]$' -- doller will make sure that it will match with last character


-- Valid and Invalid PAN categorisation

create or replace view vw_valid_invalid_pans
as
with cte_cleaned_pan as (
	select distinct upper(trim(pan_number)) as pan_number
	from stg_pan_numbers_dataset
	where pan_number is not null
	and trim(pan_number) <> ''
),
cte_valid_pans as (
	select * from cte_cleaned_pan
	where fn_to_check_adjacent_chars(pan_number) = false
	and fn_check_sequencial_chars(substring(pan_number, 1, 5)) = false
	and fn_check_sequencial_chars(substring(pan_number, 6, 4)) = false
	and pan_number ~ '^[A-Z]{5}[0-9]{4}[A-Z]$'
)
select 
	-- as we will display the total pans
	cln.pan_number,
	case
		when vld.pan_number is not null then 'Valid PAN'
		else 'Invalid PAN'
	end as status
from cte_cleaned_pan cln
left join cte_valid_pans vld
-- on vld.pan_number = cln.pan_number;
on cln.pan_number = vld.pan_number;

-- "DNRGI2432Q" -  is valid
-- "WOUCP7730E" - is invalid - why so? 7 7 adjacent numbers.

select * from vw_valid_invalid_pans;

-- Summary Report
stg_pan_numbers_dataset
vw_valid_invalid_pans

with cte as (
	select
		(select count(*) from stg_pan_numbers_dataset) as total_processed_records,
		count(*) filter (where status = 'Valid PAN') as total_valid_pans,
		count(*) filter (where status = 'Invalid PAN') as total_invalid_pans
	from vw_valid_invalid_pans
)
select
	total_processed_records,
	total_valid_pans,
	total_invalid_pans,
	-- missing pans are those pans which are not the part of cleaned pans (that means pans which is removed while filtering the data to produce cleaned data)
	(total_processed_records - (total_valid_pans + total_invalid_pans)) as total_missing_pans
from cte;



