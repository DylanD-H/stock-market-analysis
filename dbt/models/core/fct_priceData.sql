{{
    config
    (
        materialized='incremental',
        unique_key=['symbol', 'date'],
        incremental_strategy='merge',
        partition_by={
            'field': 'symbol',
            'data_type': 'STRING'
        }
    )
}}

with price_data as (
    select * from {{ ref('stg_priceData') }}
),

latest_close as (
    {% if is_incremental() %}
    select
        symbol,
        close as prev_close
    from {{ this }}
    qualify row_number() over (partition by symbol order by date desc) = 1
    {% else %}
    select
        CAST(NULL AS STRING) AS symbol,
        CAST(NULL AS FLOAT64) AS prev_close
    {% endif %}
)

select
    p.symbol,
    p.date,
    p.open,
    p.high,
    p.low,
    coalesce(LAG(p.close) OVER (PARTITION BY p.symbol ORDER BY p.date), lc.prev_close) as prev_close,
    p.close,
    p.adjusted_close,
    p.volume,
    p.dividends,
    p.split_coefficient,
    (p.close - p.open) as intraday_price_change,
    p.load_file
from price_data p
left join latest_close lc on p.symbol = lc.symbol