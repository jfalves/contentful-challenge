{{
   config(
      materialized="table",
      alias="user_event",
      schema="historical"
    )
}}

SELECT (substring("event".json_content->>'id',0,33))::uuid as id
     , ("event".json_content->>'event_type')::varchar as event_type
     , ("event".json_content->>'username')::varchar as username
     , ("event".json_content->>'user_email')::varchar as user_email
     , ("event".json_content->>'user_type')::varchar as user_type
     , ("event".json_content->>'organization_name')::varchar as organization_name
     , ("event".json_content->>'plan_name')::varchar as plan_name
     , ("event".json_content->>'received_at')::timestamp as received_at
  FROM staging."event"
