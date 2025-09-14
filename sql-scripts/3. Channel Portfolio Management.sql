										-- ------------------------------------------------
										-- 		CHANNEL PORTFOLIO MANAGEMENT ANALYSIS
										-- ------------------------------------------------

-- ************************************
	# Channel Portfolio Optimization
-- ************************************

-- 1. Expanded channel portfolio analysis:

select min(date(created_at)) as week_start_date,
	   count(distinct website_session_id) as total_sessions,
	   count(distinct case when utm_source = 'bsearch' then website_session_id else null end) as bsearch_sessions,
       count(distinct case when utm_source = 'bsearch' then website_session_id else null end)/ count(distinct website_session_id) as bsearch_share,
       count(distinct case when utm_source = 'gsearch' then website_session_id else null end) as gsearch_sessions
from website_sessions
    where utm_source in ('gsearch', 'bsearch')  
		and  utm_campaign = 'nonbrand'
        and created_at > '2012-08-22'   
        and created_at < '2012-11-29'    
group by week(created_at);
/*
	--  since it's launch, bsearch has been consistently contributing around 25% to nonbrand traffic, which helps diversify paid-search channel portfolio.
	-- the surge in sessions in the week starting 18 Nov is due to new billing-page being rolled out to all traffic.
 */
 
-- 2. Comparing channel characteristics:

select utm_source,
	   count(distinct website_session_id) as total_sessions,
	   count(distinct case when device_type = 'mobile' then website_session_id else null end) as mobile_sessions,
       count(distinct case when device_type = 'desktop' then website_session_id else null end) as desktop_sessions,
       round((count(distinct case when device_type = 'mobile' then website_session_id else null end)/ count(distinct website_session_id))*100, 2) as pct_mobile, 
	   round((count(distinct case when device_type = 'desktop' then website_session_id else null end)/ count(distinct website_session_id))*100, 2) as pct_desktop
from website_sessions
    where utm_source in ('gsearch', 'bsearch')  
		and  utm_campaign = 'nonbrand'
        and created_at > '2012-08-22' and created_at < '2012-11-30'  
group by utm_source;
/*
	-- Gsearch receives three times more traffic on mobile compared to Bsearch at this stage of business.
*/

-- 3. Cross channel bid optimization:

select device_type, utm_source,
	   count(distinct w_s.website_session_id) as total_sessions,
	   count(o.order_id) as orders,
	   round((count(o.order_id)/count(distinct w_s.website_session_id))*100, 2) as conv_rate
from website_sessions as w_s
left join orders as o
	on w_s.website_session_id = o.website_session_id
where utm_source in ('gsearch', 'bsearch')  
		and  utm_campaign = 'nonbrand'   -- limiting to nonbrand paid search
		and w_s.created_at > '2012-08-22' and w_s.created_at < '2012-09-19'  
group by device_type, utm_source;
/*
-- the nonbrand conv_rate for Bsearch for both mobile and desktop is lower than Gsearch hence Bsearch should be bid-down to optimize paid marketing budget. 
*/

-- 4. Channel portfolio trends

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
        and created_at > '2012-11-04'   
        and created_at < '2012-12-22'    
group by week(created_at);
/*
-- Bsearch desktop nonbrand traffic are bid sensitive b/c it has decreased since we bid-down whereas Bsearch mobile traffic has been roughly the same.
-- conv_rate of Bsearch nonbrand mobile traffic was already 1.3% compared to 3.8% of desktop traffic, we should now bid-up for Bsearch nonbrand desktop traffic
   which is bulk share to regain the customer share.
-- Gsearch was down too after Black Friday (Nov 23) and Cyber Monday (Nov 26) which are major retail online holidays, but Bsearch dropped even more (due to bid-down).		
*/

-- **********************************************************************************************************
-- **********************************************************************************************************

-- ******************************									
	# Analyzing Direct Traffic
-- ******************************

-- Site traffic breakdown

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
where created_at < '2012-12-23'  
group by 1, 2;
/*
-- we’re building momentum with our brand since unpaid traffic share relative to nonbrand paid has grown consistently, decreasing dependency on paid traffic.
-- unpaid traffic is growing at a higher % MoM rate than paid-nonbrand indicated by ratio increasing over time hence brand value is building up.
-- not only are our brand, direct, and organic volumes growing, but they are growing as a percentage of our paid traffic volume.
*/