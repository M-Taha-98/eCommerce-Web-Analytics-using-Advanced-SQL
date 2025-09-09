select * from orders limit 10;

select * from products; 

select * from order_items limit 15;

select * from order_item_refunds limit 20;

select * from website_pageviews limit 8;

select * from website_sessions limit 8;

											-- ------------------------------------------------
											-- 				TRAFFIC SOURCE ANALYSIS
											-- ------------------------------------------------
select web.utm_source, web.utm_content, 
		count(distinct web.website_session_id) as sessions,
		count(distinct ord.order_id) as total_orders,
        -- pct of sessions that convert to revenue producing sale
        round((count(distinct ord.order_id)/count(distinct web.website_session_id))*100,2) as session_to_order_conv_rt_pct
from website_sessions as web
left join orders as ord on web.website_session_id = ord.website_session_id
where web.website_session_id  between 1000 and 2000  -- arbitary
group by utm_source, utm_content;   -- g_ad_1 i.e. google ad 1 is deriving the most website traffic

-- assignment 1: site traffic breakdown by volume
select utm_source, utm_campaign, http_referer,
		count(distinct website_session_id) as sessions
from website_sessions 
where date(created_at) < '2012-04-12'
group by utm_source, utm_campaign,http_referer
order by sessions desc;  -- the bulk of sessions are coming from google search, nonbrand campaign

-- assignment 2: traffic source conversion rate
select 
	count(distinct web.website_session_id) as sessions,
	count(distinct ord.order_id) as orders,
	round((count(distinct ord.order_id)/count(distinct web.website_session_id))*100,2) as session_to_order_conv_rt_pct
from (select website_session_id
		from website_sessions
        where (date(created_at) < '2012-04-14' and utm_source = 'gsearch' and utm_campaign = 'nonbrand')) as web
left join orders as ord on web.website_session_id = ord.website_session_id;  
	

select 
	count(distinct web.website_session_id) as sessions,
	count(distinct ord.order_id) as orders,
	round((count(distinct ord.order_id)/count(distinct web.website_session_id))*100,2) as session_to_order_conv_rt_pct
from (select website_session_id
		from website_sessions
        where (date(created_at) < '2012-04-14' and utm_source = 'gsearch' and utm_campaign = 'nonbrand')) as web
left join (select order_id, website_session_id
			from orders) as ord
on web.website_session_id = ord.website_session_id;

select 
		count(distinct web.website_session_id) as sessions,
		count(distinct ord.order_id) as orders,
        round((count(distinct ord.order_id)/count(distinct web.website_session_id))*100,2) as session_to_order_conv_rt_pct
from website_sessions as web
left join orders as ord on web.website_session_id = ord.website_session_id
where date(web.created_at) < '2012-04-14'
group by web.utm_source, web.utm_campaign, web.http_referer
having web.utm_source = 'gsearch' and web.utm_campaign = 'nonbrand'; 
	-- conversion rate of gsearch nonbrand campaign is less than 4% needed for positive revenue on CPC as per current bid, marketing director says we're over-spending based on the current conversion rate hence he has decidied to bid down to make economics work.

-- assignment 3: traffic source trend analysis
select min(date(created_at)) as week_start_date, 
		count(distinct website_session_id) as sessions
from website_sessions
where date(created_at) < '2012-05-10' and utm_source = 'gsearch' and utm_campaign = 'nonbrand'
group by week(created_at)
order by week(created_at) asc;
-- the gsearch nonbrand session volume has reduced since the bid was dropped on 2012-04-15, notifying that this campaign is fairly sensitive to bid changes.

-- assignment 4: bid optimization for paid traffic
select
	w.device_type,
	count(distinct w.website_session_id) as sessions,
    count(distinct o.order_id) as orders,
    round((count(distinct o.order_id)/count(distinct w.website_session_id))*100,2) as session_to_order_cnv_rate
from website_sessions as w
left join orders as o on w.website_session_id = o.website_session_id
where date(w.created_at) < '2012-05-11' and w.utm_source = 'gsearch' and w.utm_campaign = 'nonbrand'
group by w.device_type
order by session_to_order_cnv_rate desc;
-- the conversion rate for desktop is close to 4%, it would be advisable to bid up for desktop specifically to get more volume hence more sales. 

-- assignment 5: traffic source trend analysis with granular segments
with t as (
select min(date(created_at)) as week_start_date, 
	   count(distinct case when device_type = 'desktop' then website_session_id else null end) as desktop_sessions,
	   count(distinct case when device_type = 'mobile' then website_session_id else null end) as mob_sessions
from website_sessions
where date(created_at) > '2012-04-15' and date(created_at) < '2012-06-09'
	and utm_source = 'gsearch' and utm_campaign = 'nonbrand'
group by week(created_at)
order by week(created_at) asc
)
select week_start_date, desktop_sessions,
	  round(((desktop_sessions - lag(desktop_sessions) over())/lag(desktop_sessions) over())*100, 1) as desktop_pct_change,
      mob_sessions,
	round(((mob_sessions - lag(mob_sessions) over())/lag(mob_sessions) over())*100, 1) as mob_pct_change
from t;
-- since bidding up on gsearch nonbrand desktop campaign on 2012-05-19 the desktop volume has increased.

												-- ------------------------------------------------
												-- 	 WEBSITE CONTENT/PERFORMANCE ANALYSIS
												-- ------------------------------------------------
-- execution time: 10.7 seconds 
SELECT 
    website_session_id,
    created_at AS pg_landing_time,
    pageview_url AS landing_page
FROM website_pageviews
WHERE (website_session_id, created_at) IN (
    SELECT website_session_id, MIN(created_at)
    FROM website_pageviews
    GROUP BY website_session_id
)
ORDER BY website_session_id ASC;

-- execution time: 15.5 seconds 
SELECT 
    wp.website_session_id as session_id,
    wp.created_at AS pg_landing_time,
    wp.pageview_url AS landing_page
