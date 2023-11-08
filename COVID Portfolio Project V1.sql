select *
From PortfolioProject..CovidVaccinations
Order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as Death_Percentage
From PortfolioProject..CovidDeaths
Where location like 'Canada'
Order by 1,2

-- Looking at Total Cases vs Population
-- Shows what % of the population got Covid

Select Location, date,  population, total_cases, (total_cases/population)*100 as Cases_Percentage
From PortfolioProject..CovidDeaths
Where location like 'Canada'
Order by 1,2

-- Looking at Countries with highest infection rate compared to population
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopInfected
From PortfolioProject..CovidDeaths
GROUP BY Location, population
Order by PercentPopInfected desc

-- Showing countries with highest death count per population

Select Location, MAX(cast(total_deaths as bigint)) as TotalDeathCount
From PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY location
Order by TotalDeathCount desc

-- Breaking things down by continent

-- Showing continents with the highest death count per population
Select continent, MAX(cast(total_deaths as bigint)) as TotalDeathCount
From PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY continent
Order by TotalDeathCount desc

-- Global Numbers

Select date, SUM(new_cases) as Total_cases, SUM(new_deaths) as Total_deaths, SUM(new_deaths)/NULLIF(SUM(new_cases),0) *100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
group by date
Order by 1,2

Select SUM(new_cases) as Total_cases, SUM(new_deaths) as Total_deaths, SUM(new_deaths)/NULLIF(SUM(new_cases),0) *100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2

-- Looking at Total Population vs Vaccinations


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint))
OVER (Partition by dea.location Order by dea.location, dea.date) as cummulativeTotalvaccinations --(cummulativeTotalvaccinations/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, cummulativeTotalvaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint))
OVER (Partition by dea.location Order by dea.location, dea.date) as cummulativeTotalvaccinations --(cummulativeTotalvaccinations/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (cummulativeTotalvaccinations/Population)*100
From PopvsVac

--select location, date, new_vaccinations, total_vaccinations
--from PortfolioProject..CovidVaccinations
--where continent is not null
--order by 1,2

-- Using Temp Table

DROP Table if exists #PercentPopVaccd
Create Table #PercentPopVaccd
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
CummulativeVaccinations numeric
)


Insert into #PercentPopVaccd
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint))
OVER (Partition by dea.location Order by dea.location, dea.date) as cummulativeTotalvaccinations --(cummulativeTotalvaccinations/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
Select *, (CummulativeVaccinations/Population)*100
From #PercentPopVaccd


-- Creating View to store data for later visualizations

Create View PercentPopVaccd as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint))
OVER (Partition by dea.location Order by dea.location, dea.date) as cummulativeTotalvaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopVaccd