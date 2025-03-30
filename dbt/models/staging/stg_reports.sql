with source as (
    select *,
    ROW_NUMBER() OVER (PARTITION BY symbol, fiscalDateEnding) AS rn 
    from 
    {{ source('staging', 'reports_ext') }}
)

select
    UPPER(symbol) as symbol,
    {{ dbt.safe_cast("fiscalDateEnding", api.Column.translate_type("date")) }} as reportDate,
    {{ dbt.safe_cast("commonStockSharesOutstanding", api.Column.translate_type("integer")) }} as commonStockSharesOutstanding,
    {{ dbt.safe_cast("totalAssets", api.Column.translate_type("integer")) }} as totalAssets,
    {{ dbt.safe_cast("totalLiabilities", api.Column.translate_type("integer")) }} as totalLiabilities,
    {{ dbt.safe_cast("cashAndCashEquivalentsAtCarryingValue", api.Column.translate_type("integer")) }} as cashAndCashEquivalentsAtCarryingValue,
    {{ dbt.safe_cast("retainedEarnings", api.Column.translate_type("integer")) }} as retainedEarnings,
    {{ dbt.safe_cast("longTermDebt", api.Column.translate_type("integer")) }} as longTermDebt,
    {{ dbt.safe_cast("goodwill", api.Column.translate_type("integer")) }} as goodwill
    
from source
WHERE rn = 1
