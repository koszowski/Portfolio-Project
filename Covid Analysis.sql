-- Select data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM "CovidDeaths"
WHERE continent is not null
ORDER BY 1, 2;
-- Looking at total cases vs total deaths
-- Chances of dying if infected with covid in my country
SELECT location, date, total_cases, total_deaths, round(total_deaths/total_cases*100, 3) as DeathPercentage
FROM "CovidDeaths"
WHERE location = 'Poland' and continent is not null
ORDER BY 1, 2;
-- Looking at total cases vs population
-- Shows what percentage of population got covid
SELECT location, date, population::int, MAX(total_cases)::int, MAX(total_cases/population)*100 as InfectionPercentage 
FROM "CovidDeaths"
WHERE continent is not null
GROUP BY 1, 2, 3
ORDER BY 1, 2 desc;
-- Looking for coutries with highest infection rate
SELECT location, cast(population as int), cast(max(total_cases) as int) as maxinfections, max(total_cases/population*100) as InfectionPercentage 
FROM "CovidDeaths"
WHERE total_cases/population is not null and continent is not null
GROUP BY 1, 2
ORDER BY 4 DESC;
-- Looking for coutries with highest death rate
SELECT location, population, max(total_deaths), max(total_deaths/population*100) as DeathPercentage 
FROM "CovidDeaths"
WHERE total_deaths/population is not null and continent is not null
GROUP BY 1, 2
ORDER BY 4 DESC;
-- Looking for countries with highest death count
SELECT location, max(total_deaths) as DeathCount
FROM "CovidDeaths"
WHERE  continent is not null and total_deaths is not null
GROUP BY 1
ORDER BY 2 DESC;

-- Grouping things by continent

-- Looking for continents with highest death count
SELECT  continent, 
		sum(new_deaths)::int as DeathCount
FROM "CovidDeaths"
WHERE continent is not null		
GROUP BY 1
ORDER BY 2 DESC;

-- GLOBAL NUMBERS

-- Death percentage by day
SELECT  date,
		sum(new_cases) as global_new_cases,
		sum(new_deaths) as global_new_deaths,
		sum(new_deaths)/sum(new_cases)*100 as death_percentage
FROM "CovidDeaths"
WHERE continent is not null
GROUP BY date
ORDER BY date;
-- Death percentage globally
SELECT	sum(new_cases)::int as total_cases,
		sum(new_deaths)::int as total_deaths,
		sum(new_deaths)/sum(new_cases)*100 as death_percentage
FROM "CovidDeaths"
WHERE continent is not null;

-- JOINING 2 TABLES
-- Total population vs new vaccinations and running total vaccinations
SELECT	continent, d.location, d.date, population,
		new_vaccinations,
		sum(new_vaccinations) over(partition by d.location order by d.location, d.date) as rolling_total_vaccinations
FROM "CovidDeaths" AS d
	INNER JOIN "CovidVaccinations" AS v
	ON d.location = v.location
	AND d.date = v.date
WHERE continent is not null
ORDER BY 2, 3;
-- Showing running vaccination percentage using CTE
WITH rolling_vaccinations AS(
	SELECT	continent, d.location, d.date, population,
		new_vaccinations,
		sum(new_vaccinations) over(partition by d.location order by d.location, d.date) as rolling_total_vaccinations
	FROM "CovidDeaths" AS d
		INNER JOIN "CovidVaccinations" AS v
		ON d.location = v.location
		AND d.date = v.date
	WHERE continent is not null
	ORDER BY 2, 3)
SELECT 	continent, location, date, population, rolling_total_vaccinations,
		rolling_total_vaccinations/population*100 AS vaccination_perce
FROM rolling_vaccinations
ORDER BY 2, 3;
-- Showing running vaccination percentage using temporary table
DROP TABLE IF EXISTS rolling_vaccinations;
CREATE TABLE rolling_vaccinations (
	continent character(50),
	location character(50),
	date date,
	population numeric,
	new_vaccinations numeric,
	rolling_total_vaccinations numeric);
INSERT INTO rolling_vaccinations (
	SELECT	continent, d.location, d.date, population,
			new_vaccinations,
			sum(new_vaccinations) over(partition by d.location order by d.location, d.date) as rolling_total_vaccinations
	FROM "CovidDeaths" AS d
		INNER JOIN "CovidVaccinations" AS v
		ON d.location = v.location
		AND d.date = v.date
	WHERE continent is not null
	ORDER BY 2, 3);
SELECT *, rolling_total_vaccinations/population*100 AS vaccination_percentage
FROM rolling_vaccinations;









