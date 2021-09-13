-- Data Trtansformation Queries

UPDATE Regions SET  MPI = a.MPI
FROM
(
	SELECT Country,   
	CASE
		WHEN MPI_Rural = 0 THEN MPI_Urban
		WHEN  MPI_Urban = 0 THEN MPI_Rural
		ELSE (MPI_Rural+MPI_Urban) / 2
		END AS MPI
		FROM MPI_National 
		WHERE Country IN
	    (SELECT Country FROM MPI_National WHERE Country IN (SELECT DISTINCT Country FROM Regions WHERE MPI IS NULL))
) a
WHERE Regions.Country = a.Country

SELECT * FROM Regions 

INSERT INTO Regions (Country)
       (SELECT Country FROM MPI_National WHERE Country NOT IN (SELECT DISTINCT Country FROM Regions))

SELECT * FROM Regions


SELECT Country, Region FROM Regions WHERE Country=Region

SELECT Country , Region, WorldRegion , ROUND(AVG(MPI),3) as MPI FROM Regions  
WHERE Country NOT IN (SELECT Country  FROM Regions WHERE Country=Region)
GROUP BY Country, Region, WorldRegion


INSERT INTO Regions (Country, Region, WorldRegion, MPI)
SELECT Country, Country, WorldRegion , ROUND(AVG(MPI),3)  FROM Regions  
WHERE Country NOT IN (SELECT Country  FROM Regions WHERE Country=Region)
GROUP BY Country, WorldRegion

SELECT * FROM Regions

INSERT INTO Regions VALUES ('Not Specified','Not Specified','Not Specified',NULL)

SELECT * FROM Loans

SELECT Country, Region, RegionID FROM Loans WHERE RegionID LIKE '#N/A'


UPDATE Loans SET Loans.RegionID = a.RegionID
FROM
(
	SELECT Country, RegionID FROM Regions WHERE Country=Region
) a
WHERE Loans.Country = a.Country and  Loans.RegionID LIKE '#N/A'


SELECT *  FROM Loans WHERE Country IN (SELECT DISTINCT Country FROM Regions)


UPDATE Loans SET RegionID = '1158' WHERE Country IN
(SELECT DISTINCT Country FROM Loans 
WHERE Country NOT IN (SELECT DISTINCT Country FROM Regions) AND  RegionID  LIKE  '#N/A')



SELECT DISTINCT Country, RegionID FROM Loans WHERE RegionID  LIKE  '#N/A'ORDER BY Country

SELECT DISTINCT Country, RegionID FROM Loans 
WHERE Country NOT IN (SELECT DISTINCT Country FROM Regions) AND  RegionID  LIKE  '#N/A'

SELECT  Country, RegionID FROM Loans 
WHERE Country NOT IN (SELECT DISTINCT Country FROM Regions) AND  RegionID

--Data Analysis Queries

--1. Countries with the lowest MPI
SELECT Country, AVG(MPI) FROM Regions GROUP BY Country ORDER BY  AVG(MPI) DESC

-- 2. Number of Loans for the Countries with the Highest MPI
SELECT Country, COUNT(*) AS NumOfLoans FROM Loans WHERE Country IN 
(SELECT Country FROM Regions GROUP BY Country HAVING AVG(MPI) >= 0.33)
GROUP BY Country ORDER BY NumOfLoans 



--3 Number of Loans for the Countries with the Lowest MPI
SELECT Country, COUNT(*) AS NumOfLoans FROM Loans WHERE Country IN 
(SELECT Country FROM Regions GROUP BY Country HAVING AVG(MPI) < 0.33)
GROUP BY Country ORDER BY NumOfLoans DESC

--4  Amount of Loans that  Countries with the Lowest MPI are getting
SELECT Country, FORMAT(SUM(LoanAmount),'#,###,###') AS TotalLoansAmt FROM Loans WHERE Country IN 
(SELECT Country FROM Regions GROUP BY Country HAVING AVG(MPI) > 0.33)
GROUP BY Country ORDER BY SUM(LoanAmount)

