DROP DATABASE desafioFrontend;
CREATE DATABASE desafioFrontend;
USE desafioFrontend;

CREATE TABLE Salesman ( 
CPF BIGINT,
Name VARCHAR(200) primary key,
Salary DOUBLE);

CREATE TABLE Customer(
CNPJ BIGINT primary key,
NAME VARCHAR(200),
BusinessArea VARCHAR(200)
);

CREATE TABLE Sales(
id INT primary key auto_increment,
total DOUBLE,
name_salesman VARCHAR(200),
FOREIGN KEY (name_salesman) REFERENCES Salesman(Name)
);

DELIMITER $$ 
DROP PROCEDURE IF EXISTS deleteAllData;
CREATE PROCEDURE deleteAllData()
BEGIN
	DELETE FROM Sales;
	DELETE FROM Customer;
	DELETE FROM Salesman;
END $$
DELIMITER ;
