-- =====================================================
-- 🏠 AIRBNB NYC 2019 - BUSINESS INSIGHTS QUERIES
-- =====================================================
-- Database: airbnb_nyc_cleaned.db
-- Table: airbnb_listings

-- 1. 📊 POPULAR ROOM TYPES ANALYSIS
SELECT 
    room_type,
    COUNT(*) as total_listings,
    ROUND(AVG(price), 2) as avg_price,
    ROUND(SUM(price), 0) as total_revenue_potential,
    ROUND(AVG(number_of_reviews), 1) as avg_reviews,
    ROUND(AVG(availability_365), 0) as avg_availability,
    ROUND((COUNT(*) * 1.0 / (SELECT COUNT(*) FROM airbnb_listings)) * 100, 1) as market_share_pct
FROM airbnb_listings 
GROUP BY room_type 
ORDER BY total_listings DESC;

-- 2. 🏙️ HIGH-REVENUE NEIGHBORHOODS (Top 15)
SELECT 
    neighbourhood_group,
    neighbourhood,
    COUNT(*) as listing_count,
    ROUND(AVG(price), 0) as avg_price,
    ROUND(MEDIAN(price), 0) as median_price,
    ROUND(SUM(price), 0) as total_revenue_potential,
    ROUND(AVG(number_of_reviews), 1) as avg_reviews,
    ROUND(AVG(availability_365), 0) as avg_availability_days
FROM airbnb_listings 
GROUP BY neighbourhood_group, neighbourhood
HAVING listing_count >= 50  -- Minimum viable sample
ORDER BY total_revenue_potential DESC 
LIMIT 15;

-- 3. 💰 TOP 10 MOST PROFITABLE AREAS (Revenue per listing)
SELECT 
    neighbourhood_group,
    neighbourhood,
    COUNT(*) as listings,
    ROUND(AVG(price) * 0.7, 0) as estimated_monthly_revenue,  -- 70% occupancy assumption
    ROUND(AVG(price), 0) as avg_price,
    ROUND(AVG(number_of_reviews), 1) as demand_indicator
FROM airbnb_listings 
GROUP BY neighbourhood_group, neighbourhood
ORDER BY estimated_monthly_revenue DESC 
LIMIT 10;

-- 4. 📈 BOOKING PATTERNS BY ROOM TYPE
SELECT 
    room_type,
    AVG(number_of_reviews) as avg_reviews,
    AVG(reviews_per_month) as avg_reviews_per_month,
    AVG(availability_365) as avg_availability,
    CASE 
        WHEN AVG(availability_365) > 200 THEN 'High Availability'
        WHEN AVG(availability_365) > 100 THEN 'Medium Availability'
        ELSE 'Low Availability'
    END as availability_category,
    ROUND(AVG(price), 0) as avg_price
FROM airbnb_listings 
GROUP BY room_type 
ORDER BY avg_reviews_per_month DESC;

-- 5. 🔥 TOP PERFORMING HOSTS (Business Opportunities)
SELECT 
    host_name,
    COUNT(DISTINCT id) as total_listings,
    ROUND(AVG(price), 0) as avg_listing_price,
    ROUND(SUM(price), 0) as total_revenue_potential,
    AVG(number_of_reviews) as avg_reviews_per_listing,
    MAX(calculated_host_listings_count) as max_listings_managed
FROM airbnb_listings 
GROUP BY host_name
HAVING total_listings >= 3
ORDER BY total_revenue_potential DESC 
LIMIT 20;

-- 6. 🎯 HIGH DEMAND vs LOW SUPPLY AREAS
WITH demand_metrics AS (
    SELECT 
        neighbourhood_group,
        neighbourhood,
        COUNT(*) as listing_count,
        AVG(number_of_reviews) as demand_score,
        AVG(price) as avg_price,
        AVG(availability_365) as supply_score
    FROM airbnb_listings 
    GROUP BY neighbourhood_group, neighbourhood
)
SELECT 
    neighbourhood_group,
    neighbourhood,
    listing_count,
    ROUND(demand_score, 1) as demand_score,
    ROUND(supply_score, 0) as supply_score,
    CASE 
        WHEN demand_score > 50 AND supply_score < 150 THEN 'HIGH OPPORTUNITY'
        WHEN demand_score > 30 THEN 'MEDIUM OPPORTUNITY'
        ELSE 'LOW OPPORTUNITY'
    END as investment_opportunity
FROM demand_metrics 
ORDER BY demand_score DESC, supply_score ASC 
LIMIT 20;

