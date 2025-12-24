# SQL Data Warehouse

Welcome to the **Data Warehouse and Analytics Project** repository!
This project demonstrates a comprehensive data warehousing and analytics solution, from building a data warehouse to generate actionable insights. Designed as a portfolio project, this highlights industry best practices in data engineering and analytics.

----

## Project Overview

### Building the Data Warehouse (Data Engineering)

#### Objectives
Develop a modern data warehouse using SQL Server to consolidate sales data, enabling analytical reporting and informed decision-making.

#### Specifications
- **Data Sources**: Import data from two source systems (ERP & CRM) provided as CSV files.
- **Data Quality**: Cleanse and resolve data quality issues prior to analysis.
- **Integration**: Combine both sources into a single, user-friendly data model designed for analytical queries.
- **Scope**: Focus on the latest dataset only; historization of data is not required.
- **Documentation**: Provide clear documentation of the data model to support both business stakeholders and analytics teams.

----

### BI: Analytics & Reporting (Data Analytics)

#### Objective
Develop SQL-based analytics to deliver detailed insights into:
- **Customer Behaviour**
- **Product performance**
- **Sales Trends**

These insights empower stakeholder with key business metrics, enabling strategic decision-making.

----
## Data Architecture
The data architecture for this project follows Medallion Architecture Bronze, Silver, and Gold layers.
<img width="936" height="583" alt="data_architecture" src="https://github.com/user-attachments/assets/82fe4f77-b649-48db-80a2-c44fcc90f764" />
- **1. Bronze Layer**: Stores raw data as-is from the source systems. Data is ingested from CSV files into SQl Server Database.
- **2. Silver Layer**: This layer includes data cleansing, standardization, and normalization processes to prepare data for analysis.
- **3. Gold Layer**: Houses business-ready data model into a star schema required for reporting and analytics.


## License
This project is licensed under the (MIT License). You are free to use, modify and share this project with proper attribution.

## About Me
Hi there! I'm **Hruday Bhaskar Madanu**. I'm a B.Com (CA) graduate from Gauthami Degree College under Osmania University. I worked as a Trust & Safety Associate at Accenture for 1.5 years. I wanted to build my career in the data analytics feild, as my interests are aligned with it.

