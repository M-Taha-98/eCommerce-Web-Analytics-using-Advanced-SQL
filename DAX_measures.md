⚙️ DAX measure calculations for Analysis & Excel Visualization:
```
 - avg_order_value = 

DIVIDE(SUM('mavenfuzzyfactory orders'[price_usd]), [orders])

 - avg_revenue_per_session =

VAR revenue =
  CALCULATE(
  	SUM('mavenfuzzyfactory orders'[price_usd]), 
  	CROSSFILTER('mavenfuzzyfactory website_pageviews'[website_session_id], 'mavenfuzzyfactory orders'[website_session_id] , Both),
  	USERELATIONSHIP( 'mavenfuzzyfactory website_pageviews'[website_session_id], 'mavenfuzzyfactory orders'[website_session_id])
  	)

RETURN 
  DIVIDE(revenue, [sessions])

- brand_cnv_rt =

VAR brand_sessions= 
  CALCULATE(
       DISTINCTCOUNT('mavenfuzzyfactory website_sessions'[website_session_id]),
       'mavenfuzzyfactory website_sessions'[utm_campaign] = "brand"
  )

RETURN 
  DIVIDE([brand_order_count], brand_sessions)

- brand_order_count =

  CALCULATE(
  	DISTINCTCOUNT( 'mavenfuzzyfactory orders'[order_id]),
  	'mavenfuzzyfactory website_sessions'[utm_campaign] = "brand"
  )

- bsearch_nonbrand_cnv_rt = 

VAR b_nonbrand_sessions = 
  CALCULATE(
  	DISTINCTCOUNT( 'mavenfuzzyfactory website_sessions'[website_session_id]),
  	'mavenfuzzyfactory website_sessions'[utm_source] = "bsearch",
  	'mavenfuzzyfactory website_sessions'[utm_campaign] = "nonbrand"
  		)

RETURN
  DIVIDE([bsearch_nonbrand_order_count], b_nonbrand_sessions)

- bsearch_nonbrand_order_count =
CALCULATE(
	DISTINCTCOUNT( 'mavenfuzzyfactory orders'[order_id]),
	'mavenfuzzyfactory website_sessions'[utm_source] = "bsearch",
	'mavenfuzzyfactory website_sessions'[utm_campaign] = "nonbrand"
)

- bsearch_sessions_pct =

DIVIDE(
	CALCULATE(
		DISTINCTCOUNT( 'mavenfuzzyfactory website_sessions'[website_session_id]),
		'mavenfuzzyfactory website_sessions'[utm_source] = "bsearch"
		),
	DISTINCTCOUNT('mavenfuzzyfactory website_sessions'[website_session_id])
)

- direct_cnv_rt =

VAR direct_sessions =
  CALCULATE(
  	DISTINCTCOUNT( 'mavenfuzzyfactory website_sessions'[website_session_id]),
  	'mavenfuzzyfactory website_sessions'[utm_source] = BLANK(),
  	'mavenfuzzyfactory website_sessions'[http_referer] = BLANK()
  )

RETURN 
  DIVIDE([direct_order_count], direct_sessions)

- direct_order_count =
  
  CALCULATE(
  	DISTINCTCOUNT( 'mavenfuzzyfactory orders'[order_id]),
  	'mavenfuzzyfactory website_sessions'[utm_source] = BLANK(),
  	'mavenfuzzyfactory website_sessions'[http_referer] = BLANK()
  )

- direct_sessions_pct =

DIVIDE(
	CALCULATE(
		DISTINCTCOUNT( 'mavenfuzzyfactory website_sessions'[website_session_id]),
		'mavenfuzzyfactory website_sessions'[utm_source] = BLANK(),
		'mavenfuzzyfactory website_sessions'[http_referer] = BLANK()
		),
	DISTINCTCOUNT('mavenfuzzyfactory website_sessions'[website_session_id])
)

- gsearch_nonbrand_cnv_rt =

VAR g_nonbrand_sessions = 
  CALCULATE(
  	DISTINCTCOUNT( 'mavenfuzzyfactory website_sessions'[website_session_id]),
  	'mavenfuzzyfactory website_sessions'[utm_source] = "gsearch",
  	'mavenfuzzyfactory website_sessions'[utm_campaign] = "nonbrand"
  		)

RETURN
  DIVIDE([gsearch_nonbrand_order_count], g_nonbrand_sessions)

- gsearch_nonbrand_order_count =

  CALCULATE(
  	DISTINCTCOUNT( 'mavenfuzzyfactory orders'[order_id]),
  	'mavenfuzzyfactory website_sessions'[utm_source] = "gsearch",
  	'mavenfuzzyfactory website_sessions'[utm_campaign] = "nonbrand"
  )

- gsearch_sessions_pct =

DIVIDE(
	CALCULATE(
		DISTINCTCOUNT( 'mavenfuzzyfactory website_sessions'[website_session_id]),
		'mavenfuzzyfactory website_sessions'[utm_source] = "gsearch"
		),
	DISTINCTCOUNT('mavenfuzzyfactory website_sessions'[website_session_id])
)

- order_count =

CALCULATE(
	DISTINCTCOUNT('mavenfuzzyfactory orders'[order_id]), 
	CROSSFILTER('mavenfuzzyfactory website_pageviews'[website_session_id],
	'mavenfuzzyfactory orders'[website_session_id] , Both),
	USERELATIONSHIP( 'mavenfuzzyfactory website_pageviews'[website_session_id],
	'mavenfuzzyfactory orders'[website_session_id])
	)

- organic_cnv_rt =

VAR organic_sessions =
  CALCULATE(
  	DISTINCTCOUNT('mavenfuzzyfactory website_sessions'[website_session_id]),
  	'mavenfuzzyfactory website_sessions'[utm_source] = BLANK(),
  	'mavenfuzzyfactory website_sessions'[http_referer] <> BLANK()
  	)
  	
RETURN
  DIVIDE([organic_order_count], organic_sessions)

- organic_order_count =

  CALCULATE(
  	DISTINCTCOUNT( 'mavenfuzzyfactory orders'[order_id]),
  	'mavenfuzzyfactory website_sessions'[utm_source] = BLANK(),
  	'mavenfuzzyfactory website_sessions'[http_referer] <> BLANK()
  	)

- organic_sessions_pct =

DIVIDE(
	CALCULATE(
		DISTINCTCOUNT( 'mavenfuzzyfactory website_sessions'[website_session_id]),
		'mavenfuzzyfactory website_sessions'[utm_source] = BLANK(),
		'mavenfuzzyfactory website_sessions'[http_referer] <> BLANK()
	),
	DISTINCTCOUNT('mavenfuzzyfactory website_sessions'[website_session_id])
)

- QoQ_cnv_rt =

VAR CurrentQuarterCnv = [session_to_order_cnv]

VAR  PreviousQuarterCnv = 
	CALCULATE (
	[session_to_order_cnv] ,
	DATEADD('calendar'[Date], -1, QUARTER))
 
RETURN
  DIVIDE (CurrentQuarterCnv - PreviousQuarterCnv, PreviousQuarterCnv)

- revenue_per_session =

VAR revenue = SUM('mavenfuzzyfactory orders'[price_usd])

RETURN
  DIVIDE(revenue, [sessions])

- sessions =

DISTINCTCOUNT('mavenfuzzyfactory website_pageviews'[website_session_id])

- sessions_MoM =

VAR CurrentMonthSessions= DISTINCTCOUNT('mavenfuzzyfactory website_sessions'[website_session_id])

VAR PreviousMonthSessions =  
			CALCULATE (
			        DISTINCTCOUNT('mavenfuzzyfactory website_sessions'[website_session_id]) ,
			        DATEADD ('calendar'[Date], -1, MONTH ))

RETURN 
	DIVIDE (CurrentMonthSessions - PreviousMonthSessions, PreviousMonthSessions)

- session_to_order_cnv =

DIVIDE(
 	DISTINCTCOUNT('mavenfuzzyfactory orders'[order_id]), 
	DISTINCTCOUNT('mavenfuzzyfactory website_sessions'[website_session_id])
)

- total_revenue_2 =

  CALCULATE(
  	SUM('mavenfuzzyfactory orders'[price_usd]), 
  	CROSSFILTER('mavenfuzzyfactory website_pageviews'[website_session_id],
  	'mavenfuzzyfactory orders'[website_session_id] , Both),
  	USERELATIONSHIP( 'mavenfuzzyfactory website_pageviews'[website_session_id],
  	'mavenfuzzyfactory orders'[website_session_id])
  	)

- unpaid_sessions_pct =

DIVIDE(
	CALCULATE(
		DISTINCTCOUNT( 'mavenfuzzyfactory website_sessions'[website_session_id]),
		'mavenfuzzyfactory website_sessions'[utm_source] = BLANK()	),
	DISTINCTCOUNT('mavenfuzzyfactory website_sessions'[website_session_id])
)

- x_sell_prod1 =

DIVIDE(
 CALCULATE(
	DISTINCTCOUNT('mavenfuzzyfactory order_items'[order_id]),
	'mavenfuzzyfactory order_items'[product_id]= 1
	),
	CALCULATE(
	DISTINCTCOUNT('mavenfuzzyfactory orders'[order_id])
	)
)

- x_sell_prod2 =

DIVIDE(
 CALCULATE(
	DISTINCTCOUNT('mavenfuzzyfactory order_items'[order_id]),
	'mavenfuzzyfactory order_items'[product_id]= 2
	),
	CALCULATE(
	DISTINCTCOUNT('mavenfuzzyfactory orders'[order_id])
	)
)

- x_sell_prod3 =

DIVIDE(
 CALCULATE(
	DISTINCTCOUNT('mavenfuzzyfactory order_items'[order_id]),
	'mavenfuzzyfactory order_items'[product_id]= 3
	),
	CALCULATE(
	DISTINCTCOUNT('mavenfuzzyfactory orders'[order_id])
	)
)

- x_sell_prod4 =

DIVIDE(
 CALCULATE(
	DISTINCTCOUNT('mavenfuzzyfactory order_items'[order_id]),
	'mavenfuzzyfactory order_items'[product_id]= 4
	),
	CALCULATE(
	DISTINCTCOUNT('mavenfuzzyfactory orders'[order_id])
	)
)
