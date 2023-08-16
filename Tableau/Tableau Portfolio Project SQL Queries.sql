/*
Queries used for Tableau Project
*/

-- 1)
Select SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From ProjectPortfolioOne..CovidDeaths
where continent is not null 
order by 1,2

-- 2)
Select Location, SUM(cast(new_deaths as int)) as TotalDeathCount
From ProjectPortfolioOne..CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International','High income','Upper middle income','Lower middle income','Low income')
Group by location
order by TotalDeathCount desc

-- 3)
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From ProjectPortfolioOne..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc

-- 4)
Select Location, Population,Date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From ProjectPortfolioOne..CovidDeaths
Group by Location, Population, date
order by PercentPopulationInfected desc

