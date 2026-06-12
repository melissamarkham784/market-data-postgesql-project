#Market Data Support & Analytics Project (PostgreSQL)

##Project Overview
This project simulates a Market Data Support and Application Support environment using PostgreSQL and historical ETF pricing data.
It replicates operational responsibilities commonly found in trade floor support teams, including:
Market data ingestion
Data validation and integrity checks
Troubleshooting import and schema failures
Monitoring data quality issues
Supporting financial time-series analysis
Creating technical documentation and support procedures
The dataset currently consists of historical SPY ETF (S&P 500 index tracking) market data sourced from Kaggle.

##Environment
###Database
PostgreSQL
###Database Client
DBeaver
###Data Source
Historical SPY ETF market data (Kaggle)

##Data Model
###Table: market_prices
Fields:
date
ticker
open_price
high_price
low_price
close_price
adjusted_close
volume
data_source
load_timestamp

##Data Ingestion Process
###Objective
Load historical SPY ETF market data into PostgreSQL for validation, analysis, and simulation of a market data support environment.
###Source Data (CSV)
Open
High
Low
Close
Volume
Date
###Target Schema Mapping
CSV fields were manually mapped in DBeaver to PostgreSQL schema:
CSV Field
Database Field
Open
open_price
High
high_price
Low
low_price
Close
close_price
Volume
volume
Date
date


##Data Ingestion Troubleshooting
###Issue 1: Column Naming Mismatch
####Symptoms
CSV column names did not match database schema.
Examples:
Open vs open_price
High vs high_price
Close vs close_price
####Investigation
Reviewed DBeaver import configuration and confirmed schema mismatch between source and target.
####Resolution
Manually mapped CSV fields to corresponding database columns during the import process.
####Learning Outcome

