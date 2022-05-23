select *
From PortfolioProject..['Covid vaccinations']
Where continent is not NULL
order by 3,4 

--select * 
--From PortfolioProject..['Covid deaths']
--order by 3,4

--Select Data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..['Covid deaths']
order by 1,2


--looking at total cases vs total deaths
--refelcts lielihood of dying if contract covid by country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..['Covid deaths']
Where location like '%states%'
order by 1,2

---look at total cases vs population
---shows what percentage of the population got covid

select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..['Covid deaths']
Where location like '%states%'
order by 1,2

--looking at countries with highest infection rate compared to population

select location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..['Covid deaths']
--Where location like '%states%'
Group by Location, population
order by PercentPopulationInfected desc

--showing countries with highest death count per population

select location, MAX(cast(Total_deaths as int)) as TotaldeathCount
From PortfolioProject..['Covid deaths']
--Where location like '%states%'
Where continent is not NULL
Group by Location
order by TotaldeathCount desc


--LET'S BREAK THINGS DOWN BY CONTINENT



---showing continents with the highest death counts

select continent, MAX(cast(Total_deaths as int)) as TotaldeathCount
From PortfolioProject..['Covid deaths']
--Where location like '%states%'
Where continent is not NULL
Group by continent
order by TotaldeathCount desc


--GLOBAL NUMBERS

select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)
*100 as DeathPercentage
From PortfolioProject..['Covid deaths']
--Where location like '%states%'
where continent is not NULL
Group by date
order by 1,2

--Narrowed

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)
*100 as DeathPercentage
From PortfolioProject..['Covid deaths']
--Where location like '%states%'
where continent is not NULL
--Group by date
order by 1,2


--Looking at total population vs vaccinations


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
, (RollingPeopleVaccinated/population)*100
From PortfolioProject..['Covid deaths'] dea
Join PortfolioProject..['Covid vaccinations'] vac
   On dea.location = vac.location
   and dea.date = vac.date
   where dea.continent is not NULL
   order by 2,3



   ---USE CTE
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..['Covid deaths'] dea
Join PortfolioProject..['Covid vaccinations'] vac
   On dea.location = vac.location
   and dea.date = vac.date
   where dea.continent is not NULL
 --  order by 2,3
   )
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


---TEMP TABLE
DROP table if exists #Percentpopulationvaccinated
Create Table #Percentpopulationvaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)



Insert into #Percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
, (RollingPeopleVaccinated/population)*100
From PortfolioProject..['Covid deaths'] dea
Join PortfolioProject..['Covid vaccinations'] vac
   On dea.location = vac.location
   and dea.date = vac.date
   where dea.continent is not NULL
   --order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #Percentpopulationvaccinated


---Creating View To Store Data for later visualisations

Create View Percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
, (RollingPeopleVaccinated/population)*100
From PortfolioProject..['Covid deaths'] dea
Join PortfolioProject..['Covid vaccinations'] vac
   On dea.location = vac.location
   and dea.date = vac.date
   where dea.continent is not NULL
   --order by 2,3

   Select *
   From Percentpopulationvaccinated