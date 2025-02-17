{{
    config(
        materialized='incremental'
    )
}}

with tmp as (
    select
    split_part(filename, '.json', 1) as game_id
    , team_json->'team'->>'id' as team_id
    , jsonb_array_elements(team_json->'statistics')->>'label' as stat_name
    , jsonb_array_elements(team_json->'statistics')->>'name' as stat_name_abbrv
    , jsonb_array_elements(team_json->'statistics')->>'displayValue' as stat_value
    from
    landing.teams
)

select
game_id::int
, team_id::int
, max(case when stat_name_abbrv = 'firstDowns' then stat_value::int else null end) as first_downs
, max(case when stat_name_abbrv = 'firstDownsPassing' then stat_value::int else null end) as first_downs_passing
, max(case when stat_name_abbrv = 'firstDownsRushing' then stat_value::int else null end) as first_downs_rushing
, max(case when stat_name_abbrv = 'thirdDownEff' then stat_value else null end) as third_down_eff
, max(case when stat_name_abbrv = 'fourthDownEff' then stat_value else null end) as fourth_down_eff
, max(case when stat_name_abbrv = 'redZoneAttempts' then stat_value else null end) as red_zone_eff
, max(case when stat_name_abbrv = 'totalDrives' then stat_value::int else null end) as total_drives
, max(case when stat_name_abbrv = 'totalOffensivePlays' then stat_value::int else null end) as offensive_plays
, max(case when stat_name_abbrv = 'totalYards' then stat_value::int else null end) as total_yards
, max(case when stat_name_abbrv = 'yardsPerPlay' then stat_value::real else null end) as yards_per_play
, max(case when stat_name_abbrv = 'netPassingYards' then stat_value::int else null end) as net_passing_yards
, max(case when stat_name_abbrv = 'completionAttempts' then stat_value else null end) as completions_attempts
, max(case when stat_name_abbrv = 'yardsPerPass' then stat_value::real else null end) as yards_per_pass
, max(case when stat_name_abbrv = 'rushingYards' then stat_value::int else null end) as rushing_yards
, max(case when stat_name_abbrv = 'rushingAttempts' then stat_value::int else null end) as rushing_attempts
, max(case when stat_name_abbrv = 'yardsPerRushAttempt' then stat_value::real else null end) as yards_per_rush
, max(case when stat_name_abbrv = 'totalPenaltiesYards' then stat_value else null end) as penalties_yards
, max(case when stat_name_abbrv = 'turnovers' then stat_value::int else null end) as turnovers
, max(case when stat_name_abbrv = 'fumblesLost' then stat_value::int else null end) as fumbles_lost
, max(case when stat_name_abbrv = 'sacksYardsLost' then stat_value else null end) as sacks_yards_lost
, max(case when stat_name_abbrv = 'interceptions' then stat_value::int else null end) as interceptions_thrown
, max(case when stat_name_abbrv = 'possessionTime' then stat_value else null end) as possession_time
from
tmp

{% if is_incremental() %}

where game_id::int not in (select game_id from {{ this }})

{% endif %}

group by
game_id
, team_id