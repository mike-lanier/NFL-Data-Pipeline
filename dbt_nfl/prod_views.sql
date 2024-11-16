create or replace view prod.v_summary_stats as (
select
s.team_id
, s.game_id
, sc.week
, t.mascot as team
, case
    when s.team_id = sc.home_team_id then sc.away_team_id
    else sc.home_team_id
  end as opp_id
, case
    when s.team_id = sc.home_team_id then 'Home'
    else 'Away'
  end as field
, case
    when s.team_id = sc.winning_team_id then 'Win'
    else 'Loss'
  end as game_result
, case
    when s.team_id = sc.home_team_id then sc.home_score
    else sc.away_score
  end as team_points_scored
, case
    when s.team_id = sc.home_team_id then sc.away_score
    else sc.home_score
  end as opp_points_scored
, st.pass_tds
, st.rush_tds
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
join
(
    select
    s.team_id
    , s.game_id
    , sum(case
        when s.playtype_id = 67 then 1
        else 0
    end) as pass_tds
    , sum(case
        when s.playtype_id = 68 then 1
        else 0
    end) as rush_tds
    from
    prod.scoring_plays s
    join
    prod.playtype t
    on
    s.playtype_id = t.playtype_id
    group by
    s.team_id
    , s.game_id
) st
on
s.team_id = st.team_id
and
s.game_id = st.game_id
);


-------------------------------------------------------------------------------------------

base yards = average rush/rec yards per game over last x number of games
matchup adjustment = find a way to rank rush/pass defenses the player is going up against
game script adjustment = another ranking whether the team is a more run/pass heavy team
usage rate = how share of targets/rush attempts does the player get of the team total on average


calculation = (base yards - matchup adjustment + game script adj) * usage rate

-------------------------------------------------------------------------------------------

create or replace view prod.v_prediction_stats as (
with player as (
select
team_id
, player_name
, pass_yds / games_played as pass_yds_per_game
, rush_yds / games_played as rush_yds_per_game
, rec_yds / games_played as rec_yds_per_game
, (rush_yds / games_played) + (rec_yds / games_played) as ttl
, round(rec_tgt::decimal / games_played, 1) as targets_per_game
, case
    when rec_tgt = 0 then 0
    else round(receptions::decimal / rec_tgt, 1)
  end as catch_pct
, rec_tgt as total_targets
, rush_att as total_rush_att
from
prod.player_stats
),

team as (
select
team_id
, sum(case
    when completions_attempts ilike '%-%' then split_part(completions_attempts, '-', 2)
    else split_part(completions_attempts, '/', 2)
  end::int) as pass_att
, sum(rushing_attempts) as rush_att
from
prod.summary_stats
group by
team_id
),

ranks as (
select
t.team_id
, t.mascot
, row_number() over(order by sum(s.rushing_yards) / count(distinct s.game_id)) as rush_def
, row_number() over(order by sum(s.net_passing_yards) / count(distinct s.game_id)) as pass_def
, sum(s.rushing_yards) / count(distinct s.game_id) as avg_rush_yds_allowed_per_game
, sum(s.net_passing_yards) / count(distinct s.game_id) as avg_pass_yds_allowed_per_game
, round(sum(s.pass_tds) / count(distinct s.game_id), 2) as avg_rush_tds_allowed_per_game
, round(sum(s.rush_tds) / count(distinct s.game_id), 2) as avg_pass_tds_allowed_per_game
from
prod.v_summary_stats s
join
prod.teams t
on
s.opp_id = t.team_id
group by
t.team_id
, t.mascot
)

select
p.team_id
, p.player_name
, p.pass_yds_per_game
, p.rush_yds_per_game
, p.targets_per_game
, p.catch_pct
, p.rec_yds_per_game
, round((p.total_rush_att::decimal / t.rush_att), 2) as rush_util
, round((p.total_targets::decimal / t.pass_att), 2) as pass_util
, round(t.pass_att::decimal / (t.pass_att + t.rush_att), 2) as team_pass_pct
, round(t.rush_att::decimal / (t.pass_att + t.rush_att), 2) as team_run_pct
, r.rush_def as team_rush_def_rank
, r.pass_def as team_pass_def_rank
, r.avg_rush_yds_allowed_per_game as avg_rush_yds_alwd
, r.avg_pass_yds_allowed_per_game as avg_pass_yds_alwd
-- , t.rush_att as team_rush_att
-- , t.pass_att as team_pass_att
from player p
join team t
on p.team_id = t.team_id
join ranks r
on t.team_id = r.team_id
order by
p.ttl desc
);