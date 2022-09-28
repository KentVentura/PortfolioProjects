SELECT
	*
FROM coviddeaths
WHERE continent IS NOT NULL
ORDER BY 3,4



-- Select Data that we are going to be using

SELECT
	Location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT
	Location,
	date,
	total_cases,
	total_deaths,
	(total_deaths/total_cases) * 100 AS Death_percentage
FROM dbo.CovidDeaths
WHERE location LIKE '%philippines%'
	AND continent IS NOT NULL
ORDER BY 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got infected by Covid19
SELECT
	Location,
	date,
	 population,
	total_cases,
	(total_cases/population) * 100 AS Infection_rate
FROM dbo.CovidDeaths
WHERE location LIKE '%philippines%'
	AND continent IS NOT NULL
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT
	Location,
	 population,
	MAX(total_cases) AS HighestInfectionCount,
	MAX((total_cases/population)) * 100 AS Infection_rate
FROM dbo.CovidDeaths
--WHERE location LIKE '%philippines%'
GROUP BY location,population
ORDER BY Infection_rate DESC


-- Showing Countries with the Highest Death Count per Population

SELECT
	Location,
	MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM dbo.CovidDeaths
--WHERE location LIKE '%philippines%'
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY TotalDeathCount DESC


-- LET'S BREAK THINGS DOWN BY CONTINENT

USE Portfolio_Project;

SELECT
	location,
	MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM dbo.CovidDeaths
--WHERE location LIKE '%philippines%'
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Showing the Continents with highest death count per population

SELECT
	continent,
	MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM dbo.CovidDeaths
--WHERE location LIKE '%philippines%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS

SELECT
	SUM(new_cases) AS total_cases,
	SUM(cast(new_deaths as INT)) AS total_deaths,
	SUM(cast(new_deaths as INT))/SUM(new_cases) * 100 AS death_percentage
FROM dbo.CovidDeaths
--WHERE location LIKE '%philippines%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

--Looking at Total Population vs Vaccinations

USE Portfolio_Project;
--Using complex query without CTE
SELECT 
	cd.continent,
	cd.location,
	cd.date,
	cd.population,
	cv.new_vaccinations,
	SUM(CAST(cv.new_vaccinations AS INT)) OVER (PARTITION BY cd.location ORDER BY cd.location,cd.date)
	AS RollingPeopleVaccinated,
	(SUM(CAST(cv.new_vaccinations AS INT)) OVER (PARTITION BY cd.location ORDER BY cd.location,cd.date)/cd.population) * 100 AS VaccinationRate
FROM dbo.CovidDeaths AS cd
JOIN dbo.CovidVaccinations AS cv 
	ON  cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 2,3

-- Using simplify CTE query

-- USE CTE

WITH PopvsVac (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
As
(
SELECT 
	cd.continent,
	cd.location,
	cd.date,
	cd.population,
	cv.new_vaccinations,
	SUM(CAST(cv.new_vaccinations AS INT)) OVER (PARTITION BY cd.location ORDER BY cd.location,cd.date)
	AS RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population) *100 
FROM dbo.CovidDeaths AS cd
JOIN dbo.CovidVaccinations AS cv 
	ON  cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
)

SELECT 
	*,
	(RollingPeopleVaccinated/population) *100 AS VaccinationRate
FROM 
	PopvsVac



-- TEMP TABLE / Creating new table with modified data set

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT 
	cd.continent,
	cd.location,
	cd.date,
	cd.population,
	cv.new_vaccinations,
	SUM(CAST(cv.new_vaccinations AS INT)) OVER (PARTITION BY cd.location ORDER BY cd.location,cd.date)
	AS RollingPeopleVaccinated
FROM dbo.CovidDeaths AS cd
JOIN dbo.CovidVaccinations AS cv 
	ON  cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 2,3


SELECT 
	*,
	(RollingPeopleVaccinated/population) *100 AS VaccinationRate
FROM 
	#PercentPopulationVaccinated


-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

CREATE VIEW PercentPopulationVaccinated AS
SELECT 
	cd.continent,
	cd.location,
	cd.date,
	cd.population,
	cv.new_vaccinations,
	SUM(CAST(cv.new_vaccinations AS INT)) OVER (PARTITION BY cd.location ORDER BY cd.location,cd.date)
	AS RollingPeopleVaccinated
FROM dbo.CovidDeaths AS cd
JOIN dbo.CovidVaccinations AS cv 
	ON  cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
--ORDER BY 2,3


SELECT *
FROM PercentPopulationVaccinated