/* HERE I WILL BE DOING SOME DATA EXPLORATION WITH COVID_DEATHS TABLE
 WHERE I WILL BE SHOWING MY SKILLS OF AGGREGATE FUNCTIONS AND COVERTING DATA TYPE USING CAST AND CONVERT */


-- CALLING ENTIRE COVID DEATH DATA --
SELECT * FROM covid_deaths;

-- CLEANING THE DATA FOR NULL VALUES AND EMPTY VALUES--

UPDATE covid_deaths SET new_deaths=0 WHERE new_deaths IS NULL
UPDATE covid_deaths SET total_deaths=0 WHERE total_deaths IS NULL
UPDATE covid_deaths SET continent='Africa' WHERE location = 'Africa'
UPDATE covid_deaths SET continent='Asia' WHERE location = 'Asia'
UPDATE covid_deaths SET continent='North America' WHERE location = 'North America'
UPDATE covid_deaths SET continent='South America' WHERE location = 'South America'
UPDATE covid_deaths SET continent='Oceania' WHERE location = 'Oceania'
UPDATE covid_deaths SET continent='World' WHERE location = 'World'
UPDATE covid_deaths SET total_cases=0 WHERE total_cases is null
UPDATE covid_deaths SET new_cases =0 WHERE new_cases is null

-- WORLD POPULATION --

SELECT sum(distinct population) as WorldPopulation, continent  
FROM Covid_deaths 
WHERE continent is not NULL and continent = 'World'
GROUP BY continent, population;


-- CASES VS POPULATION PERCENTAGE -- 

SELECT location, population, sum(new_cases) 'total new cases', (sum(new_cases)/population)*100 'Case Percentage'
FROM covid_deaths
GROUP BY location, population 
ORDER BY location;


-- DEATHS VS POPULATION PERCENTAGE --

SELECT location, population, sum(cast (new_deaths as int)) 'Total New Deaths', (sum(cast (new_deaths as int))/population)*100 'Death Percentage'
FROM covid_deaths
GROUP BY location, population 
ORDER BY location;


-- DEATH PERCENTAGE VS CASES PERCENTAGE --

SELECT location, (sum(new_cases)/population)*100 'Case Percentage', (sum(cast (new_deaths as int))/population)*100 'Death Percentage'
FROM covid_deaths
group by location, population 
order by location;


-- DEATH RATE AMONG THE INFECTED  --

SELECT location, (sum(cast (new_deaths as int))/sum(new_cases))*100 'Death Rate among the Infected'
FROM covid_deaths
WHERE new_cases != 0
GROUP BY location
ORDER BY location;


-- COUNTRIES WITH HIGHEST DEATH COUNT -- 

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Covid_deaths
WHERE location != continent
GROUP BY Location
ORDER BY TotalDeathCount desc;


-- INDIA CASES VS TOTAL INDIA POPULATION --

SELECT location, population, sum(new_cases) 'Total cases in India', (sum(new_cases)/ population)*100 'India Case percentage'
FROM covid_deaths
WHERE location like 'India'
GROUP BY location, population;


-- CONTINENT WISE DEATH PERCENTAGE --

SELECT continent, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths,  sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage  
FROM Covid_deaths 
WHERE continent is not NULL AND continent != 'World'
GROUP BY continent
ORDER BY continent;


-- CALLING ENTIRE COVID VACCINATION DATA --

SELECT * FROM Covid_vaccinations;




/* HERE I WILL BE CALCULATING THE NEW VACCINATION VS POPULATION IN EACH DATE AND LOCATION (LIKE ROLLING THE COUNTS OF PEOPLE GETTING VACCINATED IN EACH DATE), 
WHERE I WILL BE SHOWING MY SKILLS OF "PARTITION BY", "JOINS", "CTEs" AND "TEMP TABLE" */



