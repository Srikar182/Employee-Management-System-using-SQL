show databases;
create database project;
use project;

-- Table 1: Job Department
CREATE TABLE JobDepartment (
    Job_ID INT PRIMARY KEY,
    jobdept VARCHAR(50),
    name VARCHAR(100),
    description TEXT,
    salaryrange VARCHAR(50)
);

-- Table 2: Salary/Bonus
CREATE TABLE SalaryBonus (
    salary_ID INT PRIMARY KEY,
    Job_ID INT,
    amount DECIMAL(10,2),
    annual DECIMAL(10,2),
    bonus DECIMAL(10,2),
    CONSTRAINT fk_salary_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(Job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Table 3: Employee
CREATE TABLE Employee (
    emp_ID INT PRIMARY KEY,
    firstname VARCHAR(50),
    lastname VARCHAR(50),
    gender VARCHAR(10),
    age INT,
    contact_add VARCHAR(100),
    emp_email VARCHAR(100) UNIQUE,
    emp_pass VARCHAR(50),
    Job_ID INT,
    CONSTRAINT fk_employee_job FOREIGN KEY (Job_ID)
        REFERENCES JobDepartment(Job_ID)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- Table 4: Qualification
CREATE TABLE Qualification (
    QualID INT PRIMARY KEY,
    Emp_ID INT,
    Position VARCHAR(50),
    Requirements VARCHAR(255),
    Date_In DATE,
    CONSTRAINT fk_qualification_emp FOREIGN KEY (Emp_ID)
        REFERENCES Employee(emp_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Table 5: Leaves
CREATE TABLE Leaves (
    leave_ID INT PRIMARY KEY,
    emp_ID INT,
    date DATE,
    reason TEXT,
    CONSTRAINT fk_leave_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Table 6: Payroll
CREATE TABLE Payroll (
    payroll_ID INT PRIMARY KEY,
    emp_ID INT,
    job_ID INT,
    salary_ID INT,
    leave_ID INT,
    date DATE,
    report TEXT,
    total_amount DECIMAL(10,2),
    CONSTRAINT fk_payroll_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_salary FOREIGN KEY (salary_ID) REFERENCES SalaryBonus(salary_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_leave FOREIGN KEY (leave_ID) REFERENCES Leaves(leave_ID)
        ON DELETE SET NULL ON UPDATE CASCADE
);



-- 1. EMPLOYEE INSIGHTS
-- How many unique employees are currently in the system?
select count(*) as total_employees
from employee;

-- Which departments have the highest number of employees?
select jd.jobdept, count(e.emp_id) as employee_count
FROM Employee e
JOIN JobDepartment jd ON e.Job_ID = jd.Job_ID
GROUP BY jd.jobdept
ORDER BY Employee_Count DESC;

-- What is the average salary per department?
SELECT jd.jobdept, AVG(sb.amount) AS Average_Salary
FROM SalaryBonus sb
JOIN JobDepartment jd ON sb.Job_ID = jd.Job_ID
GROUP BY jd.jobdept;

-- Who are the top 5 highest-paid employees?
SELECT e.emp_ID,
       CONCAT(e.firstname,' ',e.lastname) AS Employee_Name,
       sb.amount
FROM Employee e
JOIN SalaryBonus sb ON e.Job_ID = sb.Job_ID
ORDER BY sb.amount DESC
LIMIT 5;

-- What is the total salary expenditure across the company?
SELECT SUM(sb.amount) AS Total_Salary
FROM Employee e
JOIN SalaryBonus sb 
ON e.Job_ID = sb.Job_ID;



-- 2. JOB ROLE AND DEPARTMENT ANALYSIS
-- How many different job roles exist in each department?
SELECT jobdept, COUNT(name) AS Job_Roles
FROM JobDepartment
GROUP BY jobdept;

-- What is the average salary range per department?
SELECT jd.jobdept, AVG(sb.amount) AS Average_Salary
FROM SalaryBonus sb
JOIN JobDepartment jd ON sb.Job_ID = jd.Job_ID
GROUP BY jd.jobdept;

-- Which job roles offer the highest salary?
SELECT jd.name, sb.amount
FROM JobDepartment jd
JOIN SalaryBonus sb ON jd.Job_ID = sb.Job_ID
ORDER BY sb.amount DESC;

-- Which departments have the highest total salary allocation?
SELECT jd.jobdept,
       SUM(sb.amount) AS Total_Salary
FROM SalaryBonus sb
JOIN JobDepartment jd ON sb.Job_ID = jd.Job_ID
GROUP BY jd.jobdept
ORDER BY Total_Salary DESC;

-- 3. QUALIFICATION AND SKILLS ANALYSIS
-- How many employees have at least one qualification listed?
SELECT COUNT(DISTINCT Emp_ID) AS Qualified_Employees
FROM Qualification;

-- Which positions require the most qualifications?
SELECT Position, COUNT(*) AS Total
FROM Qualification
GROUP BY Position
ORDER BY Total DESC;

-- Which employees have the highest number of qualifications?
SELECT Emp_ID, COUNT(*) AS Total_Qualifications
FROM Qualification
GROUP BY Emp_ID
ORDER BY Total_Qualifications DESC;

-- 4. LEAVE AND ABSENCE PATTERNS
-- Which year had the most employees taking leaves?
SELECT YEAR(date) AS Year,
       COUNT(*) AS Total_Leaves
FROM Leaves
GROUP BY YEAR(date)
ORDER BY Total_Leaves DESC;

-- What is the average number of leave days taken by its employees per department?
SELECT jd.jobdept,
       COUNT(l.leave_ID)/COUNT(DISTINCT e.emp_ID) AS Average_Leaves
FROM Employee e
JOIN Leaves l ON e.emp_ID=l.emp_ID
JOIN JobDepartment jd ON e.Job_ID=jd.Job_ID
GROUP BY jd.jobdept;

-- Which employees have taken the most leaves?
SELECT emp_ID,
       COUNT(*) AS Total_Leaves
FROM Leaves
GROUP BY emp_ID
ORDER BY Total_Leaves DESC;

-- What is the total number of leave days taken company-wide?
SELECT COUNT(*) AS Total_Leave_Days
FROM Leaves;

-- How do leave days correlate with payroll amounts?
SELECT e.emp_ID,
       COUNT(l.leave_ID) AS Leave_Days,
       p.total_amount
FROM Employee e
JOIN Leaves l ON e.emp_ID=l.emp_ID
JOIN Payroll p ON e.emp_ID=p.emp_ID
GROUP BY e.emp_ID,p.total_amount;


-- CHALLENGES
-- Defining table relationships and foreign keys:
-- Creating correct relationships between tables using primary and foreign keys to maintain data integrity.
-- Maintaining data consistency:
-- Using ON DELETE CASCADE, ON UPDATE CASCADE, and SET NULL to keep related data consistent when records are updated or deleted.
-- Writing complex JOIN queries:
-- Combining multiple tables (Employee, JobDepartment, Payroll, Leaves, Qualification, SalaryBonus) to generate meaningful reports.
-- Managing date formats:
-- Storing all dates in YYYY-MM-DD format to ensure accurate sorting, filtering, and time-based analysis.
-- Preventing duplicate records:
-- Applying UNIQUE constraints (such as on emp_email) to avoid duplicate employee records and maintain data accuracy.
