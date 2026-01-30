WITH address_val AS (
  SELECT FROM_HEX(SUBSTRING('{{wallet address:}}', 3)) AS addr
),

raw_interactions AS (
  SELECT 
    "to" AS counterparty, 
    gas_used * gas_price AS gas_spent, 
    block_time 
  FROM ethereum.transactions, address_val 
  WHERE "from" = addr

  UNION ALL

  SELECT 
    "from" AS counterparty, 
    0 AS gas_spent,
    block_time 
  FROM ethereum.transactions, address_val 
  WHERE "to" = addr
),

tx_stats AS (
  SELECT
    counterparty,
    COUNT(*) AS tx_count,
    SUM(gas_spent) / 1e18 AS total_gas_eth,
    MIN(block_time) AS first_interaction,
    MAX(block_time) AS last_interaction
  FROM raw_interactions
  WHERE counterparty IS NOT NULL
  GROUP BY 1
)

SELECT
  LOWER(
    CONCAT(
      '0x',
      SUBSTRING(TO_HEX(counterparty), 1, 3),
      '...',
      SUBSTRING(TO_HEX(counterparty), -3)
    )
  ) AS counterparty_short,
  tx_count,
  ROUND(total_gas_eth, 4) AS total_gas_spent_eth,
  first_interaction,
  last_interaction
FROM tx_stats
ORDER BY tx_count DESC
LIMIT 15;
