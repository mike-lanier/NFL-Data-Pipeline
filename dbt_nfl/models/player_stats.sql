{{
    config(
        materialized='incremental'
    )
}}


with tmp as (
    select
    
    , split_part(filename, '.json', 1) as game_id
    , etl_ts
    from
    landing.plays
)

select

, game_id::int
, current_timestamp::timestamp as elt_ts
from
tmp

{% if is_incremental() %}

where etl_ts >= (select max(elt_ts) from {{ this }})

{% endif %}