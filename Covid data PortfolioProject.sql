SELECT * FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 3 , 4



--TOTAL CASES TILL DATE, TOTAL DEATHS TILL DATE AND DEATH PERCENT PER COUNTRY 
--LIKELIHOOD OF DYING DUE TO COVID IN EACH COUNTRY

SELECT location, SUM(new_cases) as Total_Covid_Cases, SUM(COALESCE(new_deaths,0)) as Total_Covid_Deaths,
(SUM(COALESCE(new_deaths,0))/SUM(new_cases))*100 as DeathPercentPerCountry
FROM PortfolioProject..CovidDeaths 
WHERE continent is not null
GROUP BY PortfolioProject..CovidDeaths.location 
ORDER BY PortfolioProject..CovidDeaths.location



--DEATH PERCENT PER DAY IN EACH COUNTRY
--LIKELIHOOD OF DYING DUE TO HAVING COVID PER DAY

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as DeathPercentperDay 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--TOTAL CASES VS POPULATION PER DAY

SELECT location, date, Population, total_cases, (total_cases/Population)*100 as Total_Cases_Vs_Population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY location, date;


--COUNTRIES WITH THEIR HIGHEST INFECTION RATE

SELECT location,Population, MAX(total_cases) as HighestInfectionCases, MAX((total_cases/Population)*100) as HighestCaseCount_percent
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location, Population
ORDER BY HighestCaseCount_percent DESC;

--COUNTRIES WITH THE MAX DEATHS IN A DAY FROM HIGHEST TO LOWEST

SELECT location, MAX(cast(total_deaths as int)) as Max_Deaths_Per_Day
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY Max_Deaths_Per_Day DESC


--CONTINENTS WITH TOTAL CONTRACTION CASES FROM HIGHEST TO LOWEST

SELECT continent,SUM(new_cases) as Total_Cases 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY SUM(total_cases) DESC;

--CONTINENTS WITH MAX CONTRACTION CASES PER DAY 

SELECT continent, MAX(cast(total_deaths as int)) as Max_Deaths_Per_Day
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY Max_Deaths_Per_Day DESC;


--CONTINENTS- NULL AND LOCATION-CONTINENTS 

SELECT location, MAX(cast(total_deaths as int)) as Max_Death_Count_In_A_Day
FROM PortfolioProject..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY Max_Death_Count_In_A_Day DESC

--GLOBAL DEATH RATE PER DAY


SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as Total_Deaths,
CASE 
WHEN SUM(cast(new_deaths as int))=0 THEN Null
ELSE SUM(cast(new_deaths as int))/SUM(new_cases) * 100
END AS DeathPercent
FROM PortfolioProject..CovidDeaths
GROUP BY date
ORDER BY date;

--COVID VACCINATIONS VS POPULATION PER DAY TO CALCULATE TOTAL NO OF VACCINATED PEOPLE EACH DAY

SELECT Death.continent, Death.location, Death.date, Death.population, Vac.new_vaccinations,
SUM(CONVERT(int, Vac.new_vaccinations)) OVER (PARTITION BY Death.location) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as Death
JOIN PortfolioProject..CovidVaccinations as Vac
ON Death.location=Vac.location and Death.date=Vac.date
WHERE Death.continent is not null
ORDER BY Death.location, Death.date;





--COVID VACCINATIONS VS POPULATION PER DAY TO CALCULATE THE PERCENTAGE OF PEOPLE VACCINATED(USING CTE)

WITH PopVsVac ( continent, location, date, population, NewVaccinations, RollingPeopleVaccinated) as
(
SELECT Death.continent, Death.location, Death.date, Death.population, Vac.new_vaccinations,
SUM(CONVERT(int,Vac.new_vaccinations)) OVER (Partition By Death.location ORDER BY Death.location, Death.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as Death
JOIN PortfolioProject..CovidVaccinations as Vac
ON Death.location=Vac.location AND DEATH.date=Vac.date
WHERE Death.continent is not null )
SELECT *, (RollingPeopleVaccinated/population)*100 as 'PercentVaccinated'
FROM PopVsVac ORDER BY location


--COVID VACCINATIONS VS POPULATION PER DAY TO CALCULATE THE PERCENTAGE OF PEOPLE VACCINATED(USING temp table)

DROP TABLE if exists #PeopleVaccinatedPercentage

CREATE TABLE #PeopleVaccinatedPercentage
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PeopleVaccinatedPercentage
SELECT Death.continent, Death.location, Death.date, Death.population, Vac.new_vaccinations, 
SUM(CONVERT(int, Vac.new_vaccinations)) OVER (PARTITION BY Death.location ORDER BY Death.location, Death.date)
FROM PortfolioProject..CovidDeaths as Death
JOIN PortfolioProject..CovidVaccinations as Vac
ON Death.location=Vac.location and Death.date=Vac.date
WHERE Death.continent is not null

SELECT *, (RollingPeopleVaccinated/population)*100 as PercentVaccinated
FROM #PeopleVaccinatedPercentage ORDER BY location,date


--Create view

CREATE VIEW PercentPopulationVaccinated as 
SELECT Death.continent, Death.location, Death.date, Death.population, Vac.new_vaccinations, 
SUM(CONVERT(int, Vac.new_vaccinations)) OVER (PARTITION BY Death.location ORDER BY Death.location, Death.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as Death
JOIN PortfolioProject..CovidVaccinations as Vac
ON Death.location=Vac.location and Death.date=Vac.date
WHERE Death.continent is not null

SELECT * FROM PercentPopulationVaccinated





