FROM website_pageviews wp
INNER JOIN (
    SELECT website_session_id, MIN(created_at) AS min_created_at
    FROM website_pageviews
    GROUP BY website_session_id
) first_pages ON wp.website_session_id = first_pages.website_session_id 
              AND wp.created_at = first_pages.min_created_at
GROUP BY wp.website_session_id, wp.pageview_url
ORDER BY wp.website_session_id ASC;

-- execution time: 7.1 seconds 
create temporary table first_page_view
SELECT website_session_id, MIN(created_at) as min_created_at
    FROM website_pageviews
    GROUP BY website_session_id;
    
select 
	fpv.website_session_id as website_session_id,
    fpv.min_created_at AS pg_landing_time,
    wpv.pageview_url AS entry_page
from first_page_view as fpv
left join website_pageviews as wpv
	on fpv.min_created_at = wpv.created_at and fpv.website_session_id = wpv.website_session_id ;
    
-- execution time: 2.3 seconds 
with cte_1 as (
SELECT website_session_id, MIN(website_pageview_id) as min_pv_id
    FROM website_pageviews
    GROUP BY website_session_id )
select 
	cte_1.website_session_id as website_session_id,
    cte_1.min_pv_id AS website_pageview_id,
    wpv.created_at as landing_time,
    wpv.pageview_url AS entry_page
from cte_1
left join website_pageviews as wpv
	on cte_1.min_pv_id = wpv.website_pageview_id;

-- assignment 6: top website pages by volume
select pageview_url, count(distinct website_pageview_id) as sessions
from website_pageviews
where created_at < '2012-06-09'
group by pageview_url
order by sessions desc;
-- most viewed webpage is home page, products page and Mr Fuzzy page. Analyze performance of each of these pages to look for improvement opportunities.
-- we can investigate if this is also representative of top entry pages. 

-- assignment 7: top entry pages by volume
with cte_1 as (
	SELECT MIN(website_pageview_id) as min_pv_id
    FROM website_pageviews
    where created_at < '2012-06-12'
    GROUP BY website_session_id )
select 
	wpv.pageview_url AS entry_page,
	count(distinct wpv.website_pageview_id) as sessions_hitting_this_landing_page
from cte_1
left join website_pageviews as wpv
	on cte_1.min_pv_id = wpv.website_pageview_id
group by wpv.pageview_url
order by sessions_hitting_this_landing_page desc;
-- users are landing on the homepage, we need to analyze the landing page performance specifically for home page.

# Analyzing Bounce Rates and Landing Page Tests:

-- Business Context: we want to see landing page performance for a certain time period.
-- step 1: find the first website pageview id for relevant sessions
-- step 2: identify the landing page of each session
-- step 3: count pageviews for each session to identify 'bounces' 
-- step 4: summarize total sessions and bounced sessions by landing page

DROP TEMPORARY TABLE IF EXISTS first_pageviews_demo;
CREATE TEMPORARY TABLE first_pageviews_demo 
	SELECT wp.website_session_id, MIN(website_pageview_id) as min_pv_id
    FROM website_pageviews as wp
    inner join website_sessions	as ws
		on wp.website_session_id = ws.website_session_id
			and ws.created_at between '2014-01-01' and '2014-02-01'
	group by wp.website_session_id;

CREATE TEMPORARY TABLE sessions_with_landing_page_demo
select fp_demo.website_session_id, wp.pageview_url as landing_page
from first_pageviews_demo as fp_demo
left join website_pageviews as wp
	on fp_demo.min_pv_id = wp.website_pageview_id;
 
 
CREATE TEMPORARY TABLE bounced_sessions_only
select swl_demo.website_session_id,
	   swl_demo.landing_page,
       count(wp.website_pageview_id) as count_of_pages_viewed
from sessions_with_landing_page_demo as swl_demo
left join website_pageviews as wp
	on swl_demo.website_session_id = wp.website_session_id
group by swl_demo.website_session_id,
		 swl_demo.landing_page
having count_of_pages_viewed = 1;

select swl_demo.landing_page,
	   count(distinct swl_demo.website_session_id) as total_sessions,
       count(distinct b_s.website_session_id) as bounced_sessions,
       count(distinct b_s.website_session_id)/count(distinct swl_demo.website_session_id) as bounce_rate
from sessions_with_landing_page_demo as swl_demo
left join bounced_sessions_only as b_s
	 on swl_demo.website_session_id = b_s.website_session_id
 group by swl_demo.landing_page
 order by bounce_rate desc;   
 
-- assignment 8: bounce-rate analysis for homepage

CREATE TEMPORARY TABLE first_pageviews
	SELECT wp.website_session_id, MIN(website_pageview_id) as min_pv_id
    FROM website_pageviews as wp
    inner join website_sessions	as ws
		on wp.website_session_id = ws.website_session_id
			and ws.created_at < '2012-06-14'
	group by wp.website_session_id;
    
CREATE TEMPORARY TABLE sessions_with_landing_page
select fp.website_session_id, wp.pageview_url as landing_page
from first_pageviews as fp
left join website_pageviews as wp
	on fp.min_pv_id = wp.website_pageview_id;
    
CREATE TEMPORARY TABLE bounced_sessions
select swl.website_session_id,
	   swl.landing_page,
       count(wp.website_pageview_id) as count_of_pages_viewed
from sessions_with_landing_page as swl
left join website_pageviews as wp
	on swl.website_session_id = wp.website_session_id
group by swl.website_session_id,
		 swl.landing_page
having count_of_pages_viewed = 1;

select swl.landing_page,
	   count(distinct swl.website_session_id) as total_sessions,
       count(distinct b_s.website_session_id) as bounced_sessions,
       count(distinct b_s.website_session_id)/count(distinct swl.website_session_id) as bounce_rate
from sessions_with_landing_page as swl
left join bounced_sessions as b_s
	 on swl.website_session_id = b_s.website_session_id
 group by swl.landing_page;  -- homepage has bounce-rate of 59.2, since the majority of traffic up until 2012-06-14 is paid search traffic
							-- which should be high intent traffic, the high bounce rate is alarming and a custom landing page needs to be tested against current homepage by A/B test.

-- assignment 9: analyzing landing page test

