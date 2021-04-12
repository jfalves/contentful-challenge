{{
   config(
      materialized="table",
      alias="dim_organization",
      schema="dimensional"
    )
}}

-- Simulates SCD Type 1

SELECT substring(json_content->>'organization_key',0,33)::uuid as organization_key
     , (json_content->>'organization_name')::varchar as organization_name
     , (json_content->>'created_at')::timestamp as created_at
  FROM staging.organization
