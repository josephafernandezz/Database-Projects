SET ANSI_WARNINGS ON;
GO

use master;
GO

IF EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name = N'jaf19g')
DROP DATABASE jaf19g;
GO

IF NOT EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name = N'jaf19g')
CREATE DATABASE jaf19g;
GO

use jaf19g;
GO

IF OBJECT_ID (N'dbo.person', N'U') IS NOT NULL
DROP TABLE dbo.person;
GO

CREATE TABLE dbo.person
(
 per_id SMALLINT not null identity(1,1),
 per_ssn binary(64) NULL,
 per_fname VARCHAR(15) NOT NULL,
 per_lname VARCHAR(30) NOT NULL,
 per_gender CHAR(1) NOT NULL CHECK (per_gender IN('m','f')),
 per_dob DATE NOT NULL,
 per_street VARCHAR(30) NOT NULL,
 per_city VARCHAR(30) NOT NULL,
 per_state CHAR(2) NOT NULL DEFAULT 'FL',
 per_zip int NOT NULL check (per_zip like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
 per_email VARCHAR(100) NULL,
 per_type CHAR(1) NOT NULL CHECK (per_type IN('c','s')),
 per_notes VARCHAR(45) NULL,
 PRIMARY KEY (per_id),

 CONSTRAINT ux_per_ssn unique nonclustered (per_ssn ASC)
);
GO

IF OBJECT_ID (N'dbo.phone', N'U') IS NOT NULL
DROP TABLE dbo.phone;
GO

CREATE TABLE dbo.phone
(
 phn_id SMALLINT NOT NULL identity (1,1),
 per_id SMALLINT NOT NULL,
 phn_num bigint NOT NULL check (phn_num like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
 phn_type char(1) NOT NULL CHECK (phn_type IN ('h','c','w','f')),
 phn_notes VARCHAR(255) NULL,
 PRIMARY KEY (phn_id),

 CONSTRAINT FK_phone_person
  FOREIGN KEY (per_id)
  REFERENCES dbo.person(per_id)
  ON DELETE CASCADE
  ON UPDATE CASCADE
);
GO

IF OBJECT_ID (N'dbo.customer', N'U') IS NOT NULL
DROP TABLE dbo.customer;
GO

CREATE TABLE dbo.customer
(
 per_id SMALLINT not null,
 cus_balance decimal(7,2) NOT NULL check (cus_balance >=0),
 cus_total_sales decimal(7,2) NOT NULL check (cus_total_sales >0),
 cus_notes VARCHAR(45) NULL,
 PRIMARY KEY (per_id),

 CONSTRAINT fk_customer_person
  FOREIGN KEY (per_id)
  REFERENCES dbo.person (per_id)
  ON DELETE CASCADE
  ON UPDATE CASCADE
);
GO

IF OBJECT_ID (N'dbo.slsrep', N'U') IS NOT NULL
DROP TABLE dbo.slsrep;
GO

CREATE TABLE dbo.slsrep
(
 per_id SMALLINT not null,
 srp_yr_sales_goal decimal(8,2) NOT NULL check (srp_yr_sales_goal >= 0),
 srp_ytd_sales decimal(8,2) NOT NULL check (srp_ytd_sales >= 0),
 srp_ytd_comm decimal(7,2) NOT NuLL check (srp_ytd_comm >= 0),
 srp_notes VARCHAR(45) NULL,
 PRIMARY KEY (per_id),

 CONSTRAINT fk_slsrep_person
  FOREIGN KEY (per_id)
  REFERENCES dbo.person (per_id)
  ON DELETE CASCADE
  ON UPDATE CASCADE
);
GO

IF OBJECT_ID (N'dbo.srp_hist', N'U') IS NOT NULL
DROP TABLE dbo.srp_hist;
GO

CREATE TABLE dbo.srp_hist
(
 sht_id SMALLINT not null identity(1,1),
 per_id SMALLINT not null,
 sht_type char(1) not null CHECK (sht_type IN('i','u','d')),
 sht_modified datetime not null,
 sht_modifier varchar(45) not null default system_user,
 sht_date date not null default getDate(),
 sht_yr_sales_goal decimal(8,2) NOT NULL check (sht_yr_sales_goal >= 0),
 sht_ytd_sales decimal(8,2) NOT NULL check (sht_ytd_sales >= 0),
 sht_ytd_comm decimal(7,2) NOT NULL check (sht_ytd_comm >= 0),
 sht_notes VARCHAR(45) NULL,
 PRIMARY KEY (sht_id),

 CONSTRAINT fk_srp_hist_slsrep
   FOREIGN KEY (per_id)
   REFERENCES dbo.slsrep (per_id)
   ON DELETE CASCADE
   ON UPDATE CASCADE
);
GO

IF OBJECT_ID (N'dbo.contact', N'U') IS NOT NULL
DROP TABLE dbo.contact;
GO

CREATE TABLE dbo.contact 
(
 cnt_id int NOT NULL identity(1,1),
 per_cid smallint NOT NULL,
 per_sid smallint NOT NULL,
 cnt_date datetime NOT NULL,
 cnt_notes varchar(255) NULL,
 PRIMARY KEY (cnt_id),

 CONSTRAINT fk_contact_customer
  FOREIGN KEY (per_cid)
  REFERENCES dbo.customer (per_id)
  ON DELETE CASCADE
  ON UPDATE CASCADE,

 CONSTRAINT fk_contact_slsrep
  FOREIGN KEY (per_sid)
  REFERENCES dbo.slsrep (per_id)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION
);
GO

--Table [order]
-- must use delimiter [] for reserved words
IF OBJECT_ID (N'dbo.[order]', N'U') IS NOT NULL
DROP TABLE dbo.[order];

CREATE TABLE dbo.[order]
(
    ord_id int NOT NULL identity(1,1),
    cnt_id int NOT NULL,
    ord_placed_date DATETIME NOT NULL,
    ord_filled_date DATETIME NULL,
    ord_notes VARCHAR(255) NULL,
    PRIMARY KEY (ord_id),

    CONSTRAINT fk_order_contact 
    FOREIGN KEY (cnt_id)
    REFERENCES dbo.contact (cnt_id)
    ON DELETE CASCADE 
    ON UPDATE CASCADE
);
GO

-- region Table
IF OBJECT_ID (N'dbo.region', N'U') IS NOT NULL
DROP TABLE dbo.region;
GO

CREATE TABLE region
(
    reg_id TINYINT NOT NULL identity(1,1),
    reg_name CHAR(1) NOT NULL, 
    reg_notes VARCHAR(255) NULL,
    PRIMARY KEY(reg_id)
);
GO

-- State Table
IF OBJECT_ID (N'dbo.state', N'U') IS NOT NULL
DROP TABLE dbo.state;
GO

CREATE TABLE dbo.state
(
    ste_id TINYINT NOT NULL identity (1,1),
    reg_id TINYINT NOT NULL,
    ste_name CHAR(2) NOT NULL DEFAULT 'FL',
    ste_notes VARCHAR(255) NULL,
    PRIMARY KEY(ste_id),

    CONSTRAINT fk_state_region
    FOREIGN KEY (reg_id)
    REFERENCES dbo.region (reg_id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);
GO

-- City Table
IF OBJECT_ID (N'dbo.city', N'U') IS NOT NULL
DROP TABLE dbo.city;
GO

CREATE TABLE dbo.city
(
    cty_id SMALLINT NOT NULL identity(1,1),
    ste_id TINYINT NOT NULL,
    cty_name VARCHAR(30) NOT NULL,
    cty_notes VARCHAR(255) NULL,
    PRIMARY KEY (cty_id),

    CONSTRAINT fk_city_state
    FOREIGN KEY (ste_id)
    REFERENCES dbo.state (ste_id)
    ON DELETE CASCADE 
    ON UPDATE CASCADE 
);
GO

-- Store Table
IF OBJECT_ID (N'dbo.store', N'U') IS NOT NULL
DROP TABLE dbo.store;
GO

CREATE TABLE dbo.store
(
    str_id SMALLINT NOT NULL identity(1,1),
    cty_id SMALLINT NOT NULL,
    str_name VARCHAR(45) NOT NULL,
    str_street VARCHAR(30) NOT NULL,
    str_zip int NOT NULL check (str_zip like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    str_phone BIGINT NOT NULL check (str_phone like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    str_email VARCHAR(100) NOT NULL,
    str_url VARCHAR(100) NOT NULL,
    str_notes VARCHAR(255) NULL,
    PRIMARY KEY (str_id),

    CONSTRAINT fk_store_city
    FOREIGN KEY (cty_id)
    REFERENCES dbo.city (cty_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
GO

IF OBJECT_ID (N'dbo.invoice', N'U') IS NOT NULL
DROP TABLE dbo.invoice;
GO

CREATE TABLE dbo.invoice
(
 inv_id int NOT NULL identity(1,1),
 ord_id int NOT NULL,
 str_id SMALLINT NOT NULL,
 inv_date DATETIME NOT NULL,
 inv_total DECIMAL(8,2) NOT NULL check (inv_total >= 0),
 inv_paid bit NOT NULL,
 inv_notes VARCHAR(255) NULL,
 PRIMARY KEY (inv_id),

 CONSTRAINT fk_invoice_order
  FOREIGN KEY (ord_id)
  REFERENCES dbo.[order](ord_id)
  ON DELETE CASCADE
  ON UPDATE CASCADE,

  CONSTRAINT fk_invoice_store
   FOREIGN KEY (str_id)
   REFERENCES dbo.store (str_id)
   ON DELETE CASCADE
   ON UPDATE CASCADE
 );
GO

IF OBJECT_ID (N'dbo.payment', N'U') IS NOT NULL
DROP TABLE dbo.payment;
GO

CREATE TABLE dbo.payment
(
 pay_id int NOT NULL identity(1,1),
 inv_id int NOT NULL,
 pay_date DATETIME NOT NULL,
 pay_amt DECIMAL(7,2) NOT NULL check (pay_amt >= 0),
 pay_notes VARCHAR(255) NULL,
 PRIMARY KEY (pay_id),

 CONSTRAINT fk_payment_invoice
  FOREIGN KEY (inv_id)
  REFERENCES dbo.invoice (inv_id)
  ON DELETE CASCADE
  ON UPDATE CASCADE
);
GO

IF OBJECT_ID (N'dbo.vendor', N'U') IS NOT NULL
DROP TABLE dbo.vendor;
GO

CREATE TABLE dbo.vendor
(
 ven_id SMALLINT NOT NULL identity(1,1),
 ven_name VARCHAR(45) NOT NULL,
 ven_street VARCHAR(30) NOT NULL,
 ven_city VARCHAR(30) NOT NULL,
 ven_state CHAR(2) NOT NULL DEFAULT 'FL',
 ven_zip int NOT NULL check (ven_zip like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
 ven_phone bigint NOT NULL check (ven_phone like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
 ven_email VARCHAR(100) NULL,
 ven_url VARCHAR(100) NULL,
 ven_notes VARCHAR(255) NULL,
 PRIMARY KEY (ven_id)
);
GO

IF OBJECT_ID (N'dbo.product', N'U') IS NOT NULL
DROP TABLE dbo.product;
GO

CREATE TABLE dbo.product
(
 pro_id SMALLINT NOT NULL identity(1,1),
 ven_id SMALLINT NOT NULL,
 pro_name VARCHAR(30) NOT NULL,
 pro_descript VARCHAR(45) NULL,
 pro_weight FLOAT NOT NULL check (pro_weight >= 0),
 pro_qoh SMALLINT NOT NULL check (pro_qoh >= 0),
 pro_cost DECIMAL(7,2) NOT NULL check (pro_cost >= 0),
 pro_price DECIMAL(7,2) NOT NULL check (pro_price >= 0),
 pro_discount DECIMAL(3,0) NULL,
 pro_notes VARCHAR(255) NULL,
 PRIMARY KEY (pro_id),

 CONSTRAINT fk_product_vendor
  FOREIGN KEY (ven_id)
  REFERENCES dbo.vendor (ven_id)
  ON DELETE CASCADE
  ON UPDATE CASCADE
 );
GO

IF OBJECT_ID (N'dbo.product_hist', N'U') IS NOT NULL
DROP TABLE dbo.product_hist;
GO

CREATE TABLE dbo.product_hist 
(
 pht_id int NOT NULL identity (1,1),
 pro_id SMALLINT NOT NULL,
 pht_date DATETIME NOT NULL,
 pht_cost DECIMAL(7,2) NOT NULL check (pht_cost >= 0),
 pht_price DECIMAL(7,2) NOT NULL check (pht_price >= 0),
 pht_discount DECIMAL(3,0) NULL,
 pht_notes VARCHAR(255) NULL,
 PRIMARY KEY (pht_id),

 CONSTRAINT fk_product_hist_product
  FOREIGN KEY (pro_id)
  REFERENCES dbo.product (pro_id)
  ON DELETE CASCADE
  ON UPDATE CASCADE
);
GO

IF OBJECT_ID (N'dbo.order_line', N'U') IS NOT NULL
DROP TABLE dbo.order_line;
GO

CREATE TABLE dbo.order_line
(
 oln_id int NOT NULL identity(1,1),
 ord_id int NOT NULL,
 pro_id SMALLINT NOT NULL,
 oln_qty SMALLINT NOT NULL check (oln_qty >= 0),
 oln_price DECIMAL(7,2) NOT NULL check (oln_price >= 0),
 oln_notes VARCHAR(255) NULL,
 PRIMARY KEY (oln_id),

 CONSTRAINT fk_order_line_order
  FOREIGN KEY (ord_id)
  REFERENCES dbo.[order] (ord_id)
  ON DELETE CASCADE
  ON UPDATE CASCADE,

  CONSTRAINT fk_order_line_product
   FOREIGN KEY (pro_id)
   REFERENCES dbo.product(pro_id)
   ON DELETE CASCADE
   ON UPDATE CASCADE
);
GO

-- Time Table
IF OBJECT_ID (N'dbo.time', N'U') IS NOT NULL
DROP TABLE dbo.time;
GO

CREATE TABLE dbo.time
(
    tim_id INT NOT NULL identity(1,1),
    tim_yr SMALLINT NOT NULL, -- 2 byte integer
    tim_qtr TINYINT NOT NULL,
    tim_month TINYINT NOT NULL,
    tim_week TINYINT NOT NULL,
    tim_day TINYINT NOT NULL,
    tim_time TIME NOT NULL,
    tim_notes VARCHAR(255) NULL,
    PRIMARY KEY(tim_id)
);
GO

-- Table Sale
IF OBJECT_ID (N'dbo.sale', N'U') IS NOT NULL
DROP TABLE dbo.sale;
GO

CREATE TABLE dbo.sale
(
    pro_id SMALLINT NOT NULL,
    str_id SMALLINT NOT NULL,
    cnt_id INT NOT NULL,
    tim_id INT NOT NULL,
    sal_qty SMALLINT NOT NULL,
    sal_price DECIMAL(4,2) NOT NULL,
    sal_total DECIMAL(5,2) NOT NULL,
    sal_notes VARCHAR(255) NULL,
    PRIMARY KEY(pro_id, cnt_id, tim_id, str_id),

    -- make sure combination of time, contact, store, and product are unique
    CONSTRAINT ux_pro_id_str_id_cnt_id_tim_id
    unique nonclustered (pro_id ASC, str_id ASC, cnt_id ASC, tim_id ASC),

    CONSTRAINT fk_sale_time
        FOREIGN KEY (tim_id)
        REFERENCES dbo.time (tim_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_sale_contact
        FOREIGN KEY (cnt_id)
        REFERENCES dbo.contact (cnt_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_sale_store
        FOREIGN KEY (str_id)
        REFERENCES dbo.store (str_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_sale_product
        FOREIGN KEY (pro_id)
        REFERENCES dbo.product (pro_id)
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);
GO

SELECT * FROM information_schema.tables;

--------------------------------------------
--inserts
--------------------------------------------

INSERT INTO dbo.person
(per_ssn, per_fname, per_lname, per_gender, per_dob, per_street, per_city, per_state, per_zip, per_email, per_type, per_notes)
VALUES
(HASHBYTES('SHA2_512','test1'), 'Steve','Rogers', 'm', '1923-10-03', '437 Southern Drive', 'Rochester', 'NY', 324440222, 'srogers@comcast.net', 's', NULL),
(HASHBYTES('SHA2_512','test2'), 'Bruce','Wayne', 'm', '1968-03-20', '1007 Mountain Drive', 'Gotham', 'NY', 983208440, 'bwayne@knology.net', 's', NULL),
(HASHBYTES('SHA2_512','test3'), 'Peter','Parker', 'm', '1988-09-12', '20 Ingram Streeet', 'New York', 'NY', 102862341, 'pparker@msn.com', 's', NULL),
(HASHBYTES('SHA2_512','test4'), 'Jane','Thompson', 'f', '1978-05-08', '13563 Ocean View Drive', 'Seattle', 'WA', 132084409, 'jthompson@gmail.com', 's', NULL),
(HASHBYTES('SHA2_512','test5'), 'Debra','Steele', 'f', '1994-07-19', '543 Oak ln', 'Milwaukee', 'WI', 108765456, 'dsteele@verizon.net', 's', NULL),
(HASHBYTES('SHA2_512','test6'), 'Tony','Stark', 'm', '1972-05-04', '332 Palm Avenue', 'Malibu', 'CA', 902638332, 'tstark@yahoo.com', 'c', NULL),
(HASHBYTES('SHA2_512','test7'), 'Hank','Pymi', 'm', '1980-08-28', '2355 Brown Street', 'Cleveland', 'OH', 822348890, 'hpym@aol.com', 'c', NULL),
(HASHBYTES('SHA2_512','test8'), 'Bob','Best', 'm', '1992-02-10', '4902 Avendale Avenue', 'Scottsdale', 'AZ', 872638332, 'bbest@yahoo.com', 'c', NULL),
(HASHBYTES('SHA2_512','test9'), 'Sandra','Dole', 'f', '1990-01-26', '87912 Lawrence Ave', 'Atlanta', 'GA', 671238890, 'sdole@gmail.com', 's', NULL),
(HASHBYTES('SHA2_512','test10'), 'Ben','Avery', 'm', '1992-12-24', '6432 Thunderbird Ln', 'Sioux Falls', 'SD', 562638332, 'bavery@hotmail.com', 'c', NULL),
(HASHBYTES('SHA2_512','test11'), 'Arthur', 'Curry', 'm', '1975-12-15', '3304 Euclid Avenue', 'Miami', 'FL', 342219932 , 'acurry@gmail.com', 'c', NULL),
(HASHBYTES('SHA2_512','test12'), 'Diana', 'Price', 'f', '1980-08-22', '944 Green Street', 'Las Vegas', 'NV', 332048823, 'dprice@sympatico.com', 'c', NULL),
(HASHBYTES('SHA2_512','test13'), 'Adam', 'Jurris', 'm', '1995-01-31', '98435 Valencia Dr', 'Gulf Shores', 'AL', 870219932, 'ajurris@gmx.com', 'c', NULL),
(HASHBYTES('SHA2_512','test14'), 'Judy', 'Sleen', 'f', '1970-03-22', '56343 Rover Ct.', 'Billings', 'MT', 672048823, 'jsleen@sympatico.com', 'c', NULL),
(HASHBYTES('SHA2_512','test15'), 'Bill', 'Neiderheim', 'm', '1982-06-13', '43567 Netherland Blvd', 'South Bend', 'IN', 320219932, 'bneiderheim@comcast.net', 'c', NULL);
GO
select * from dbo.person;

INSERT INTO dbo.slsrep
(per_id, srp_yr_sales_goal, srp_ytd_sales, srp_ytd_comm, srp_notes)
VALUES
(1, 100000, 60000, 1800, NULL),
(2, 80000, 35000, 3500, NULL),
(3, 150000, 84000, 9650, 'Great Salesperson'),
(4, 125000, 87000, 15300, NULL),
(5, 98000, 43000, 8750, NULL);
GO
select * from dbo.slsrep;

INSERT INTO dbo.customer
(per_id, cus_balance, cus_total_sales, cus_notes)
VALUES
(6, 120, 14789, NULL),
(7, 98.46, 234.92, NULL),
(8, 0, 4578, 'Customer always pays on time.'),
(9, 981.73, 1672.38, 'High balance.'),
(10, 541.21, 782.56, NULL),
(11, 251.92, 13782.96, 'Good Customer'),
(12, 582.67, 963.12, 'Previously paid in full.'),
(13, 121.67, 1057.45, 'Recent Customer'),
(14, 765.43, 6789.42, 'Buys bulk quantities.'),
(15, 304.39, 456.81, 'Has not purchased recently');
GO
select * from dbo.customer;

INSERT INTO dbo.contact
(per_sid,per_cid, cnt_date, cnt_notes)
VALUES

(1,6, '1990-01-01', NULL),
(2,6, '2001-09-29', NULL),
(3,7, '2002-08-15', NULL),
(2,7, '2002-09-01', NULL),
(4,7, '2004-01-05', NULL),
(5,8, '2004-02-28', NULL),
(4,8, '2004-03-03', NULL),
(1,9, '2004-04-07', NULL),
(5,9, '2004-07-29', NULL),
(3,11, '2005-05-02', NULL),
(4,13, '2005-06-14', NULL),
(2,15, '2005-07-02', NULL);
GO
select * from dbo.contact;

INSERT INTO dbo.[order]
(cnt_id, ord_placed_date, ord_filled_date, ord_notes)
VALUES
(1, '2010-11-23', '2010-12-24', NULL),
(2, '2005-03-19', '2005-07-28', NULL),
(3, '2011-07-01', '2011-07-06', NULL),
(4, '2009-12-24', '2010-01-05', NULL),
(5, '2008-09-21', '2008-11-26', NULL),
(6, '2009-04-17', '2009-04-30', NULL),
(7, '2010-05-31', '2010-06-07', NULL),
(8, '2007-09-02', '2007-09-16', NULL),
(9, '2011-12-08', '2011-12-23', NULL),
(10, '2012-02-29', '2012-05-02', NULL);
GO
select * from dbo.[order]

INSERT INTO region
(reg_name, reg_notes)
VALUES 
('c', NULL),
('n', NULL),
('e', NULL),
('s', NULL),
('w', NULL);
GO
select * from dbo.region;

INSERT INTO state
(reg_id, ste_name, ste_notes)
VALUES
(1, 'CA', NULL),
(2, 'MI', NULL), 
(3, 'AZ', NULL),
(4, 'GA', NULL), 
(5, 'SC', NULL);
GO
select * from dbo.state;

INSERT INTO dbo.city
(ste_id, cty_name, cty_notes)
VALUES 
(1, 'Sacramento', NULL),
(2, 'Detroit', NULL),
(3, 'Phoenix', NULL),
(4, 'Atlanta', NULL),
(5, 'Charleston', NULL);
GO
SELECT * FROM dbo.city;

INSERT INTO dbo.store
(cty_id, str_name, str_street, str_zip, str_phone, str_email, str_url, str_notes)
VALUES
(1, 'CVS', '8064 Springview Center', 286552301, 7151776936, 'fcolthard0@domainmarket.com', 'https://harvard.edu', null),
(2, 'Best Buy', '20777 Magdeline Point', 989391341, 9054068652, 'tcahani1@guardian.co.uk', 'https://walmart.com', null),
(3, 'Walgreens', '63016 Katie Plaza', 291103334, 1708680450, 'mbartozzi2@deviantart.com', 'https://sina.com.cn', null),
(4, 'Publix', '39997 Porter Road', 824353562, 3588766639, 'jschukraft3@bing.com', 'https://wix.com', null),
(5, 'Walmart', '90 Westport Crossing', 411130599, 2298271008, 'twarburton4@archive.org', 'https://geocities.com', null);
GO
select * from dbo.store;

INSERT INTO dbo.invoice
(ord_id, str_id, inv_date, inv_total, inv_paid, inv_notes)
VALUES
(5, 1, '2001-05-03', 58.32, 0, NULL),
(4, 1, '2006-11-11', 100.59, 0, NULL),
(1, 1, '2010-09-16', 57.34, 0, NULL),
(3, 2, '2011-01-10', 99.32, 1, NULL),
(2, 3, '2008-06-24', 1109.67, 1, NULL),
(6, 4, '2009-04-20', 239.83, 0, NULL),
(7, 5, '2010-06-05', 547.29, 0, NULL),
(8, 2, '2007-09-09', 644.21, 1, NULL),
(9, 3, '2011-12-17', 934.12, 1, NULL),
(10, 4, '2012-03-18', 27.45, 0, NULL);
GO
select * from dbo.invoice;

INSERT INTO dbo.vendor
(ven_name, ven_street, ven_city, ven_state, ven_zip, ven_phone, ven_email, ven_url, ven_notes)
VALUES
('Sysco', '531 Dolphin Run', 'Orlando', 'FL', '344761234', '7641238543', 'sale@sysco.com', 'https://www.sysco.com', NULL),
('General Electric', '100 Happy Trails Dr.', 'Boston', 'MA', '123458743', '2134569641', 'support@ge.com', 'http://www.ge.com', 'Very good turnaround'),
('Cisco', '300 Cisco Dr.', 'Stanford', 'OR', '872315492', '7823456723', 'cisco@cisco.com', 'http://www.cisco.com', NULL),
('Goodyear', '100 Goodyear dr', 'Gary', 'IN', '485321956', '5784218427', 'sales@goodyear.com', 'http://www.goodyear.com', NULL),
('Snap-on', '42185 Magenta Ave', 'Lake Falls', 'ND', '387513649', '9197345632', 'support@snapon.com', 'http://www.snap-on.com', 'Good quality tools!');

GO

select * from dbo.vendor;

INSERT INTO dbo.product
(ven_id, pro_name, pro_descript, pro_weight, pro_qoh, pro_cost, pro_price, pro_discount, pro_notes)
VALUES
(1, 'hammer', '', 2.5, 45, 4.99, 7.99, 39, 'Discounted only when purchased with screwdriver set.'),
(2, 'screwdriver', '', 1.8, 120, 1.99, 3.49, NULL, NULL),
(4, 'pail', '16 gallon', 2.8, 48, 3.89, 7.99, 40, NULL),
(5, 'cooking oil', 'Peanut Oil', 15, 19, 19.99, 28.99, NULL, 'gallons'),
(3, 'frying pan', '', 3.5, 178, 8.45, 13.99, 50, 'Currently 1/2 price sale.');

GO

select * from dbo.product;

INSERT INTO dbo.order_line
(ord_id, pro_id, oln_qty, oln_price, oln_notes)
VALUES
(1, 2, 10, 8.0, NULL),
(2, 3, 7, 9.88, NULL),
(3, 4, 3, 6.99, NULL),
(5, 1, 2, 12.76, NULL),
(4, 5, 13, 58.99, NULL);

GO

select * from dbo.order_line;

INSERT INTO dbo.payment
(inv_id, pay_date, pay_amt, pay_notes)
VALUES
(5, '2008-07-01', 5.99,NULL),
(4, '2010-09-28', 4.99,NULL),
(1, '2008-07-23', 8.75,NULL),
(3, '2010-10-31', 19.55,NULL),
(2, '2011-03-29', 32.5,NULL),
(6, '2010-10-03', 20.00,NULL),
(8, '2008-08-09', 1000.00,NULL),
(9, '2009-01-10', 103.68,NULL),
(7, '2007-03-15', 25.00,NULL),
(10, '2007-05-12', 40.00,NULL),
(4, '2007-05-22', 9.33,NULL);

GO

select * from dbo.payment;

INSERT INTO dbo.product_hist
(pro_id, pht_date, pht_cost, pht_price, pht_discount, pht_notes)
VALUES
(1, '2005-01-02 11:53:34', 4.99, 7.99, 30, 'Discounted only when purchased wwith screwdriver set'),
(2, '2005-02-03 09:13:56', 1.99, 3.49, NULL, NULL),
(3, '2005-03-04 23:21:49', 3.89, 7.99, 40, NULL),
(4, '2006-05-06 18:09:04', 19.99, 28.99, NULL, 'gallons'),
(5, '2006-05-07 15:07:29', 8.45, 13.99, 50, 'currently 1/2 price sale.');

GO

select * from dbo.product_hist;

INSERT INTO dbo.time
(tim_yr, tim_qtr, tim_month, tim_week, tim_day, tim_time, tim_notes)
VALUES
(1999, 1, 6, 35, 180, '0:55:17', null),
(2008, 1, 1, 3, 145, '10:57:24', null),
(2012, 2, 2, 5, 104, '0:43:50', null),
(1967, 2, 6, 43, 102, '12:20:35', null),
(2005, 2, 9, 36, 71, '3:06:19', null);
GO 
select * from dbo.time;

INSERT INTO sale
(pro_id, str_id, cnt_id, tim_id, sal_qty, sal_price, sal_total, sal_notes)
VALUES
(1, 2, 3, 4, 7, 28.81, 920.01, null),
(2, 1, 3, 5, 27, 68.51, 651.79, null),
(3, 1, 2, 5, 6, 21.49, 865.31, null),
(4, 2, 3, 1, 37, 94.42, 584.12, null),
(4, 3, 2, 1, 36, 14.11, 270.75, null),
(5, 4, 3, 2, 39, 83.26, 391.61, null),
(5, 5, 3, 2, 29, 32.78, 484.27, null),
(1, 5, 4, 3, 26, 97.71, 424.11, null),
(1, 4, 5, 2, 13, 42.61, 778.52, null),
(1, 2, 3, 5, 39, 48.03, 995.12, null),
(3, 1, 4, 5, 42, 84.64, 349.71, null),
(2, 3, 4, 1, 25, 10.67, 549.84, null),
(5, 2, 3, 1, 38, 77.74, 751.33, null),
(1, 3, 2, 4, 42, 34.25, 130.88, null),
(1, 3, 5, 2, 31, 12.72, 916.01, null),
(3, 2, 4, 1, 34, 14.81, 933.12, null),
(1, 4, 3, 2, 43, 39.93, 355.33, null),
(3, 2, 4, 5, 29, 79.01, 600.46, null),
(4, 3, 5, 1, 21, 10.67, 952.81, null),
(2, 1, 3, 5, 23, 57.31, 470.98, null),
(1, 2, 3, 1, 24, 29.46, 415.55, null),
(1, 2, 3, 2, 6, 85.48, 653.87, null),
(1, 2, 3, 3, 39, 34.35, 419.08, null),
(2, 3, 4, 5, 37, 21.42, 780.42, null),
(1, 5, 2, 4, 34, 94.69, 678.62, null);
GO
select * from dbo.sale;

INSERT INTO dbo.srp_hist
(per_id, sht_type, sht_modified, sht_modifier, sht_date, sht_yr_sales_goal, sht_ytd_sales, sht_ytd_comm, sht_notes)
VALUES
(1,'i', getDATE(), SYSTEM_USER, getDATE(), 100000, 110000, 11000,NULL),
(4,'i', getDATE(), SYSTEM_USER, getDATE(), 150000, 175000, 17500,NULL),
(3,'u', getDATE(), SYSTEM_USER, getDATE(), 200000, 185000, 18500,NULL),
(2,'u', getDATE(), ORIGINAL_LOGIN(), getDATE(), 210000, 220000, 22000,NULL),
(5,'i', getDATE(), ORIGINAL_LOGIN(), getDATE(), 225000, 230000, 2300,NULL);

GO

select * from dbo.srp_hist;

INSERT INTO dbo.phone
(per_id, phn_num, phn_type, phn_notes)
VALUES
(1, '3055555551', 'h', NULL),
(2, '7865555552', 'c', NULL),
(3, '3055555253', 'w', NULL),
(4, '7865545554', 'f', NULL),
(5, '3055555525', 'h', NULL);
GO
SELECT * FROM dbo.phone;

----------------------------
--REQUIRED REPORT
----------------------------

--1st arg is object name, 2nd arg is type (P=Procedure)


IF OBJECT_ID(N'dbo.product_days_of_week',N'P') IS NOT NULL
DROP PROC dbo.product_days_of_week;
GO

CREATE PROC dbo.product_days_of_week AS
BEGIN
select pro_name, pro_descript, datename(dw, tim_day-1) 'day_of_week'
  from product p 
    join sale s on p.pro_id=s.pro_id
    join time t on t.tim_id=s.tim_id
  order by tim_day-1 asc;
END
GO

-- call stored procedure
exec dbo.product_days_of_week;
';