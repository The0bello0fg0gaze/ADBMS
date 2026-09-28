CREATE TABLE department (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(30)
);

CREATE TABLE employee (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    salary NUMERIC(10,2),
    dept_id INT REFERENCES department(dept_id)
);

INSERT INTO department VALUES
(1, 'IT'),
(2, 'Sales'),
(3, 'HR');

INSERT INTO employee VALUES
(101, 'Aman', 90000, 1),
(102, 'Neha', 70000, 1),
(103, 'Raj', 50000, 1),
(104, 'Priya', 80000, 2),
(105, 'Karan', 60000, 2),
(106, 'Riya', 40000, 2),
(107, 'Mohit', 75000, 3),
(108, 'Simran', 55000, 3);

-- 1 ANS :- 
SELECT
    d.dept_name AS department_name,
    e.emp_name AS employee_name,
    e.salary AS salary
FROM department AS d
JOIN employee AS e ON d.dept_id = e.dept_id
WHERE e.salary > (
    SELECT AVG(e2.salary)
    FROM employee AS e2
    WHERE e2.dept_id = e.dept_id
)
AND (
    SELECT COUNT(*)
    FROM employee AS e3
    WHERE e3.dept_id = e.dept_id
) >= 3;



------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------V

--Q2:
CREATE TABLE bank_customer (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(50),
    balance NUMERIC(10,2)
);

CREATE TABLE customer_audit (
    audit_id SERIAL PRIMARY KEY,
    customer_id INT,
    customer_name VARCHAR(50),
    action VARCHAR(20),
    action_time TIMESTAMP
);

INSERT INTO bank_customer VALUES
(1, 'Rahul', 50000),
(2, 'Neha', 75000);

INSERT INTO bank_customer VALUES
(1, 'Rahul', 50000),
(2, 'Neha', 75000);

CREATE OR REPLACE FUNCTION log_customer_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO customer_audit (customer_id, customer_name, action, action_time)
        VALUES (NEW.customer_id, NEW.customer_name, 'ADDED', CURRENT_TIMESTAMP);
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO customer_audit (customer_id, customer_name, action, action_time)
        VALUES (OLD.customer_id, OLD.customer_name, 'REMOVED', CURRENT_TIMESTAMP);
        RETURN OLD;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER customer_audit_trigger
AFTER INSERT OR DELETE ON bank_customer
FOR EACH ROW
EXECUTE FUNCTION log_customer_changes();
