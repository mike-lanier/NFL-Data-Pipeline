create or replace view prod.v_summary_stats as (
    select
s.team_id
, s.game_id
, t.mascot as team
, case
    when s.team_id = sc.home_team_id then 'Home'
    else 'Away'
  end as field
, case
    when s.team_id = sc.winning_team_id then 'Win'
    else 'Loss'
  end as game_result
, case
    when s.team_id = sc.home_team_id then sc.away_team_id
    else sc.home_team_id
  end as opp_id
, sc.matchup_abbrv as matchup
, s.first_downs
, s.first_downs_passing
, s.first_downs_rushing
, s.third_down_eff
, s.fourth_down_eff
, s.red_zone_eff
, s.total_drives
, s.offensive_plays
, s.total_yards
, s.yards_per_play
, s.net_passing_yards
, s.completions_attempts
, s.yards_per_pass
, s.rushing_yards
, s.rushing_attempts
, s.yards_per_rush
, s.penalties_yards
, s.turnovers
, s.fumbles_lost
, s.sacks_yards_lost
, s.interceptions_thrown
, s.possession_time
from
prod.summary_stats s
JOIN
prod.teams t
on
s.team_id = t.team_id
inner join
prod.schedule sc
on
s.game_id = sc.game_id
);


select *
from
prod.v_summary_stats
where
first_downs_rushing > first_downs_passing