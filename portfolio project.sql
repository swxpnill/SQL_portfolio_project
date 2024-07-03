Select *
From PortfolioProject..CovidDeaths$
order by 3,4

-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
order by 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where location like '%india%'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of populaton got Covid

select location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
from CovidDeaths$
--where location like '%india%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
from CovidDeaths$
--where location like '%india%'
Group by location, population
order by PercentagePopulationInfected DESC

-- Showing Countries with Highest Death Count pre Population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths$
--where location like '%india%'
Group by location
order by TotalDeathCount DESC

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths$
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths$
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


-- Looking at Total Population vs Vaccination
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
dea.date) as Peoplevaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
     on dea.location = vac.location
	 and dea.date = vac.date
	 where dea.continent is not null
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

with PopvsVac (contienet, location, date, population, new_vaccinations, Peoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
dea.date) as Peoplevaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
     on dea.location = vac.location
	 and dea.date = vac.date
	 where dea.continent is not null
--order by 2,3
)
select *, (Peoplevaccinated/population)*100
from PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
coninent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Peoplevaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
dea.date) as Peoplevaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
     on dea.location = vac.location
	 and dea.date = vac.date
	 --where dea.continent is not null
--order by 2,3

select *, (Peoplevaccinated/population)*100
from #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
dea.date) as Peoplevaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
     on dea.location = vac.location
	 and dea.date = vac.date
	 where dea.continent is not null
--order by 2,3

 
select *
from PercentPopulationVaccinated