--5  Amount of Loans that  Countries with the Highest MPI are getting
SELECT Country, FORMAT(SUM(LoanAmount),'#,###,###') AS TotalLoansAmt FROM Loans WHERE Country IN 
(SELECT Country FROM Regions GROUP BY Country HAVING AVG(MPI) < 0.33)
GROUP BY Country ORDER BY SUM(LoanAmount) DESC

-- 6 Query 5 but with MPI values displayed 
SELECT r.Country, FORMAT(SUM(l.LoanAmount),'#,###,###') AS TotalLoansAmt , r.MPI
FROM Regions r JOIN Loans l ON r.RegionID=l.RegionID
GROUP BY r.Country, r.MPI
HAVING AVG(r.MPI) < 0.33
ORDER BY SUM(l.LoanAmount) DESC

-- 7 Query 4 but with MPI values displayed 
SELECT r.Country, FORMAT(SUM(l.LoanAmount),'#,###,###') AS TotalLoansAmt , r.MPI
FROM Regions r JOIN Loans l ON r.RegionID=l.RegionID
GROUP BY r.Country, r.MPI
HAVING AVG(r.MPI) > 0.33
ORDER BY SUM(l.LoanAmount)
 

--8 Countries  that do not have any  partners
SELECT Country, AVG(MPI) AS MPI 
FROM Regions
WHERE Country NOT IN (SELECT DISTINCT Country FROM Partners)
GROUP BY Country
ORDER BY 2 DESC
-- number of loabs for countries that have no partners 
SELECT Country, COUNT(*) AS NumOfLoans FROM Loans WHERE Country IN 
(SELECT Country
FROM Regions
WHERE Country NOT IN (SELECT DISTINCT Country FROM Partners)
GROUP BY Country)
GROUP BY Country ORDER BY NumOfLoans DESC


--9 Countrues Countries with high MPI that do not have any  partners
SELECT Country 
FROM Regions
WHERE Country NOT IN (SELECT DISTINCT Country FROM Partners)
GROUP BY Country
HAVING AVG(MPI) > 0.33

-- 10 Number of loans that these countries  in Query 9 have - they have none and their MPIs are high
SELECT Country, COUNT(*) AS NumOfLoans FROM Loans WHERE Country IN 
(SELECT Country 
FROM Regions
WHERE Country NOT IN (SELECT DISTINCT Country FROM Partners)
GROUP BY Country
HAVING AVG(MPI) > 0.33)
GROUP BY Country ORDER BY NumOfLoans 


--11 countries with less than 3 partners
SELECT DISTINCT Country, COUNT(PartnerID) AS NumOfPartners
FROM Partners GROUP BY Country HAVING  COUNT(PartnerID) < 3

--12 MPIs of These countries having less than 3 partners
SELECT p.Country, r.MPI, COUNT(p.PartnerID) AS NumOfPartners
FROM Regions r JOIN Partners p ON r.Country=p.Country
WHERE r.Country=r.Region
GROUP BY p.Country, r.MPI 
HAVING COUNT(p.PartnerID) < 3 

--13 MPIs of These countries having less than 3 partners and MPI > 0.33
SELECT p.Country, r.MPI, COUNT(p.PartnerID) AS NumOfPartners
FROM Regions r JOIN Partners p ON r.Country=p.Country
WHERE r.Country=r.Region
GROUP BY p.Country, r.MPI 
HAVING COUNT(p.PartnerID) < 3 AND r.MPI > 0.33

SELECT p.Country, r.MPI, COUNT(p.PartnerID) AS NumOfPartners
FROM Regions r JOIN Partners p ON r.RegionID=p.RegionID
GROUP BY p.Country, r.MPI 
HAVING COUNT(p.PartnerID) < 3 AND r.MPI > 0.33

--14 Number of loans that these countries in 13 Have 
SELECT country, count(*) AS NumLoans FROM loans GROUP BY country having country in 
('Timor-Leste','Burundi','Liberia','Somalia','Burkina Faso','South Sudan')

