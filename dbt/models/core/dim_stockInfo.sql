
WITH nyseInfo AS (
    SELECT 
        REPLACE(REPLACE(REPLACE(Symbol, '/', '-'), '^', '-P-'), ' ', '') AS Symbol, 
        Name, 
        Market_Cap, 
        Country, 
        IPO_Year, 
        COALESCE(Sector, 'Other') AS Sector, 
        Industry,
        "NYSE" AS Exchange
    FROM {{ source('core', 'nyseInfo_ext') }}
),

nasdaqInfo AS (
    SELECT 
        REPLACE(REPLACE(REPLACE(Symbol, '/', '-'), '^', '-P-'), ' ', '') AS Symbol, 
        Name, 
        Market_Cap, 
        Country, 
        IPO_Year, 
        COALESCE(Sector, 'Other') AS Sector, 
        Industry,
        "NASDAQ" AS Exchange
    FROM {{ source('core', 'nasdaqInfo_ext') }}
)
SELECT 
    UPPER(Symbol) AS Symbol, 
    Name, 
    Market_Cap, 
    Country, 
    IPO_Year, 
    Sector, 
    Industry,
    Exchange
FROM nyseInfo
UNION ALL
SELECT 
    UPPER(Symbol) AS Symbol, 
    Name, 
    Market_Cap, 
    Country, 
    IPO_Year, 
    Sector, 
    Industry,
    Exchange
FROM nasdaqInfo