-- 7. 💎 PREMIUM vs BUDGET SEGMENTS
SELECT 
    CASE 
        WHEN price >= 200 THEN 'Premium'
        WHEN price >= 100 THEN 'Mid-Range'
        ELSE 'Budget'
    END as price_segment,
    COUNT(*) as listing_count,
    ROUND(AVG(number_of_reviews), 1) as avg_reviews,
    ROUND(AVG(availability_365), 0) as avg_availability,
    ROUND(AVG(price), 0) as avg_price,
    ROUND((COUNT(*) * 1.0 / (SELECT COUNT(*) FROM airbnb_listings)) * 100, 1) as market_share
FROM airbnb_listings 
GROUP BY price_segment
ORDER BY avg_price DESC;

-- 8. 🕒 SEASONALITY & AVAILABILITY PATTERNS
SELECT 
    CASE 
        WHEN availability_365 >= 300 THEN 'Year-Round'
        WHEN availability_365 >= 150 THEN 'Seasonal'
        ELSE 'Weekend/Short-term'
    END as availability_pattern,
    COUNT(*) as listing_count,
    ROUND(AVG(price), 0) as avg_price,
    ROUND(AVG(number_of_reviews), 1) as demand_indicator,
    ROUND(AVG(minimum_nights), 1) as avg_min_nights
FROM airbnb_listings 
GROUP BY availability_pattern
ORDER BY listing_count DESC;

-- 9. 📍 MANHATTAN vs BROOKLYN REVENUE COMPARISON
SELECT 
    neighbourhood_group,
    COUNT(*) as total_listings,
    ROUND(AVG(price), 0) as avg_price,
    ROUND(SUM(price), 0) as total_revenue_potential,
    ROUND(AVG(number_of_reviews), 1) as avg_reviews,
    ROUND(AVG(availability_365), 0) as avg_availability,
    room_type,
    COUNT(*) as room_type_count
FROM airbnb_listings 
WHERE neighbourhood_group IN ('Manhattan', 'Brooklyn')
GROUP BY neighbourhood_group, room_type
ORDER BY total_revenue_potential DESC;

-- 10. 🚀 GROWTH OPPORTUNITIES (Underserved High-Demand Areas)
WITH market_analysis AS (
    SELECT 
        neighbourhood_group,
        AVG(number_of_reviews) as demand,
        AVG(price) as avg_price,
        COUNT(*) as supply,
        AVG(availability_365) as availability
    FROM airbnb_listings 
    GROUP BY neighbourhood_group
)
SELECT 
    neighbourhood_group,
    ROUND(demand, 1) as demand_score,
    ROUND(avg_price, 0) as avg_price,
    supply as listing_supply,
    ROUND(availability, 0) as avg_availability,
    CASE 
        WHEN demand > 30 AND supply < 5000 THEN 'HIGH GROWTH POTENTIAL'
        WHEN demand > 20 THEN 'MODERATE GROWTH'
        ELSE 'SATURATED MARKET'
    END as recommendation
FROM market_analysis 
ORDER BY demand DESC;

-- 11. 🏆 TOP 20 NEIGHBORHOODS FOR NEW LISTINGS
SELECT 
    neighbourhood_group,
    neighbourhood,
    COUNT(*) as current_listings,
    ROUND(AVG(price), 0) as avg_price,
    ROUND(AVG(number_of_reviews), 1) as demand_score,
    ROUND(AVG(availability_365), 0) as competition_level,
    ROUND((AVG(number_of_reviews) / NULLIF(AVG(availability_365), 0)) * 100, 1) as demand_to_supply_ratio
FROM airbnb_listings 
GROUP BY neighbourhood_group, neighbourhood
HAVING current_listings >= 20
ORDER BY demand_to_supply_ratio DESC 
LIMIT 20;

-- 12. 📊 EXECUTIVE SUMMARY DASHBOARD
SELECT 
    'TOTAL MARKET' as metric_category,
    COUNT(*)::text || ' listings' as metric_value,
    ROUND(AVG(price), 0)::text || '$ avg price' as key_insight
FROM airbnb_listings

UNION ALL

SELECT 
    neighbourhood_group as metric_category,
    COUNT(*)::text || ' listings' as metric_value,
    ROUND(AVG(price), 0)::text || '$ avg' as key_insight
FROM airbnb_listings 
GROUP BY neighbourhood_group

UNION ALL

SELECT 
    room_type as metric_category,
    COUNT(*)::text || ' (' || ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM airbnb_listings)), 1) || '%)' as metric_value,
    ROUND(AVG(price), 0)::text || '$ avg' as key_insight
FROM airbnb_listings 
GROUP BY room_type

ORDER BY metric_category;