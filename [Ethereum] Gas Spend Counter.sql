WITH daily_gas AS (
  SELECT
    DATE_TRUNC('day', block_time) AS day,
    SUM(gas_used * gas_price) / 1e18 AS daily_gas_eth
  FROM ethereum.transactions
  WHERE "from" = FROM_HEX(SUBSTRING('{{wallet address:}}', 3))
  GROUP BY 1
)

SELECT
  day,
  CAST(daily_gas_eth AS DECIMAL(10,5)) AS daily_gas_eth,
  CAST(SUM(daily_gas_eth) OVER (ORDER BY day) AS DECIMAL(10,5)) AS cumulative_gas_eth
FROM daily_gas
ORDER BY day;