###Issue 2: Missing Required Field (ticker)
####Symptoms
Import process failed due to:
null value in column "ticker" violates not-null constraint
####Investigation
The CSV dataset did not include a ticker column, while the initial database schema defined ticker as:
NOT NULL
part of a composite primary key (date, ticker)
This caused the ingestion process to fail because PostgreSQL attempted to insert NULL values for a required field.
Attempts to modify constraints directly resulted in errors due to primary key dependency.
####Resolution
To resolve the ingestion issue, the table was dropped and recreated with a more flexible schema:
CREATE TABLE market_prices (
date DATE,
ticker VARCHAR(10),
open_price NUMERIC,
high_price NUMERIC,
low_price NUMERIC,
close_price NUMERIC,
adjusted_close NUMERIC,
volume BIGINT,
data_source VARCHAR(50),
load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
After successful data ingestion, the missing ticker values were populated:
UPDATE market_prices
SET ticker = 'SPY'
WHERE ticker IS NULL;
####Learning Outcome

Primary keys enforce both uniqueness and non-null constraints. Schema design must be considered before ingestion to avoid structural conflicts.



##Data Quality & Validation
To simulate market data support monitoring, the following validation queries were implemented:
###OHLC Integrity Check
Ensures market structure validity:

SELECT *
FROM market_prices
WHERE high_price < low_price;
SELECT *
FROM market_prices
WHERE close_price > high_price
  OR close_price < low_price;
###Volume Anomaly Check
Detects missing or invalid feed data:

SELECT *
FROM market_prices
WHERE volume = 0 OR volume IS NULL;
###Time Series Exploration
Basic ordering by date:

SELECT *
FROM market_prices
ORDER BY "date";
###Data Recency Check
Checks if data feed is up to date:


SELECT
    ticker,
    MAX("date") AS last_available_date,
    CURRENT_DATE - MAX("date") AS days_since_last_update
FROM market_prices
GROUP BY ticker;
###Missing Data Detection
Detects incomplete market data rows:


SELECT *
FROM market_prices
WHERE open_price IS NULL
   OR close_price IS NULL
   OR high_price IS NULL
   OR low_price IS NULL;
###Duplicate Record Detection
Finds duplicate market data entries:


SELECT
    date,
    ticker,
    COUNT(*)
FROM market_prices
GROUP BY date, ticker
HAVING COUNT(*) > 1;
###Market Data Overview
Summary of dataset health:


SELECT
    ticker,
    COUNT(*) AS total_rows,
    MIN("date") AS start_date,
    MAX("date") AS end_date,
    AVG((close_price - open_price) / open_price) AS avg_daily_return
FROM market_prices
GROUP BY ticker;



##Financial Analysis
The dataset is now being used for exploratory financial analysis and performance monitoring.
###Daily Return Calculation
Calculates the daily percentage change in SPY price to show how much the value moves each day:

SELECT
   "date",
   open_price,
   close_price,
   (close_price - open_price) / open_price AS daily_return
FROM market_prices
WHERE ticker = 'SPY'
ORDER BY "date";
###Average Daily Return
Shows the average daily performance of SPY over the dataset period.

SELECT AVG((close_price - open_price) / open_price) AS avg_daily_return
FROM market_prices
WHERE ticker = 'SPY';
###Volatility Measurement
Measures how much SPY’s daily returns vary, showing how stable or volatile the asset is.:

SELECT STDDEV((close_price - open_price) / open_price) AS volatility
FROM market_prices
WHERE ticker = 'SPY';
###Top 5 Performing Days
Identifies the 5 days where SPY had the strongest positive price movements:

SELECT
   "date",
   open_price,
   close_price,
   (close_price - open_price) / open_price AS daily_return
FROM market_prices
WHERE ticker = 'SPY'
ORDER BY daily_return DESC
LIMIT 5;




##Post-Import Troubleshooting
###Issue 3: View Visibility and Metadata Synchronisation
####Symptoms
A database view named market_prices_analysis was created to simplify analytical queries and prepare data for Tableau visualisation:
CREATE VIEW market_prices_analysis AS
SELECT
"date",
ticker,
open_price,
high_price,
low_price,
close_price,
volume,
(close_price - open_price) / open_price AS daily_return
FROM market_prices;
When querying the view, DBeaver reported that the object could not be found and displayed warning indicators despite the view having been created successfully.
####Investigation
The view was verified using PostgreSQL system metadata:
SELECT table_name
FROM information_schema.views
WHERE table_schema = 'public';
The query confirmed that market_prices_analysis existed within the database.
####Root Cause
The issue was caused by a metadata synchronisation problem between DBeaver and PostgreSQL. The database contained the view, but the active DBeaver session had not refreshed its object metadata.
####Resolution

The database connection was disconnected and reconnected, forcing DBeaver to refresh its metadata cache and synchronise with the PostgreSQL catalogue.
####Learning Outcome
This issue demonstrated the importance of distinguishing between database-level problems and client application behaviour. Troubleshooting required validation at both the database and application layers.
###Issue 4: Source Data Quality Investigation

####Symptoms

During validation of the imported SPY dataset, unusual trading date patterns were identified.
Trading dates were reviewed using SQL queries to verify chronological consistency and identify potential anomalies:
SELECT
"date",
TO_CHAR("date", 'Day') AS day_name
FROM market_prices
ORDER BY "date"
LIMIT 20;
The dataset contained Sunday records while some expected Friday records were absent. E.g.,
1993-01-28 (Thursday)
1993-01-31 (Sunday)
1993-02-01 (Monday)
####Investigation
Cross-referencing the source dataset against Yahoo Finance revealed additional inconsistencies beyond missing trading days.
It was observed that:
Price values appear shifted by approximately one trading day
OHLC values (open, high, low, close) do not consistently align with external market data
Example:
Database date shows 27/03/2025 open price
Yahoo Finance shows the same price corresponds to 28/03/2025
Thus, two core issues were identified:
Time-series misalignment
Trading data appears shifted by one business day
Some expected trading dates are missing entirely
OHLC inconsistency
High and low values do not consistently align with reference market data
Suggests potential structural misalignment in source dataset construction

####Root Cause
Further investigation confirmed that the dates stored within PostgreSQL matched the dates contained within the original CSV source file.
The anomaly originated from the source dataset rather than the PostgreSQL import process.
Likely causes include:
Incorrect time-series indexing during dataset creation
Row shifting during preprocessing or export
Structural issues in the original Kaggle dataset pipeline
####Resolution
The issue has been documented as a data integrity concern.
The dataset is considered suitable only for:
exploratory analysis
data quality simulation
support-style anomaly detection
It is not suitable for production-grade financial accuracy without correction or replacement.
####Learning Outcome
This investigation demonstrates the importance of validating financial datasets against authoritative external sources.
In market data and application support environments, time-series integrity and OHLC consistency are critical, as even minor misalignment can impact downstream analytics, reporting, and decision-making systems.


##Current Project Status

###Completed
PostgreSQL environment setup and configuration
Creation of market_prices relational schema
SPY ETF dataset ingestion (Kaggle source)
Data mapping and transformation of CSV fields to SQL schema
Post-ingestion data correction and ticker standardisation
Development of initial data quality validation checks (OHLC, missing values, volume anomalies)
Implementation of financial time-series analysis queries (returns, volatility, trend analysis)
Tableau dashboard development for visualisation of price trends, returns, and data quality KPIs
###In Progress
Expansion towards a multi-asset dataset (QQQ, GLD planned)
Refinement of anomaly detection queries for improved data quality monitoring
Enhancement of KPI calculations for more granular exception tracking
###Upcoming Phase
Cross-asset analysis (SPY vs QQQ vs GLD comparative performance)
Development of an advanced “market data health monitoring” layer with detailed error diagnostics
Integration of improved or alternative data sources to address missing or misaligned market data issues
Enhancement of dashboard reporting layer for improved operational usability and clarity
Transition from high-level KPI monitoring to detailed exception-based reporting suitable for support workflows
