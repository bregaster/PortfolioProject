select  location, date, total_cases, new_cases, total_deaths, population from CovidDeaths
order by 1, 2

--looking at total cases vs total death
-- show likelihood of dying if you contract covid in your country
select  location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_precentage
from CovidDeaths
where location like 'Indonesia'
order by 1, 2 

--looking at total cases vs population
--show what precentage of populati on got covid
select  location, date,population, total_cases, (total_cases/population)*100 as  percent_population_infected
from CovidDeaths
where location like 'Indonesia'
order by 1, 2 

--looking at countrys with highest infection rate compared to population
select  location, population, max(total_cases) as highest_infection_count, max(total_cases/population)*100 as percent_population_infected
from CovidDeaths
group by location, population
order by percent_population_infected desc

--showing the countrues with highest death count per population
select  location, max(cast(total_deaths as int)) as total_death_count
from CovidDeaths
where continent is not null
group by location
order by total_death_count desc


--BREAK THINGS BY CONTINENT
--showing continents with the highest death count per population
select  continent, max(cast(total_deaths as int)) as total_death_count
from CovidDeaths
where continent is not null
group by continent
order by total_death_count desc

select  location, max(cast(total_deaths as int)) as total_death_count
from CovidDeaths
where continent is null
group by location
order by total_death_count desc


--GLOBAL NUMBERS
select  date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_death , sum(cast(new_deaths as int))/sum(new_cases)*100 as death_precentage
from CovidDeaths
where continent is not null
group by date
order by 1, 2 

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_death , sum(cast(new_deaths as int))/sum(new_cases)*100 as death_precentage
from CovidDeaths
where continent is not null
--group by date
order by 1, 2 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) 
over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from CovidDeaths dea join CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

--CTE
with PopvsVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as(

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) 
over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from CovidDeaths dea join CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
)
select * , (rolling_people_vaccinated/population)*100 
from PopvsVac

--temp table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255) ,
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

insert into #PercentPopulationVaccinated

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) 
over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from CovidDeaths dea join CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
--where dea.continent is not null

select * , (rolling_people_vaccinated/population)*100 
from #PercentPopulationVaccinated


---creating view to store data for later visualization

create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) 
over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from CovidDeaths dea join CovidVaccinations vac
	on dea.location=vac.location 
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated