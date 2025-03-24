with 

source as (

    select * from {{ source('staging', 'historical_reports_ext') }}

),

renamed as (

    select
        symbol,
        fiscaldateending,
        commonstocksharesoutstanding,
        totalassets,
        totalliabilities,
        cashandcashequivalentsatcarryingvalue,
        retainedearnings,
        longtermdebt,
        goodwill

    from source

)

select * from renamed
