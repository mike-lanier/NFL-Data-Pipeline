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

create table landing.player_stats (
    id SERIAL PRIMARY KEY,
    stats_json JSONB,
    filename VARCHAR(30),
    etl_ts TIMESTAMP
);
