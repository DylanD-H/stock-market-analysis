# Stock Market Analysis | 2025 Data Engineering Zoomcamp Project

## Project Overview
This project analyzes the US stock market using historical price data and quarterly financial reports. The primary goal is to uncover insights into sector performance and stock market trends. By building an end-to-end data pipeline, we process and visualize the data using a clear and accessible dashboard.

For information on setting up the project see [Setup](/setup/README.md)
## Technologies Used
- Cloud Provider: Google Cloud Platform (GCP)

- Data Lake: Google Cloud Storage (GCS)
- Data Warehouse: BigQuery
- Orchestration & Infrastrcture as Code: Kestra
- Data Transformation: dbt
- Visualization: Looker Studio
- API Data Source: Alpha Vantage
  
## Pipeline
The data pipeline follows a batch processing model. It is divided into two main components: the Kestra pipeline and the dbt project.

### Kestra Pipeline

- The pipeline starts by creating necessary infrastructure using the **Create_GCP_KVs** flow. This flow generates key-value pairs for streamlined access to GCP resources.

- The **GCP_Infrastructure** flow then uses these values to create a Google Cloud Storage bucket and a BigQuery dataset.

- Once the infrastructure is ready, the **Initialization** flow downloads historical stock price data, quarterly balance sheets, and stock symbol information from the NASDAQ and NYSE exchanges. It uploads these datasets to the GCS bucket and creates external tables in BigQuery.

- The dbt project is then synced from the GitHub repository and built within BigQuery.

- Data updates are managed using the **Weekly_Price_Data** flow, which runs every Saturday at 8 AM UTC. It fetches new weekly data from my [stock-analysis-data repository](https://github.com/DylanD-H/stock-analysis-data), ensuring the data remains up to date.

### dbt Project

The dbt project consists of six models responsible for transforming and structuring data:

- **stg_priceData & stg_reports:**

  - Views that cast fields to correct data types.

  - Remove duplicates and unnecessary data.

  - Prepare data to be merged into fact tables.

- **fct_priceData:**

  - Incremental table partitioned by symbol.

  - Stores historical stock price data for all listed stocks.

  - Performs transformations to calculate previous day close price and intraday price change.

- **fct_quarterlyReports:**

  - Incremental table partitioned by symbol.

  - Stores key data from quarterly balance sheets.

  - Calculates historical market capitalization and filters out unreasonable data.

- **dim_stockInfo:**

  - Lookup table with stock information from both NASDAQ and NYSE.

  - Standardizes symbols and replaces NULL sectors with 'Other.'

- **agg_sectorPerformance:**

  - Aggregates sector-level data using market cap-weighted averages.

  - Calculates sector performance metrics by comparing weighted average closing values daily.

  - Filters outliers to ensure accurate analysis.

![image](https://github.com/user-attachments/assets/31f3500e-4c93-45f1-9d06-bc6e0f027af0)


## Dashboard
The dashboard consists of four primary visualizations:
1. **Cumulative Performance:**

    - Displays cumulative sector performance over time using market cap-weighted averages.

    - Helps identify sector growth trends and market volatility.

2. **Overall Performance:**

    - Provides a quick snapshot of the overall market performance for the selected period.

3. **Average Performance:**

    - Compares average sector performance between different weeks to identify short-term trends.

4. **Market Share:**

    - Visualizes the market share distribution of different sectors.

    - Helps assess sector dominance and diversity.

      
![image](https://github.com/user-attachments/assets/782367b2-3e14-4ad2-8fc7-75012c314e61)

[Link to dashboard](https://lookerstudio.google.com/s/lMJSiUFm3Bo)


