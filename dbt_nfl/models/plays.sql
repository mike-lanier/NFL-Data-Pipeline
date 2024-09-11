{{
    config(
        materialized='incremental'
    )
}}


with tmp as (
    select
    plays_json->>'id' as play_id
    , plays_json->>'sequenceNumber' as seq_num
    , plays_json->>'scoringPlay' as scoring_play
    , plays_json->'period'->>'number' as quarter_id
    , plays_json->'clock'->>'displayValue' as start_clock
    , plays_json->'start'->'team'->>'id' as poss_team_id
    , plays_json->'start'->>'down' as down
    , plays_json->'start'->>'distance' as distance
    , plays_json->'start'->>'yardLine' as yardline
    , plays_json->'type'->>'id' as playtype_id
    , plays_json->>'text' as play_detail
    , plays_json->>'statYardage' as yards_gained
    , split_part(filename, '.json', 1) as game_id
    , etl_ts
    from
    landing.plays
)

select distinct
play_id::bigint
, seq_num::int
, scoring_play
, quarter_id
, start_clock
, poss_team_id::int
, down
, distance
, yardLine
, playtype_id::int
, play_detail
, yards_gained
, game_id::int
, current_timestamp::timestamp as elt_ts
from
tmp

{% if is_incremental() %}

where etl_ts >= (select max(elt_ts) from {{ this }})

{% endif %}