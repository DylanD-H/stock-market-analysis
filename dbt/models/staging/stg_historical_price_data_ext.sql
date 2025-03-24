with 

source as (

    select * from {{ source('staging', 'historical_price_data_ext') }}

),

renamed as (

    select
        date,
        ticker,
        open,
        high,
        low,
        close,
        volume,
        dividends,
        stock_splits

    from source

)

select * from renamed
