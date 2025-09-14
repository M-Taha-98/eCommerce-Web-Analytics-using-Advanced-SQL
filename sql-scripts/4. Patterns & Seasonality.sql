									-- ------------------------------------------------
									-- 		BUSINESS PATTERNS AND SEASONALITY
									-- ------------------------------------------------
							
-- ***********************************************
	# Analyzing Business Patterns & Seasonality:
-- ***********************************************
 
-- 1. Seasonality Analysis:

select year(ws.created_at) as year, month(ws.created_at) as month,
	   count(distinct ws.website_session_id) as sessions,
       count(o.order_id) as orders
from website_sessions as ws
left join orders as o
	on ws.website_session_id = o.website_session_id
where ws.created_at < '2013-01-02'    
group by 1, 2;
/*
-- surge in traffic volume and orders is observed in November (peak season).
*/
     
select year(ws.created_at) as yr, week(ws.created_at) as week, min(date(ws.created_at)) as week_start_date,
	   count(distinct ws.website_session_id) as sessions,
       count(o.order_id) as orders
from website_sessions as ws
left join orders as o
	on ws.website_session_id = o.website_session_id
where ws.created_at < '2013-01-02'    
group by 1, 2;
/*
-- first two weeks of April saw surge in traffic, Easter(Apr 8th) could have contributed to it. 
-- weeks starting  18 Nov and 25 Nov saw surge in traffic and orders due to Black Friday and Cyber Monday (seasonal traffic surge).
-- relatively higher volume and orders in December as well leading up to Christmas.
*/

-- 2. Analyzing business patterns
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
/*
-- weekdays are most busy from 9am to 5pm.
-- weekends are less busy but relatively receive higher volumes between 9am-5pm. Sunday sees a spike of volume from 8pm-11pm. 
*/