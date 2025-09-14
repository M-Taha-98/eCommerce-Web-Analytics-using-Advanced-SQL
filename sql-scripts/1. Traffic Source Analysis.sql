											-- ------------------------------------------------
											-- 				TRAFFIC SOURCE ANALYSIS
											-- ------------------------------------------------

-- Top Traffic Sources:
select utm_source, utm_campaign, http_referer,
		count(distinct website_session_id) as sessions
from website_sessions 
where date(created_at) < '2012-04-12'
group by utm_source, utm_campaign,http_referer
order by sessions desc;  

/*
Insights Based on the Results:
-- the bulk of sessions are coming from google search, nonbrand campaign
*/

-- Traffic source conversion rate:
select 
		count(distinct web.website_session_id) as sessions,
		count(distinct ord.order_id) as orders,
        round((count(distinct ord.order_id)/count(distinct web.website_session_id))*100,2) as session_to_order_conv_rt_pct
from website_sessions as web
left join orders as ord on web.website_session_id = ord.website_session_id
where date(web.created_at) < '2012-04-14'
group by web.utm_source, web.utm_campaign, web.http_referer
having web.utm_source = 'gsearch' and web.utm_campaign = 'nonbrand'; 
/*
-- conversion rate of gsearch nonbrand campaign is less than 4% which is needed for positive revenue on CPC as per current bid, we could be 
   over-spending based on the current conversion rate hence it is advisable to bid down to make economics work.
*/

-- **********************************************************************************************************

-- Traffic source trend analysis:
select min(date(created_at)) as week_start_date, 
		count(distinct website_session_id) as sessions
from website_sessions
where date(created_at) < '2012-05-10' and utm_source = 'gsearch' and utm_campaign = 'nonbrand'
group by week(created_at)
order by week(created_at) asc;
/*
-- the gsearch nonbrand session volume has reduced since the bid was dropped on 2012-04-15, notifying that this campaign is fairly sensitive to bid changes.
*/

-- **********************************************************************************************************

-- Bid optimization for paid traffic:
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
/*
-- the conversion rate for desktop is close to 4%, it would be advisable to bid up for desktop specifically to get more volume hence drive more sales. 
*/

-- Trend analysis by device type
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
/*
-- since bidding up on gsearch nonbrand desktop campaign on 2012-05-19 the desktop volume has increased.
*/