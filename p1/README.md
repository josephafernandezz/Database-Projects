# LIS3781 - Advanced Database Management

## Joseph Fernandez

### Project 1 Requirements:

Business Rules: 
As the lead DBA for a local municipality, you are contacted by the city council to design a database in 
order to track and document the city’s court case data. Some report examples:  
Which attorney is assigned to what case(s)? 
How many unique clients have cases (be sure to add a client to more than one case)? 
How many cases has each attorney been assigned, and names of their clients (return number and 
names)? 
How many cases does each client have with the firm (return a name and number value)? 
Which types of cases does/did each client have/had and their start and end dates? 
Which attorney is associated to which client(s), and to which case(s)? 
Names of three judges with the most number of years in practice, include number of years. 
Also, include the following business rules:  
• An attorney is retained by (or assigned to) one or more clients, for each case. 
• A client has (or is assigned to) one or more attorneys for each case. 
• An attorney has one or more cases. 
• A client has one or more cases. 
• Each court has one or more judges adjudicating. 
• Each judge adjudicates upon exactly one court. 
• Each judge may preside over more than one case. 
• Each case that goes to court is presided over by exactly one judge. 
• A person can have more than one phone number. 

#### README.md file should include the following items:

* Screenshts of ERD
* Screenshot: At least *one* required report (i.e., exercise below), and SQL code solution. 
* Bitbucket repo links: *Your* lis3781 Bitbucket repo link

### Solution File

[P1 Solutions](lis3781_p1_solutions.sql "My solutions file")

#### Assignment Screenshots:

*Screenshots of ERD*:

![ERD Screenshot 1](erd1.png)
![ERD Screenshot 2](erd2.png)

*Screenshots of Required Report*

![Required Report](requiredreport.png)