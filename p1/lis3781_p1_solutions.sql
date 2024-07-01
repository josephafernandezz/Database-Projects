
/* 1. Create a view that displays attorneys’ *full* names, *full* addresses, ages, hourly rates, the bar
    names that they’ve passed, as well as their specialties, sort by attorneys’ last names. */

drop VIEW if exists v_attorney_info;
CREATE VIEW v_attorney_info AS

    select 
    concat(per_lname,",", per_fname) as name,
    concat(per_street ",", per_city, ",", per_state, "", per_zip) as address
    TIMESTAMPDIFF(year,per_dob,now()) as age,
    CONCAT('$', FORMAT(aty_hourly_rate, 2)) as hourly_rate, 
    bar_name, spc_type
    from person
      natural join attorney
      natural join bar
      natural join specialty
      order by per_lname;

--might need to take out/add quote next to as on line 21
select 'display view v_attorney_info' as; 

select * from v_attorney_info;
drop VIEW if exists v_attorney_info;
do sleep(5);

/* 2. Create a stored procedure that displays how many judges were born in each month of the year,
sorted by month. */

select per_id, per_fname, per_lname, per_dob, monthname(per_dob) from person;
do sleep(5);

select p.per_id, per_fname, per_lname, per_dob, per_type 
from person as p 
  natural join judge as j;
do sleep(5);

drop procedure if exists sp_num_judges_born_by_month;
DELIMITER //
CREATE PROCEDURE sp_num_judges_born_by_month
BEGIN
    select month(per_dob) as month, monthname(per_dob) as month_name, count(*) as count
    from person
    natural join judge
    group by month_name
    order by month;
END //
DELIMITER ;
--might need to add qute next to as
select 'calling sp_num_judges_born_by_month()' as;

CALL sp_num_judges_born_by_month();
do sleep(5);

drop procedure if exists sp_num_judges_born_by_month;
do sleep(5);

/* 3. Create a stored procedure that displays *all* case types and descriptions, as well as judges’ *full*
names, *full* addresses, phone numbers, years in practice, for cases that they presided over, with
their start and end dates, sort by judges’ last names. */

drop procedure if exists sp_cases_and_judges;
DELIMITER //
CREATE PROCEDURE sp_cases_and_judges()
BEGIN

select per_id, cse_id, cse_type, cse_description,
    concat(per_fname, "", per_lname) as name,
    concat ('(',substring(phn_num, 1, 3), ')', substring(phn_num, 4, 3), '-', substring(phn_num, 7, 4)) as judge_office_num,
    phn_type,
    jud_years_in_practice,
    cse_start_date,
    cse_end_date
from person
    natural join judge
    natural join `case`
    natural join phone
  where per_type='j'
  order by per_lname;

END //
DELIMITER;

/* 4. Create a trigger that automatically adds a record to the judge history table for every record added
to the judge table */
-- might need to add quote after as
SELECT 'show person data *before* adding person record' as;
select per_id, per_fname, per_lname from person;
do sleep(5);

INSERT INTO person 
()
values 
();

select 'show person data *after* adding person record' as;
select per_id, per_fname, per_lname from person;
do sleep(5);

select 'show judge/judge_hist date *before* AFTER INSERT trigger fires (trg_judge_history_after_insert)' as;
select * from judge;
select * from judge_hist;
do sleep(7);

DROP TRIGGER IF EXSISTS trg_judge_history_after_insert;

DELIMITER //
CREATE TRIGGER trg_judge_history_after_insert
AFTER INSERT ON judge
FOR EACH ROW
BEGIN  
    INSERT INTO judge_hist
    ()
    VALUES 
    (
        NEW.per_id, NEW.crt_id, current_timestamp(), 'i', NEW.jud_salary,
        concat("modifying user:", user(), "Notes:", NEW.jud_notes)
    );
    END //
    DELIMITER

SELECT 'fire trigger by inserting record into judge table' as;
do sleep(5);

INSERT INTO judge
()
values
((select count(per_id) from person), );

/* 5. Create a trigger that automatically adds a record to the judge history table for every record modified in the judge table */
select 'show judge/judge_hist data *before* AFTER UPDATE trigger fires (trg_judge_history_after_update)' as;
select * from judge;
select * from judge_hist;
do sleep(7);

DROP TRIGGER IF EXISTS trg_judge_history_after_update;
DELIMITER //
CREATE TRIGGER trg_judge_history_after_update
AFTER UPDATE ON JUDGE
FOR EACH ROW 
BEGIN 
    INSERT INTO judge_hist
    ()
    VALUES
    (
        NEW.per_id, NEW.crt_id, current_timestamp(), 'u', NEW.jud_salary,
        concat("modifying user:", user(), "notes:", NEW.jud_notes)
    );

    END //
    DELIMITER;

select 'fire trigger by updating latest judge entry (salary and notes)' as;
do sleep(5);

UPDATE judge
SET jud_salary=190000, jud_notes='senior justice - longest serving member'
WHERE per_id=16;

select 'show judge/judge_hist data *after* AFTER UPDATE trigger fires (trg_judge_history_after_update)' as;
select * from judge;
select * from judge_hist;
do sleep(7);

DROP TRIGGER IF EXISTS trg_judge_history_after_update;

/* 6. Create a one-time event that executes one hour following its creation, the event should add a
judge record (one more than the required five records), have the event call a stored procedure that
adds the record (name it one_time_add_judge) */

drop procedure if exists sp_add_judge_record;
DELIMITER //

CREATE PROCEDURE sp_add_judge_record()
BEGIN   
    INSERT INTO judge
    ()
    values
    ()
END //

DELIMITER;

select '1) check event_scheduler' as;
SHOW VARIABLES LIKE 'event_scheduler';
do sleep(5);

select '2) if not, turn it on...' as ;

select '3) recheck event_scheduler' as ;

select 'Demo: use stored proc to add judge record after 5 seconds. Note: insert will also fire trigger for judge history' as ;

select 'show judge/judge_hist data *before* event fires *(one_time_add_judge)' as ;
select * from judge;
select * from judge_hist;
do sleep(7);

DROP EVENT IF EXISTS one_time_add_judge;
DELIMITER //
CREATE EVENT IF NOT EXISTS one_time_add_judge
ON SCHEDULE 
    AT NOW() + INTERVAL 5 second
    COMMENT 'adds a judge record only one-time'
DO
BEGIN
    CALL sp_add_judge_record();
END //

DELIMITER;







