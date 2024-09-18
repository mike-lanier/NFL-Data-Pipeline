{{
    config(
        materialized='incremental'
    )
}}

with tmp as (
    select
    plays_json->'type'->>'id' as playtype_id
    , plays_json->'type'->>'abbreviation' as playtype_abbrv
    , plays_json->'type'->>'text' as playtype_detail
    from
    landing.plays

    union

    select
    plays_json->'pointAfterAttempt'->>'id' as playtype_id
    , plays_json->'pointAfterAttempt'->>'abbreviation' as playtype_abbrv
    , plays_json->'pointAfterAttempt'->>'text' as playtype_detail
    from
    landing.plays
)

select distinct
playtype_id::int
, playtype_abbrv
, playtype_detail
from
tmp

{% if is_incremental() %}

where playtype_id::int not in (select playtype_id from {{ this }})
and
playtype_id is not null

{% endif %}