--15 Number of Partner per country
SELECT DISTINCT country, count(DISTINCT partnerid)  as NumOfPartners
FROM partners GROUP BY country ORDER BY count(DISTINCT partnerid) DESC
SELECT DISTINCT country, count(DISTINCT partnerid)  as NumOfPartners
FROM partners GROUP BY country ORDER BY country

--16  countries with more than 10 partners
SELECT DISTINCT Country, COUNT(PartnerID) AS NumOfPartners
FROM Partners GROUP BY Country HAVING  COUNT(PartnerID) > 10

-- 17 MPIs of These countries having  more than 10 partners
SELECT p.Country, r.MPI, COUNT(p.PartnerID) AS NumOfPartners
FROM Regions r JOIN Partners p ON r.RegionID=p.RegionID
GROUP BY p.Country, r.MPI 
HAVING COUNT(p.PartnerID) > 10 AND r.MPI IS NOT NULL

--18 Number of Loans for countries countries that have large number of partners have 
SELECT country, count(*) FROM loans GROUP BY country having country in 
('Mexico','Peru','Indonesia','Cambodia','Ghana','Kenya', 'Uganda')

-- 19 Repayment Schedule of Countries
SELECT r.RepaymentInterval, COUNT(l.RepaymentID) 
FROM Loans l JOIN Repayment r ON r.RepaymentID=l.RepaymentID
GROUP BY l.RepaymentID, r.RepaymentInterval


-- 20 Mean Repayment Period IN months for Countries with the Highest MPI
SELECT Country, AVG(LoanTerm) AS AvgLoanTerm FROM Loans WHERE Country IN 
(SELECT Country FROM Regions GROUP BY Country HAVING AVG(MPI) > 0.33)
GROUP BY Country ORDER BY SUM(LoanAmount)

SELECT country, year(loandate), count(*) FROM loans GROUP BY year(loandate) ,country HAVING country
in (SELECT country FROM regions GROUP BY country HAVING avg(mpi) >0.4) 
ORDER BY  country

--21 Number of loans  by year
SELECT YEAR(LoanDate) AS [Year], count(*) AS NumLoans FROM Loans GROUP BY YEAR(LoanDate)ORDER BY [Year]

--Number of loans for countries by year (Low MPI Countries)
SELECT YEAR(LoanDate), Country, COUNT(*) AS NumOfLoans FROM Loans 
WHERE Country IN 
(SELECT Country FROM Regions GROUP BY Country HAVING AVG(MPI) < 0.33)
GROUP BY Country, LoanDate
--ORDER BY NumOfLoans DESC
ORDER BY YEAR(LoanDate), NumOfLoans DESC

--Number of loans for countries by year (High MPI Countries)
SELECT YEAR(LoanDate), Country, COUNT(*) AS NumOfLoans FROM Loans 
WHERE Country IN 
(SELECT Country FROM Regions GROUP BY Country HAVING AVG(MPI) >= 0.33)
GROUP BY Country, LoanDate
--ORDER BY NumOfLoans DESC
ORDER BY YEAR(LoanDate), NumOfLoans DESC

--22 Number of loans for HIGH MPI countries
SELECT YEAR(LoanDate) AS [Year], count(*) AS NumLoans FROM Loans
WHERE Country IN (SELECT Country FROM regions GROUP BY Country HAVING AVG(MPI) > 0.33)
GROUP BY YEAR(LoanDate)
ORDER BY [Year]

--23 Number of loans for Low MPI countries
SELECT YEAR(LoanDate) AS [Year], count(*) AS NumLoans FROM Loans
WHERE Country IN (SELECT Country FROM regions GROUP BY Country HAVING AVG(MPI) <= 0.33)
GROUP BY YEAR(LoanDate)
ORDER BY [Year]

SELECT * FROM DeprivationsByCountry  

-- Find the Number of Loans Kiva has given based on Sectors
SELECT s.Sector, COUNT(*) AS NUMLoans FROM Sectors s JOIN Loans l ON s.SectorID=l.SectorID 
GROUP BY s.Sector

