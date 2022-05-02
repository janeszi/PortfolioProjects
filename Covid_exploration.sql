-- Order by functions.
--Select *
--From PortfolioProjects..CovidVacc
--Order by location, date
Select *
From PortfolioProjects..CovidDeath
Where continent is not null
Order by location,date

-- Filtering
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProjects..CovidDeath
Where continent is not null
Order by location, date

-- Cases and Death, shows the percentage of dying from covid in UK

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProjects..CovidDeath
Where location='United Kingdom'
and continent is not null
Order by location, date

-- Cases and Population, shows the percentage of population got covid in UK

Select location, date, population, total_cases, (total_cases/population)*100 as PopulationCases
From PortfolioProjects..CovidDeath
Where location='United Kingdom'
and continent is not null
Order by location, date

-- Countries with highest infection rate compared to population

Select location, population, MAX(total_cases) as HighestInfection, MAX((total_cases/population))*100 as PopulationCases
From PortfolioProjects..CovidDeath
-- Where location='United Kingdom'
Where continent is not null
Group by location, population
Order by PopulationCases desc


-- Countries with Highest Death count
-- First error, total_deaths were a wrong data type(nvarchar255) so it showed different values, fixed by changing the data type to integer
-- Second error, location column, some of the locations were not supposed to be in the list such as World, Upper middle income, High income etc., error: entire continents were grouping
-- Second error fixed, added sql code where continent is not null
Select location, MAX(cast(total_deaths as int)) as HighestDeathCount
From PortfolioProjects..CovidDeath
-- Where location='United Kingdom'
Where continent is not null
Group by location
Order by HighestDeathCount desc

-- Continent highest death count

Select continent, MAX(cast(total_deaths as int)) as HighestDeathCount
From PortfolioProjects..CovidDeath
-- Where location='United Kingdom'
Where continent is not null
Group by continent
Order by HighestDeathCount desc

-- Global count by date

Select date, SUM(new_cases) as total_Cases, SUM(cast(new_deaths as int)) as total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProjects..CovidDeath
Where continent is not null
Group by date
Order by date, total_Cases

-- Total cases worldwide

Select SUM(new_cases) as total_Cases, SUM(cast(new_deaths as int)) as total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProjects..CovidDeath
Where continent is not null
Order by total_Cases, total_Deaths


-- Join Death and Vaccination

Select *
From PortfolioProjects..CovidDeath death
Join PortfolioProjects..CovidVacc vacc
	On death.location = vacc.location
	and death.date = vacc.date

-- Population and Vaccinations

Select death.continent, death.location, death.date, death.population, vacc.new_vaccinations
From PortfolioProjects..CovidDeath death
Join PortfolioProjects..CovidVacc vacc
	On death.location = vacc.location
	and death.date = vacc.date
Where death.continent is not null
Order by location, date

-- New vaccination Break it up by Location
-- first error: because of the huge amount of new_vaccination row I wasn't able to cast it to "int"
-- first error fix: used "bigint" instead of "int"
-- second error: new vaccination and total vaccination weren't adding up with People vacc because the partition is only by location
-- second error fix: ordered by location and date

Select death.continent, death.location, death.date, death.population, vacc.new_vaccinations, SUM(cast(vacc.new_vaccinations as bigint)) over (Partition by death.location order by death.location,
death.date) as People_Vacc
From PortfolioProjects..CovidDeath death
Join PortfolioProjects..CovidVacc vacc
	On death.location = vacc.location
	and death.date = vacc.date
Where death.continent is not null
Order by location, date

-- New vaccination Calculation/CTE
With PopVacc (continent, location, date, population, new_vaccinations, People_Vacc)
as
(
Select death.continent, death.location, death.date, death.population, vacc.new_vaccinations, SUM(cast(vacc.new_vaccinations as bigint)) over (Partition by death.location order by death.location,
death.date) as People_Vacc
From PortfolioProjects..CovidDeath death
Join PortfolioProjects..CovidVacc vacc
	On death.location = vacc.location
	and death.date = vacc.date
Where death.continent is not null
)
Select *, (People_Vacc/population)*100
from PopVacc

-- TempTable
Drop table if exists #PercentagePopVacc
Create Table #PercentagePopVacc
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
People_Vacc numeric)

Insert into #PercentagePopVacc
Select death.continent, death.location, death.date, death.population, vacc.new_vaccinations, SUM(cast(vacc.new_vaccinations as bigint)) over (Partition by death.location order by death.location,
death.date) as People_Vacc
From PortfolioProjects..CovidDeath death
Join PortfolioProjects..CovidVacc vacc
	On death.location = vacc.location
	and death.date = vacc.date
Where death.continent is not null

Select *, (People_Vacc/population)*100
from #PercentagePopVacc


-- Store data for visualizations

Create view PercentagePopVacc as 
Select death.continent, death.location, death.date, death.population, vacc.new_vaccinations, SUM(cast(vacc.new_vaccinations as bigint)) over (Partition by death.location order by death.location,
death.date) as People_Vacc
From PortfolioProjects..CovidDeath death
Join PortfolioProjects..CovidVacc vacc
	On death.location = vacc.location
	and death.date = vacc.date
Where death.continent is not null

Select *
from PercentagePopVacc

-- Data for Tableau
--Total cases and death percentage
Select SUM(new_cases) as total_Cases, SUM(cast(new_deaths as int)) as total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProjects..CovidDeath
Where continent is not null
Order by total_Cases, total_Deaths

-- Total deaths by continent
Select location, SUM(cast(new_deaths as int)) as TotalDeaths
from PortfolioProjects..CovidDeath
Where continent is null
and location not in ('World', 'Upper middle income', 'High income', 'Lower middle income', 'Low income', 'European Union', 'International')
Group by location
order by TotalDeaths desc

-- Covid Highest infection rate, country total
Select location, population, MAX(total_cases) as HighestInfection, MAX((total_cases/population))*100 as PopulationCases
From PortfolioProjects..CovidDeath
Where continent is not null
Group by location, population
Order by PopulationCases desc

-- Covid rates by date
Select location, population, date, MAX(total_cases) as HighestInfection, MAX((total_cases/population))*100 as PopulationCases
From PortfolioProjects..CovidDeath
Where continent is not null
Group by location, population, date
Order by PopulationCases desc
