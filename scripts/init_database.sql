/*
===============================================================================
Database Initialization Script
===============================================================================
Purpose:
    This script initializes the Data Warehouse environment by creating the 
    'DataWarehouse' database and setting up the Medallion Architecture schemas.

WARNING:
    This script will DROP the 'DataWarehouse' database if it already exists.
    All existing data and objects will be permanently lost.
===============================================================================
*/

-- ============================================================================
-- 1. Database Creation & Context Setup
-- ============================================================================

USE master;
GO

-- Check if database exists, disconnect active sessions, and drop it
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    PRINT 'Database exists. Disconnecting sessions and dropping database...';
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END;
GO

-- Create the database
PRINT 'Creating database: DataWarehouse...';
CREATE DATABASE DataWarehouse;
GO

-- Switch context to the newly created database
USE DataWarehouse;
GO

-- ============================================================================
-- 2. Schema Creation (Medallion Architecture Layers)
-- ============================================================================

-- Bronze Schema: Raw data landing area (exact copy of source files)
PRINT 'Creating schema: bronze...';
CREATE SCHEMA bronze;
GO

-- Silver Schema: Cleansed, standardized, and validated data
PRINT 'Creating schema: silver...';
CREATE SCHEMA silver;
GO

-- Gold Schema: Business-ready dimensional model (Star Schema / Views)
PRINT 'Creating schema: gold...';
CREATE SCHEMA gold;
GO

PRINT 'Data Warehouse initialization completed successfully.';
