Select *
From PortfolioProject..CovidDeaths
Order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1,2

--Looking at Total Cases Vs Total Death in the United Kingdom

Select Location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%Kingdom%'
Order by 1,2

--Looking at Total Cases Vs Population in the United Kingdom
-- Shows what Percentage of Population got Covid

Select Location, date, population, total_cases, ((cast(total_cases as float))/ population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%Kingdom%'
Order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population

Select Location, population, Max(cast(total_cases as float)) as HighestInfectionCount, Max((cast(total_cases as float))/ population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by location, population
Order by PercentPopulationInfected Desc

-- Showing Countries with Highest Death Count per Population

Select Location, Max(cast(total_deaths as float)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent Is Not Null
Group by location
Order by TotalDeathCount Desc

--Showing Countries with Highest Cases Count per Population

Select Location, Max(cast(total_cases as float)) as TotalCasesCount
From PortfolioProject..CovidDeaths
Where continent Is Not Null
Group by location
Order by TotalCasesCount Desc

-- Showing continents with the highest deaths count per population

Select continent, Max(cast(total_deaths as float)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent Is not Null
Group by continent
Order by TotalDeathCount Desc

--GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths)/(SUM(Nullif(new_cases,0))))*100 as DeathPercentage 
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2

--Looking at Total Population vs Vaccinations

--Using CTE

Set ANSI_WARNINGS OFF
GO
With PopvsVac(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(Cast(vac.new_vaccinations as bigint)) Over (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *,(RollingPeopleVaccinated/population)*100 as PercentPopulationVaccinated
From PopvsVac


--Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(Cast(vac.new_vaccinations as bigint)) Over (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null