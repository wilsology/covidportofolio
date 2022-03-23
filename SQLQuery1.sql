--SELECT *
--FROM PortofolioProject..CovidDeath
--order by 3,4

--SELECT *
--FROM PortofolioProject..CovidVacc
--order by 3,4

--Select Data that we are going to be using
SELECT Location, date, total_cases,new_cases,total_deaths, population
FROM PortofolioProject..CovidDeath
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths, shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases,total_deaths,(Total_deaths/Total_cases)*100 AS death_percentage
FROM PortofolioProject..CovidDeath
WHERE Location = 'Singapore'
ORDER BY 1,2

--look at total cases vs total population, shows what percentage of population got covid
SELECT Location, date, total_cases,population,(Total_cases/population)*100 AS infect_rate
FROM PortofolioProject..CovidDeath

ORDER BY 1,2

--finding which country have the highest infection rate compared to population
SELECT Location, MAX(total_cases) AS HighestInfected ,population,MAX((Total_cases/population))*100 AS infect_rate
FROM PortofolioProject..CovidDeath
GROUP BY location,population
ORDER BY infect_rate DESC

--showing countries with highest death rate
SELECT Location, MAX(cast(total_deaths AS int)) AS HighestTotalDeathCount
FROM PortofolioProject..CovidDeath
WHERE continent is not null
GROUP BY location
ORDER BY HighestTotalDeathCount DESC

--by continent --show continent with highest death count per population
SELECT continent, MAX(cast(total_deaths AS int)) AS HighestTotalDeathCount
FROM PortofolioProject..CovidDeath
WHERE continent is not null
GROUP BY continent
ORDER BY HighestTotalDeathCount DESC


--by global numbers
SELECT SUM(new_cases) AS TotalNewCase, SUM(CAST(new_deaths AS int)) AS TotalNewDeath, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS death_percentage
FROM PortofolioProject..CovidDeath
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2
--joining death data and vac data tgt
SELECT *
FROM PortofolioProject..CovidDeath as Dea
JOIN PortofolioProject..CovidVacc as Vac
	ON dea.location=vac.location
	AND dea.date=vac.date

--looking at population and vaccination rate
SELECT dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations,SUM(CAST(vac.new_vaccinations AS bigint)) OVER (partition by dea.location order by dea.location, dea.date)AS RunningTotalVaccinated
FROM PortofolioProject..CovidDeath as Dea
JOIN PortofolioProject..CovidVacc as Vac
	ON dea.location=vac.location
	AND dea.date=vac.date
	WHERE dea.continent is not null
	ORDER BY 2,3


--CTE 
WITH PopVSVac (Continent,location,date,population,new_vaccinations,RunningTotalVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations,SUM(CAST(vac.new_vaccinations AS bigint)) OVER (partition by dea.location order by dea.location, dea.date)AS RunningTotalVaccinated
FROM PortofolioProject..CovidDeath as Dea
JOIN PortofolioProject..CovidVacc as Vac
	ON dea.location=vac.location
	AND dea.date=vac.date
	WHERE dea.continent is not null
)
Select *, RunningTotalVaccinated/Population*100 AS VaccinationRate
From PopVSVac


--CTE without date
WITH PopVSVac (continent,location,population,new_vaccinations,RunningTotalVaccinated)
AS
(
SELECT dea.continent, dea.location,dea.population,vac.new_vaccinations,SUM(CAST(vac.new_vaccinations AS bigint)) OVER (partition by dea.location order by dea.location)AS RunningTotalVaccinated
FROM PortofolioProject..CovidDeath as Dea
JOIN PortofolioProject..CovidVacc as Vac
	ON dea.location=vac.location
	AND dea.date=vac.date
	WHERE dea.continent is not null
)
Select *, (RunningTotalVaccinated)/Population*100 AS VaccinationRate
From PopVSVac

--creating view for tableau viz
Create VIEW deathcount AS
WITH PopVSVac (Continent,location,date,population,new_vaccinations,RunningTotalVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations,SUM(CAST(vac.new_vaccinations AS bigint)) OVER (partition by dea.location order by dea.location, dea.date)AS RunningTotalVaccinated
FROM PortofolioProject..CovidDeath as Dea
JOIN PortofolioProject..CovidVacc as Vac
	ON dea.location=vac.location
	AND dea.date=vac.date
	WHERE dea.continent is not null
)
Select *, RunningTotalVaccinated/Population*100 AS VaccinationRate
From PopVSVac