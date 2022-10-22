
Select *
FROM [Portfolio Project COVID19 ]..[Covid Deaths]
order by 3,4

Select *
FROM [Portfolio Project COVID19 ]..[Covid Vac]
order by 3,4

--Select Data that we are going to be using 

Select Location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project COVID19 ]..[Covid Deaths]
order by 1,2

--Looking at total cases vs total deaths in the US 

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project COVID19 ]..[Covid Deaths]
WHERE location like '%states%'
order by 1,2

--Total cases vs population, what % of population contracted COVID? 
Select Location, date, population total_cases, (total_cases/Population)*100 as InfectionRate
From [Portfolio Project COVID19 ]..[Covid Deaths]
WHERE location like '%states%'
order by 1,2

--Countries with highest infection rate compared to population
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercectPopulationInfected
From [Portfolio Project COVID19 ]..[Covid Deaths]
Group by Location, Population	
order by PercectPopulationInfected desc

--Showing Countries with Highest Death count per population
Select Location, MAX(CAST(total_deaths as int)) as TotalDeathCount
From [Portfolio Project COVID19 ]..[Covid Deaths]
Where continent is not null
Group by Location
order by TotalDeathCount desc

--Global Numbers
SELECT date, SUM(new_cases), SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(new_cases)*100 as GlobalDeathPercentage
FROM [Portfolio Project COVID19 ]..[Covid Deaths]
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--Looking at total population vs Vaccinations
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, TotalPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER by dea.location, dea.Date) as TotalPeopleVaccinated
FROM [Portfolio Project COVID19 ]..[Covid Deaths] dea
JOIN [Portfolio Project COVID19 ]..[Covid Vac] vac
	ON dea.location = vac.location
	and dea.date = vac.date 
)
SELECT * , (TotalPeopleVaccinated/Population)*100 as PercentageVaccinated
FROM PopvsVac

--TEMP TABLE 
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
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM [Portfolio Project COVID19 ]..[Covid Deaths] dea
JOIN [Portfolio Project COVID19 ]..[Covid Vac] vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating view to store data for later viz
Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM [Portfolio Project COVID19 ]..[Covid Deaths] dea
JOIN [Portfolio Project COVID19 ]..[Covid Vac] vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

