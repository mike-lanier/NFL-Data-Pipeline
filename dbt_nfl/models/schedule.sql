{{
    config(
        materialized='incremental'
    )
}}

with tmp as (
select
sched_json->>'id' as game_id
, sched_json->'week'->>'number' as week
, sched_json->>'date' as game_date
, sched_json->>'name' as matchup_full
, sched_json->>'shortName' as matchup_abbrv
, jsonb_array_elements(jsonb_array_elements(sched_json->'competitions')->'competitors')->>'id' as team_id
, jsonb_array_elements(jsonb_array_elements(sched_json->'competitions')->'competitors')->>'homeAway' as home_away
, jsonb_array_elements(jsonb_array_elements(sched_json->'competitions')->'competitors')->>'winner' as winner
, jsonb_array_elements(jsonb_array_elements(sched_json->'competitions')->'competitors')->>'score' as score
, jsonb_array_elements(sched_json->'competitions')->'venue'->>'id' as venue_id
, jsonb_array_elements(sched_json->'competitions')->'attendance' as attendance
from
landing.schedule
),

conv as (
select
game_id::int
, week::int
, game_date::timestamp as game_ts
, matchup_full
, matchup_abbrv
, max(case when home_away = 'home' then team_id::int else null end) as home_team_id
, max(case when home_away = 'away' then team_id::int else null end) as away_team_id
, max(case when winner = 'true' then team_id::int else null end) as winning_team_id
, max(case when home_away = 'home' then score::int else null end) as home_score
, max(case when home_away = 'away' then score::int else null end) as away_score
, venue_id::int
, attendance::int
from
tmp
group by
game_id
, week::int
, game_date::timestamp
, matchup_full
, matchup_abbrv
, venue_id::int
, attendance::int
)

select distinct
game_id
, week
, game_ts::date as game_date
, game_ts::time as game_time
, matchup_full
, matchup_abbrv
, away_team_id
, home_team_id
, winning_team_id
, away_score
, home_score
, venue_id
, attendance
from
conv

{% if is_incremental() %}

where game_id not in (select game_id from {{ this }})

{% endif %}