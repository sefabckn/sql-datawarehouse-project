/*
=================================================================

Create Database and Schemas

=================================================================

Script Purpose:

This Scripts Createas a  database called "DataWareHouse" and later
The Script adds 3 schemas called "bronze", "silver", and "gold".

*/



USE master;

CREATE DATABASE DataWareHouse;

USE DataWareHouse;

CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO -- Separate bathes with GO keyword when working with multiple SQL statements
CREATE SCHEMA gold;
GO
