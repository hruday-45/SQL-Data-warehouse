/*******************************************************************************
-- Function Name: silver.fn_CleanSilverEncoding
-- Description:   Standardizes text data by removing accents, special symbols, 
--                and common encoding artifacts. specifically tuned for 
--                Portuguese (Brazilian) localized strings in the Olist dataset.
--
-- Transformations:
--   1. Converts text to Lowercase and trims white space.
--   2. Replaces noise symbols (*, ´, ., º, etc.) with empty spaces.
--   3. Normalizes encoding artifacts (e.g., '4o centenario' to 'centenario').
--   4. Removes Portuguese accents (e.g., 'ã' -> 'a', 'ç' -> 'c').
--   5. Deduplicates internal spaces.
--
-- Usage: SELECT silver.fn_CleanSilverEncoding(customer_city) FROM bronze.table;
-- Layer:  Silver (Data Cleaning)
-- Notice: Run this fuction before executing procedure_load_silver.sql
*******************************************************************************/

DROP FUNCTION IF EXISTS silver.fn_CleanSilverEncoding;
GO

CREATE OR ALTER FUNCTION silver.fn_CleanSilverEncoding (@InputText NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
AS
BEGIN
    IF @InputText IS NULL RETURN NULL;

    DECLARE @Result NVARCHAR(MAX) = LOWER(TRIM(@InputText));

    -- Step 1: Removing common noise symbols you identified (*, ´, ., º, etc.)
    -- We replace them with a space
    SET @Result = TRANSLATE(@Result, N'*´.⁰º…', '      ');

    -- Step 2: Handling specific Portuguese encoding artifacts
    -- Sometimes 'º' or 'ª' are encoded differently in raw CSVs
    SET @Result = REPLACE(@Result, N'4 centenario', 'centenario');
    SET @Result = REPLACE(@Result, N'4o centenario', 'centenario');

    -- Step 3: Removing Accents (The "Abadiânia" fix)
    SET @Result = TRANSLATE(@Result, 
        N'áéíóúàèìòùâêîôûãõäëïöüç', 
        N'aeiouaeiouaeiouaoaeiouc');

    -- Step 4: Cleaning up double spaces created by the translations
    WHILE CHARINDEX('  ', @Result) > 0
        SET @Result = REPLACE(@Result, '  ', ' ');

    RETURN TRIM(@Result);
END;
GO