select *
from website_pageviews
where created_at = (
		select min(created_at) 
		from website_pageviews
		where pageview_url = '/lander-1'  -- lander-1 was first created at 19 June 2012.
);

# landing page test will be evaluated from timeperiod of 19 June, 2012 to July 28, 2012.

with first_pageviews as (    
SELECT wp.website_session_id, MIN(website_pageview_id) as min_pv_id
    FROM website_pageviews as wp
    inner join website_sessions	as ws
		on wp.website_session_id = ws.website_session_id
			and ws.created_at between '2012-06-19' and  '2012-07-28'
            and ws.utm_source = 'gsearch'
            and ws.utm_campaign = 'nonbrand'
	group by wp.website_session_id
),
sessions_with_landing_page as (
select fp.website_session_id, wp.pageview_url as landing_page
from first_pageviews as fp
left join website_pageviews as wp
	on fp.min_pv_id = wp.website_pageview_id
where wp.pageview_url in ('/home','/lander-1')
),  
bounced_sessions as (
select swl.website_session_id,
	   swl.landing_page,
       count(wp.website_pageview_id) as count_of_pages_viewed
from sessions_with_landing_page as swl
left join website_pageviews as wp
	on swl.website_session_id = wp.website_session_id
group by swl.website_session_id,
		 swl.landing_page
having count_of_pages_viewed = 1
)
select swl.landing_page,
	   count(distinct swl.website_session_id) as total_sessions,
       count(distinct b_s.website_session_id) as bounced_sessions,
       count(distinct b_s.website_session_id)/count(distinct swl.website_session_id) as bounce_rate
from sessions_with_landing_page as swl
left join bounced_sessions as b_s
	 on swl.website_session_id = b_s.website_session_id
 group by swl.landing_page;  
	-- bounce rate for the new page 53.2% is lower than homepage 58.3% for the test duration hence we need to direct all gsearch nonbrand traffic to the new lander page.

-- assignment 10: landing page trend analysis

with first_pageview as (
select w_p.website_session_id, 
		MIN(w_p.website_pageview_id) as min_pv_id
from website_pageviews as w_p
inner join website_sessions as w_s
	on w_s.website_session_id = w_p.website_session_id
    and w_p.created_at > '2012-06-01' and w_p.created_at < '2012-08-31'
    and w_s.utm_campaign = 'nonbrand'
    and w_p.pageview_url in ('/home','/lander-1')
    and w_s.utm_source = 'gsearch'
group by w_p.website_session_id
),
sessions_with_landing_page as (
select f_p.website_session_id, w_p.pageview_url as landing_page, date(w_p.created_at) as date_created
from first_pageview as f_p
inner join website_pageviews as w_p
	on f_p.min_pv_id = w_p.website_pageview_id
),
bounced_sessions as (
select swl.website_session_id,
	   swl.landing_page,
       count(wp.website_pageview_id) as count_of_pages_viewed
from sessions_with_landing_page as swl
left join website_pageviews as wp
	on swl.website_session_id = wp.website_session_id
group by swl.website_session_id, swl.landing_page
having count_of_pages_viewed = 1
)
select min(swl.date_created) as week_start_date,
	   count(distinct case when swl.landing_page = '/home' then swl.website_session_id else null end) as home_sessions,
	   count(distinct case when swl.landing_page = '/lander-1' then swl.website_session_id else null end) as lander1_sessions,
       count(distinct b_s.website_session_id) as bounced_sessions,
       count(distinct b_s.website_session_id)/count(distinct swl.website_session_id) as bounce_rate
from sessions_with_landing_page as swl
left join bounced_sessions as b_s
	 on swl.website_session_id = b_s.website_session_id
 group by week(swl.date_created);  
	-- bounce rate has seen improvement from around 60% to 50%. We also see all traffic directed to lander-1 page since the landing page test was conducted.

# Conversion Funnel Analysis
-- Demo on Building Conversion Funnels:
-- Business Context:
	-- we want to build a mini conversion funnel, from /lander-2 to cart
    -- we want to know how many people reach step, and also drop-off rates
    -- for simplicity of demo, we are looking at /lander-2 traffic only
    -- for simplicity of demo, we are looking at customers who like Mr Fuzzy only
    
-- Step 1: select all pageviews for relevant sessions
-- Step 2: identify each relevant pageview as the specific funnel step
-- Step 3: create the session-level conversion funnel view
-- Step 4: aggregate the data to assess funnel performance

CREATE TEMPORARY TABLE session_level_made_it_flags_demo
select 
	website_session_id, max(products_page) as products_made_it, max(mrfuzzy_page) as mrfuzzy_made_it, max(cart_page) as cart_page_made_it
from (
	select 
		ws.website_session_id, wp.pageview_url, wp.created_at as pageview_created_at,
		case when pageview_url = '/products' then 1 else 0 end as products_page,
		case when pageview_url = '/the-original-mr-fuzzy' then 1 else 0 end as mrfuzzy_page,
		case when pageview_url = '/cart' then 1 else 0 end as cart_page
	from website_sessions as ws
	left join website_pageviews as wp
		on ws.website_session_id = wp.website_session_id
	where ws.created_at between '2014-01-01' and '2014-02-01'	-- random timeframe for demo
		and wp.pageview_url in ('/lander-2', '/products', '/the-original-mr-fuzzy', '/cart')  -- four-step funnel
	order by ws.website_session_id, wp.created_at
) as pageview_level
group by website_session_id;
	-- at this point in time of business, there are multiple products so it is possible for a session to proceed from products page to cart skipping mr-fuzzy page which would mean different product is being viewed.

select 
	count(distinct website_session_id) as sessions,
    count(distinct case when products_made_it = 1 then website_session_id else null end) as to_products,
	count(distinct case when mrfuzzy_made_it = 1 then website_session_id else null end) as to_mrfuzzy,
    count(distinct case when cart_page_made_it = 1 then website_session_id else null end) as to_cart
from session_level_made_it_flags_demo;

