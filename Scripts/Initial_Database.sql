/*
==========================================
Data Warehouse Initialisation Script
==========================================
 Purpose:
    This script sets up the foundation for the Data Warehouse project.
    It creates the main database (DataWarehouse) and establishes the
    bronze, silver, and gold schemas to support the layered architecture
    for data ingestion, transformation, and analytics.
==========================================
*/


USE master;
GO

-- Create the database

CREATE DATABASE DataWarehouse;

USE DataWarehouse;

-- Create schemas

CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
