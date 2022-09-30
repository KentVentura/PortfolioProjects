/*

QUERIES USED FOR TABLEAU PROJECT (Covid19 Infection and Death Analysis)


*/


-- 1. Total number of cases/deaths and Death rate

SELECT
	SUM(new_cases) AS total_cases,
	SUM(CAST(new_deaths AS int)) AS total_deaths,
	SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM coviddeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- for double checking just to make sure our numbers are correct.
-- we will include in where clause location = "world"

SELECT
	SUM(new_cases) AS total_cases,
	SUM(CAST(new_deaths AS int)) AS total_deaths,
	SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM coviddeaths
WHERE location = 'world'
ORDER BY 1,2


--2 We clean our Data set and Filter the location to "Continents" only

-- We take these out as they are not included in the above queries and want to stay consistent
-- European Union is part of Europe

SELECT
	location,
	SUM(CAST(new_deaths AS int)) AS TotalDeathCount
FROM coviddeaths
WHERE continent IS NULL
	AND location NOT IN ('world','European Union','International')
GROUP BY location
ORDER BY TotalDeathCount DESC


-- 3. Infection count and Infection rate per Country and population
SELECT
	location,
	population,
	MAX(total_cases) AS HighestInfectionCount,
	MAX((total_cases/population))*100 AS PopulationInfectedRate
FROM coviddeaths
GROUP BY location,population
ORDER BY PopulationInfectedRate DESC


-- 4. Infection count and Infection rate per Country and population with DATE

SELECT
	location,
	population,
	date,
	MAX(total_cases) AS HighestInfectionCount,
	MAX((total_cases/population))*100 AS PopulationInfectedRate
FROM coviddeaths
GROUP BY location,population, date
ORDER BY PopulationInfectedRate DESC
