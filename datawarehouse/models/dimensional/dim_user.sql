{{
   config(
      materialized="table",
      alias="dim_user",
      schema="dimensional"
    )
}}

SELECT DISTINCT * FROM {{ ref("user_snapshot") }}
