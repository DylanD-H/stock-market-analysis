with source as (
    select *
    from {{ source('staging', 'priceData_ext') }}
)

select
    upper(symbol) as symbol,
    {{ dbt.safe_cast("date", api.Column.translate_type("date")) }} as date,
    {{ dbt.safe_cast("open", api.Column.translate_type("float")) }} as open,
    {{ dbt.safe_cast("high", api.Column.translate_type("float")) }} as high,
    {{ dbt.safe_cast("low", api.Column.translate_type("float")) }} as low,
    {{ dbt.safe_cast("close", api.Column.translate_type("float")) }} as close,
    {{ dbt.safe_cast("adjusted_close", api.Column.translate_type("float")) }} as adjusted_close,
    {{ dbt.safe_cast("volume", api.Column.translate_type("integer")) }} as volume,
    {{ dbt.safe_cast("dividend_amount", api.Column.translate_type("numeric")) }} as dividends,
    {{ dbt.safe_cast("split_coefficient", api.Column.translate_type("numeric")) }} as split_coefficient,
    '{{ var("file_name","unknown_file" )}}' AS load_file

from source
where 
    date IS NOT NULL
    AND symbol IS NOT NULL
    AND close IS NOT NULL
    AND open IS NOT NULL
    AND close >= 0 
    AND open >= 0
    AND high >= GREATEST(open,close)
    AND low <= LEAST(open,close)
