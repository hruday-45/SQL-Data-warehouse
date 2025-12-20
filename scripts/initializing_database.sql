/*
================================================================================================
Create Database and Schemas
================================================================================================
Script Purpose:
  This script creates a new database named 'DataWarehouse' after checking if it already exists.
  If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas within the database: 'bronze', 'silver', and 'gold'.

WARNING:
  Running this script will drop the entire 'DataWarehouse' database if it exists.
  All data in the database will be permanently deleted. Proceed with caution and ensure you have proper backups before running this script.
*/

--Create Database 'DataWarehouse'

--Create Database 'DataWarehouse'

USE master;
GO

--Drop and recreate the 'DataWarehouse' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
	ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWarehouse;
END;
GO

CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO

/* =============================================================================
    2. FUNCTIONS, these will be used at the time of Silver Layer Data Cleansing.
    ============================================================================= */

PRINT '==========================================================================';

PRINT '---> Dropping a scalar-valued function if exists: silver.fn_cap_city_names';
IF OBJECT_ID(N'silver.fn_cap_city_names', N'FN') IS NOT NULL
DROP FUNCTION silver.fn_cap_city_names;

PRINT '---> Creating a scalar-valued function: silver.fn_cap_city_names';
GO

CREATE OR ALTER FUNCTION silver.fn_cap_city_names (@City VARCHAR(255))
RETURNS VARCHAR(255) AS
    BEGIN
        DECLARE @Result VARCHAR(255);
            SELECT @Result = STRING_AGG(
                CASE WHEN LOWER(value) IN ('de', 'do', 'da', 'dos', 'das', 'e') AND ordinal > 1 
                    THEN LOWER(value)
                    ELSE UPPER(LEFT(value, 1)) + LOWER(SUBSTRING(value, 2, LEN(value)))
                END, ' ') WITHIN GROUP (ORDER BY ordinal)
            FROM STRING_SPLIT(@City, ' ', 1);
        RETURN @Result;
    END;
GO

PRINT '============================================================================';

PRINT '---> Dropping a scalar-valued function if exists: silver.fn_states_fullnames';
IF OBJECT_ID(N'silver.fn_states_fullnames', N'FN') IS NOT NULL
DROP FUNCTION silver.fn_states_fullnames;

PRINT '---> Creating a scalar-valued function: silver.fn_states_fullnames';
GO

CREATE FUNCTION silver.fn_states_fullnames (@StateCode NVARCHAR(50))
RETURNS NVARCHAR(100)
AS
BEGIN
DECLARE @Statefullname NVARCHAR(100);
SET @StateCode = UPPER(TRIM(@StateCode));
SET @Statefullname = CASE @StateCode
    WHEN 'PE' THEN 'Pernambuco'
    WHEN 'PB' THEN 'Paraíba'
    WHEN 'PA' THEN 'Pará'
    WHEN 'RS' THEN 'Rio Grande do Sul'
    WHEN 'AC' THEN 'Acre'
    WHEN 'BA' THEN 'Bahia'
    WHEN 'SP' THEN 'São Paulo'
    WHEN 'SC' THEN 'Santa Catarina'
    WHEN 'SE' THEN 'Sergipe'
    WHEN 'MA' THEN 'Maranhão'
    WHEN 'TO' THEN 'Tocantins'
    WHEN 'RO' THEN 'Rondônia'
    WHEN 'DF' THEN 'Distrito Federal'
    WHEN 'MT' THEN 'Mato Grosso'
    WHEN 'PR' THEN 'Paraná'
    WHEN 'CE' THEN 'Ceará'
    WHEN 'AL' THEN 'Alagoas'
    WHEN 'RR' THEN 'Roraima'
    WHEN 'MG' THEN 'Minas Gerais'
    WHEN 'MS' THEN 'Mato Grosso do Sul'
    WHEN 'GO' THEN 'Goiás'
    WHEN 'RN' THEN 'Rio Grande do Norte'
    WHEN 'AP' THEN 'Amapá'
    WHEN 'RJ' THEN 'Rio de Janeiro'
    WHEN 'ES' THEN 'Espírito Santo'
    WHEN 'AM' THEN 'Amazonas'
    WHEN 'PI' THEN 'Piauí'
    ELSE 'N/A'
END;
RETURN @Statefullname;
END;
GO

PRINT '==============================================================================';
