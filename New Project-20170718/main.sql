-- This would typically be in a separate schema but keeping things simple since this is SQLLite
CREATE TABLE IF NOT EXISTS TVPricesTemporary (
  TVModel VARCHAR(1024) NOT NULL,
  DateUpdated DATETIME NOT NULL,
  Price NUMBER(20,2) NOT NULL
);

-- The actual prices table
CREATE TABLE IF NOT EXISTS TVPrices (
  PriceId INTEGER PRIMARY KEY AUTOINCREMENT,
  TVModel VARCHAR(1024) NOT NULL,
  DateUpdated DATETIME NOT NULL,
  Price NUMBER(20,2) NOT NULL
);


-- Truncate then bulk load the records into the temp table
DELETE FROM TVPricesTemporary;
.mode csv
.import data.csv TVPricesTemporary

-- migrate all records over to actual table (would be a merge in typical code)
INSERT INTO TVPrices(TVModel, DateUpdated, Price)
SELECT TVModel, DateUpdated, Price FROM TVPricesTemporary;

.print ''
.print 'Problem 1: List The Table As Is'
.print ''
SELECT PriceId, TVModel, DateUpdated, Price FROM TVPrices;

.print ''
.print 'Problem 2: Sort by Update Date'
.print ''
SELECT PriceId, TVModel, DateUpdated, Price
FROM TVPrices
ORDER BY DateUpdated DESC;

.print ''
.print 'Problem 3: Get Unique TVModels (normally I would use a CTE but this will work)'
.print ''
SELECT lastPrice.PriceId, lastPrice.TVModel, lastPrice.DateUpdated, lastPrice.Price
FROM TVPrices lastPrice
    LEFT JOIN TVPrices currentPrice ON lastPrice.TVModel = currentPrice.TVModel and currentPrice.DateUpdated > lastPrice.dateUpdated
WHERE currentPrice.PriceId IS NULL;

-- this isn't too typical, but for replayability
DROP TABLE TVPricesTemporary;
DROP TABLE TVPrices;