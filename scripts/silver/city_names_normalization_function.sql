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

CREATE OR ALTER FUNCTION silver.fn_CleanSilverEncoding
(
    @InputText NVARCHAR(MAX)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    IF @InputText IS NULL RETURN NULL;

    DECLARE @Result NVARCHAR(MAX);

    -- Unicode-safe normalization (critical)
    SET @Result = @InputText COLLATE Latin1_General_100_CI_AS_SC;

    -- Trim + lowercase
    SET @Result = LOWER(LTRIM(RTRIM(@Result)));

    -- Remove hidden / non-printable characters
    SET @Result = REPLACE(@Result, CHAR(160), ' '); -- NBSP
    SET @Result = REPLACE(@Result, CHAR(9),  ' ');  -- tab
    SET @Result = REPLACE(@Result, CHAR(13), ' ');
    SET @Result = REPLACE(@Result, CHAR(10), ' ');

    -- Remove punctuation / noise (but NOT letters or accents)
    SET @Result = TRANSLATE(
        @Result,
        N'!"#$%&''()*+,-./:;<=>?@[\]^_`{|}~',
        REPLICATE(' ', 32)
    );

    -- Collapse multiple spaces
    WHILE CHARINDEX('  ', @Result) > 0
        SET @Result = REPLACE(@Result, '  ', ' ');

    RETURN TRIM(@Result);
END;
GO