select 
	count(distinct website_session_id) as sessions,
    count(distinct case when products_made_it = 1 then website_session_id else null end)
		/count(distinct website_session_id) as lander_clickthrough_rate,  					-- how many users proceeded to products pade from lander page
	count(distinct case when mrfuzzy_made_it = 1 then website_session_id else null end)
		/count(distinct case when products_made_it = 1 then website_session_id else null end) as products_clickthrough_rate,
    count(distinct case when cart_page_made_it = 1 then website_session_id else null end)
		/count(distinct case when mrfuzzy_made_it = 1 then website_session_id else null end) as mrfuzzy_clickthrough_rate
from session_level_made_it_flags_demo;


-- assignment 11: building conversion funnels

CREATE TEMPORARY TABLE session_level_made_it_flags
select 
	website_session_id, max(products_page) as products_made_it, max(mrfuzzy_page) as mrfuzzy_made_it, max(cart_page) as cart_page_made_it,
    max(shipping_page) as shipping_page_made_it, max(billing_page) as billing_page_made_it, max(thankyou_page) as thankyou_page_made_it
from (
	select 
		ws.website_session_id, wp.pageview_url, wp.created_at as pageview_created_at,
		case when pageview_url = '/products' then 1 else 0 end as products_page,
		case when pageview_url = '/the-original-mr-fuzzy' then 1 else 0 end as mrfuzzy_page,
		case when pageview_url = '/cart' then 1 else 0 end as cart_page,
        case when pageview_url = '/shipping' then 1 else 0 end as shipping_page,
        case when pageview_url = '/billing' then 1 else 0 end as billing_page,
        case when pageview_url = '/thank-you-for-your-order' then 1 else 0 end as thankyou_page
	from website_sessions as ws
	left join website_pageviews as wp
		on ws.website_session_id = wp.website_session_id
	where ws.created_at between '2012-08-05' and '2012-09-05'	
		and wp.pageview_url in ('/lander-1', '/products', '/the-original-mr-fuzzy', '/cart', '/shipping', '/billing', '/thank-you-for-your-order')  
        and ws.utm_source = 'gsearch'
	order by ws.website_session_id, wp.created_at
	) as pageview_level
group by website_session_id;

select 
	count(distinct website_session_id) as sessions,
    count(distinct case when products_made_it = 1 then website_session_id else null end) as to_products,
	count(distinct case when mrfuzzy_made_it = 1 then website_session_id else null end) as to_mrfuzzy,
    count(distinct case when cart_page_made_it = 1 then website_session_id else null end) as to_cart,
    count(distinct case when shipping_page_made_it = 1 then website_session_id else null end) as to_shipping,
    count(distinct case when billing_page_made_it = 1 then website_session_id else null end) as to_billing,
    count(distinct case when thankyou_page_made_it = 1 then website_session_id else null end) as to_thankyou
from session_level_made_it_flags;

select 
    count(distinct case when products_made_it = 1 then website_session_id else null end)
		/count(distinct website_session_id) as lander1_click_rate,  				
	count(distinct case when mrfuzzy_made_it = 1 then website_session_id else null end)
		/count(distinct case when products_made_it = 1 then website_session_id else null end) as products_click_rate,
    count(distinct case when cart_page_made_it = 1 then website_session_id else null end)
		/count(distinct case when mrfuzzy_made_it = 1 then website_session_id else null end) as mrfuzzy_click_rate,
	count(distinct case when shipping_page_made_it = 1 then website_session_id else null end)
		/count(distinct case when cart_page_made_it = 1 then website_session_id else null end) as cart_click_rate,
	count(distinct case when billing_page_made_it = 1 then website_session_id else null end)
		/count(distinct case when shipping_page_made_it = 1 then website_session_id else null end) as shipping_click_rate,
	count(distinct case when thankyou_page_made_it = 1 then website_session_id else null end)
		/count(distinct case when billing_page_made_it = 1 then website_session_id else null end) as billing_click_rate
from session_level_made_it_flags;
	-- we are losing majority of gsearch visitors on lander-1, mr-fuzzy and billing pages.


-- assignment 12: conversion funnel test analysis
select *
from website_pageviews
where created_at = (
		select min(created_at) 
		from website_pageviews
		where pageview_url = '/billing-2'  -- billing-2 was first created at 10 Sep 2012.
);

-- landing page test will be evaluated from timeperiod of 10 Sep, 2012 to Nov 10, 2012.
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
select t1.*, orders.order_id
from t1
left join orders 
	on t1.website_session_id = orders.website_session_id
)
select billing_version_seen,
	count(distinct website_session_id) as sessions,
    count(distinct order_id) as orders,
    count(distinct order_id)/count(distinct website_session_id) as billing_to_order_rate
from t2
group by billing_version_seen;
 -- '/billing-2' sees higher billing_to_order_conversion_rate for all traffic hence it is advisable to switch to new billing page in the future.
 

										-- ------------------------------------------------
										-- 		CHANNEL PORTFOLIO MANAGEMENT ANALYSIS
										-- ------------------------------------------------

# Channel Portfolio Optimization

-- assignment 13: expanded channel portfolio analysis:

select min(date(created_at)) as week_start_date,
	   count(distinct website_session_id) as total_sessions,
	   count(distinct case when utm_source = 'bsearch' then website_session_id else null end) as bsearch_sessions,
       count(distinct case when utm_source = 'bsearch' then website_session_id else null end)/ count(distinct website_session_id) as bsearch_share,
       count(distinct case when utm_source = 'gsearch' then website_session_id else null end) as gsearch_sessions
from website_sessions
    where utm_source in ('gsearch', 'bsearch')  
		and  utm_campaign = 'nonbrand'
        and created_at > '2012-08-22'   -- assignment limit
        and created_at < '2012-11-29'    
group by week(created_at);
		--  since it's lauch, bsearch has been consistently contributing around 25% to nonbrand traffic, which helps diversify paid-search channel portfolio.
        -- the surge in sessions in the week starting 18 Nov is due to new billing-page being rolled out to all traffic.
        
-- assignment 14: comparing channel characteristics

