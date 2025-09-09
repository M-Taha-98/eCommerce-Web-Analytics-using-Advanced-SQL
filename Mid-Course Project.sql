												-- ------------------------------------
												-- 			Mid Course Project
												-- ------------------------------------

# 1. since Gsearch is biggest driver of business, we look at monthly trends for gsearch sessions and orders to showcase the growth:

select concat(DATE_FORMAT(ws.created_at, '%b'),' 2012') as month,
	   count(distinct ws.website_session_id) as sessions,
	   count(distinct o.order_id) as orders,
       round((count(distinct o.order_id)/count(distinct ws.website_session_id))*100, 2) as session_order_cnv_ratio
from website_sessions as ws
left join orders as o
	 on ws.website_session_id = o.website_session_id
where ws.utm_source = 'gsearch'
	 and ws.created_at < '2012-11-27' 
group by month(ws.created_at), concat(DATE_FORMAT(ws.created_at, '%b'), ' 2012')
order by month(ws.created_at) asc;   
	-- Gsearch session volume has increased nearly 2.5x from beginning of business to date.
    -- orders volume has also increased nearly 3 times over the course of the 8 months. 
    -- session_to_order conversion ratio has also incrased from around 3% in initial three months to around 4.2% in the most recent three months.

# 2. monthly trends for gsearch sessions split up by brand and nonbrand:
-- to check if we are picking up brand traction or not which is indicator of brand development
select concat(DATE_FORMAT(ws.created_at, '%b'),' 2012') as month,
	   count(distinct case when utm_campaign = 'brand' then ws.website_session_id else null end) as brand_sessions,
	   count(distinct case when utm_campaign = 'brand' then o.order_id else null end) as brand_orders,
       round((count(distinct case when utm_campaign = 'brand' then o.order_id else null end)
				/count(distinct case when utm_campaign = 'brand' then ws.website_session_id else null end))*100, 2) as brand_order_session_cnv_ratio,
	   count(distinct case when utm_campaign = 'nonbrand' then ws.website_session_id else null end) as nonbrand_sessions,
	   count(distinct case when utm_campaign = 'nonbrand' then o.order_id else null end) as nonbrand_orders,
       round((count(distinct case when utm_campaign = 'nonbrand' then o.order_id else null end)
				/count(distinct case when utm_campaign = 'nonbrand' then ws.website_session_id else null end))*100, 2) as nonbrand_order_session_cnv_ratio
from website_sessions as ws
left join orders as o
	 on ws.website_session_id = o.website_session_id
where ws.utm_source = 'gsearch'
	 and ws.created_at < '2012-11-27' 
group by month(ws.created_at), concat(DATE_FORMAT(ws.created_at, '%b'), ' 2012');
   -- increase in Gsearch brand sessions close to 400/month by Nov is a good indicator of brand growth.

# 3. monthly trends of Gsearch nonbrand by device type:

select concat(DATE_FORMAT(ws.created_at, '%b'),' 2012') as month,
	   count(distinct case when device_type = 'desktop' then ws.website_session_id else null end) as desktop_sessions,
	   count(distinct case when device_type = 'desktop' then o.order_id else null end) as desktop_orders,
       round((count(distinct case when device_type = 'desktop' then o.order_id else null end)
				/count(distinct case when device_type = 'desktop' then ws.website_session_id else null end))*100, 2) as desktop_order_session_cnv_ratio,
	   count(distinct case when device_type = 'mobile' then ws.website_session_id else null end) as mobile_sessions,
	   count(distinct case when device_type = 'mobile' then o.order_id else null end) as mobile_orders,
       round((count(distinct case when device_type = 'mobile' then o.order_id else null end)
				/count(distinct case when device_type = 'mobile' then ws.website_session_id else null end))*100, 2) as mobile_order_session_cnv_ratio
from website_sessions as ws
left join orders as o
	 on ws.website_session_id = o.website_session_id
where ws.utm_source = 'gsearch'
	 and ws.created_at < '2012-11-27' 
     and ws.utm_campaign = 'nonbrand'
group by month(ws.created_at), concat(DATE_FORMAT(ws.created_at, '%b'), ' 2012');
	-- desktop traffic for Gsearch nonbrand has consistently improved while the order_conversion_rate has also steadily increased.
    -- mobile traffic for Gsearch nonbrand has been volatile but has picked up since August, the order_conversion_ratio has been low and unstaedy throughout.
    -- desktop traffic to mobile traffic ratio in initial months was around 2:1, while the gap increased to over 3:1 in the recent months. 
    -- dekstop orders to mobile orders ratio in initial months was around 7:1, while the gap increased to around 10:1 in the recent months. 
 
# 4. monthly trends for all channels:

