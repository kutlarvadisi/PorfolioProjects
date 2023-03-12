-- Select Data that we are going to be starting with

Select location, date, total_cases, total_deaths, new_cases, population from CovidDeaths$
order by 1,2

-- Total Cases vs Total Deaths

Select location, date, total_deaths, total_cases,
case when total_cases=0 then 0 else cast(total_deaths as float)/cast(total_cases as float)*100 end as deathratio
From CovidDeaths$

-- Total Cases vs Population

select location, date, total_cases, population, 
Case when population=0 then 0 else cast(total_cases as float)/CAST(population as float)*100 end as PercentPopulationInfected
from CovidDeaths$

-- Countries with Highest Infection Rate compared to Population
SELECT location, population,
    MAX(CAST(total_cases AS BIGINT)) AS highestinfectioncount,
    CASE WHEN population = 0 THEN 0 ELSE
        MAX(CAST(total_cases AS BIGINT) / NULLIF(CAST(population AS FLOAT), 0)) * 100
    END AS HighestInfectionRatecomparedtoPopulation
FROM CovidDeaths$
where location like'%morocco%'
GROUP BY location, population
ORDER BY HighestInfectionRatecomparedtoPopulation DESC;

-- Countries with Highest Death Count per Population
Select location, MAX(cast(total_deaths as int)) as totaldeathcount 
from CovidDeaths$
where continent is not null 
group by location 
order by totaldeathcount desc

-- BREAKING THINGS DOWN BY CONTINENT
select continent, max(cast(total_deaths as int)) as totaldeathDeathCount  
from CovidDeaths$
where continent is not null 
group by continent
order by totaldeathDeathCount  desc

-- GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths$
where continent is not null 
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
 on dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null
 and  vac.new_vaccinations is not null
 order by 2,3

 -- Using CTE to perform Calculation on Partition By in previous query
with PopvsVac(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
 on dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null
 and  vac.new_vaccinations is not null
 --order by 2,3
 )
 select*,(RollingPeopleVaccinated/population)*100 as ratio
 from PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths$ dea
Join CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths$ dea
Join CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 