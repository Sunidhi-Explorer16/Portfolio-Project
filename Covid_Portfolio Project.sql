
select location,date,total_cases,new_cases,total_deaths,population
from portfolioproject..CovidDeaths where continent is not null order by 1,2

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100
as DeathPercentage
from portfolioproject..CovidDeaths where location like '%nd%'
order by 1,2

select location,date,population,total_cases,(total_cases/population)*100
as PercentPopulationInfected
from portfolioproject..CovidDeaths where location like '%anad%'
order by 1,2

--Looking at country with highest infection rate compared to population

select location,population,max(total_cases) as HighestInfectionCount,
max(total_cases/population)*100
as PercentPopulationInfected
from portfolioproject..CovidDeaths 
--where location like '%anad%'
group by location,population
order by PercentPopulationInfected desc

--Showing countries with highest death count per population


select location,max(cast(total_deaths as int)) as totalDeathCount
from portfolioproject..CovidDeaths 
--where location like '%anad%'
where continent is not null
group by location
order by totalDeathCount desc

--Showing the continents with the highest death count per population

select continent,max(cast(total_deaths as int)) as totalDeathCount
from portfolioproject..CovidDeaths 
--where location like '%anad%'
where continent is not null
group by continent
order by totalDeathCount desc

--GLOBAL NUMBERS

select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPrcentage
from portfolioproject..CovidDeaths 
--where location like '%anad%'
where continent is not null
--group by date
order by 1,2

--Using CovidVaccination Table

select * from portfolioproject..CovidDeaths as dea
join portfolioproject..CovidVaccinations as vac
    on dea.location = vac.location and 
	dea.date = vac.date

--Looking at Total Population vs Vaccinations

select dea.continent,dea.location,dea.date,dea.population,cast(vac.new_vaccinations as int) 
as newvaccinations
from portfolioproject..CovidDeaths as dea
join portfolioproject..CovidVaccinations as vac
    on dea.location = vac.location and 
	dea.date = vac.date
	where dea.continent is not null
	order by 2,3


select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) 
over(partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from portfolioproject..CovidDeaths as dea
join portfolioproject..CovidVaccinations as vac
    on dea.location = vac.location and 
	dea.date = vac.date
	where dea.continent is not null
	order by 2,3

--USE CTE

With PopvsVac (continent,location,date,population,new_vaccinations,rollingpeoplevaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) 
over(partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated 
--(RollingPeopleVaccinated/population)*100
from portfolioproject..CovidDeaths as dea
join portfolioproject..CovidVaccinations as vac
    on dea.location = vac.location and 
	dea.date = vac.date
	where dea.continent is not null
	--order by 2,3
)
select * , (RollingPeopleVaccinated/population)*100 as VaccinationDrive
from PopvsVac


--TEMP TABLE
Drop table if exists #Percentpopulationvaccinated
Create Table #Percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Rollingpeoplevaccinated numeric
)

Insert into #Percentpopulationvaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) 
over(partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated 
--(RollingPeopleVaccinated/population)*100
from portfolioproject..CovidDeaths as dea
join portfolioproject..CovidVaccinations as vac
    on dea.location = vac.location and 
	dea.date = vac.date
	--where dea.continent is not null
	--order by 2,3
Select * , (RollingPeopleVaccinated/population)*100 as VaccinationDrive
from #Percentpopulationvaccinated


--Creating view to store data for later visualization


Create View 
Percentpopulationvaccinated as 
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) 
over(partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated 
--(RollingPeopleVaccinated/population)*100
from portfolioproject..CovidDeaths as dea
join portfolioproject..CovidVaccinations as vac
    on dea.location = vac.location and 
	dea.date = vac.date
	where dea.continent is not null
	--order by 2,3

Select *
from Percentpopulationvaccinated

