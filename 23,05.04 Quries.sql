
select *
from Covid19Vaccinations
order by 3,4

select count (people_fully_vaccinated)
from covid19vaccinations


select count (people_vaccinated)
from Covid19Vaccinations

select *
from Covid19Deaths
order by 3,4;


select location, date, total_cases, new_cases, total_deaths,population
from Covid19Deaths
order by 1,2

--Total cases Vs Total Deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
from Covid19Deaths
Where location like '%gha%'
order by 1,2

--Total population that has Covid

select location, date, total_cases, population, (total_cases/population)*100 as Populationpercentage
from Covid19Deaths
Where location like '%gha%'
order by 1,2

--Looking at countries with highest infection rate compared to population

select location, population, max(total_cases) as HighestInfectioncount, 
max(total_cases/population)*100 as Populationpercentageinfected
from Covid19Deaths
--Where location like '%africa%'
group by location, population
order by Populationpercentageinfected desc


create view Populationpercentageinfected as
select location, population, max(total_cases) as HighestInfectioncount, 
max(total_cases/population)*100 as Populationpercentageinfected
from Covid19Deaths
--Where location like '%africa%'
group by location, population
--order by Populationpercentageinfected desc

select *
from Populationpercentageinfected


--Showing countries with highest death count  per population

select location, max(total_deaths) as TotaldeathCount
from Covid19Deaths
--Where location like '%africa%'
group by location
order by TotaldeathCount desc

Create view TotalDeathCountbyCountry as
select location, max(total_deaths) as TotaldeathCount
from Covid19Deaths
--Where location like '%africa%'
group by location
--order by TotaldeathCount desc

select *
from TotalDeathCountbyCountry

select location, max(cast(total_deaths as int)) as TotaldeathCount
from Covid19Deaths
--Where location like '%africa%'
where continent is not null
group by location
order by TotaldeathCount desc

--Showing continents with the highest death count per population

select continent, max(cast(total_deaths as int)) as TotaldeathCount
from Covid19Deaths
--Where location like '%africa%'
where continent is not null
group by continent
order by TotaldeathCount desc

--Global numbers

select  date, sum(cast(new_cases as int)), sum(cast(new_deaths as int)) --sum(new_deaths)/sum(new_cases)*100 as deathpercentage
from Covid19Deaths
--Where location like '%gha%'
where continent is null
group by date
order by 1,2

--Looking at Total Population vs Vaccinations

select *
from Covid19Deaths dea
join Covid19Vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from Covid19Deaths dea
join Covid19Vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
order by 1,2,3

--CTE

with popvsVac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from Covid19Deaths dea
join Covid19Vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--order by 1,2,3
)
select *, (rollingpeoplevaccinated/population)*100
from popvsVac



--Temp Table

Drop table if exists #Percentpopulationvaccinated
Create Table #Percentpopulationvaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #Percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from Covid19Deaths dea
join Covid19Vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--order by 1,2,3

select *, (RollingPeopleVaccinated/population)*100
from #Percentpopulationvaccinated

--Creating view to store Date for Later Visualization

create view Percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from Covid19Deaths dea
join Covid19Vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--order by 1,2,3

select *
from Percentpopulationvaccinated