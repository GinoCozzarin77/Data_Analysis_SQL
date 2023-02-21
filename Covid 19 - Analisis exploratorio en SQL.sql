/*
Covid 19 Exploracion de datos
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select *
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 3,4

-- Seleccionamos los datos con los que vamos a comenzar
-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths

-- Muestra la probabilidad de morir si contrae covid en su pais
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
From PortfolioProject..CovidDeaths
Where location like '%Argentina%'
and continent is not null 
and total_cases <> '0'
order by 1,2


-- Total Cases vs Population

-- Mostramos que pocentaje de la poblacion esta infectada con Covid
-- Shows what percentage of population infected with Covid

Select Location, date, population, total_cases,  (total_cases/population)*100 as Percent_Population_Infected
From PortfolioProject..CovidDeaths
Where location like '%Argentina%'
and population <> '0'
order by 1,2

--Mostramos los paises con el ratio de infeccion mas alto comparado con su poblacion
-- Countries with Highest Infection Rate compared to Population

Select Location, population, MAX(total_cases) as Highest_InfectionCount,  Max((total_cases/population))*100 as Percent_Population_Infected
From PortfolioProject..CovidDeaths
Where  population <> '0'
--and location like '%Argentina%'
Group by Location, population
order by Percent_Population_Infected desc

--Mostramos los paises con el acumulado de muertes mas alto por su poblacion
-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as Total_death_Count
From PortfolioProject..CovidDeaths
Where continent is not null
-- and location like '%Argentina%'
Group by Location
order by Total_death_Count desc

-- DESGLOSE POR CONTINENTE
-- BREAKING THINGS DOWN BY CONTINENT

--Mostramos los continentes con el acumulado de muertes mas alto por su poblacion
-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as Total_death_Count
From PortfolioProject..CovidDeaths
-- and location like '%Argentina%'
Where continent is not null 
Group by continent
order by Total_death_Count desc

-- NUMEROS GLOBALES
-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%Argentina%'
where continent is not null 
--Group By date
order by 1,2


-- Total Population vs Vaccinations

-- Con esta consulta mostramos el porcentaje de la poblacion que al menos recibio una vacuna contra el Covid
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Rolling_People_Vaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Uso de CTE (common table expressions) para realizar el cálculo en la clausula Partition by de la consulta anterior
-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Rolling_People_Vaccinated
--, (Rolling_People_Vaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (Rolling_People_Vaccinated/population)*100
From PopvsVac
where PopvsVac.population <> '0'	

-- Usamos una tabla temporal para realizar el cálculo en la clausula Partition by de la consulta anterior
-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #Percent_Population_Vaccinated
Create Table #Percent_Population_Vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations bigint,
Rolling_People_Vaccinated numeric
)

Insert into #Percent_Population_Vaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Rolling_People_Vaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (Rolling_People_Vaccinated/Population)*100
From #Percent_Population_Vaccinated
where #Percent_Population_Vaccinated.population <> '0' 

-- Creamos una Vista para almacenar datos para visualizaciones posteriores
-- Creating View to store data for later visualizations

Create View Percent_Population_Vaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Rolling_People_Vaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

