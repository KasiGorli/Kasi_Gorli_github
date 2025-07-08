use Portfolio_Project



select * from CovidVaccinations$
where continent is not null
order by 3,4

--select data that we are going to be using

select location,date,total_cases,new_cases,total_deaths,population
from CovidDeaths$
order by 1,2
 
 -- We will Look at total cases vs total deaths
 -- Also likelihood of dying if you contract covid in your country

select location,date,total_cases,total_deaths,(total_deaths/total_cases * 100) as Death_Percentage 
from CovidDeaths$
where location like '%states%'
order by 1,2

--Looking at Total_cases vs Population
--Shows what percentage got covid

select location,date,total_cases,population,(total_cases/population * 100) as Death_Percentage 
from CovidDeaths$
where location like '%states%'
order by 1,2

--Looking at countries with highes infection rate

select location,population, MAX(total_cases) as Highest_infections, MAX(total_cases/population * 100) as Percent_population_infected
from CovidDeaths$
group by location, population
order by Percent_population_infected desc

--showing countries with highest death count per population

select location, max(cast(total_deaths as int)) as Highest_deaths --MAX(total_deaths/population) as percent_population_died
from CovidDeaths$
--where location like '%india%'
where continent is null
group by location
order by Highest_deaths desc

-- Showing continents with the higest_death counts

select continent, max(cast(total_deaths as int)) as Highest_deaths 
from CovidDeaths$
--where location like '%india%'
where continent is not null
group by continent
order by Highest_deaths desc

--Global Numbers

select sum(new_cases) as Total_cases, sum(cast(new_deaths as int)) as Total_deaths, sum(cast(new_deaths as int))/sum(new_cases)* 100 as Death_Percentage--, total_deaths, (total_deaths/total_cases* 100) as Death_percentage
from CovidDeaths$
where continent is not null
group by date
order by 1,2

--Looking at Total population vs Vaccinations

with POPvsVacc ( continent, location, date, Population, new_vaccination, Running_total) as
(
select cd.location,cd.date, cd.continent,cd.population,cv.new_vaccinations, SUM(convert(int,cv.new_vaccinations)) over (partition by cd.location, cd.date order by cd.location, cd.date) as Running_total
from CovidDeaths$ cd
join CovidVaccinations$ cv
on cd.continent = cv.continent and cd.date = cv.date
where cd.continent is not null and cv.new_vaccinations is not null
)

select * ,(Running_total/population) * 100 as Percentage
from POPvsVacc

--Temp Table
 drop table #Percentpopulationvaccinated

 create table #Percentpopulationvaccinated
 (
 continent varchar(255),
 location varchar(255),
 Date datetime,
 Population numeric,
 New_vaccinations numeric,
 Running_total numeric
 )

 insert into #Percentpopulationvaccinated
 select cd.location,cd.date), cd.continent,cd.population,cv.new_vaccinations, SUM(convert(int,cv.new_vaccinations)) over (partition by cd.location, cd.date order by cd.location, cd.date) as Running_total
from CovidDeaths$ cd
join CovidVaccinations$ cv
on cd.continent = cv.continent and cd.date = cv.date
where cd.continent is not null and cv.new_vaccinations is not null

--Creating a view to store data for later visualizations

create view PopulationPercentVaccinate as

select cd.location,cd.date, cd.continent,cd.population,cv.new_vaccinations, 
	SUM(convert(int,cv.new_vaccinations)) 
over (partition by cd.location, cd.date order by cd.location, cd.date) as Running_total
from CovidDeaths$ cd
join CovidVaccinations$ cv
	on cd.continent = cv.continent and cd.date = cv.date
	where cd.continent is not null 
	--and cv.new_vaccinations is not null

