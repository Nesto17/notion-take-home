-- Query 1
-- How much money are we earning — what was our revenue for each month in 2018, for team vs personal plans?

WITH monthly_revenue AS (
  SELECT 
      strftime('%m', i.period_start) AS month,
      s.plan_id,
      SUM(i.amount_due) as total
  FROM invoices i 
  INNER JOIN subscriptions s 
      ON i.subscription_id = s.id
  WHERE i.period_start >= '2018-01-01' AND i.period_start < '2019-01-01'
  GROUP BY 1, 2
)

SELECT 
	month,
    SUM(COALESCE(CASE WHEN plan_id = 'personal' THEN total END, 0)) AS personal_plan_revenue,
    SUM(COALESCE(CASE WHEN plan_id = 'team' THEN total END, 0)) AS team_plan_revenue
FROM monthly_revenue
GROUP BY 1
ORDER BY 1 ASC;