with monthly_trend as (
select month(ws.created_at) as month_num,
	   concat(DATE_FORMAT(ws.created_at, '%b'),' 2012') as month,
	   coalesce(ws.utm_source, 'organic/direct_type_in') as traffic_source,
	   count(distinct ws.website_session_id) as sessions,
	   count(distinct o.order_id) as orders,
       round((count(distinct o.order_id)/count(distinct ws.website_session_id))*100, 2) as session_order_cnv_ratio
from website_sessions as ws
left join orders as o
	 on ws.website_session_id = o.website_session_id
where ws.created_at < '2012-11-27' 
group by month(ws.created_at), concat(DATE_FORMAT(ws.created_at, '%b'), ' 2012'), ws.utm_source
),
with_totals as (
select month_num, month, traffic_source, sessions,
	  sum(sessions) over(partition by month order by month_num asc) as monthly_total_sessions,
	  round((sessions/sum(sessions) over(partition by month))*100, 2) as pct_share_of_traffic_source,
     orders, session_order_cnv_ratio
from monthly_trend
order by month_num asc
)
select month, traffic_source, sessions, orders, monthly_total_sessions,
	   round(((monthly_total_sessions - 
		lag(monthly_total_sessions, 3) over(order by month_num asc))/lag(monthly_total_sessions, 3) over(order by month_num asc))*100, 2) as traffic_MoM_pct_chng,
	   pct_share_of_traffic_source, session_order_cnv_ratio
from with_totals
order by month_num asc;
   -- launch of Bsearch nonbrand campaign on 19 Aug increased traffic_share of Bsearch from 1% in July to 12% in August.
   -- /billing-2 page was tested out starting 10 Sep and was rolled out for all traffic on Nov 10, which accounts for surge in overall traffic in Oct and Nov.


# 5. monthly session_to_order conversion ratio:

select 
	   concat(DATE_FORMAT(ws.created_at, '%b'),' 2012') as month,
	   count(distinct ws.website_session_id) as sessions,
	   count(distinct o.order_id) as orders,
       round((count(distinct o.order_id)/count(distinct ws.website_session_id))*100, 2) as session_order_cnv_ratio
from website_sessions as ws
left join orders as o
	 on ws.website_session_id = o.website_session_id
where ws.created_at < '2012-11-27'
group by month(ws.created_at), concat(DATE_FORMAT(ws.created_at, '%b'), ' 2012')
order by month(ws.created_at) asc;
	-- session_order_conversion_ratio has increased over the course of 8 months from under 3% to around 4.5%
    
# 6. Revenue analysis for Gsearch nonbrand camapign since lander page-test:

-- during lander-1 page test 19 June to 28 July
select 
	   count(distinct ws.website_session_id) as sessions,
	   count(distinct o.order_id) as orders,
       round((count(distinct o.order_id)/count(distinct ws.website_session_id))*100, 2) as session_order_cnv_ratio,
       sum(o.price_usd) as total_revenue
from website_sessions as ws
left join orders as o
	 on ws.website_session_id = o.website_session_id
where ws.created_at > '2012-06-19' and  ws.created_at < '2012-07-28' and ws.utm_campaign = 'nonbrand' and ws.utm_source = 'gsearch';

-- after lander-1 page test to date
select 
	   concat(DATE_FORMAT(ws.created_at, '%b'),' 2012') as month,
	   count(distinct ws.website_session_id) as sessions,
	   count(distinct o.order_id) as orders,
       round((count(distinct o.order_id)/count(distinct ws.website_session_id))*100, 2) as session_order_cnv_ratio,
       sum(o.price_usd) as total_revenue
from website_sessions as ws
left join orders as o
	 on ws.website_session_id = o.website_session_id
where ws.created_at < '2012-11-27' and ws.utm_campaign = 'nonbrand' and ws.utm_source = 'gsearch' and ws.website_session_id > 17145 -- 17145 is the last /home session
group by month(ws.created_at), concat(DATE_FORMAT(ws.created_at, '%b'), ' 2012')
order by month(ws.created_at) asc;
	-- the session_to_order_conversion ratio since the lander page test has increased from around 3.5% before test to around 4.2% in Nov.
    -- the revenue has also surged from around USD 3500/month before test to over USD 8500/month since and most recently in Nov it is in excess of USD 17,000.

# 7. Conversion funnel analysis for each landing page during 19 June to 28 July:

