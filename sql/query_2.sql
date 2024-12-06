-- Query 2
-- How many customers are we losing — what was our customer churn rate for each month in 2018, for team vs. personal plans?

WITH monthly_churns AS (
  SELECT 
  strftime('%m', canceled_at) AS churned_month,
  plan_id,
  COUNT(id) AS churned_customers
  FROM subscriptions
  WHERE canceled_at != 'None' AND canceled_at >= '2018-01-01' AND canceled_at < '2019-01-01'
  GROUP BY 1, 2
), 
monthly_starting_active_accounts AS (
  SELECT 
    strftime('%m', i.period_end) AS start_month,
    s.plan_id,
  	COUNT(i.id) AS active_customers
  FROM invoices i
  INNER JOIN subscriptions s
  	ON i.subscription_id = s.id
  WHERE i.period_end >= '2018-01-01' AND i.period_end < '2019-01-01'
  GROUP BY 1, 2
),
monthly_combined_churns AS (
  sELECT 
    mc.churned_month AS month,
    mc.plan_id,
    mc.churned_customers,
    msaa.active_customers,
    COALESCE(ROUND(CAST(mc.churned_customers AS FLOAT) / msaa.active_customers, 4), 0) AS churn_rate
  FROM monthly_churns mc
  LEFT JOIN monthly_starting_active_accounts msaa
      ON mc.churned_month = msaa.start_month AND 
         mc.plan_id = msaa.plan_id
  ORDER BY 1, 2
)

SELECT 
	month,
    SUM(CASE WHEN plan_id = 'personal' THEN churn_rate END) AS personal_plan_churn_rate,
    SUM(CASE WHEN plan_id = 'team' THEN churn_rate END) AS team_plan_churn_rate
FROM monthly_combined_churns
GROUP BY 1;