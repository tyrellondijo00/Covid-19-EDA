-- Exploratory Data Analysis on Covid Deaths

SELECT *
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date

SELECT location, date, new_cases, total_cases, total_deaths, population
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date

--Total Deaths vs Total Cases

SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location = 'Kenya' AND continent IS NOT NULL
ORDER BY location, date

-- Total Cases vs Population

SELECT location, date, population, total_cases, (total_cases/population)*100 AS InfectedPercentage
FROM CovidDeaths
WHERE location = 'Kenya' AND continent IS NOT NULL
ORDER BY location, date

-- Countries with Highest Infection Rate Percentage

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, (MAX(total_cases)/population)*100 AS PercentPopulationInfected
FROM CovidDeaths 
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--Countries with Highest Death Rate Percentage

SELECT location, population, MAX(total_deaths) AS HighestDeathCount, (MAX(total_deaths)/population)*100 AS PercentPopulationDied
FROM CovidDeaths 
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationDied DESC

--Continents with Highest Death Counts

SELECT location, MAX(total_deaths) AS HighestDeathCountContinent
FROM CovidDeaths 
WHERE continent IS NULL
GROUP BY location
ORDER BY HighestDeathCountContinent DESC


--Continents with Highest Death Percentage Per Population 

SELECT location, population, (MAX(total_deaths)/population) AS HighestDeathPercentage
FROM CovidDeaths 
WHERE continent IS NULL
GROUP BY location, population
ORDER BY HighestDeathPercentage DESC

--Continents with Highest Infection Percentage Per Population 

SELECT location, population, (MAX(total_cases)/population) AS HighestInfectionPercentage
FROM CovidDeaths 
WHERE continent IS NULL
GROUP BY location, population
ORDER BY HighestInfectionPercentage DESC


--Global Numbers

SELECT location, population, (SUM(new_cases)/population)*100 AS GlobalInfectionPercentage, (SUM(new_deaths)/population)*100 AS GlobalDeathPercentage
FROM CovidDeaths
WHERE location = 'World' AND continent IS NULL
GROUP BY location, population

SELECT date, SUM(new_cases) AS NewCasesPerDay, SUM(new_deaths) AS NewDeathsPerDay
FROM CovidDeaths
GROUP BY date
ORDER BY date

-- Global Total Cases vs Deaths

SELECT location, SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, (SUM(new_deaths)/SUM(new_cases))*100 AS GlobalDeathsPerInfection
FROM CovidDeaths
WHERE location = 'World' AND continent IS NULL
GROUP BY location

-- Exploratory Data Analysis on Covid Vaccinations
-- Joining the Two Tables

SELECT *
FROM CovidDeaths dea
JOIN CovidVaccinations vacc
	ON dea.location = vacc.location
	AND dea.date = vacc.date


-- Total Vaccinations vs Populations

SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations, SUM(vacc.new_vaccinations) OVER (PARTITION BY  dea.location ORDER BY dea.location, dea.date) AS TotalVaccinationsPerCountry
FROM CovidDeaths dea
JOIN CovidVaccinations vacc
	ON dea.location = vacc.location
	AND dea.date = vacc.date
WHERE dea.continent IS NOT NULL
ORDER BY location, date

-- Creating A Temp Table With Total Vaccinations Per Country

DROP TABLE IF EXISTS #TotalVaccinationPerCountry
CREATE TABLE #TotalVaccinationPerCountry (
continent nvarchar(50),
location nvarchar(50),
date datetime2(7),
population bigint,
new_vaccinations float,
total_vaccinations_per_country float
)

-- Inserting Data Into Temp Table


INSERT INTO #TotalVaccinationPerCountry
SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations, SUM(vacc.new_vaccinations) OVER (PARTITION BY  dea.location ORDER BY dea.location, dea.date) AS TotalVaccinationsPerCountry
FROM CovidDeaths dea
JOIN CovidVaccinations vacc
	ON dea.location = vacc.location
	AND dea.date = vacc.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, dea.date

SELECT *
FROM #TotalVaccinationPerCountry

-- Percentage of Country Vaccinated

SELECT location, population, (MAX(total_vaccinations_per_country)/population)*100 AS VaccinationPercentage
FROM #TotalVaccinationPerCountry
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY VaccinationPercentage DESC


--Creating Views To Store Data For Visualizations

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations, SUM(vacc.new_vaccinations) OVER (PARTITION BY  dea.location ORDER BY dea.location, dea.date) AS TotalVaccinationsPerCountry
FROM CovidDeaths dea
JOIN CovidVaccinations vacc
	ON dea.location = vacc.location
	AND dea.date = vacc.date
WHERE dea.continent IS NOT NULL

CREATE VIEW GlobalCasesVsDeaths AS
SELECT location, SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, (SUM(new_deaths)/SUM(new_cases))*100 AS GlobalDeathsPerInfection
FROM CovidDeaths
WHERE location = 'World' AND continent IS NULL
GROUP BY location

CREATE VIEW InfectionPercentagePerPopulation AS
SELECT location, population, (MAX(total_cases)/population) AS HighestInfectionPercentage
FROM CovidDeaths 
WHERE continent IS NULL
GROUP BY location, population