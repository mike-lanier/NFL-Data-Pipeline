create table landing.schedule (
    id SERIAL PRIMARY KEY,
    sched_json JSONB,
    filename VARCHAR(30),
    etl_ts TIMESTAMP
);

create table landing.plays (
    id SERIAL PRIMARY KEY,
    plays_json JSONB,
    filename VARCHAR(30),
    etl_ts TIMESTAMP
);

create table landing.scoring_plays (
    id SERIAL PRIMARY KEY,
    score_json JSONB,
    filename VARCHAR(30),
    etl_ts TIMESTAMP
);

create table landing.teams (
    id SERIAL PRIMARY KEY,
    team_json JSONB,
    filename VARCHAR(30),
    etl_ts TIMESTAMP
);

create table landing.divisions (
    division_id INT,
    division_name VARCHAR(15),
    conference_id INT
);

insert into landing.divisions values
(1, 'AFC East', 1),
(2, 'AFC North', 1),
(3, 'AFC South', 1),
(4, 'AFC West', 1),
(5, 'NFC East', 2),
(6, 'NFC North', 2),
(7, 'NFC South', 2),
(8, 'NFC West', 2);

create table landing.conferences (
    conference_id_id INT,
    conference_name_long VARCHAR(30),
    conference_name_short VARCHAR(10),
    conference_abbrv VARCHAR(3)
);

insert into landing.conferences values
(1, 'American Football Conference', 'American', 'AFC'),
(2, 'National Football Conference', 'National', 'NFC');


create table landing.pro_fb_ref_team_match as (
    select
    team_id
    , case
        when team_id = 1 then 'ATL'
        when team_id = 2 then 'BUF'
        when team_id = 3 then 'CHI'
        when team_id = 4 then 'CIN'
        when team_id = 5 then 'CLE'
        when team_id = 6 then 'DAL'
        when team_id = 7 then 'DEN'
        when team_id = 8 then 'DET'
        when team_id = 9 then 'GNB'
        when team_id = 10 then 'TEN'
        when team_id = 11 then 'IND'
        when team_id = 12 then 'KAN'
        when team_id = 13 then 'LVR'
        when team_id = 14 then 'LAR'
        when team_id = 15 then 'MIA'
        when team_id = 16 then 'MIN'
        when team_id = 17 then 'NWE'
        when team_id = 18 then 'NOR'
        when team_id = 19 then 'NYG'
        when team_id = 20 then 'NYJ'
        when team_id = 21 then 'PHI'
        when team_id = 22 then 'ARI'
        when team_id = 23 then 'PIT'
        when team_id = 24 then 'LAC'
        when team_id = 25 then 'SFO'
        when team_id = 26 then 'SEA'
        when team_id = 27 then 'TAM'
        when team_id = 28 then 'WAS'
        when team_id = 29 then 'CAR'
        when team_id = 30 then 'JAX'
        when team_id = 33 then 'BAL'
        when team_id = 34 then 'HOU'
        else null
      end as pfr_team
    from
    prod.teams t
);
