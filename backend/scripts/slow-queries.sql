-- گزارش کوئری‌های کند بر اساس pg_stat_statements
-- اجرا: docker exec -i ma-warehouse-db psql -U postgres -d ma_warehouse < scripts/slow-queries.sql

SELECT
    round(total_exec_time::numeric / 1000, 1)        AS total_ms,
    calls,
    round(mean_exec_time::numeric, 1)                AS mean_ms,
    round(max_exec_time::numeric, 1)                 AS max_ms,
    left(query, 140)                                 AS query
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 20;
