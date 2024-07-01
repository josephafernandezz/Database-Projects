DROP SEQUENCE seq_cus_id;
CREATE SEQUENCE seq_cus_id
start with 1
increment by 1
minvalue 1
maxvalue 10000;

DROP TABLE customer CASCADE CONSTRAINTS PURGE;
CREATE TABLE CUSTOMER(
    cus_id number (3,0) not null, --max value 999
    cus_fname varchar2(15) not null,
    cus_lname varchar2(30) not null,
    cus_street varchar2(30) not null,
    cus_city varchar2(30) not null,
    cus_state char(2) not null,
    cus_zip number(9) not null, --equivalent to number (9,0)
    cus_phone number(10) not null,
    cus_email varchar2(100),
    cus_balance number(7,2), 
    cus_notes varchar2(255),
CONSTRAINT pk_customer PRIMARY KEY(cus_id)
);

DROP SEQUENCE seq_com_id;
Create sequence seq_com_id
start with 1
increment by 1
minvalue 1
maxvalue 10000;

drop table commodity CASCADE CONSTRIANTS PURGE;
CREATE TABLE commodity
(
    com_id number not null,
    com_name varchar2(20),
    com_price NUMBER(8,2) NOT NULL,
    cus_notes varchar2(255),
CONSTRAINT pk_commodity PRIMARY KEY(com_id),
CONSTRAINT uq_com_name UNIQUE(com_name)
);

DROP SEQUENCE seq_ord_id;
CREATE SEQUENCE seq_ord_id
start with 1
increment by 1
minvalue 1
maxvalue 10000;

DROP TABLE "order" CASCADE CONSTRAINTS PURGE;
CREATE TABLE "order"
(
    ord_id number (4,0) not null,
    cus_id number,
    com_id number,
    ord_num_units number(5,0) not null,
    ord_total_cost number(8,2) not null,
    ord_notes varchar2(255),
    CONSTRAINT pk_order PRIMARY KEY(ord_id),
    CONSTRAINT fk_order_customer
    FOREIGN KEY (cus_id)
    REFERENCES customer(cus_id),
    CONSTRAINT fk_order_commodity
    FOREIGN KEY (com_id)
    REFERENCES commodity(com_id),
    CONSTRAINT check_unit CHECK(ord_num_units > 0),
    CONSTRAINT check_total CHECK(ord_total_cost > 0)
);

-- DATA INSERTS 