-- TOTAL POPULATION VS VACCINATION -- 
-- SHOWS PERCENTAGE OF POPULATION THAT HAS RECIEVED COVID VACCINATION --

SELECT cdea.continent, cdea.location, cdea.date, cdea.population, cvac.new_vaccinations, 
       SUM(CONVERT(bigint, cvac.new_vaccinations)) OVER (PARTITION BY cdea.location ORDER BY cdea.location, cdea.date) AS RollingVacCounts
	   --NOW TO CONVERT THIS INTO PERCENTAGE I WILL CREATE BOTH CTE AND TEMP TABLE 
FROM PortfolioProject..Covid_deaths  cdea
 JOIN PortfolioProject..Covid_vaccinations cvac
  ON cdea.location = cvac.location
  AND cdea.date = cvac.date 
WHERE cdea.continent IS NOT NULL
 ORDER BY cdea.location, cdea.date;



-- 1) USING CTE TO PERFORM CALCULATION ON "PARTITION BY" IN PREVIOUS QUERY --


WITH vacpop (continent, location, date, population, new_vaccinations, RollingVacCounts)
AS
(
SELECT cdea.continent, cdea.location, cdea.date, cdea.population, cvac.new_vaccinations, 
       SUM(CONVERT(bigint, cvac.new_vaccinations)) OVER (PARTITION BY cdea.location ORDER BY cdea.location, cdea.date) AS RollingVacCounts
	   --NOW TO CONVERT THIS INTO PERCENTAGE I WILL CREATE BOTH CTE AND TEMP TABLE 
FROM PortfolioProject..Covid_deaths  cdea
 JOIN PortfolioProject..Covid_vaccinations cvac
  ON cdea.location = cvac.location
  AND cdea.date = cvac.date 
WHERE cdea.continent IS NOT NULL
--ORDER BY cdea.location;
)
SELECT *, RollingVacCounts/population * 100 AS VacPercentage
 FROM vacpop
  ORDER BY location, date asc;



-- 2) USING TEMP TABLE TO PERFORM CALCULATION ON PARTITION BY IN PREVIOUS QUERY --


DROP TABLE IF EXISTS #vacpopulation    /* JUST IN CASE IF THIS TABLE PRE-EXISTS */
CREATE TABLE #vacpopulation
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingVacCounts numeric
)
INSERT INTO #vacpopulation
SELECT cdea.continent, cdea.location, cdea.date, cdea.population, cvac.new_vaccinations, 
       SUM(CONVERT(bigint, cvac.new_vaccinations)) OVER (PARTITION BY cdea.location ORDER BY cdea.location, cdea.date) AS RollingVacCounts
	   --NOW TO CONVERT THIS INTO PERCENTAGE I WILL CREATE BOTH CTE AND TEMP TABLE 
FROM PortfolioProject..Covid_deaths  cdea
 JOIN PortfolioProject..Covid_vaccinations cvac
  ON cdea.location = cvac.location
  AND cdea.date = cvac.date 
--WHERE cdea.continent IS NOT NULL
--ORDER BY cdea.location;

SELECT*, RollingVacCounts/population * 100 AS VacPercentage
 FROM #vacpopulation
  ORDER BY location, date asc;



-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS --


CREATE VIEW vacpopulation AS 
SELECT cdea.continent, cdea.location, cdea.date, cdea.population, cvac.new_vaccinations, 
       SUM(CONVERT(bigint, cvac.new_vaccinations)) OVER (PARTITION BY cdea.location ORDER BY cdea.location, cdea.date) AS RollingVacCounts
	   --NOW TO CONVERT THIS INTO PERCENTAGE I WILL CREATE BOTH CTE AND TEMP TABLE 
FROM PortfolioProject..Covid_deaths  cdea
 JOIN PortfolioProject..Covid_vaccinations cvac
  ON cdea.location = cvac.location
  AND cdea.date = cvac.date 
WHERE cdea.continent IS NOT NULL;