--Find out the number of loans Kiva has given based on  the Sectors that are related to MPI
SELECT s.Sector, COUNT(*) AS NUMLoans FROM Sectors s JOIN Loans l ON s.SectorID=l.SectorID 
GROUP BY s.Sector HAVING s.Sector IN ('Food', 'Health','Education', 'Housing')

--Find out the number of loans Kiva has given based on the Sectors that are related to MPI per country
SELECT s.Sector, l.Country, COUNT(*) AS NUMLoans FROM Sectors s JOIN Loans l ON s.SectorID=l.SectorID 
GROUP BY s.Sector, l.Country HAVING s.Sector IN ('Food', 'Health','Education', 'Housing')
ORDER BY Country

-- Find Number of Loans Kiva has given in The Education Sector per Country
SELECT Country, Count(*) AS NumLoans FROM Loans 
WHERE SectorID=12 OR 
Useid IN (SELECT DISTINCT useid FROM uses 
WHERE [use] LIKE '%school%' OR [use] LIKE '%educat%' OR [use] LIKE '%stud%' 
or [use] LIKE '%university%'  OR [use] LIKE '%tuition%')
GROUP BY Country ORDER BY Country

-- Find Number of Loans Kiva has given in The Living Conditions Deprivation per Country
SELECT Country, Count(*) AS NumLoans FROM Loans 
WHERE SectorID=14 OR 
Useid IN (SELECT DISTINCT useid FROM uses 
WHERE  [use] LIKE '%house%' OR  [use] LIKE '%renovate%' OR [use] LIKE '%solar%' 
or [use] LIKE '%appliance%' OR [use] LIKE '%furniture%' OR [use] LIKE '%lamp%' OR  [use] LIKE '%light%' 
or [use] LIKE '%bed%' OR  [use] LIKE '%refigerator%' OR [use] LIKE '%room%' OR [use] LIKE '%paint%'
or [use] LIKE '%television%' OR [use] LIKE '%roof%' OR [use] LIKE '%door%' OR [use] LIKE '%window%'
or [use] LIKE '%stove%'  OR [use] LIKE '%insulat%'  OR [use] LIKE '%motorc%' OR [use] LIKE '%sand%' 
or [use] LIKE '%brick%')
GROUP BY Country ORDER  BY Country

-- Find Number of Loans Kiva has given in The Electricity Sector per Country
SELECT Country, Count(*) AS NumLoans FROM Loans 
WHERE Useid IN (SELECT DISTINCT useid FROM uses 
WHERE  [use] LIKE '%electricity%' OR [use] LIKE '%electric%' OR [use] LIKE '%power%')
GROUP BY Country ORDER BY Country

-- Find Number of Loans Kiva has given in The Health Sector per Country
SELECT Country, Count(*) AS NumLoans FROM Loans 
WHERE SectorID=11 OR 
Useid IN (SELECT DISTINCT useid FROM uses 
WHERE  [use] LIKE '%health%'   OR [use] LIKE '%doctor%' OR [use] LIKE '%medic%' OR [use] LIKE '%sick%')
GROUP BY Country ORDER BY Country


-- Find Number of Loans Kiva has given in The Drinking Water Sector per Country
SELECT Country, Count(*) AS NumLoans FROM Loans 
WHERE Useid IN (SELECT DISTINCT useid FROM uses 
WHERE [use] LIKE '%water%' OR  [use] LIKE '%tank%' OR [use] LIKE '%filter%' OR [use] LIKE '%pipe%' OR 
[use] LIKE '%purif%')
GROUP BY Country
ORDER BY Country

-- Find Number of Loans Kiva has given in The Sanitation Sector per Country
SELECT Country, Count(*) AS NumLoans FROM Loans 
WHERE Useid IN (SELECT DISTINCT useid FROM uses 
WHERE [use] LIKE '%toilet%' OR  [use] LIKE '%bath%' OR [use] LIKE '%latrine%' OR 
[use] LIKE '%septic%') 
GROUP BY Country 
ORDER BY Country


--Find out the MPI of these Countries in DeprivationsByCountry
SELECT r.Country , AVG(r.MPI) FROM DeprivationsByCountry d JOIN Regions r ON d.Country=r.Country GROUP BY r.Country
