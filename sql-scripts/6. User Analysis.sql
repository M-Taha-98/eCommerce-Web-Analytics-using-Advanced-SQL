											-- ---------------------------------
											-- 			USER ANALYSIS
											-- ---------------------------------

-- ***************************************
	# Repeat purchase behaviour analysis
-- ***************************************

-- 1. Identifying repeat visitors:

--  limit analysis to users only who had first_sesion in the time frame defined

with repeat_session_summary as (
select user_id,
	 count(case when is_repeat_session = 1 then website_session_id else null end) as num_of_repeat_sessions
from website_sessions
where created_at < '2014-11-01'
      and user_id in  (select distinct user_id
					   from website_sessions
					   where is_repeat_session = 0
						 and created_at between '2014-01-01' and '2014-11-01')
group by 1
)
select num_of_repeat_sessions as repeat_sessions,
	   count(distinct user_id) as users
from repeat_session_summary
group by 1;
/*
-- a fair number of our customers do come back to our site after the first session. 
*/

-- 2. Analyzing repeat behavior:

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
/*
-- users on avg take about a month to come back to the website.
*/

-- 3. New v.s repeat channel patterns:

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
/*
-- one-third of repeat customers are coming back via paid_brand channel, which potantially means we’re paying for these customers 
   with paid search brand ads multiple times. 
-- but brand clicks are cheaper than nonbrand. So all in all, we’re not paying very much for these subsequent visits.
*/

-- 4. New v.s repeat performance:

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
/*
-- repeat sessions do convert to orders more than first sessions, which is expected behavior since repeat user is higher intent customer.
-- interestingly, repeat sessions bring in nearly 20% more revenue per session than first sessions.
*/