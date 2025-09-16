											-- -----------------------------------------
											-- 			End of Third Year Analysis
											-- -----------------------------------------
                                            
# 1. volume growth trended analysis.

-- overall session and order volume, trended by quarter

with growth_summary as (
select year(ws.created_at) as yr, quarter(ws.created_at) as qtr,
		count(distinct ws.website_session_id) as sessions,
        count(distinct o.order_id) as orders
from website_sessions as ws
left join orders as o     
		on ws.website_session_id = o.website_session_id
group by 1, 2
)
select yr, qtr, sessions,
		round((sessions - lag(sessions) over(order by yr asc, qtr asc))/lag(sessions) over(order by yr asc, qtr asc)*100, 1) as QoQ_session_growth,
        orders,
        round((orders - lag(orders) over(order by yr asc, qtr asc))/lag(orders) over(order by yr asc, qtr asc)*100, 1) as QoQ_orders_growth
from growth_summary;

-- session and order volume has seen consistent growth indicating overall healthy business growth over the three year period we have been in market.
-- Traffic volume and sales dropped sharply in Q1 2013, possibly due to post-holiday season decline.
-- Each year, Q4 has been the biggest business-driver since sales are boosted by holiday season spike.
    

# 2. quarterly figures since we launched, for session-to-order conversion rate, revenue per order, and revenue per session:

with growth_summary as (
select year(ws.created_at) as yr, quarter(ws.created_at) as qtr,
        count(distinct o.order_id)/count(distinct ws.website_session_id) as session_to_order_cnv_rt,
       round(sum(o.price_usd)/count(distinct o.order_id), 2) as aov,
        round(sum(o.price_usd)/count(distinct ws.website_session_id), 2) as revenue_per_session
from website_sessions as ws
left join orders as o     
		on ws.website_session_id = o.website_session_id
group by 1, 2
)
select *,  
round((session_to_order_cnv_rt - lag(session_to_order_cnv_rt) over(order by yr asc, qtr asc))/lag(session_to_order_cnv_rt) over(order by yr asc, qtr asc)*100, 2) as QoQ_cnv_rt_growth
from growth_summary;

-- session_to_order_cnv rate has seen more than 1.75x growth since the launch of business, Q1 of 2023 saw highest QoQ growth of nearly 39%.
-- average order value has increased steadily as product portfolio has grown over time, the most significant growth seen in Q1 of 2024 of approx $7.4 which also increased the revenue/session to $4.08 from $3.53 in the previous quarter.

# 3. channel growth: quarterly view of **orders** from Gsearch nonbrand, Bsearch nonbrand, brand search overall, organic search, and direct type-in:

with growth_summary as (
select year(ws.created_at) as yr, quarter(ws.created_at) as qtr,
		count(distinct case when utm_source  = 'gsearch' and utm_campaign = 'nonbrand' then order_id else null end) as g_nonbrand_orders,
        count(distinct case when utm_source  = 'bsearch' and utm_campaign = 'nonbrand' then order_id else null end) as b_nonbrand_orders,
       count(distinct case when utm_campaign = 'brand' then order_id else null end) as brand_overall_orders,
       count(distinct case when utm_source is null and http_referer is not null then order_id else null end) as organic_search_orders,
       count(distinct case when utm_source is null and http_referer is null then order_id else null end) as direct_typein_orders      
from website_sessions as ws
left join orders as o     
		on ws.website_session_id = o.website_session_id
group by 1, 2
)
select yr, qtr,
	g_nonbrand_orders,
	round((g_nonbrand_orders - lag(g_nonbrand_orders) over(order by yr asc, qtr asc))/lag(g_nonbrand_orders) over(order by yr asc, qtr asc)*100, 1) as QoQ_gsearch_nonbrand,
    b_nonbrand_orders,
	round((b_nonbrand_orders - lag(b_nonbrand_orders) over(order by yr asc, qtr asc))/lag(b_nonbrand_orders) over(order by yr asc, qtr asc)*100, 1) as QoQ_bsearch_nonbrand,
    brand_overall_orders,
    round((brand_overall_orders - lag(brand_overall_orders) over(order by yr asc, qtr asc))/lag(brand_overall_orders) over(order by yr asc, qtr asc)*100, 1) as QoQ_brand,
    organic_search_orders,
    round((organic_search_orders - lag(organic_search_orders) over(order by yr asc, qtr asc))/lag(organic_search_orders) over(order by yr asc, qtr asc)*100, 1) as QoQ_organic,
    direct_typein_orders,
    round((direct_typein_orders - lag(direct_typein_orders) over(order by yr asc, qtr asc))/lag(direct_typein_orders) over(order by yr asc, qtr asc)*100, 1) as QoQ_direct
