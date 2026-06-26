CREATE DATABASE fraud_analysis;
SHOW DATABASES;

USE fraud_analysis;

CREATE TABLE transactions (
    step INT,
    type VARCHAR(20),
    amount DECIMAL(15,2),
    nameOrig VARCHAR(50),
    oldbalanceOrg DECIMAL(15,2),
    newbalanceOrig DECIMAL(15,2),
    nameDest VARCHAR(50),
    oldbalanceDest DECIMAL(15,2),
    newbalanceDest DECIMAL(15,2),
    isFraud INT,
    isFlaggedFraud INT
);
SHOW VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 1;
-- dataset file path --
LOAD DATA LOCAL INFILE '/Users/jayeshsunilthakare/Desktop/SQL/fraud_detection/dataset/paysim.csv'
INTO TABLE transactions
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;











