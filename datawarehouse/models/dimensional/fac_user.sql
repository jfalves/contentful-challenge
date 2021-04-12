{{
   config(
      materialized="table",
      alias="fac_user",
      schema="dimensional"
    )
}}

select received_at::date as date_calendar
     , sum(
     	 count(case event_type when 'User Created' then 1 end) -
       	 count(case event_type when 'User Deleted' then -1 end)
       ) over (order by received_at::date) as user_count
  from {{ ref("dim_user") }}
 where event_type in ('User Created','User Deleted')
 group by received_at::date
