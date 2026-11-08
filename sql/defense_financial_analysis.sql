CREATE VIEW financial_performance_view AS
SELECT
    ticker,
    year,
    revenue,
    operating_income,
    net_income,
    operating_cash_flow,
    capital_expenditures,
    free_cash_flow,
    total_assets,
    total_liabilities,

    ROUND(
        100.0 * (revenue - LAG(revenue) OVER (
            PARTITION BY ticker ORDER BY year
        )) / NULLIF(
            LAG(revenue) OVER (
                PARTITION BY ticker ORDER BY year
            ), 0
        ),
        4
    ) AS revenue_growth_pct,

    ROUND(
        100.0 * operating_income / NULLIF(revenue, 0),
        4
    ) AS operating_margin_pct,

    ROUND(
        100.0 * net_income / NULLIF(revenue, 0),
        4
    ) AS net_margin_pct,

    ROUND(
        100.0 * free_cash_flow / NULLIF(revenue, 0),
        4
    ) AS fcf_margin_pct,

    ROUND(
        100.0 * total_liabilities / NULLIF(total_assets, 0),
        4
    ) AS liabilities_to_assets_pct

FROM financials;

CREATE VIEW peer_rankings_view AS
SELECT
    ticker,
    year,
    revenue_growth_pct,
    operating_margin_pct,
    fcf_margin_pct,

    RANK() OVER (
        PARTITION BY year
        ORDER BY revenue_growth_pct DESC
    ) AS revenue_growth_rank,

    RANK() OVER (
        PARTITION BY year
        ORDER BY operating_margin_pct DESC
    ) AS operating_margin_rank,

    RANK() OVER (
        PARTITION BY year
        ORDER BY fcf_margin_pct DESC
    ) AS fcf_margin_rank

FROM financial_performance_view;
