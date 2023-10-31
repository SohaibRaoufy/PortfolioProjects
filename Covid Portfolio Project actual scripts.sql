SELECT * 
FROM PortfolioProject ..CovidDeaths
where continent is not null
ORDER BY 3,4;

--SELECT * 
--FROM PortfolioProject ..CovidVaccinations
--ORDER BY 3,4;


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject ..CovidDeaths
where continent is not null
ORDER BY 1,2;


--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, new_cases, total_deaths,  (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
FROM PortfolioProject ..CovidDeaths
--where location like '%states%'
where continent is not null
ORDER BY 1,2;

--Looking at Total Cases vs Population
-- Shows what percentage o population got Covid

SELECT location, date, population, total_cases,  (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 as PercentagePopulationInfected
FROM PortfolioProject ..CovidDeaths
--where location like '%states%'
where continent is not null
ORDER BY 1,2;

--Looking at Countries with Highest Infection Rate compared to population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, (MAX(total_cases)/population)*100 as PercentagePopulationInfected
FROM PortfolioProject ..CovidDeaths
--where location like '%states%'
GROUP BY location, population
ORDER BY PercentagePopulationInfected DESC;

--Showing Countries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathsCount
FROM PortfolioProject ..CovidDeaths
where continent is not null
GROUP BY location
ORDER BY TotalDeathsCount DESC;



-- Let's BREAK THINGS DOWN BY CONTINENT

--Showing continents with highest death per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathsCount
FROM PortfolioProject ..CovidDeaths
where continent is not null
GROUP BY continent 
ORDER BY TotalDeathsCount DESC;



-- GLOBAL NUMBERS


SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject ..CovidDeaths
--where location like '%states%'
where continent is not NULL
--GROUP BY date
ORDER BY 1,2;


--Looking at Total Population vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject ..CovidDeaths dea
JOIN PortfolioProject .. CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 2,3



-- USE CTE


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject ..CovidDeaths dea
JOIN PortfolioProject .. CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL
--ORDER BY 2,3

)

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac



-- TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject .. CovidDeaths dea
JOIN PortfolioProject .. CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent is not NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualtizations

USE PortfolioProject 
Go
CREATE View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject .. CovidDeaths dea
JOIN PortfolioProject .. CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL
--ORDER BY 2,3

