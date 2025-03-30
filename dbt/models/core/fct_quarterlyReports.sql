{{
    config
    (
        materialized='incremental',
        unique_key=['symbol', 'reportDate'],
        incremental_strategy='merge'
    )
}}




WITH close_prices AS (
    SELECT
        cp.symbol,
        cp.date,
        cp.close,
        rp.reportDate,
        ROW_NUMBER() OVER (
            PARTITION BY cp.symbol, rp.reportDate
            ORDER BY ABS(DATE_DIFF(DATE(rp.reportDate), DATE(cp.date), DAY)) ASC
        ) AS row_num
    FROM {{ ref('fct_priceData') }} cp
    JOIN {{ ref('stg_reports') }} rp
        ON cp.symbol = rp.symbol
    WHERE DATE(cp.date) BETWEEN DATE_SUB(DATE(rp.reportDate), INTERVAL 2 DAY) AND DATE_ADD(DATE(rp.reportDate), INTERVAL 2 DAY)
),


reports_with_marketCap as(
    SELECT
        rp.symbol,
        rp.reportDate,
        rp.commonStockSharesOutstanding,
        cp.close,
        rp.commonStockSharesOutstanding * cp.close AS market_cap
  FROM {{ ref('stg_reports') }} rp
  LEFT JOIN close_prices cp
  ON rp.symbol = cp.symbol
  AND DATE(rp.reportDate) = DATE(cp.reportDate)
  AND cp.row_num = 1
)

SELECT * FROM reports_with_marketCap
WHERE commonStockSharesOutstanding > 0
AND market_cap < 3.5e12
AND symbol IS NOT NULL
AND close IS NOT NULL