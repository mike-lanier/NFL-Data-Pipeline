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
, case
    when team_id::int in (2, 15, 17, 20) then 1
    when team_id::int in (4, 5, 23, 33) then 2
    when team_id::int in (10, 11, 30, 34) then 3
    when team_id::int in (7, 12, 13, 24) then 4
    when team_id::int in (6, 19, 21, 28) then 5
    when team_id::int in (3, 8, 9, 16) then 6
    when team_id::int in (1, 18, 27, 29) then 7
    when team_id::int in (22, 14, 25, 26) then 8
    else null
  end as division_id
, loc_area
, mascot
, team_desc_full
from
tmp

{% if is_incremental() %}

where team_id::int not in (select team_id from {{ this }})

{% endif %}