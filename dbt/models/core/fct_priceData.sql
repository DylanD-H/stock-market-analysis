{{
    config
    (
        materialized='incremental',
        unique_key=['symbol', 'date'],
        incremental_strategy='merge'
    )
}}

with price_data as (
    select *,
    LAG(close) OVER (PARTITION BY symbol ORDER BY date) AS prev_close,
 from {{ ref('stg_priceData') }}
)

select
    symbol,
    date,
    open,
    high,
    low,
    prev_close,
    close,
    adjusted_close,
    volume,
    dividends,
    split_coefficient,
    (close - open) as intraday_price_change,
    (close - prev_close) as daily_price_change,
    ((close - prev_close)/prev_close)*100 as daily_price_change_percentage,
    load_file
from price_data
