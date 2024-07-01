drop database if exists jaf19g;
create database if not exists jaf19g;
use jaf19g;

DROP TABLE IF EXISTS company;
CREATE TABLE IF NOT EXISTS company
(
    cmp_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    cmp_type enum('C-Corp', 'S-Corp', 'Non-Profit', 'LLC', 'Partnership'),
    cmp_street VARCHAR(30) NOT NULL,
    cmp_city VARCHAR(30) NOT NULL,
    cmp_state CHAR(2) NOT NULL,
    cmp_zip CHAR(9) NOT NULL COMMENT 'no dashes',
    cmp_phone BIGINT UNSIGNED NOT NULL COMMENT 'ssn and zip codes can be zero-filled, but not US area codes',
    cmp_ytd_sales DECIMAL(10,2) NOT NULL COMMENT '12,345,678.90',
    cmp_email VARCHAR(100) NULL,
    cmp_url VARCHAR(100) NULL,
    cmp_notes VARCHAR(255) NULL,
    PRIMARY KEY (cmp_id)
)
ENGINE = InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;

SHOW WARNINGS;

INSERT INTO company
VALUES
(null,'C-Corp', '8427 Spohn Drive', 'Miami', 'FL', 987317443, 4819595110, 98420250.21, 'lwhite1@goodreads.com', 'https://diigo.com', 'Cras mi pede, malesuada in, imperdiet et.'),
(null,'LLC', '015 Old Shore Drive', 'Orlando', 'FL', 885101737, 2087956702, 39945039.89, null, null, null),
(null,'C-Corp', '80446 3rd Hill', 'Austin', 'TX', 216621902, 4167463571, 81790939.92, null, null, null),
(null,'Partnership', '59574 Farmco Drive', 'Los Angeles', 'CA', 180921869, 7403756961, 82298121.97, null, null, null),
(null,'C-Corp', '7662 Crowley Junction', 'Boston', 'MA', 919185115, 1222752352, 24861569.89, null, null, null);

SHOW WARNINGS;

DROP TABLE IF EXISTS customer;
CREATE TABLE IF NOT EXISTS customer
(
    cus_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    cmp_id INT UNSIGNED NOT NULL,
    cus_ssn BINARY(64) NOT NULL,
    cus_pass BINARY(64) NOT NULL COMMENT 'only demo purposes - do not use salt in the name',
    cus_type ENUM('Loyal','Discount','Impulse','Need-Based','Wandering'),
    cus_first VARCHAR(15) NOT NULL,
    cus_last VARCHAR(30) NOT NULL,
    cus_street VARCHAR(30) NULL,
    cus_city VARCHAR(30) NULL,
    cus_state CHAR(2) NULL,
    cus_zip CHAR(9) NULL,
    cus_phone BIGINT UNSIGNED NOT NULL,
    cus_email VARCHAR(100) NULL,
    cus_balance DECIMAL(7,2) NULL,
    cus_tot_sales DECIMAL(7,2) NULL,
    cus_notes VARCHAR(255) NULL,
    PRIMARY KEY (cus_id),

    UNIQUE INDEX ux_cus_ssn (cus_ssn ASC),
    INDEX idx_cmp_id (cmp_id ASC),

    CONSTRAINT fk_customer_company
        FOREIGN KEY (cmp_id)
        REFERENCES company(cmp_id)
        ON DELETE NO ACTION
        ON UPDATE CASCADE
)

ENGINE = InnoDB CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;

SHOW WARNINGS;

set @salt=RANDOM_BYTES(64);

INSERT INTO customer
VALUES
(null,2,unhex(SHA2(CONCAT(@salt, 000456789),512)), @salt, 'Loyal', 'Donny', 'Gerault', '3303 Walton Circle', 'San Antonio', 'TX', 409874708, 4354035009, 'dgerault4@jugem.jp', 97363.09, 81976.42, 'Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.'),
(null,4,unhex(SHA2(CONCAT(@salt, 001456789),512)), @salt, 'Wandering', 'Trumann', 'Reiling', '5 Londonderry Place', 'San Francisco', 'CA', 682989103, 8536016460, 'treiling0@mapy.cz', 15701.59, 35696.16, 'Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus.'),
(null,1,unhex(SHA2(CONCAT(@salt, 002456789),512)), @salt, 'Impulse', 'Dagmar', 'Cheatle', '242 Mockingbird Pass', 'Cleveland', 'OH', 672403037, 1275406232, 'dcheatle1@intel.com', 12322.48, 11969.9, 'Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim.'),
(null,3,unhex(SHA2(CONCAT(@salt, 003456789),512)), @salt, 'Wandering', 'Padget', 'Bazek', '23011 Alpine Hill', 'Atlanta', 'GA', 646750253, 1794841921, 'pbazek2@google.com.au', 46264.35, 13039.22, 'Morbi ut odio.'),
(null,1,unhex(SHA2(CONCAT(@salt, 004456789),512)), @salt, 'Need-Based', 'Glenn', 'Dimelow', '25773 John Wall Place', 'Miami', 'FL', 708595893, 4275356552, 'gdimelow3@nyu.edu', 46503.44, 38393.6, 'Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat.');

SHOW WARNINGS;

select * from customer;
select * from company;

--create user 1 and grant privileges
CREATE USER IF NOT EXISTS 'user1'@'localhost' IDENTIFIED BY 'test1';
GRANT select, update, delete on jaf19g.company to 'user1'@'localhost';
GRANT select, update, delete on jaf19g.customer to 'user1'@'localhost';
FLUSH PRIVILEGES;

--create user 2 and grant privileges
CREATE USER IF NOT EXISTS 'user2'@'localhost' IDENTIFIED BY 'test2';
GRANT select, insert on jaf19g.customer to 'user2'@'localhost';
FLUSH PRIVILEGES;

--INSERT statements for user1
INSERT INTO company
VALUES
(null,'C-Corp', '3000 SW 87th Ave', 'Miami', 'Fl', 331335757, 1234567890, 24861569.89, null, null, null);


INSERT INTO customer
VALUES
(null,3,unhex(SHA2(CONCAT(@salt, 005456789),512)), @salt, 'Need-Based', 'Pat', 'De Torres', '25773 John Wall Place', 'Miami', 'FL', 708595893, 4275356552, 'gdimelow3@nyu.edu', 46503.44, 38393.6, 'Integer tincidunt ante vel ipsum.');


--Statements for user2
use jaf19g;
select * from company;

DELETE FROM company WHERE cmp_id=1;

--admin delete statements
DROP TABLE company;
DROP TABLE customer;