# 🏛️ SQL Data Warehouse: End-to-End E-Commerce Analytics

Welcome to the **Data Warehouse and Analytics Project** repository! 
This project demonstrates a comprehensive data warehousing and analytics solution, from building a robust pipeline to generating actionable business insights. Designed as a portfolio highlight, it showcases industry best practices in data engineering and SQL-based analytics.

----

## 🎯 Project Overview

### 🛠️ Building the Data Warehouse (Data Engineering)
**Objective:** Develop a modern data warehouse using **SQL Server** to consolidate sales data, enabling analytical reporting and informed decision-making.

* **Data Sources:** CSV flat files.
* **Data Quality:** Systematic cleansing and anomaly resolution.
* **Integration:** Star Schema architecture for high-performance analytical queries.
* **Scope:** Latest-state snapshot (non-historized) for streamlined reporting.
* **Documentation:** Comprehensive technical mapping for business and tech stakeholders.

### 📈 BI: Analytics & Reporting (Data Analytics)
**Objective:** Develop SQL-based analytics to deliver deep-dive insights into:
* **Customer Behavior** (Segmentation & Lifecycle)
* **Product Performance** (Revenue & Volume analysis)
* **Sales Trends** (Temporal growth patterns)

----

## 🏗️ Data Architecture
This project implements the **Medallion Architecture**, progressing through Bronze, Silver, and Gold layers to ensure data reliability.



1.  **🥉 Bronze Layer:** Immutable landing zone. Raw data ingested "as-is" from CSV sources.
2.  **🥈 Silver Layer:** The refinery. Data cleansing, standardization, and normalization.
3.  **🥇 Gold Layer:** Business-ready zone. Optimized **Star Schema** utilizing SQL Views for reporting.

----

# 🛒 Olist E-Commerce Analytics Hub

## 📊 Dataset Overview
* **Source:** [Olist E-Commerce Public Dataset on Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
* **Context:** Real commercial data from **100,000 orders** (2016–2018) in Brazil.
* **Structure:** 9 interconnected tables forming a robust relational schema.

---
## 🛠️ Tech Stack & Tools
The following tools were leveraged to build this end-to-end analytical solution:

* **💾 SQL Server 2022**: Primary Database Engine used for the Data Warehouse (Bronze, Silver, and Gold layers).
* **📐 Draw.io**: Used for designing the **Data Architecture** and **Star Schema** ERD.
* **📓 Notion**: Utilized for project management, technical documentation, and tracking data mapping requirements.
* **🤖 Gemini AI**: Employed as a technical co-pilot for optimizing SQL queries and refining documentation logic.

---

## 📂 Repository Structure
* `📁 datasets`: Placeholder for raw CSV data.
* `📁 documents`: Project documentation including **Data Catalog**, **Data Flow**, and **Star Schema** diagrams.
* `📁 scripts`:
    * `📁 bronze`: DDLs and Bulk Load scripts for raw ingestion.
    * `📁 silver`: DDLs and stored procedures for data refinement.
    * `📁 gold`: DDLs for business-ready Star Schema views.
* `📁 tests`: Dedicated SQL scripts for **Quality Checks** on the Silver and Gold layers.

---

## ⚖️ License
This project is licensed under the **MIT License**. You are free to use, modify, and share this project with proper attribution.

---

## 👨‍💻 About Me
**Hruday Bhaskar Madanu** *Data Analytics Enthusiast | Former Operations Professional*

I am a **B.Com (Computer Applications)** graduate from Gauthami Degree College (Osmania University) with a passion for transforming raw numbers into strategic narratives. 

* **The Transition:** After 1.5 years as a **Trust & Safety Associate at Accenture**, I developed a sharp eye for data patterns and integrity. I am now pivoting my career into **Data Analytics**, bridging my operational experience with technical SQL expertise.
* **My Philosophy:** I believe data is only as good as its integrity. This project reflects my commitment to building "Gold Standard" data models that businesses can trust implicitly.

## 📫 Let's Connect!
* www.linkedin.com/in/hruday-bhaskar-madanu
* hrudaybhaskar45@gmail.com
