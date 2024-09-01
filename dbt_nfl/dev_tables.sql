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