select utm_source,
	   count(distinct website_session_id) as total_sessions,
	   count(distinct case when device_type = 'mobile' then website_session_id else null end) as mobile_sessions,
       count(distinct case when device_type = 'desktop' then website_session_id else null end) as desktop_sessions,
       round((count(distinct case when device_type = 'mobile' then website_session_id else null end)/ count(distinct website_session_id))*100, 2) as pct_mobile, 
	   round((count(distinct case when device_type = 'desktop' then website_session_id else null end)/ count(distinct website_session_id))*100, 2) as pct_desktop
from website_sessions
    where utm_source in ('gsearch', 'bsearch')  
		and  utm_campaign = 'nonbrand'
        and created_at > '2012-08-22' and created_at < '2012-11-30'  -- assignment limit
group by utm_source;
		-- Gsearch receives 3 times more traffic on mobile compared to Bsearch at this stage of business.

-- assignment 15: cross channel bid optimization

select device_type, utm_source,
	   count(distinct w_s.website_session_id) as total_sessions,
	   count(o.order_id) as orders,
	   round((count(o.order_id)/count(distinct w_s.website_session_id))*100, 2) as conv_rate
from website_sessions as w_s
left join orders as o
	on w_s.website_session_id = o.website_session_id
where utm_source in ('gsearch', 'bsearch')  
		and  utm_campaign = 'nonbrand'   -- limiting to nonbrand paid search
		and w_s.created_at > '2012-08-22' and w_s.created_at < '2012-09-19'  -- assignment limit
group by device_type, utm_source;
	-- the nonbrand conv_rate for Bsearch for both mobile and desktop is lower than Gsearch hence Bsearch should be bid-down to optimize paid marketing budget. 

-- assignment 16: channel portfolio trends
	-- Bsearch nonbrand was bid-down on Dec 2nd.

select min(date(created_at)) as week_start_date,
	   count(distinct case when utm_source = 'bsearch' and device_type = 'desktop' then website_session_id else null end) as b_dtop_sessions,
       count(distinct case when utm_source = 'gsearch' and device_type = 'desktop' then website_session_id else null end) as g_dtop_sessions,
       round((count(distinct case when utm_source = 'bsearch' and device_type = 'desktop' then website_session_id else null end)/  count(distinct case when utm_source = 'gsearch' and device_type = 'desktop' then website_session_id else null end))*100, 2) as b_pct_of_g_dtop,
       count(distinct case when utm_source = 'bsearch' and device_type = 'mobile' then website_session_id else null end) as b_mob_sessions,
       count(distinct case when utm_source = 'gsearch' and device_type = 'mobile' then website_session_id else null end) as g_mob_sessions,
       round((count(distinct case when utm_source = 'bsearch' and device_type = 'mobile' then website_session_id else null end)/  count(distinct case when utm_source = 'gsearch' and device_type = 'mobile' then website_session_id else null end))*100, 2) as b_pct_of_g_mob
from website_sessions
    where utm_source in ('gsearch', 'bsearch')  
		and  utm_campaign = 'nonbrand'
        and created_at > '2012-11-04'   -- assignment limit
        and created_at < '2012-12-22'    
group by week(created_at);
	-- Bsearch desktop nonbrand traffic are bid sensitive b/c it has decreased since we bid-down whereas Bsearch mobile traffic has been roughly the same.
    -- conv_rate of Bsearch nonbrand mobile traffic was already 1.3% compared to 3.8% of desktop traffic, we should now bid-up for Bsearch nonbrand desktop traffic which is bulk share to regain the customer share.
	-- Gsearch was down too after Black Friday (Nov 23) and Cyber Monday (Nov 26) which are major retail online holidays, but Bsearch dropped even more (due to bid-down).		

                                            
# Analyzing Direct Traffic

-- assignment 16: site traffic breakdown

select year(created_at) as year, month(created_at) as month, 
	   count(distinct case when utm_campaign = 'nonbrand' then website_session_id else null end) as nonbrand_sessions,
       count(distinct case when utm_campaign = 'brand' then website_session_id else null end) as brand_sessions,
       round((count(distinct case when utm_campaign = 'brand' then website_session_id else null end)
		/count(distinct case when utm_campaign = 'nonbrand' then website_session_id else null end))*100, 2) as brand_pct_of_nonbrand,
       count(distinct case when utm_source is null and http_referer is null then website_session_id else null end) as direct_sessions,
       round((count(distinct case when utm_source is null and http_referer is null then website_session_id else null end)
		/count(distinct case when utm_campaign = 'nonbrand' then website_session_id else null end))*100, 2) as direct_pct_of_nonbrand,
	   count(distinct case when utm_source is null and http_referer is not null then website_session_id else null end) as organic_sessions,
       round((count(distinct case when utm_source is null and http_referer is not null then website_session_id else null end)
		/count(distinct case when utm_campaign = 'nonbrand' then website_session_id else null end))*100, 2) as organic_pct_of_nonbrand
from website_sessions
where created_at < '2012-12-23'   -- assignment limit 
group by 1, 2;
	-- we’re building momentum with our brand since unpaid traffic share relative to nonbrand paid has grown consistently, decreasing dependency on paid traffic.
    -- unpaid traffic is growing at a higher % MoM rate than paid-nonbrand indicated by ratio increasing over time hence brand value is building up.
    -- not only are our brand, direct, and organic volumes growing, but they are growing as a percentage of our paid traffic volume. 
									
  
									-- ------------------------------------------------
									-- 		BUSINESS PATTERNS AND SEASONALITY
									-- ------------------------------------------------
                                    
-- assignment 17: seasonality

select year(ws.created_at) as year, month(ws.created_at) as month,
	   count(distinct ws.website_session_id) as sessions,
       count(o.order_id) as orders
from website_sessions as ws
left join orders as o
	on ws.website_session_id = o.website_session_id
where ws.created_at < '2013-01-02'    
group by 1, 2;
		-- surge in traffic volume and orders is observed in November (peak season).
        
select year(ws.created_at) as yr, week(ws.created_at) as week, min(date(ws.created_at)) as week_start_date,
	   count(distinct ws.website_session_id) as sessions,
       count(o.order_id) as orders
