
with extInfo as (

    select
        symbol,
        industry,
        sector,
        fulltimeemployees as fullTimeEmployees

    from {{ source('core', 'extended_stock_info_ext') }}

)
select 
    b.symbol,
    b.name as companyName,
    b.exchange,
    b.ipodate,
    e.industry,
    e.sector,
    e.fullTimeEmployees

from {{ source('core', 'basic_stock_info_ext') }} b
inner join extInfo e on b.symbol = e.symbol
where LOWER(b.assettype) = 'stock' 
    and b.name is not null




