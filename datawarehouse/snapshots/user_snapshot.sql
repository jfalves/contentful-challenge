{% snapshot user_snapshot %}

{{
    config(
      target_database='datawarehouse',
      target_schema='snapshots',
      unique_key="id",
      strategy='timestamp',
      updated_at='received_at'
    )
}}

SELECT * FROM {{ ref('user_event') }} WHERE received_at::date = '{{ var("received_at") }}'

{% endsnapshot %}