from website_sessions as ws
left join orders as o
	on ws.website_session_id = o.website_session_id
where ws.created_at < '2013-01-02'    
group by 1, 2;
	-- first two weeks of April saw surge in traffic, Easter(Apr 8th) could have contributed to it. 
    -- weeks starting  18 Nov and 25 Nov saw surge in traffic and orders due to Black Friday and Cyber Monday (seasonal traffic surge).
    -- relatively higher volume and orders in December as well leading up to Christmas.

-- assignment 18: analyzing business patterns
with daily_hourly_sessions as (
select date(created_at) as created_date,
	   weekday(created_at) as week_day,
       hour(created_at) as hour,
       count(distinct website_session_id) as sessions
from website_sessions
where created_at between '2012-09-15' and '2012-11-15'   
group by 1,2,3
)
select hour,
		round(avg(sessions), 1) as avg_sessions,
	    round(avg(case when week_day = 0 then sessions else null end), 1) as mon,
		round(avg(case when week_day = 1 then sessions else null end), 1) as tue,
        round(avg(case when week_day = 2 then sessions else null end), 1) as wed,
        round(avg(case when week_day = 3 then sessions else null end), 1) as thu,
        round(avg(case when week_day = 4 then sessions else null end), 1) as fri,
        round(avg(case when week_day = 5 then sessions else null end), 1) as sat,
        round(avg(case when week_day = 6 then sessions else null end), 1) as sun
from daily_hourly_sessions
group by hour
order by hour asc;
		-- weekdays are most busy from 9am to 5pm.
        -- weekends are less busy but relatively receive higher volumes between 9am-5pm. Sunday sees a spike of volume from 8pm-11pm. 
                                    
                                    
									-- --------------------------------------
									-- 				PRODUCT ANALYSIS
									-- --------------------------------------

# Analyzing Product Sales and Product Lanches

-- assignment 19: product-level sales analysis	
					
select 	year(created_at) as yr, month(created_at) as month,
		count(distinct order_id) as number_of_sales,
        sum(price_usd) as total_revenue,
        sum(price_usd-cogs_usd) as total_margin
from orders 
where created_at < '2013-01-04'
group by year(created_at), month(created_at);								
		-- the sales, revenue and margin figures have been on an upward trend which is a positive sign for the business.

-- assignment 20: product-launch sales analysis

select * from products; -- New Product 'The Forever Love Bear' was launched on Jan 6th 2013.
					
select 	year(w_s.created_at) as yr, month(w_s.created_at) as month,
		count(distinct w_s.website_session_id) as total_sessions,
		count(distinct o.order_id) as total_orders,
        count(distinct o.order_id)/count(distinct w_s.website_session_id) as conv_rate,
        sum(o.price_usd)/count(distinct w_s.website_session_id) as revenue_per_session,
        count(distinct case when p.product_id = 1 then o.order_id else null end) as product_one_orders,
        count(distinct case when p.product_id = 2 then o.order_id else null end) as product_two_orders
from website_sessions as w_s
left join orders as o
	on w_s.website_session_id = o.website_session_id
left join products as p
	on o.primary_product_id = p.product_id
where w_s.created_at between '2012-04-01' and  '2013-04-05'  -- assignment limit
group by year(created_at), month(created_at);	
	-- conv_rate and revenue_per_session has increased since launch of the new product which is positive for the business.
    -- the surge in orders of this new product in Feb 2013 can be associated with Valentines Day purchases.
    
# Product Level Website Pathing Analysis

-- assignment 21: product-pathing analysis

with session_level_made_it_flags as (
 select 
	website_session_id,
    session_created_at,
    max(products_page) as products_made_it, 
    max(mrfuzzy_page) as mrfuzzy_made_it, 
    max(lovebear_page) as lovebear_made_it
from (
	select 
		ws.website_session_id, ws.created_at as session_created_at, wp.pageview_url, 
		case when pageview_url = '/products' then 1 else 0 end as products_page,
		case when pageview_url = '/the-original-mr-fuzzy' then 1 else 0 end as mrfuzzy_page,
        case when pageview_url = '/the-forever-love-bear' then 1 else 0 end as lovebear_page
	from website_sessions as ws
	left join website_pageviews as wp
		on ws.website_session_id = wp.website_session_id
	where ws.created_at between '2012-10-06' and '2013-04-06'
		 and wp.pageview_url in ('/products', '/the-original-mr-fuzzy', '/the-forever-love-bear')  
	) as pageview_level
group by website_session_id
) 
select case 
		when website_session_id between 31518 and 63513 then 'A. Pre_Product_2' 
        when website_session_id between 63515 and 83783 then 'B. Post_Product_2' 
        end as time_period,
	count(distinct website_session_id) as to_product_sessions,
    count(distinct case when mrfuzzy_made_it != 0 or lovebear_made_it != 0 then website_session_id else null end) as w_next_pg,
        count(distinct case when mrfuzzy_made_it != 0 or lovebear_made_it != 0 then website_session_id else null end)
		/count(distinct website_session_id) as pct_w_next_pg,  
	count(distinct case when mrfuzzy_made_it = 1 then website_session_id else null end) as to_mrfuzzy,
    count(distinct case when mrfuzzy_made_it = 1 then website_session_id else null end)
		/count(distinct website_session_id) as pct_to_mrfuzzy,
    count(distinct case when lovebear_made_it = 1 then website_session_id else null end) as to_lovebear,
    count(distinct case when lovebear_made_it = 1 then website_session_id else null end)
		/count(distinct website_session_id) as pct_to_lovebear
from session_level_made_it_flags
group by 1;
-- the percent of /products pageviews that clicked to Mr. Fuzzy has gone down since the launch of the Love Bear, but the overall clickthrough rate has gone up, so it seems to be generating additional product interest overall.

-- assignment 22: product-level conversion funnel

