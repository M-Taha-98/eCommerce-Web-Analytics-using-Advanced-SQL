												-- ------------------------------------------------
												-- 	 WEBSITE CONTENT/PERFORMANCE ANALYSIS
												-- ------------------------------------------------
	
-- ***********************************************
	# Analyzing Top website pages and entry pages:
-- ***********************************************

-- 1. Top website pages by volume:
select pageview_url, count(distinct website_pageview_id) as sessions
from website_pageviews
where created_at < '2012-06-09'
group by pageview_url
order by sessions desc;
/*
-- most viewed webpage is home page, products page and Mr Fuzzy page. Analyze performance of each of these pages to look for improvement opportunities.
-- we can investigate if this is also representative of top entry pages. 
*/

-- 2.Top entry pages by volume:
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
/*
-- users are landing on the homepage, we need to analyze the landing page performance specifically for home page.
*/

-- **********************************************************************************************************
-- **********************************************************************************************************

-- *************************************************
	# Analyzing Bounce Rates and Landing Page Tests:
-- *************************************************

-- 1. Bounce-rate analysis for homepage:
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
 group by swl.landing_page;  
 /*
 -- homepage has bounce-rate of 59.2, since the majority of traffic up until 2012-06-14 is paid search traffic which should 
    be high intent traffic, the high bounce rate is alarming and a custom landing page needs to be tested against current homepage by A/B test.
*/

-- 2. Analyzing landing page test:
select *
from website_pageviews
where created_at = (
		select min(created_at) 
		from website_pageviews
		where pageview_url = '/lander-1'  -- lander-1 was first created at 19 June 2012.
);

-- landing page test will be evaluated from timeperiod of 19 June, 2012 to July 28, 2012.

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
 /*
-- bounce rate for the new page 53.2% is lower than homepage 58.3% for the test duration hence we need to direct all gsearch nonbrand traffic to the new lander page.
*/

-- 3. Landing page trend analysis:

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
 /*
-- bounce rate has seen improvement from around 60% to 50%. We also see all traffic directed to lander-1 page since the landing page test was conducted.
*/

-- **********************************************************************************************************
-- **********************************************************************************************************

-- ******************************
	# Conversion Funnel Analysis
-- ******************************

-- 1. Building conversion funnels:
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
/*
-- business is losing majority of gsearch visitors on lander-1, mr-fuzzy and billing pages.
*/

-- 2. Conversion funnel test analysis:
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
/*
 -- '/billing-2' sees higher billing_to_order_conversion_rate for all traffic hence it is advisable to switch to new billing page in the future.
*/