--select * from ProjectPortfolioOne..CovidDeaths

--select * from ProjectPortfolioOne..CovidVaccinations order


--------------------------------------------------------------------------------------------------------------------------------------------------------------
-- COVID DEATHS TABLE

Select location, date, total_cases, new_cases, total_deaths, population
from ProjectPortfolioOne..CovidDeaths
where continent is not null
order by 1,2

-- Total Cases vs Total Deaths
Select location, date, total_cases, total_deaths,
		(Convert(decimal(15,3),total_deaths)/Convert(decimal(15,3),total_cases))*100 AS DeathPercentage /*Chances of getting COVID at the particular time*/
from ProjectPortfolioOne..CovidDeaths
Where location = 'India' and continent is not null
order by 1,2

-- Total Cases vs Population
Select location, date, population, total_cases,
		(Convert(decimal(15,3),total_cases)/Convert(decimal(15,3),population))*100 AS AffectedPopulationPercentage /*percentage of population got COVID*/
from ProjectPortfolioOne..CovidDeaths
Where location = 'Cyprus' and continent is not null
order by 1,2

-- Countries with Highest Infection Rate compared to Population
Select location, population, Max(total_cases) as HighestInfectionCount,
		Max(total_cases/population)*100 AS AffectedPopulationPercentage /*percentage of population got COVID*/
from ProjectPortfolioOne..CovidDeaths
where continent is not null
Group by location, population
order by AffectedPopulationPercentage desc

-- Countries with Highest Dath Count per Population
Select location, population, Max(Convert(int,total_deaths)) as TotalDeathCount
from ProjectPortfolioOne..CovidDeaths
where continent is not null
Group by location, population
order by TotalDeathCount desc

-- By Continent with the Highest Death count per Population
select Continent, sum(population) TotalPopulationByContinent, sum(TotalDeath) as TotalDeathByContinent
from (
select continent, location, population, max(Convert(int,total_deaths)) as TotalDeath
from ProjectPortfolioOne..CovidDeaths
where continent is not null
group by continent, location, population
) as max_population_per_country
group by continent
order by 3 desc;

-- Global Percentage Count of Death by population
select sum(population) TotalGlobalPopulation, sum(TotalDeath) as TotalGlobalDeath, sum(TotalDeath)/sum(population)*100 as DeathPercentageGlobally
from (
select continent, location, population, max(Convert(int,total_deaths)) as TotalDeath
from ProjectPortfolioOne..CovidDeaths
where continent is not null
group by continent, location, population
) as max_population_per_country;


-- Global Percentage Count of Death by Total COVID Cases
select sum(TotalCases) as TotalGlobalCases,sum(TotalDeath) as TotalGlobalDeath, sum(TotalDeath)/sum(TotalCases)*100 as DeathPercentage
from (
select continent, location, population, sum(new_cases) as TotalCases, max(Convert(int,total_deaths)) as TotalDeath
from ProjectPortfolioOne..CovidDeaths
where continent is not null
group by continent, location, population
) as max_population_per_country;

---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- COVID VACCINATIONS TABLE 
-- performing with COVID DEATHS via Joins

select * from ProjectPortfolioOne..CovidVaccinations

-- Total Population vs Vaccinations
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
from ProjectPortfolioOne..CovidDeaths dea
join ProjectPortfolioOne..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Using CTE
with PopvsVac (Continent,Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated)
AS (
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
from ProjectPortfolioOne..CovidDeaths dea
join ProjectPortfolioOne..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as VaccinationPercentage
from PopvsVac

-- Using TEMP Table

Drop Table if exists #PercentPopulationVaccinated
-- create
Create Table #PercentPopulationVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
--insert
Insert Into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
from ProjectPortfolioOne..CovidDeaths dea
join ProjectPortfolioOne..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--display
Select *, (RollingPeopleVaccinated/Population) as VaccinationPercentage
from #PercentPopulationVaccinated 
order by 2,3

-- Creating a View to store data for later Visualization
Create View PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
from ProjectPortfolioOne..CovidDeaths dea
join ProjectPortfolioOne..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null;

Select * from PercentPopulationVaccinated;
