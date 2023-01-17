select * from portfolio.coviddeaths
where continent is not null
order by 3,4;


-- looking ata Ttatal cases vs Total deaths
-- Show Covid iS Seriously Injuring People and If You have been in phone there are more chances of Dying

select location, date , total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from portfolio.coviddeaths
where location like '%india%'
order by 1,2;

-- looking at Total Cases VS Population Density
-- Shows Pertange off Population got covid

select location, date , total_cases, population_density, (total_cases/population_density)*100 as PercentagePopulationInfected
from portfolio.coviddeaths
-- where location like '%india%'
order by 1,2;

-- Countries with Lowest Infaction Rate Copared to population
select location, date , min(total_cases), population_density, min((total_cases/population_density))*100 as PercentagePopulationInfected
from portfolio.coviddeaths
-- where location like '%india%'
group by location, population_density
order by PercentagePopulationInfected ;


-- Showingies with Lowest Death 
select location, min(total_deaths )
 as  TotaldeathsCount
from portfolio.coviddeaths
-- where location like '%india%'
where continent is not null
group by location
order by TotaldeathsCount desc;

-- Lets Break Thing Down By Continent
-- Max(cast(total_deaths as int))  Max(total_deaths )	

Select distinct Location, max(cast(total_deaths as  UNSIGNED INTEGER))
as TotalDeathCount
From Portfolio.CovidDeaths
-- Where location like '%india%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc;

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as UNSIGNED INTEGER)) as total_deaths, SUM(cast(new_deaths as UNSIGNED INTEGER))/SUM(New_Cases)*100 as DeathPercentage
From Portfolio.CovidDeaths
-- Where location like '%india%'
where continent is not null 
-- Group By date
order by 1,2;

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccinations
, SUM(CONVERT(vac.new_vaccinations, unsigned)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated from  
Portfolio.CovidDeaths as dea
join portfolio.covidvaccine as vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null  
-- and RollingPeopleVaccinated > 0 
order by 2,3;

-- CTE

WITH popVSvacc (continent, location, date, population_density, new_vaccinations, rolling_people_vaccinations) 
AS (
SELECT deaths.continent, deaths.location, deaths.date, deaths.population_density, vacc.new_vaccinations, 
	SUM(CAST(vacc.new_vaccinations as unsigned int)) OVER (Partition by deaths.location ORDER BY deaths.location, 
	deaths.date ) AS rolling_people_vaccinations
FROM Portfolio.CovidDeaths as deaths
JOIN Portfolio.CovidVaccine as vacc
 ON deaths.location = vacc.location
	AND deaths.date = vacc.date
WHERE deaths.continent is not null  
)
SELECT *, (rolling_people_vaccinations/population_density)*100 as rolling_vacc_percentage
From popVSvacc;
 
-- Using Temp Table to perform Calculation on Partition By in previous query

create TEMPORARY table  percentpopulationvaccinated 
( continent varchar(100), location varchar(100), date datetime,
 population_density numeric, new_vaccinations numeric, rollingpeoplevaccinated numeric)

insert into percentpopulationvaccinated 
SELECT deaths.continent, deaths.location, deaths.date, deaths.population_density, vacc.new_vaccinations, 
	SUM(CAST(vacc.new_vaccinations as unsigned int)) OVER (Partition by deaths.location ORDER BY deaths.location, 
	deaths.date ) AS rolling_people_vaccinations
FROM Portfolio.CovidDeaths as deaths
JOIN Portfolio.CovidVaccine as vacc
 ON deaths.location = vacc.location
	AND deaths.date = vacc.date
WHERE deaths.continent is not null
  )
SELECT *, (rolling_people_vaccinations/population_density)*100 
From percentpopulationvaccinated;


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccinations
, SUM(CONVERT(vac.new_vaccinations, unsigned)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated from  
Portfolio.CovidDeaths as dea
join portfolio.covidvaccine as vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null  
-- and RollingPeopleVaccinated > 0 
order by 2,3;
commit

