WITH latest_reports AS (
    SELECT
        qr.symbol,
        qr.market_cap,
        qr.reportDate,
        pd.date AS price_date
    FROM {{ ref('fct_quarterlyReports') }} qr
    JOIN {{ ref('fct_priceData') }} pd
        ON pd.symbol = qr.symbol
    WHERE qr.reportDate = (
        SELECT MAX(sub_qr.reportDate)
        FROM {{ ref('fct_quarterlyReports') }} sub_qr
        WHERE sub_qr.symbol = qr.symbol AND sub_qr.reportDate <= pd.date
    )
),

sector_data AS (
    SELECT
        pd.date,
        si.sector,
        pd.symbol,
        pd.prev_close,
        pd.close,
        pd.daily_price_change,
        lr.market_cap
    FROM {{ ref('fct_priceData') }} pd
    JOIN {{ ref('dim_stockInfo') }} si
        ON pd.symbol = si.symbol
    LEFT JOIN latest_reports lr
        ON pd.symbol = lr.symbol AND pd.date = lr.price_date
    WHERE pd.prev_close IS NOT NULL
),

sector_weighted_avg_close AS (
    SELECT
        date,
        sector,
        count(1) AS totalCount,
        SUM(market_cap) AS totalSectorMarketCap,
        SUM(close * market_cap) / NULLIF(SUM(market_cap), 0) AS weighted_avg_close
    FROM sector_data
    WHERE market_cap IS NOT NULL
    GROUP BY date, sector
),

sector_performance AS (
    SELECT
        date,
        sector,
        totalCount,
        totalSectorMarketCap,
        weighted_avg_close,
        LAG(weighted_avg_close) OVER (PARTITION BY sector ORDER BY date) AS prev_weighted_avg_close,
        CASE 
        WHEN (weighted_avg_close > 1 OR weighted_avg_close < -1) AND (LAG(weighted_avg_close) OVER (PARTITION BY sector ORDER BY date) > 1 OR LAG(weighted_avg_close) OVER (PARTITION BY sector ORDER BY date) < -1)
        THEN
            ((weighted_avg_close - LAG(weighted_avg_close) OVER (PARTITION BY sector ORDER BY date)) / ABS(LAG(weighted_avg_close) OVER (PARTITION BY sector ORDER BY date)))*100
        ELSE 0
        END AS sector_performance 
    FROM sector_weighted_avg_close
    WHERE totalCount > 20
)

SELECT *
FROM sector_performance
