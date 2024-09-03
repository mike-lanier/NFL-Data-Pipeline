{{
    config(
        materialized='incremental'
    )
}}


with tmp as (
    select
    team_json->'team'->>'id' as team_id
    , team_json->'team'->>'location' as loc_area
    , team_json->'team'->>'name' as mascot
    , team_json->'team'->>'displayName' as team_desc_full
    from
    landing.teams
)

select distinct
team_id::int
, loc_area
, mascot
, team_desc_full
from
tmp

{% if is_incremental() %}

where team_id::int not in (select team_id from {{ this }})

{% endif %}