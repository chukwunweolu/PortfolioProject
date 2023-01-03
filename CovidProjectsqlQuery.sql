-- Checking and figuring out if my covid deaths table is correct 
select *
from PortfolioProject..covid_deaths
where continent is not null
order by 3, 4


-- Checking and figuring out if my covid deaths vaccination table is correct 
select *
from PortfolioProject..covid_vaccinations
order by 3, 4


-- Selecting the Data I want to use
select location,
		date,
		total_cases,
		new_cases,
		total_deaths,
		population
from PortfolioProject..covid_deaths
order by 1, 2


-- Comparing Total cases vs Total deaths in United states
-- Shows the Deaths Percentage of people that got covid
select location,
		date,
		total_cases,
		total_deaths,
		(total_deaths/total_cases)*100 as DeathsPercentage
from PortfolioProject..covid_deaths
where location like '%states%'
order by 1, 2


-- Comparing Total cases and Population
-- Shows what percentage of population got covid
select location,
		date,
		population,
		total_cases,
		(total_cases/population)*100 as PercentagePopulationInfected
from PortfolioProject..covid_deaths
where location like '%nigeria%'
order by 1, 2


-- Comparing Total cases and Population in Nigeria only

select location,
		date,
		population,
		total_cases,
		(total_cases/population)*100 as PercentagePopulationInfected
from PortfolioProject..covid_deaths
where location = 'Nigeria'
order by 1, 2



-- Looking at countries with highest infection rate

select location,
		population,
		max(total_cases) as HighestInfectionCount,
		max((total_cases/population))*100 as PercentagePopulationInfected
from PortfolioProject..covid_deaths
-- where location = 'Nigeria'
where continent is not null
group by location,
		population
order by PercentagePopulationInfected desc



-- Showing countries with highest death count per population

select location,
		max(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject..covid_deaths
-- where location = 'Nigeria'
where continent is not null
group by location
order by HighestDeathCount desc



-- LET'S BREAK THINGS DOWN BY CONTINENT

select continent,
		max(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject..covid_deaths
-- where location = 'Nigeria'
where continent is not null
group by continent
order by HighestDeathCount desc



-- Looking at total death counts per continents

select continent,
		max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..covid_deaths
-- where location = 'Nigeria'
where continent is not null
group by continent
order by TotalDeathCount desc


select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..covid_deaths
where continent is not null
order by 1, 2




-- USING CTE

-- Looking at the Total population versus the total vaccination


with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
from PortfolioProject..covid_deaths dea
join PortfolioProject..covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac




-- TEMP TABLE

Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
from PortfolioProject..covid_deaths dea
join PortfolioProject..covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2, 3
  
select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated





-- How to create a view that I can use to visualize data 

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
from PortfolioProject..covid_deaths dea
join PortfolioProject..covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null




-- Exploring data from the view table I created

select *
from PercentPopulationVaccinated