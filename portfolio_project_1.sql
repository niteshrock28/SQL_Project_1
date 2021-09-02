--select * 
--from PortfolioProject..CovidDeaths
--order by 3,4

--select * 
--from PortfolioProject..CovidVaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1, 2

-- Total Cases Vs Total Deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%asia%'
order by 1, 2

-- Percentage of population gets covid OR infection rate

select location, date, population, total_cases, (total_cases/population)*100 as CovidPercentage
from PortfolioProject..CovidDeaths
where location like '%asia%'
order by 1, 2

-- Countries with hightest infection rate compared to population

select location, population, max(total_cases) as Infection_count_max,  MAX((total_cases/population)*100) as Highest_Infected_Percentage
from PortfolioProject..CovidDeaths
--where location like '%asia%'
group by location, population
order by 4 desc

-- Countries with hightest death count per population

select location, max(cast(total_deaths as int)) as Total_Death_Count
from PortfolioProject..CovidDeaths
--where location like '%asia%'
where continent is not null
group by location
order by 2 desc

-- Break this down by continent

select location, max(cast(total_deaths as int)) as Total_Death_Count
from PortfolioProject..CovidDeaths
--where location like '%asia%'
where continent is null
group by location
order by 2 desc

-- Global Death Percentage

select date, sum(new_cases) as Total_cases, sum(cast(new_deaths as int)) as Total_Deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_Percentage
from PortfolioProject..CovidDeaths
--where location like '%asia%'
where continent is not null
group by date
order by 1 

--Total Population vs Vaccination

select dae.continent, dae.location, dae.date, dae.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dae.location order by dae.location, dae.date) as Rolling_people_vacinated
from PortfolioProject..CovidDeaths dae join PortfolioProject..CovidVaccinations vac
on dae.date = vac.date and dae.location = vac.location
where dae.continent is not null
order by 2, 3

--CET(Common Table Expression)

with pop_vs_vac(continent, location, date, population, new_vaccination, Rolling_people_vacinated)
as
(
select dae.continent, dae.location, dae.date, dae.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dae.location order by dae.location, dae.date) as Rolling_people_vacinated
from PortfolioProject..CovidDeaths dae join PortfolioProject..CovidVaccinations vac
on dae.date = vac.date and dae.location = vac.location
where dae.continent is not null
--order by 2, 3
)
select *
from pop_vs_vac

-- Creating View to store data for later visualizations

create view pops_vac as
select dae.continent, dae.location, dae.date, dae.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dae.location order by dae.location, dae.date) as Rolling_people_vacinated
from PortfolioProject..CovidDeaths dae join PortfolioProject..CovidVaccinations vac
on dae.date = vac.date and dae.location = vac.location
where dae.continent is not null
--order by 2, 3

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

--Tableau Visualization Querries
-- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc




























