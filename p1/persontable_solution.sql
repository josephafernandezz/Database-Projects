START TRANSACTION;

INSERT INTO person
(per_id, per_ssn, per_salt, per_fname, per_lname, per_street, per_city, per_state, per_zip, per_email, per_dob, per_type, per_notes)
VALUES
(null, null, null, 'Jacklin', 'Cavolini', '7259 Hansons Road', 'Montgomery', 'AL', 760318963, 'jcavolini0@people.com.cn', '1972-09-18', 'j', null),
(null, null, null, 'Livvyy', 'Pautot', '872 Coolidge Trail', 'Memphis', 'TN', 921039037, 'lpautot1@jimdo.com', '1950-09-12', 'j', null),
(null, null, null, 'Frederique', 'Francais', '75042 Continental Circle', 'Boston', 'MA', 633481375, 'ffrancais2@bloglovin.com', '1985-12-21', 'a', null),
(null, null, null, 'Sherri', 'Daykin', '61 Green Ridge Road', 'Baltimore', 'MD', 760024668, 'sdaykin3@1und1.de', '1979-09-23', 'c', null),
(null, null, null, 'Hi', 'Lincke', '1179 Transport Trail', 'Brooksville', 'FL', 264657472, 'hlincke4@opera.com', '1985-12-14', 'j', null),
(null, null, null, 'Lexine', 'Rue', '5450 Marcy Center', 'Reading', 'PA', 528320137, 'lrue0@reverbnation.com', '1956-07-10', 'j', null),
(null, null, null, 'Joane', 'Loynes', '0148 Westend Terrace', 'Terre Haute', 'IN', 515451489, 'jloynes1@wired.com', '1973-07-03', 'c', null),
(null, null, null, 'Valene', 'Archbould', '78 Trailsway Pass', 'Washington', 'DC', 720624538, 'varchbould2@sitemeter.com', '1963-07-15', 'a', 'Vestibulum quam sapien, varius ut, blandit non, interdum in, ante.'),
(null, null, null, 'Chad', 'Schulter', '851 Longview Park', 'Washington', 'DC', 652373932, 'cschulter3@netvibes.com', '1957-05-29', 'j', null),
(null, null, null, 'Oralie', 'Caizley', '30 Sundown Trail', 'Jamaica', 'NY', 238278894, 'ocaizley4@home.pl', '1989-12-08', 'j', 'Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo.'),
(null, null, null, 'Beauregard', 'Salvage', '81 Brickson Park Plaza', 'Waco', 'TX', 647911551, 'bsalvage5@angelfire.com', '1977-04-12', 'a', null),
(null, null, null, 'Grazia', 'Dilkes', '10821 Little Fleur Drive', 'Las Vegas', 'NV', 591452069, 'gdilkes6@guardian.co.uk', '1954-07-26', 'j', 'Curabitur in libero ut massa volutpat convallis.');
(null, null, null, 'Cahra', 'Fend', '30 Jenifer Plaza', 'Miami', 'FL', 838649328, 'cfend7@friendfeed.com', '1984-12-15', 'j', null),
(null, null, null, 'Ray', 'Heeks', '6 Farmco Drive', 'Bakersfield', 'CA', 447688661, 'rheeks8@sbwire.com', '1980-03-07', 'a', null),
(null, null, null, 'Nick', 'Pinnock', '670 Pleasure Circle', 'Wichita', 'KS', 801440883, 'npinnock9@springer.com', '1961-07-31', 'j', null);
COMMIT;

DROP PROCEDURE IF EXISTS CreatePersonSSN;
DELIMITER $$
CREATE PROCEDURE CreatePersonSSN()
BEGIN
DECLARE x, y INT;
SET x = 1;

select count(*) into y from person;

WHILE x <= y DO 

    SET @salt=RANDOM_BYTES(64);
    SET @ran_num=FLOOR(RAND()* (999999999-111111111+1)) + 111111111;
    SET @ssn=unhex(sha2(concat(@salt,@ran_num), 512));

    UPDATE person
    set per_ssn=@ssn, per_salt=@salt
    where per_id=x;

    SET x = x + 1;

    END WHILE;

END$$
DELIMITER;
call CreatePersonSSN();