with session_level_made_it_flags as (
 select 
	website_session_id,
    min(created_at) as session_created_at,
    max(mrfuzzy_page) as mrfuzzy_made_it, 
    max(lovebear_page) as lovebear_made_it,
    max(cart_page) as cart_made_it,
    max(shipping_page) as shipping_made_it,
    max(billing_page) as billing_made_it,
    max(thankyou_page) as thankyou_made_it
from (
	select 
		website_session_id, created_at, pageview_url, 
		case when pageview_url = '/the-original-mr-fuzzy' then 1 else 0 end as mrfuzzy_page,
        case when pageview_url = '/the-forever-love-bear' then 1 else 0 end as lovebear_page,
		case when pageview_url = '/cart' then 1 else 0 end as cart_page,
        case when pageview_url = '/shipping' then 1 else 0 end as shipping_page,
        case when pageview_url = '/billing-2' then 1 else 0 end as billing_page,
        case when pageview_url = '/thank-you-for-your-order' then 1 else 0 end as thankyou_page
	from website_pageviews 
	where created_at between '2013-01-06' and '2013-04-10'
		 and pageview_url in ('/the-original-mr-fuzzy', '/the-forever-love-bear', '/cart', '/shipping', '/billing-2', '/thank-you-for-your-order')  
	) as pageview_level
group by website_session_id
) 
select case 
		when mrfuzzy_made_it = 1  then 'mr_fuzzy' 
        when lovebear_made_it = 1  then 'love_bear' 
        end as product_seen,
	count(distinct website_session_id) as sessions,
	count(distinct case when cart_made_it = 1 then website_session_id else null end) as to_cart,
	count(distinct case when cart_made_it = 1 then website_session_id else null end)
		/ count(distinct website_session_id) as product_page_click_rt,
	count(distinct case when shipping_made_it = 1 then website_session_id else null end) as to_shipping,
    count(distinct case when shipping_made_it = 1 then website_session_id else null end)
		/ count(distinct case when cart_made_it = 1 then website_session_id else null end) as cart_click_rt,
    count(distinct case when billing_made_it = 1 then website_session_id else null end) as to_billing,
    count(distinct case when billing_made_it = 1 then website_session_id else null end) 
		/ count(distinct case when shipping_made_it = 1 then website_session_id else null end) as shipping_click_rt,
    count(distinct case when thankyou_made_it = 1 then website_session_id else null end) as to_thankyou,
	count(distinct case when thankyou_made_it = 1 then website_session_id else null end)
		/ count(distinct case when billing_made_it = 1 then website_session_id else null end) as billing_click_rt
from session_level_made_it_flags
group by 1;
-- We had found that adding a second product increased overall CTR from the /products page, and this analysis shows that the Love Bear has a better click rate to the /cart page and comparable rates throughout the rest of the funnel.
-- Seems like the second product was a great addition for our business.

# Cross-Selling and Product Portfolio Analysis

-- assignment 23: CROSS-SELL ANALYSIS

-- find the sessions that involve cart
-- find where user went next from cart in those sessions
-- exclude sessions which abandoned at cart i.e. next_page is null
-- join with orders table
-- split by pre_Cross_Sell Aug 25th - Sep 25th 2013 and post_Cross_Sell Sep 25th - Oct 25th 2013

with page_views as (
select *,
	 lead(website_pageview_id) over(partition by website_session_id order by created_at asc) as next_page_viewed_id
from website_pageviews
where created_at between '2013-08-25' and '2013-10-25'
),
next_page as (
select  pv.website_session_id, pv.created_at as webpage_created, pv.pageview_url, wp.pageview_url as next_page_viewed
from page_views as pv
left join website_pageviews as wp
	on pv.next_page_viewed_id = wp.website_pageview_id
where pv.pageview_url  = '/cart'
)
select 
	case when np.webpage_created >= '2013-08-25' and np.webpage_created < '2013-09-25' then 'A.Pre_Cross_Sell'
		when  np.webpage_created >= '2013-09-25' and np.webpage_created < '2013-10-25' then 'B.Post_Cross_Sell'
        end as time_period,
        count(distinct np.website_session_id) as cart_sessions,
        count(distinct case when next_page_viewed is not null then np.website_session_id else null end) as clickthroughs,
        count(distinct case when next_page_viewed is not null then np.website_session_id else null end)/count(distinct np.website_session_id) as cart_ctr,
        sum(items_purchased)/count(distinct o.order_id) as products_per_order,
        sum(price_usd)/count(distinct o.order_id) as aov,
        sum(price_usd)/count(distinct np.website_session_id) as revenue_per_cart_session
from next_page as np
left join orders as o
	on np.website_session_id = o.website_session_id
group by 1;
	-- cross-selling has helped the business sice the products_per_order, avg_order_value and revenue_per_session has increased.
    
-- assignment 24: Product Portfolio Expansion

with page_views as (
select distinct
		case when created_at >= '2013-11-12' and created_at < '2013-12-12' then 'A.Pre_Birthday_Bear'
		when  created_at >= '2013-12-12' and created_at < '2014-01-12' then 'B.Post_Birthday_Bear'
        end as time_period,
		website_session_id
from website_pageviews
where created_at between '2013-11-12' and '2014-01-12'
)
select time_period,
	   count(distinct pv.website_session_id) as sessions,
	   count(distinct o.order_id)/count(distinct pv.website_session_id) as session_to_order_conv_rate,
	   sum(price_usd)/count(distinct o.order_id) as aov,
	   sum(items_purchased)/count(distinct o.order_id) as products_per_order,
	   sum(price_usd)/count(distinct pv.website_session_id) as revenue_per_cart_session
from page_views as pv
left join orders as o
	on pv.website_session_id = o.website_session_id
group by 1;
	-- increase in all metrics show that introduction of the third product has benefitted the business.
    

# Product Refund Analysis

-- assignment 25: product refund rates

--  group by year, month
-- count(o1.order_id) as num_of_orders
-- count(o2.order_id) as num_of_orders_with_refund

