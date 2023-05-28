
use covid_db


----------------
---- Select Data that we are going to be starting with
select location, date, total_cases,  total_deaths,(total_deaths/total_cases)*100 as deathpercentage
from coviddeath$
where location = 'Vietnam'
order by 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in Vietnam


select location, date, total_cases,  population,(total_cases/population)*100 as deathpercentage
from coviddeath$
where location = 'Vietnam'
order by 5 desc


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid


Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From CovidDeath$
order by 1,2


-- Countries with Highest Infection Rate compared to Population


select location, population, max(total_cases) as HighestCases,  max((total_cases/population)*100) as DeathPercentage
from coviddeath$
Group by location, population
order by  4 desc


-- Countries with Highest Death Count per Population


select continent, max(total_deaths) as TotalDeathCount
from coviddeath$
where continent is not null
Group by continent
order by  TotalDeathCount desc



--Global number
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeath$
where continent is not null 
--Group By date
order by 1,2

----Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select de.continent, de.location, de.date, de.population, va.new_vaccinations,
	sum(cast(va.new_vaccinations as float)) over (partition by de.location order by de.location, de.date) as RollingPeopleVaccinated
from CovidDeath$ as de
join CovidVacination va
	on de.location = va.location
	and de.date = va.date
where de.continent is not null
order by 1,2


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select de.continent, de.location, de.date, de.population, va.new_vaccinations
, SUM(CONVERT(float,va.new_vaccinations)) OVER (Partition by de.Location Order by de.location, de.Date) as RollingPeopleVaccinated

From CovidDeath$ de
Join CovidVacination va
	On de.location = va.location
	and de.date = va.date
where de.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PctofPopulationVaccinated
From PopvsVac


--Using temp table


drop table if exists PercentPopulationVaccinated
create table PercentPopulationVaccinated(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_Vaccinations numeric,
	RollingPeopleVaccinated numeric

)

insert into PercentPopulationVaccinated
Select de.continent, de.location, de.date, de.population, va.new_vaccinations
, SUM(CONVERT(float,va.new_vaccinations)) OVER (Partition by de.Location Order by de.location, de.Date) as RollingPeopleVaccinated

From CovidDeath$ de
Join CovidVacination va
	On de.location = va.location
	and de.date = va.date
where de.continent is not null 
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100 as PctofPopulationVaccinated
from PercentPopulationVaccinated


--Create view


create view PercentOfPopulationVaccinated as
Select de.continent, de.location, de.date, de.population, va.new_vaccinations
, SUM(CONVERT(float,va.new_vaccinations)) OVER (Partition by de.Location Order by de.location, de.Date) as RollingPeopleVaccinated

From CovidDeath$ de
Join CovidVacination va
	On de.location = va.location
	and de.date = va.date
where de.continent is not null 
--order by 2,3
