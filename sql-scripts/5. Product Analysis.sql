									-- --------------------------------------
									-- 			PRODUCT ANALYSIS
									-- --------------------------------------
                                    
                                    
-- ***********************************************
	# Analyzing Product Sales and Product Lanches
-- ***********************************************

-- 1. Product-level sales analysis:	
					
select 	year(created_at) as yr, month(created_at) as month,
		count(distinct order_id) as number_of_sales,
        sum(price_usd) as total_revenue,
        sum(price_usd-cogs_usd) as total_margin
from orders 
where created_at < '2013-01-04'
group by year(created_at), month(created_at);	
/*							
-- the sales, revenue and margin figures have been on an upward trend which is a positive sign for the business.
*/

-- 2. Product-launch sales analysis:

	-- New Product 'The Forever Love Bear' was launched on Jan 6th 2013.
					
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
where w_s.created_at between '2012-04-01' and  '2013-04-05'  
group by year(created_at), month(created_at);	
/*
-- conv_rate and revenue_per_session has increased since launch of the new product which is positive for the business.
-- the surge in orders of this new product in Feb 2013 can be associated with Valentines Day purchases.
 */ 
  
-- **********************************************************************************************************
-- **********************************************************************************************************

-- ********************************************
	# Product Level Website Pathing Analysis
-- ********************************************

-- 1. Product-pathing analysis:

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
/*
-- the percent of /products pageviews that clicked to Mr. Fuzzy has gone down since the launch of the Love Bear, but the overall clickthrough rate 
   has gone up, so it seems to be generating additional product interest overall.
*/

-- 2. Product-level conversion funnel:

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
/*
-- We had found that adding a second product increased overall CTR from the /products page, and this analysis shows that the Love Bear has a better 
   click rate to the /cart page and comparable rates throughout the rest of the funnel.
-- Seems like the second product was a great addition for the business.
*/

-- **********************************************************************************************************
-- **********************************************************************************************************

-- ************************************************
	# Cross-Selling and Product Portfolio Analysis
-- ************************************************

-- 1. CROSS-SELL ANALYSIS:

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
/*
-- cross-selling has helped the business sice the products_per_order, avg_order_value and revenue_per_session has increased.
*/

-- 2. Product Portfolio Expansion:

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
	   sum(price_usd)/count(distinct pv.website_session_id) as revenue_per_session
from page_views as pv
left join orders as o
	on pv.website_session_id = o.website_session_id
group by 1;
/*
-- increase in all metrics show that introduction of the third product has benefitted the business.
*/   

-- **********************************************************************************************************
-- **********************************************************************************************************

-- *****************************
	# Product Refund Analysis
-- *****************************

-- Product refund rates:

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
/*
-- Quality issues with product_1 appear to be now fixed.
*/
    