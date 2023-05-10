SELECT * FROM Portfolio.dbo.CovidDeaths$
WHERE continent is not null 
ORDER BY 3,4;

--SELECT * FROM Portfolio.dbo.CovidVaccinations$


SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio.dbo.CovidDeaths$
ORDER By 1,2


--Looking at Total Cases vs Total Deaths

SELECT Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM Portfolio.dbo.CovidDeaths$
WHERE location like '%states'
ORDER By 1,2;

--Looking at the Total Cases vs Population

SELECT Location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
FROM Portfolio.dbo.CovidDeaths$
WHERE location like '%states'
ORDER By 1,2;

--Looking at Countries with Hightest Infection Rate compared to Population
SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as  PercentPopulationInfected
FROM Portfolio.dbo.CovidDeaths$
--WHERE location like '%states'
GROUP BY Location, population
ORDER By PercentPopulationInfected DESC;

--Showing Countrie with Hightest Death Count per Population

SELECT continent, MAX(cast(Total_deaths as int)) AS TotalDeathCount
FROM Portfolio.dbo.CovidDeaths$
--WHERE location like '%states'
WHERE continent is not null
GROUP BY continent
ORDER By TotalDeathCount DESC;


--Showing the Continetent with the highest death count per population

SELECT continent, MAX(cast(Total_deaths as int)) AS TotalDeathCount
FROM Portfolio.dbo.CovidDeaths$
--WHERE location like '%states'
WHERE continent is not null
GROUP BY continent
ORDER By TotalDeathCount DESC;

--GLOBAL NUMBERS

SELECT date, SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 AS DeathPercentage
FROM Portfolio.dbo.CovidDeaths$
--WHERE location like '%states'
WHERE continent is not null
GROUP BY date
ORDER By 1,2;


--Looking at Total Population vs Vaccinations


With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as INT)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM Portfolio..CovidDeaths$ dea
JOIN Portfolio..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER By 2,3
)
SELECT *,(RollingPeopleVaccinated/Population)*100 FROM PopvsVac;

--USE CTE

With PopvsVac
AS;


--TEMP TABLE 
DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as INT)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM Portfolio..CovidDeaths$ dea
JOIN Portfolio..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER By 2,3

SELECT *,(RollingPeopleVaccinated/Population)*100 
FROM #PercentPopulationVaccinated;

--Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as INT)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM Portfolio..CovidDeaths$ dea
JOIN Portfolio..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER By 2,3


SELECT * 
FROM PercentPopulationVaccinated