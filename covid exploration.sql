--SELECT *
--FROM PortfolioProject.dbo.CovidDeaths$
--ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidDeaths$
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths$
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying if you contract covid in a specified country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
WHERE location like '%Kenya%'
ORDER BY 1,2

-- Looking at Countries with highest infection rate compared to population
Select location, population, MAX(total_cases) AS HigestInfectionCount, MAX(total_cases/population) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%Kenya%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--Showing countries with the highest death count per population
Select location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%Kenya%'
WHERE location IS NOT null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Breaking it down by continents

-- Shouwing continents with the highest death count per population

Select continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%Kenya%'
WHERE continent IS NOT null
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global numbers

Select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%Kenya%'
WHERE continent is not NULL
ORDER BY 1,2

--Looking at total population cs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) 
OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 1,2,3


--Use CTE

WITH PopvsVac(continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated) as (

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) 
OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not NULL
--ORDER BY 1,2,3
)
Select *, (RollingPeopleVaccinated/population) * 100
From PopvsVac

-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) 
OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not NULL
--ORDER BY 1,2,3

Select *, (RollingPeopleVaccinated/population) * 100
From #PercentPopulationVaccinated

-- Creating view to store data for later visualizations

Create View PercentagePopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) 
OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not NULL
--ORDER BY 1,2,3