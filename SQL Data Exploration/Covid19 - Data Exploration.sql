-- All data ordered by location and date
SELECT *
FROM ExploratoryAnalysis..CovidDeaths
order by 3, 4; 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM ExploratoryAnalysis..CovidDeaths
order by 1, 2;

-- Total Cases vs. Total Deaths Percentage
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
FROM ExploratoryAnalysis..CovidDeaths
order by 1, 2;

-- Total Cases vs. Population Percentage
SELECT location, date, total_cases, population, (total_cases/population)*100 as InfectedPercentage 
FROM ExploratoryAnalysis..CovidDeaths
order by 1, 2;

CREATE VIEW PercentPopulationInfected as
SELECT location, date, total_cases, population, (total_cases/population)*100 as InfectedPercentage 
FROM ExploratoryAnalysis..CovidDeaths;

SELECT location, date, total_cases, population, (total_cases/population)*100 as InfectedPercentage 
FROM ExploratoryAnalysis..CovidDeaths
WHERE location = 'Serbia'
order by 1, 2;

SELECT location, date, total_cases, population, (total_cases/population)*100 as InfectedPercentage 
FROM ExploratoryAnalysis..CovidDeaths
WHERE location like '%states%'
order by 1, 2;

-- Countries with the highest infection rates compared to their population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 AS PopulationInfectedPercentage  
FROM ExploratoryAnalysis..CovidDeaths
GROUP BY location, population
ORDER BY PopulationInfectedPercentage DESC;

-- Highest deaths count per country
SELECT location, MAX(CAST(total_deaths AS int)) AS HighestDeathsCount
FROM ExploratoryAnalysis..CovidDeaths
WHERE continent <> 'NULL'
GROUP BY location
ORDER BY HighestDeathsCount DESC;

-- Loking at the data per continent
-- Highest Death Count Per Continent
SELECT continent, MAX(cast(total_deaths as INT)) MaxTotalDeaths
FROM ExploratoryAnalysis..CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY MaxTotalDeaths DESC;

-- Total Numbers Worldwide
SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths as INT)) AS TotalDeaths, (SUM(CAST(new_deaths as INT))/SUM(new_cases))*100 AS DeathPercentage
FROM ExploratoryAnalysis..CovidDeaths
WHERE continent is not NULL
ORDER BY 1, 2;

-- Total Number of Vaccinations vs Population per Date & Country
SELECT cv.location, cv.date, cd.population, cv.new_vaccinations,
SUM(CAST(cv.new_vaccinations AS INT)) OVER(PARTITION BY cv.location ORDER BY cv.location, cv.date) as TotalVaccinations
FROM ExploratoryAnalysis..CovidVaccinations AS cv
JOIN ExploratoryAnalysis..CovidDeaths AS cd ON cv.iso_code = cd.iso_code AND cv.date = cd.date
WHERE cv.continent is not null
ORDER BY 1, 2;

-- View to store this data
CREATE VIEW TotalVaccinationsPerCountry AS
SELECT cv.location, cv.date, cd.population, cv.new_vaccinations,
SUM(CAST(cv.new_vaccinations AS INT)) OVER(PARTITION BY cv.location ORDER BY cv.location, cv.date) as TotalVaccinations
FROM ExploratoryAnalysis..CovidVaccinations AS cv
JOIN ExploratoryAnalysis..CovidDeaths AS cd ON cv.iso_code = cd.iso_code AND cv.date = cd.date
WHERE cv.continent is not null;

-- Percentage of vaccinated people per country and date (using previous query) 
WITH AllTotalVaccinations AS(
SELECT cv.location, cv.date, cd.population, cv.new_vaccinations,
SUM(CAST(cv.new_vaccinations AS INT)) OVER(PARTITION BY cv.location ORDER BY cv.location, cv.date) as TotalVaccinations
FROM ExploratoryAnalysis..CovidVaccinations AS cv
JOIN ExploratoryAnalysis..CovidDeaths AS cd ON cv.iso_code = cd.iso_code AND cv.date = cd.date
WHERE cv.continent is not null
)
SELECT location, date, population, new_vaccinations, TotalVaccinations, ((TotalVaccinations)/population)*100 as PercentageVaccinated
FROM AllTotalVaccinations;

-- Percentage of vaccinated people per country
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated(
Location nvarchar(255),
Population numeric,
New_vaccinations numeric,
TotalVaccinations numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT cv.location, cd.population, cv.new_vaccinations,
SUM(CAST(cv.new_vaccinations AS INT)) OVER(PARTITION BY cv.location ORDER BY cv.location) as TotalVaccinations
FROM ExploratoryAnalysis..CovidVaccinations AS cv
JOIN ExploratoryAnalysis..CovidDeaths AS cd ON cv.iso_code = cd.iso_code AND cv.date = cd.date
WHERE cv.continent is not null

SELECT DISTINCT location, population, TotalVaccinations, (TotalVaccinations/population)*100 PercentageVaccinated
FROM(SELECT *, DENSE_RANK() OVER(PARTITION BY location ORDER BY TotalVaccinations DESC) AS d_rnk
		FROM #PercentPopulationVaccinated) Max_Vaccinated
WHERE Max_Vaccinated.d_rnk = 1;


-- Percentage of worldwide population that's gotten vaccinated
WITH TotalVaccinatedPerCountry AS (
SELECT DISTINCT location, population, TotalVaccinations
FROM(SELECT *, DENSE_RANK() OVER(PARTITION BY location ORDER BY TotalVaccinations DESC) AS d_rnk
		FROM #PercentPopulationVaccinated) Max_Vaccinated
WHERE Max_Vaccinated.d_rnk = 1
)
SELECT SUM(population) AS WorldPopulation, SUM(TotalVaccinations) AS WorldwideVaccinations, (SUM(TotalVaccinations)/SUM(population))*100 AS PercentageVaccinated
FROM TotalVaccinatedPerCountry;