with first_pageview as (
select w_p.website_session_id, 
		MIN(w_p.website_pageview_id) as min_pv_id
from website_pageviews as w_p
inner join website_sessions as w_s
	on w_s.website_session_id = w_p.website_session_id
    and w_p.created_at between '2012-06-19' and '2012-07-28'	
    and w_p.pageview_url in ('/home','/lander-1') 
    and w_s.utm_source = 'gsearch'
    and w_s.utm_campaign = 'nonbrand'
group by w_p.website_session_id
),
sessions_with_landing_page as (
select f_p.website_session_id, w_p.pageview_url as landing_page, w_p.created_at
from first_pageview as f_p
inner join website_pageviews as w_p
	on f_p.min_pv_id = w_p.website_pageview_id
),
session_level_made_it_flags_2 as (
select 
	website_session_id, landing_page,
    max(products_page) as products_made_it, max(mrfuzzy_page) as mrfuzzy_made_it, max(cart_page) as cart_page_made_it,
    max(shipping_page) as shipping_page_made_it, max(billing_page) as billing_page_made_it, max(thankyou_page) as thankyou_page_made_it
from (
select slp.website_session_id, slp.landing_page,
		wp.pageview_url, wp.created_at,
        case when wp.pageview_url = '/products' then 1 else 0 end as products_page,
		case when wp.pageview_url = '/the-original-mr-fuzzy' then 1 else 0 end as mrfuzzy_page,
		case when wp.pageview_url = '/cart' then 1 else 0 end as cart_page,
        case when wp.pageview_url = '/shipping' then 1 else 0 end as shipping_page,
        case when wp.pageview_url = '/billing' then 1 else 0 end as billing_page,
        case when wp.pageview_url = '/thank-you-for-your-order' then 1 else 0 end as thankyou_page
from sessions_with_landing_page as slp
inner join website_pageviews as wp
	on slp.website_session_id = wp.website_session_id
 ) as pageview_level
 group by website_session_id, landing_page
)
select landing_page,
    count(distinct website_session_id) as sessions,
    count(distinct case when products_made_it = 1 then website_session_id else null end)
		/count(distinct website_session_id) as lander_click_rate,
    count(distinct case when products_made_it = 1 then website_session_id else null end) as to_products, 
	count(distinct case when mrfuzzy_made_it = 1 then website_session_id else null end)
		/count(distinct case when products_made_it = 1 then website_session_id else null end) as products_click_rate,
	count(distinct case when mrfuzzy_made_it = 1 then website_session_id else null end) as to_mrfuzzy,
    count(distinct case when cart_page_made_it = 1 then website_session_id else null end)
		/count(distinct case when mrfuzzy_made_it = 1 then website_session_id else null end) as mrfuzzy_click_rate,
	count(distinct case when cart_page_made_it = 1 then website_session_id else null end) as to_cart,
	count(distinct case when shipping_page_made_it = 1 then website_session_id else null end)
		/count(distinct case when cart_page_made_it = 1 then website_session_id else null end) as cart_click_rate,
	count(distinct case when shipping_page_made_it = 1 then website_session_id else null end) as to_shipping, 
	count(distinct case when billing_page_made_it = 1 then website_session_id else null end)
		/count(distinct case when shipping_page_made_it = 1 then website_session_id else null end) as shipping_click_rate,
	count(distinct case when billing_page_made_it = 1 then website_session_id else null end) as to_billing,
	count(distinct case when thankyou_page_made_it = 1 then website_session_id else null end)
		/count(distinct case when billing_page_made_it = 1 then website_session_id else null end) as billing_click_rate,
	count(distinct case when thankyou_page_made_it = 1 then website_session_id else null end) as to_thankyou
from session_level_made_it_flags_2
group by landing_page; 
	-- drop-off rate across the funnel is very similar for both lander pages.
    
    
# 8. Impact analysis of billing test:

-- during billing page test duration:
with t1 as ( 
select 
	ws.website_session_id,
	case 
    when pageview_url = '/billing' then '/billing' 
	when pageview_url = '/billing-2' then '/billing-2' 
    else 'other' end as billing_version_seen
from website_sessions as ws
left join website_pageviews as wp
	on ws.website_session_id = wp.website_session_id
where ws.created_at between '2012-09-10' and '2012-11-10'	
	and wp.pageview_url in ('/billing', '/billing-2')  
order by ws.website_session_id, wp.created_at
),
t2 as (
select t1.*, orders.order_id, orders.price_usd
from t1
left join orders 
	on t1.website_session_id = orders.website_session_id
)
select billing_version_seen,
	count(distinct website_session_id) as sessions,
    count(distinct order_id) as orders,
    sum(price_usd) as total_revenue,
    sum(price_usd)/count(distinct website_session_id) as avg_revenue_per_session
from t2
group by billing_version_seen;
	-- revenue lift of around USD 8.5 per session on average from /billing-2 was genereted in the test.

-- during last month:
with t1 as ( 
select 
	ws.website_session_id,
	case 
    when pageview_url = '/billing' then '/billing' 
	when pageview_url = '/billing-2' then '/billing-2' 
    else 'other' end as billing_version_seen
from website_sessions as ws
left join website_pageviews as wp
	on ws.website_session_id = wp.website_session_id
where ws.created_at between '2012-10-27' and '2012-11-27'	
	and wp.pageview_url in ('/billing', '/billing-2')  
order by ws.website_session_id, wp.created_at
),
t2 as (
select t1.*, orders.order_id, orders.price_usd
from t1
left join orders 
	on t1.website_session_id = orders.website_session_id
)
select billing_version_seen,
	count(distinct website_session_id) as sessions,
	count(distinct order_id) as orders,
    round((count(distinct order_id)/count(distinct website_session_id))*100, 2) as billing_to_order_ratio,
    sum(price_usd) as total_revenue,
    sum(price_usd)/count(distinct website_session_id) as avg_revenue_per_session
from t2
group by billing_version_seen;
	-- over the last month, /billing-2 has seen more conversions despite lower session volume and hence a higher avg revenue per session.
     -- we have had 583 total /billing-2 sessions in the last month.
	 -- USD 8.5 incremental avg revenue per session  = ~ USD 5,000 incremental avg revenue in last month compared to if we had been using only /billing page instead.
     
    