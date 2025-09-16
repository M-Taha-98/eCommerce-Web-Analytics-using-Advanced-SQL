# eCommerce-Web-Analytics-using-Advanced-SQL 📈

---


## 🔗 Project Overview  
The project undertakes analysis and optimization of website traffic, marketing channels, user behavior and product portfolio for an eCommerce retailer startup. As an eCommerce Database Analyst my job is to work alongside management including the CEO, the Head of Marketing, and the Website Manager to help steer the business. 

The project follows analysis and optimization of marketing channels, measuring and testing website conversion performance, and using data to understand the impact of new product launches as the business grows.


## 🛠️ Key Skills & Tools 

✅ **SQL Queries & Optimization** - Leveraged advanced SQL for in-depth data analysis, utilizing techniques such as CTEs for query simplification, temp tables for intermediate result staging, and data programs for building complex workflows.

✅ **Excel Data Model & Power Pivot** – Build data model in Excel by connecting to SQL database, used power pivot and charts to analyze and summarize business performance metrics. 

✅ **Business Reporting** – Thourough reporting of business growth and peformance metrics over three years of operation, with key insights and recommendations.

✅ **Stakeholder Presentation** – In-depth stakeholder presentation for the business board and potential investor utilizing data storytelling principles.


## 📊 Project Breakdown  

### 🔹 **1. Traffic Source Analysis**  
- Conducted analysis of acquisition channels and their performance metrics.
- Recommended strategic bid modifications to enhance marketing ROI.

### 🔹 **2. Website Performance Analysis**  
- Analyzed site engagement and conversion data at the webpage level.
- Developed and assessed conversion funnels to identify and improve critical user pathways.

### 🔹 **3. Channel Portfolio Analysis**  
- Investigated performance trends and seasonal fluctuations across paid, organic and direct channels.
- Performed time-series analyses to uncover business patterns and seasonality.

### 🔹 **4. Product Level Analysis**  
- Evaluated sales performance, product affinity, and return rates.
- Pinpointed crucial success indicators for product portfolio optimization.

### 🔹 **5. User Level Analysis**  
- Analyzed customer retention and repeat-visit behavior.
- Mapped the acquisition paths of high-value user segments.

<br>

## 📆 Excel Data Model

<div align="center">
<img width="658" height="552" alt="image" src="https://github.com/M-Taha-98/eCommerce-Web-Analytics-using-Advanced-SQL/blob/main/snippets/data%20model%20snap.png" />
</div>

<br>

⚙️ DAX calculations:
  - Sample of Measures (Check out [here](https://github.com/M-Taha-98/eCommerce-Web-Analytics-using-Advanced-SQL/blob/main/DAX_measures.md) for complete list of DAX measures):
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


## 📃 Business Reporting
An in-depth project report has been created, detailing the findings and business recommendations. Please see the full report [here](https://github.com/M-Taha-98/eCommerce-Web-Analytics-using-Advanced-SQL/blob/main/Project%20Report_Advanced%20SQL.pdf) for a complete analysis.

<div align="center">
<img width="658" height="552" alt="image" src="https://github.com/M-Taha-98/eCommerce-Web-Analytics-using-Advanced-SQL/blob/main/snippets/report%20snap.png" />
</div>

<br>

## 📊 Stakeholder Presentation
A comprehensive stakeholder presentation, summarizing the key insights. View the full slide deck [here](https://github.com/M-Taha-98/eCommerce-Web-Analytics-using-Advanced-SQL/blob/main/Presentation.pptx) for the complete overview.

<div align="center">
<img width="658" height="552" alt="image" src="https://github.com/M-Taha-98/eCommerce-Web-Analytics-using-Advanced-SQL/blob/main/snippets/presentation%20snap.png" />
</div>

<br>


## 📂 Repository Structure  
```
📂 eCommerce-Web-Analytics-using-Advanced-SQL
│── 📂 snippets
│
│── 📂 sql-scripts
│   ├── 1. Traffic Source Analysis.sql
│   ├── 2. Website Performance Analysis.sql
│   ├── 3. Channel Portfolio Management.sql
│   ├── 4. Patterns & Seasonality.sql
│   ├── 5. Product Analysis.sql
│   ├── 6. User Analysis.sql
│
│   ├── DAX_measures.md
│   ├── Presentation.pptx
│   ├── Project Report_Advanced SQL.pdf
│
│── README.md

```

📌 **Check out the complete [SQL scripts](https://github.com/M-Taha-98/eCommerce-Web-Analytics-using-Advanced-SQL/tree/main/sql-scripts), report and presentation to explore the analysis in detail!**  

___

<div align="center">
  
[![View LinkedIn Profile](https://img.shields.io/badge/View%20Profile%20on-LinkedIn-0077B5?logo=linkedin&logoColor=white)](https://www.linkedin.com/in/mohammadtaha-businessanalytics/)
  
</div>
