SELECT *
FROM PortofolioProjects.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 3,4

SELECT *
FROM PortofolioProjects.dbo.CovidVaccinations
WHERE continent is not null
ORDER BY 3,4


-- Choix des données à utiliser

SELECT location, date, total_cases, new_cases, new_cases, total_deaths, population 
FROM PortofolioProjects.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 1,2


-- Total cases VS Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortofolioProjects.dbo.CovidDeaths
where location like '%Mali%' AND continent is not null
ORDER BY 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of percentage got Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 as infectionPercentage
FROM PortofolioProjects.dbo.CovidDeaths
where location like '%states%' AND continent is not null
ORDER BY 1,2


-- Looking at country with highest infection rate compared to population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as infectionPercentage
FROM PortofolioProjects.dbo.CovidDeaths
--where location like '%states%'
WHERE continent is not null
GROUP BY Location, population
ORDER BY infectionPercentage DESC


-- Looking at countries with Highest Death Count per population

SELECT location, population, MAX(cast(total_deaths as int)) as HighestDeathCount, MAX((cast(total_deaths as int)/population))*100 as DeathPercentage
FROM PortofolioProjects.dbo.CovidDeaths
--where location like '%states%'
WHERE continent is not null
GROUP BY Location, population
ORDER BY HighestDeathCount DESC


-- Continent breakdown

SELECT location, population, MAX(cast(total_deaths as int)) as HighestDeathCount, MAX((cast(total_deaths as int)/population))*100 as DeathPercentage
FROM PortofolioProjects.dbo.CovidDeaths
--where location like '%states%'
WHERE continent is null
GROUP BY location, population
ORDER BY HighestDeathCount DESC


-- GLOBAL NUMBRES

SELECT	date
		,SUM(new_cases) as total_cases
		,SUM(cast(new_deaths as int)) as total_deaths
		,(SUM(cast(new_deaths as int))/SUM(new_cases))*100 as GlobalDeathPercentage

FROM PortofolioProjects.dbo.CovidDeaths

--where location like '%states%'
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2


-- Looking at Total Population Vs Vaccination (using partition by)

SELECT	 dea.continent
		,dea.location, dea.date
		,dea.population
		,vac.new_vaccinations
		,SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition By dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated

FROM	PortofolioProjects.dbo.CovidDeaths dea
		Join PortofolioProjects.dbo.CovidVaccinations vac
		ON dea.location = vac.location 
		AND dea.date = vac.date

WHERE	dea.continent is not null
Order by 2,3



--USE CTE (Continent, Location, Date, Population, RollingPeopleVaccinated, new_vaccinations)

With PopVsVac 
AS
(
SELECT	 dea.continent
		,dea.location
		,dea.date
		,dea.population
		,vac.new_vaccinations
		,SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition By dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated

FROM	PortofolioProjects.dbo.CovidDeaths dea
		Join PortofolioProjects.dbo.CovidVaccinations vac
		ON dea.location = vac.location 
		AND dea.date = vac.date

WHERE	dea.continent is not null

)

select *, RollingPeopleVaccinated,(RollingPeopleVaccinated/population)*100
From PopVsVac





-- Temp table

DROP TABLE if exists #PercPopVAccinated
CREATE TABLE #PercPopVAccinated
(
Continent nvarchar(225),
Location nvarchar(225),
Date Datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercPopVAccinated
SELECT	 dea.continent
		,dea.location
		,dea.date
		,dea.population
		,vac.new_vaccinations
		,SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition By dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated

FROM	PortofolioProjects.dbo.CovidDeaths dea
		Join PortofolioProjects.dbo.CovidVaccinations vac
		ON dea.location = vac.location 
		AND dea.date = vac.date
WHERE	dea.continent is not null

select *, RollingPeopleVaccinated,(RollingPeopleVaccinated/population)*100
From #PercPopVAccinated




-- Creating view to store data for later visualization


CREATE View PercPopVAccinated as
SELECT	 dea.continent
		,dea.location
		,dea.date
		,dea.population
		,vac.new_vaccinations
		,SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition By dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated

FROM	PortofolioProjects.dbo.CovidDeaths dea
		Join PortofolioProjects.dbo.CovidVaccinations vac
		ON dea.location = vac.location 
		AND dea.date = vac.date
WHERE	dea.continent is not null




Select *
FROM PercPopVAccinated