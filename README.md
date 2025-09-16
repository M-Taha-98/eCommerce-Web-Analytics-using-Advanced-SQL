# eCommerce-Web-Analytics-using-Advanced-SQL 📈

---


## 🔗 Project Overview  
The project undertakes analysis and optimization of website traffic, marketing channels, user behavior and product portfolio for an online retailer startup. As an eCommerce Database Analyst my job is to work alongside management including the CEO, the Head of Marketing, and the Website Manager to help steer the business. 

The project follows analysis and optimization of marketing channels, measuring and testing website conversion performance, and using data to understand the impact of new product launches as the business grows.


## 🛠️ Key Skills & Tools 

✅ **SQL Queries & Optimization** - Leveraged advanced SQL for in-depth data analysis, utilizing techniques such as CTEs for query simplification, temp tables for intermediate result staging, and data programs to building complex workflows.

✅ **Excel Data Model & Power Pivot** – Build data model in Excel by connecting to SQL database, used power pivot and charts to analyze and summarize business performance metrics. 

✅ **Business Reporting** – Thourough reporting of business growth and peformance metrics over three years of operation, with key insights and recommendations.

✅ **Stakeholder Presentation** – In-depth stakeholder presentation for the business board and potential investor utilizing data storytelling principles.


## 📊 Project Breakdown  

### 🔹 **1. Traffic Analysis & Optimization**  
- Analyzed traffic sources and conversion rates.  
- Suggested bid adjustments to optimize marketing budgets.  

### 🔹 **2. Website Measurement & Conversion Funnel Analysis**  
- Evaluated page-level traffic and conversion performance.  
- Built and analyzed **conversion funnels** to optimize user journeys.  

### 🔹 **3. Channel Analysis & Optimization**  
- Explored **paid vs. free traffic** trends and seasonal variations.  
- Conducted **time-series analysis** for long-term insights.  

### 🔹 **4. Product-Level Analysis**  
- Assessed product sales, cross-selling patterns, and refund rates.  
- Identified key product performance metrics.  

### 🔹 **5. User-Level Analysis**  
- Studied repeat visitors and customer segmentation.  
- Identified high-value customers and their traffic sources.

## Excel Data Model

<div align="center">
<img width="658" height="552" alt="image" src="https://github.com/M-Taha-98/eCommerce-Web-Analytics-using-Advanced-SQL/blob/main/snippets/data%20model%20snap.png" />
</div>

<br>

⚙️ DAX calculations:
  - Sample of Measures (Check out for complete list of DAX measures):
```
 - Average order value = 

DIVIDE(SUM('mavenfuzzyfactory orders'[price_usd]), [orders])

 - Average revenue per session =

VAR revenue =
  CALCULATE(
  	SUM('mavenfuzzyfactory orders'[price_usd]), 
  	CROSSFILTER('mavenfuzzyfactory website_pageviews'[website_session_id], 'mavenfuzzyfactory orders'[website_session_id] , Both),
  	USERELATIONSHIP( 'mavenfuzzyfactory website_pageviews'[website_session_id], 'mavenfuzzyfactory orders'[website_session_id])
  	)

RETURN 
  DIVIDE(revenue, [sessions])

- Brand Conversion Rate = 

VAR brand_sessions = 
  CALCULATE(
       DISTINCTCOUNT('mavenfuzzyfactory website_sessions'[website_session_id]),
       'mavenfuzzyfactory website_sessions'[utm_campaign] = "brand"
  )

RETURN 
  DIVIDE([brand_order_count], brand_sessions)
```


## 📃 Project Report





## 📂 Repository Structure  
```
📂 Advanced-SQL-MySQL-for-Ecommerce-Data-Analysis
│── 📂 Executive Report
│   ├── Executive Report SQL-Data-Driven-eCommerce-Analysis.pdf
│
│── 📂 SQL Scripts
│   ├── 1. Traffic Source Analysis.sql
│   ├── 2. Website Performance Analysis.sql
│   ├── 3. Channel Portfolio Analysis & Optimization.sql
│   ├── 4.1 Products sales analysis.sql
│   ├── 4.2 Product Cross selling Analysis.sql
│   ├── 4.3 Product Portfolio Expansion Analysis.sql
│   ├── 4.4 Product Refund Rates Analysis.sql
│   ├── 5. User Analysis.sql
│
│── 📂 Dataset.zip
│   ├── create_mavenfuzzyfactory_vApril2022.sql
│   ├── preparing_workbench_vApril2022.sql
│
│── README.md

```

📌 **Check out the SQL scripts and reports to explore the analysis in detail!**  