from growth_summary;

-- Gsearch_nonbrand orders show quarterly patterns: order volume grow at faster rate in Q2 and Q4 compared to in Q1 and Q3.
-- Bsearch_nonbrand order volume dropped to all time low of around 180 orders in Q1 of 2013 but has been steadily growing since.
-- After Gsearch nonbrand, Bsearch nonbrand brings in the highest order volume. interestingly in Q2 and Q3 of 2014, orders from organic outnumbered orders from Bsearch nonbrand. 
-- Orders from brand searches, organic traffic and direct type-in traffic has been growing steadily to-date which is indicative of brand-recognition and that the business has been able to establish value amongst customers.
    

# 4. session_to_order conversion rate by channel type:

select year(ws.created_at) as yr, quarter(ws.created_at) as qtr,
		(count(distinct case when utm_source  = 'gsearch' and utm_campaign = 'nonbrand' then order_id else null end) 
			/count(distinct case when utm_source  = 'gsearch' and utm_campaign = 'nonbrand' then ws.website_session_id else null end))*100 as g_nonbrand_cnv_rt,
        (count(distinct case when utm_source  = 'bsearch' and utm_campaign = 'nonbrand' then order_id else null end)
        /count(distinct case when utm_source  = 'bsearch' and utm_campaign = 'nonbrand' then ws.website_session_id else null end))*100  as b_nonbrand_cnv_rt,
       (count(distinct case when utm_campaign = 'brand' then order_id else null end)
       /count(distinct case when utm_campaign = 'brand' then ws.website_session_id else null end))*100 as brand_overall_cnv_rt,
       (count(distinct case when utm_source is null and http_referer is not null then order_id else null end) 
       /count(distinct case when utm_source is null and http_referer is not null then ws.website_session_id else null end))*100 as organic_search_cnv_rt,
       (count(distinct case when utm_source is null and http_referer is null then order_id else null end) 
       /count(distinct case when utm_source is null and http_referer is null then ws.website_session_id else null end))*100 as direct_typein_cnv_rt  
from website_sessions as ws
left join orders as o     
		on ws.website_session_id = o.website_session_id
group by 1, 2;

-- /billing-2 page was rolled out for all traffic in Nov 2012 and lauched second product in Jan 2013 hence the conv_rt grew significantly from Q4 2012 to Q1 2013.
-- cn_rt increased significantly again in Q1 2014, because we introduced cross-selling in Sep 2013 and launched third product in Dec 2013.
-- cn_rt increased significantly since Q4 2014 after the supplier issues of Mr Fuzzy were resolved.
    
# 5. seasonality and product-level analysis

-- total sales and revenue trended monthly:

with monthly_performance as (
select year(ws.created_at) as yr, month(ws.created_at) as mon,
	   count(distinct order_id) as total_orders,
       round(sum(o.price_usd), 2) as total_revenue
from website_sessions as ws
left join orders as o     
		on ws.website_session_id = o.website_session_id
group by 1, 2
)
select yr, mon,
 total_orders,  
 round((total_orders - lag(total_orders) over(order by yr asc, mon asc))/lag(total_orders) over(order by yr asc, mon asc)*100, 1) as MoM_sales_growth,
 total_revenue,
 round((total_revenue - lag(total_revenue) over(order by yr asc, mon asc))/lag(total_revenue) over(order by yr asc, mon asc)*100, 1) as MoM_revenue_growth
from monthly_performance;

-- sales and revenue has a seasonal pattern: spikes are observed in month of Nov (holidays) and then drops to pre-holiday level in Dec and Jan.
-- sales spike observed in Dec 2013 when third product was launched.

-- revenue and margin by product trended monthly:

with monthly_product_level_performance as (
select year(ws.created_at) as yr, month(ws.created_at) as mon,
	   sum(case when oi.product_id = 1 then oi.price_usd-oi.cogs_usd else null end) as p1_total_margin,
        round(sum(case when oi.product_id = 1 then oi.price_usd else null end), 1) as p1_total_revenue,
       sum(case when oi.product_id = 2 then oi.price_usd-oi.cogs_usd else null end) as p2_total_margin,
		round(sum(case when oi.product_id = 2 then oi.price_usd else null end), 1) as p2_total_revenue,
       sum(case when oi.product_id = 3 then oi.price_usd-oi.cogs_usd else null end) as p3_total_margin,
        round(sum(case when oi.product_id = 3 then oi.price_usd else null end), 1) as p3_total_revenue,
       sum(case when oi.product_id = 4 then oi.price_usd-oi.cogs_usd else null end) as p4_total_margin,
       round(sum(case when oi.product_id = 4 then oi.price_usd else null end), 1) as p4_total_revenue
from website_sessions as ws
inner join orders as o     
		on ws.website_session_id = o.website_session_id
inner join order_items as oi
	on o.order_id = oi.order_id
group by 1, 2
)
select *
from monthly_product_level_performance;

