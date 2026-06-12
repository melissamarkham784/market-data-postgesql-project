

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

SELECT * 
FROM market_prices;

UPDATE market_prices
SET ticker = 'SPY'
WHERE ticker is NULL;

SELECT * 
FROM market_prices;

SELECT open_price 
FROM market_prices;

SELECT  open_price, 
		close_price 
FROM market_prices;

SELECT * 
FROM market_prices;


SELECT  open_price, 
		close_price 
FROM market_prices
WHERE "date" 
BETWEEN '1993-01-28' AND '1993-02-10';

SELECT * 
FROM market_prices
ORDER BY "date";

SELECT * 
FROM market_prices
WHERE high_price < low_price;

SELECT * FROM market_prices
WHERE close_price > high_price
   OR close_price < low_price;

SELECT * FROM market_prices
WHERE volume = 0 OR volume IS NULL;

SELECT * FROM market_prices;

select
    "date", open_price, close_price, (close_price - open_price) / open_price AS daily_return
FROM market_prices
WHERE ticker = 'SPY'
ORDER BY "date";

SELECT AVG((close_price - open_price) / open_price) AS avg_daily_return
FROM market_prices
WHERE ticker = 'SPY';

SELECT STDDEV((close_price - open_price) / open_price) AS volatility
FROM market_prices
WHERE ticker = 'SPY';

SELECT * 
FROM market_prices
WHERE ticker = 'SPY'
ORDER BY (close_price - open_price) / open_price DESC
LIMIT 5;

SELECT
    "date", open_price, close_price, (close_price - open_price) / open_price AS percentage
FROM market_prices
WHERE ticker = 'SPY'
ORDER BY percentage DESC
LIMIT 5;

select * FROM market_prices;

SELECT
    ticker,
    MAX("date") AS last_available_date,
    CURRENT_DATE - MAX("date") AS days_since_last_update
FROM  market_prices
GROUP BY ticker;

SELECT *
FROM market_prices
WHERE open_price IS NULL
   OR close_price IS NULL
   OR high_price IS NULL
   OR low_price IS NULL;

SELECT
    date,
    ticker,
    COUNT(*)
FROM market_prices
GROUP BY date, ticker
HAVING COUNT(*) > 1;

SELECT
    ticker,
    COUNT(*) AS total_rows,
    MIN("date") AS start_date,
    MAX("date") AS end_date,
    AVG((close_price - open_price) / open_price) AS avg_daily_return
FROM market_prices
GROUP BY ticker;

CREATE VIEW public.market_prices_analysis AS
SELECT
    "date",
    ticker,
    open_price,
    high_price,
    low_price,
    close_price,
    volume,
    (close_price - open_price) / open_price AS daily_return
FROM public.market_prices;

SELECT *
FROM public.market_prices_analysis
LIMIT 10;

SELECT *
FROM public.market_prices_analysis
LIMIT 10;

SELECT * FROM public.market_prices_analysis;

SELECT "date", EXTRACT(DOW FROM "date") AS day_of_week
FROM market_prices
ORDER BY "date"
LIMIT 20;

SELECT
    "date",
    TO_CHAR("date", 'Day') AS day_name
FROM market_prices
ORDER BY "date"
LIMIT 20;

SELECT "date"
FROM market_prices
ORDER BY "date"
LIMIT 20;

SELECT *
FROM market_prices
ORDER BY "date" DESC
LIMIT 20;

SELECT *
FROM market_prices
WHERE open_price IS NULL
   OR close_price IS NULL
   OR high_price IS NULL
   OR low_price IS NULL;

SELECT *
FROM market_prices
WHERE high_price < low_price
   OR close_price > high_price
   OR close_price < low_price;