INSERT INTO customer VALUES (seq_cus_id.nextval, 'Marie-ann', 'Mesnard', '8978 Waywood Hill', 'Miami', 'FL', 753979902, 4869924280, 'mmesnard0@geocities.jp', 11408.75, null);
INSERT INTO customer VALUES (seq_cus_id.nextval, 'Vin', 'McGillivray', '234 Lillian Alley', 'Tampa', 'FL', 617713474, 6643407387, 'vmcgillivray1@lycos.com', 84066.58, 'Aenean fermentum. Donec ut mauris eget massa tempor convallis.');
INSERT INTO customer VALUES (seq_cus_id.nextval, 'Gray', 'Noseworthy', '132 Fuller Hill', 'West Palm', 'FL', 195226523, 1925627650, 'gnoseworthy2@qq.com', 96113.94, 'Vivamus vel nulla eget eros elementum pellentesque. Quisque porta volutpat erat.');
INSERT INTO customer VALUES (seq_cus_id.nextval, 'Cathrine', 'Costa', '42 Mcbride Way', 'Dallas', 'TX', 827539963, 5257867154, 'ccosta3@ustream.tv', 29958.49, 'Praesent lectus.');
INSERT INTO customer VALUES (seq_cus_id.nextval, 'Marion', 'Liggens', '33 Monica Terrace', 'Orlando', 'FL', 359489634, 7167003675, 'mliggens4@illinois.edu', 20200.64, 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est.');

INSERT INTO commodity VALUES (1, 'Zamit', 1396.16, 'lobortis');
INSERT INTO commodity VALUES (2, 'Mat Lam Tam', 80610.0, 'aliquam sit');
INSERT INTO commodity VALUES (3, 'Stringtough', 82026.4, 'nulla');
INSERT INTO commodity VALUES (4, 'Redhold', 44446.11, 'praesent blandit');
INSERT INTO commodity VALUES (5, 'Y-Solowarm', 54213.6, 'eget orci');

INSERT INTO "order" VALUES (seq_ord_id.nextval, 1, 1, 80319, 439183.52, 'Vivamus vestibulum sagittis sapien.');
INSERT INTO "order" VALUES (seq_ord_id.nextval, 2, 2, 47547, 498374.16, 'Morbi a ipsum.');
INSERT INTO "order" VALUES (seq_ord_id.nextval, 3, 3, 80958, 747095.31, 'Duis consequat dui nec nisi volutpat eleifend.');
INSERT INTO "order" VALUES (seq_ord_id.nextval, 4, 4, 86812, 271137.83, 'Duis ac nibh.');
INSERT INTO "order" VALUES (seq_ord_id.nextval, 5, 5, 46622, 155206.32, 'Pellentesque eget nunc.');


-- 1. Display Oracle version 2:
    SELECT * FROM v$version;

    SELECT * FROM v$version
    WHERE banner LIKE 'Oracle%';

    ***shows all oracle versions information 
    SELECT * FROM PRODUCT_COMPONENT_VERSION;

-- 3. Display current user
    SELECT user FROM dual;

-- 4. Display current day/time (formatted)
    SELECT TO_CHAR (SYSDATE, 'MM-DD-YYYY HH24:MI:SS') *NOW*
    FROM DUAL;

-- 5. display privileges
    SELECT * FROM USER_SYS_PRIVS;

-- 6. display all user tables,
    SELECT OBJECT_NAME FROM USER_OBJECTS
    WHERE OBJECT_TYPE = "TABLE";
or
    SELECT table_name
    FROM user_tables;
or
    SELECT owner, table_name
    FROM all tables
    WHERE owner = 'jaf19g'

-- 7. Display structure for each table
    DESCRIBE CUSTOMER;
    DESCRIBE commodity;
    DESCRIBE "order";

-- 8. List the customer number, last name, first name, and e-mail of every cutomer.
    SELECT cus_id, cus_lname, cus_fname, cus_email
    FROM customer;

-- 9. Same query as above, include street, city, state, and sort by state in descending order, and last name in ascending order.
    SELECT cus_id, cus_lname, cus_fname, cus_email, cus_street, cus_city, cus_state
    FROM customer
    ORDER BY cus_state DESC, cus_lname;

-- 10. What is the full name of customer number 3? display last name first.
    SELECT cus_lname, cus_fname
    FROM customer
    WHERE cus_id = 3;

-- 11. 
    select cus_id, cus_lname, cus_fname, cus_balance
    from customer
    where cus_balance > 1000
        order by cus_balance desc;

-- 12. 
    select com_name, to_char(com_price, 'L99,999.99') as price_fromatted
    from commodity
    order by com_price;

-- 13. 
    select (cus_lname || ',' || cus_fname) as name,
    select(cus_lname || ',' || cus_city || ',' || cus_state || ',' || cus_zip) as address
    from customer
    order by cus_zip desc;

-- 14. 
    select * from "order"
    where com_id not in (select com_id from commodity where lower(com_name)='cereal');

    select * form "order"
    where com_id != (select com_id from commodity where lower(com_name)='cereal');

    select * form "order"
    where com_id <> (select com_id from commodity where lower(com_name)='cereal');

-- 15. 
    --left align 
    select cus_id, cus_lname, to_char(cus_balance, '$99,999.99') as balance_formatted
    from customer
    where cus_balance >= 500 and cus_balance <= 1000;

    --right align 
    select cus_id, cus_lname, to_char(cus_balance, 'L99,999.99') as balance_formatted
    from customer
    where cus_balance >= 500 and cus_balance <= 1000;

    --Or 
    select cus_id, cus_lname, to_char(cus_balance, 'L99,999.99') as balance_formatted
    from customer
    where cus_balance between 500 and 1000;

-- 16. List the customer number, last name, first name, and balance 
    SELECT cus_id, cus_lname, cus_fname, to_char(cus_balance, 'L99.999.99') as balance_formatted
    from customerwhere cus_balance >
        (select avg(cus_balance) from customer);

-- 17. List the customer num, name, and total order amount
    select cus_id, cus_lname, cus_fname, to_char(sum(ord_total_cost),'L99,999.99') as "total orders"
    from customer
        natural join "order"
    group by cus_id, cus_lname, cus_fname
    order by sum(ord_total_cost) desc;

-- 18. list the customer number, last name, first name, and address
    select cus_id, cus_lname, cus_fname, cus_street, cus_city, cus_state, cus_zip
    from customer
    where cus_street like '%Peach%';

-- 19. list the customer number, name, and total order amount for each customer whose total order amount is greater than 1500
    select cus_id, cus_lname, cus_fname, to_char(sum(ord_total_cost), 'L99,999.99') as "total orders"
    from customer
        natural join "order"
    group by cus_id, cus_lname, cus_fname
    having sum(ord_total_cost) > 1500
    order by sum(ord_total_cost) desc;

-- 20. List the customer number, name, and number of units orders
    select cus_id, cus_lname, cus_fname, ord_num_units
    from customer
        natural join "order"
    where ord_num_units IN (30, 40, 50);

-- 21.
    select cus_id, cus_lname, cus_fname
    count(*) as "number of orders",
    to_char(min(ord_total_cost), 'L99,999.99') as "minimum order cost",
    to_char(max(ord_total_cost), 'L99,999.99') as "maximum order cost",
    to_char(sum(ord_total_cost), 'L99,999.99') as "total orders",
    from customer 
    natural join "order"
    where exists
        (select count(*) from customer having COUNT(*) >= 5)
    group by cus_id, cus_lname, cus_fname;

-- 22. Find aggregate values for customers
    select 
        count(*),
        count(cus_balance),
        sum(cus_balance),
        avg(cus_balance),
        max(cus_balance),
        min(cus_balance)
    from customer;

-- 23. find how many unique customers have orders
-- steps
-- 1. list all customer numbers including duplicates
    select cus_id from "order";
-- 2. List all customer numbers excluding duplicates
    select distinct cus_id from "order";
-- 3. List number of unique customers who have orders 
    select count(distinct cus_id) from "order";

-- 24. List the customer number, name, commodity name, order number, etc.
    select cu.cus_id, cus_lname, com_name, order_id, to_char(ord_total_cost, 'L99,999.99') as "order amount"
    from customer cu   
        join "order" o on o.cus_id=cu.cus_id
        join commodity co on co.com_id=o.com_id
    order by ord_total_cost desc;

-- 25.
    SET DEFINE OFF 
    select * from commodity;