-- product_1 shows seasonality: revenue and margin increases in Nov each year.
-- revenue of product_1 increased sharply after supplier was changed in Sep 2014.
    
# 6. monthly sessions to the /products page, the % of those sessions clicking through another page, and conversion from /products to placing an order:

with page_views as (
select *,
	 lead(website_pageview_id) over(partition by website_session_id order by created_at asc) as next_page_viewed_id  -- find where user went next from landing page in each session
from website_pageviews
),
product_bounds as (   -- get the 1st and 2nd /products timestamps per session
    select website_session_id,
           min(case when rn = 1 then created_at end) as first_product_at,
           min(case when rn = 2 then created_at end) as second_product_at
    from (
        select website_session_id,
               created_at,
               row_number() over(partition by website_session_id order by created_at asc) as rn
        from website_pageviews
        where pageview_url = '/products'
    ) as temp
    group by website_session_id
),
next_page_products as (
select  pv.website_session_id, 
		pv.created_at as webpage_created_at, 
        pv.pageview_url, 
        wp.pageview_url as next_page_viewed,
		dense_rank() over(partition by pv.website_session_id order by pv.created_at asc) as products_view_order,   -- only consider first products pageview in a session  
        o.order_id, 
        o.created_at as order_created_at,
        pb.first_product_at,
        pb.second_product_at
from page_views as pv
left join website_pageviews as wp
	on pv.next_page_viewed_id = wp.website_pageview_id
left join orders as o
	on pv.website_session_id = o.website_session_id
left join product_bounds as pb
	on pb.website_session_id = pv.website_session_id
where pv.pageview_url  = '/products'   -- find the sessions that involve /products page
)
select 		-- filters orders placed after very first product pageview in a session, orders placed from any subsequent product pageview in same session are not counted.
	year(np.webpage_created_at) as yr, 
    month(np.webpage_created_at) as mo, 
	count(distinct np.website_session_id) as product_sessions,
	count(distinct case when np.next_page_viewed is not null then np.website_session_id else null end)/count(distinct np.website_session_id) as products_ctr,
	count(distinct case when np.order_id is not null and np.order_created_at > np.first_product_at and (np.second_product_at is null or np.order_created_at < np.second_product_at)
          then np.order_id else null end)/count(distinct np.website_session_id) as product_session_order_cnv_rt
from next_page_products as np
where products_view_order = 1
group by 1, 2;	
			
-- products_ctr improved from 72% to 76% upon launch of product-2 in Jan 2013.
-- it again improved to around 80% when third product was launched in Dec 2013.
-- cnv_rt has improved over time from around 8% to around 14%, major increments observed after new product launches.
    

# 7. how well each product cross-sells from one another?

select o.primary_product_id,
	count(distinct o.order_id) as orders,
    count(distinct case when oi.product_id = 1 then o.order_id else null end) as x_sell_prod1,
	count(distinct case when oi.product_id = 2 then o.order_id else null end) as x_sell_prod2,
	count(distinct case when oi.product_id = 3 then o.order_id else null end) as x_sell_prod3,
	count(distinct case when oi.product_id = 4 then o.order_id else null end) as x_sell_prod4,
	round((count(distinct case when oi.product_id = 1 then o.order_id else null end)/count(distinct o.order_id))*100, 2) as x_sell_prod1_rt,
	round((count(distinct case when oi.product_id = 2 then o.order_id else null end)/count(distinct o.order_id))*100, 2) as x_sell_prod2_rt,
	round((count(distinct case when oi.product_id = 3 then o.order_id else null end)/count(distinct o.order_id))*100, 2) as x_sell_prod3_rt,
	round((count(distinct case when oi.product_id = 4 then o.order_id else null end)/count(distinct o.order_id))*100, 2) as x_sell_prod4_rt
from orders as o
left join order_items as oi
	on o.order_id = oi.order_id
    and oi.is_primary_item = 0  -- only bringing in cross-sells
where o.created_at > '2014-12-05'
group by 1;

--  since 4th product was made available as a primary product, all other three products cross-sells with it equally well.
-- prod1 cross-sells well most with prod3. prod2 cross-sells well most with prod1. prod3 cross-sells well most with prod1.