select year(o1.created_at) as yr, month(o1.created_at) as month,
	count(distinct case when o1.product_id = 1 then o1.order_id else null end) as p1_orders,
	count(distinct case when o1.product_id = 1 and o2.order_item_refund_id is not null then o1.order_id else null end)/count(distinct case when o1.product_id = 1 then o1.order_id else null end) as p1_refund_rt,
    count(distinct case when o1.product_id = 2 then o1.order_id else null end) as p2_orders,
    count(distinct case when o1.product_id = 2 and o2.order_item_refund_id is not null then o1.order_id else null end)/count(distinct case when o1.product_id = 2 then o1.order_id else null end) as p2_refund_rt,
    count(distinct case when o1.product_id = 3 then o1.order_id else null end) as p3_orders,
    count(distinct case when o1.product_id = 3 and o2.order_item_refund_id is not null then o1.order_id else null end)/count(distinct case when o1.product_id = 3 then o1.order_id else null end) as p3_refund_rt,
    count(distinct case when o1.product_id = 4 then o1.order_id else null end) as p4_orders,
    count(distinct case when o1.product_id = 4 and o2.order_item_refund_id is not null then o1.order_id else null end)/count(distinct case when o1.product_id = 4 then o1.order_id else null end) as p4_refund_rt
from order_items as o1
left join order_item_refunds as o2
	on o1.order_id = o2.order_id
    and o1.order_item_id = o2.order_item_id
where o1.created_at < '2014-10-15'
group by 1, 2;
	-- data agrees with Cindy's story that quality issues with product_1 are now fixed.

	
											-- ---------------------------------
											-- 			USER ANALYSIS
											-- ---------------------------------

# Repeat purchase behaviour analysis

-- assignment 26: identifying repeat visitors

--  limit analysis to users only who had first_sesion in the time frame defined

with repeat_session_summary as (
select user_id,
	 count(case when is_repeat_session = 1 then website_session_id else null end) as num_of_repeat_sessions
from website_sessions
where created_at < '2014-11-01'
      and user_id in  (select distinct user_id
					   from website_sessions
					   where is_repeat_session = 0
						 and created_at between '2014-01-01' and '2014-11-01')-- assignment limit
group by 1
)
select num_of_repeat_sessions as repeat_sessions,
	   count(distinct user_id) as users
from repeat_session_summary
group by 1;
	-- a fair number of our customers do come back to our site after the first session. 
    

-- assignment 27: analyzing repeat behavior

-- users who have first in timeframe and their first_session date

with session_summary as (
select user_id, created_at, is_repeat_session,
	   rank() over(partition by user_id order by created_at asc) as nth_session
from website_sessions
where created_at < '2014-11-03'
      and user_id in  (select distinct user_id
					   from website_sessions
					   where is_repeat_session = 0
						 and created_at between '2014-01-01' and '2014-11-03')  -- users who had first_session in this timeframe 
),
repeat_visitors as(
select *,
		datediff(created_at, lag(created_at) over(partition by user_id order by created_at asc)) as days_first_to_second
from session_summary
where user_id in (select distinct user_id
					from session_summary
                    where nth_session >= 2 )  -- users only who have had atleast one repeat_session
	 and nth_session in (1,2)  				  -- ignoring the third visit
)
select 
        avg(days_first_to_second) as avg_days_first_to_second,
        min(days_first_to_second) as min_days_first_to_second,
        max(days_first_to_second) as max_days_first_to_second
from repeat_visitors;
		-- users on avg take about a month to come back to the website.


-- assignment 28: new v.s repeat channel patterns

-- considering only users who had first_session in this timeframe 
with session_summary as (
select user_id, website_session_id, created_at, is_repeat_session, utm_source, utm_campaign, http_referer
from website_sessions
where created_at < '2014-11-05'
      and user_id in  (select distinct user_id
					   from website_sessions
					   where is_repeat_session = 0
						 and created_at between '2014-01-01' and '2014-11-05')  -- users who had first_session in this timeframe 
)
select case
		when utm_source in ('gsearch', 'bsearch') and utm_campaign = 'brand' then 'paid_brand'
        when utm_source in ('gsearch', 'bsearch') and utm_campaign = 'nonbrand' then 'paid_nonbrand'
        when utm_source = 'socialbook' then 'paid_social'
        when utm_source is null and http_referer is not null then 'organic_search'
        when utm_source is null and http_referer is null then 'direct_type_in'
        end as channel_group,
        count(distinct case when is_repeat_session = 0 then website_session_id else null end) as new_sessions,
		count(distinct case when is_repeat_session != 0 then website_session_id else null end) as repeat_sessions
from session_summary
group by 1;

-- all users in this timeframe 
select case
		when utm_source in ('gsearch', 'bsearch') and utm_campaign = 'brand' then 'paid_brand'
        when utm_source in ('gsearch', 'bsearch') and utm_campaign = 'nonbrand' then 'paid_nonbrand'
        when utm_source = 'socialbook' then 'paid_social'
        when utm_source is null and http_referer is not null then 'organic_search'
        when utm_source is null and http_referer is null then 'direct_type_in'
        end as channel_group,
        count(distinct case when is_repeat_session = 0 then website_session_id else null end) as new_sessions,
		count(distinct case when is_repeat_session = 1 then website_session_id else null end) as repeat_sessions
from website_sessions
where created_at between '2014-01-01' and '2014-11-05'
group by 1
order by repeat_sessions desc;
	-- one-third of repeat customers are coming back via paid_brand channel, which potantially means we’re paying for these customers with paid search brand ads multiple times. 
    -- but brand clicks are cheaper than nonbrand. So all in all, we’re not paying very much for these subsequent visits.


-- assignment 29: new v.s repeat performance

select is_repeat_session,
        count(distinct ws.website_session_id) as sessions,
        count(distinct order_id) as orders,
        count(distinct order_id)/count(distinct ws.website_session_id) as conv_rt,
		sum(price_usd)/count(distinct ws.website_session_id) as revenue_per_session
from website_sessions as ws
left join orders as o
	on ws.website_session_id = o.website_session_id
where ws.created_at between '2014-01-01' and '2014-11-08'
group by 1;
	-- repeat sessions do convert to orders more than first sessions, which is expected behavior since repeat user is higher intent customer.
    -- interestingly, repeat sessions bring in nearly 20% more revenue per session than first sessions.
    




