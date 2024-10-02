with tmp as (
    select
    ps.player_name
    , t.team_id
    , ps.position
    , ps.age
    , ps.games_played
    , ps.games_started
    , ps.pass_comp
    , ps.pass_att
    , ps.pass_yds
    , ps.pass_tds
    , ps.pass_int
    , ps.rush_att
    , ps.rush_yds
    , ps.rush_yds_per_att
    , ps.rush_tds
    , ps.rec_tgt
    , ps.receptions
    , ps.rec_yds
    , ps.rec_yds_per_catch
    , ps.rec_tds
    , ps.fumbles
    , ps.fumbles_lost
    , ps.total_tds
    , ps.fantasy_ppr
    from
    landing.player_stats ps
    join
    landing.pro_fb_ref_team_match t
    on
    ps.team = t.pfr_team
    where
    ps.player_rank != 'Rk'
)

select
player_name
, team_id::int
, position
, age::int
, games_played::int
, games_started::int
, pass_comp::int
, pass_att::int
, pass_yds::int
, pass_tds::int
, pass_int::int
, rush_att::int
, rush_yds::int
, rush_yds_per_att::real
, rush_tds::int
, rec_tgt::int
, receptions::int
, rec_yds::int
, rec_yds_per_catch::real
, rec_tds::int
, fumbles::int
, fumbles_lost::int
, total_tds::int
, fantasy_ppr::real
, current_timestamp::timestamp as elt_ts
from
tmp