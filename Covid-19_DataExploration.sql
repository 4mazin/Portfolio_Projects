SELECT*
FROM [Covid-19_DataExploration]..CovidDeaths$
--where continent is not null
order by 3,4

--SELECT*
--FROM [Covid-19_DataExploration]..CovidVaccinations$
--ORDER BY 3,4

--select data that we are going to use

select location , date , total_cases, new_cases , total_deaths , population
FROM [Covid-19_DataExploration]..CovidDeaths$
where continent is not null
order by 1 , 2

-- LOKKING AT TOTAL_CASES VS TOTAL_DEATHS
-- SHOWS LIKELIHOOD OF DYING IF YOU CONTRACT COVID IN EGYPT FOR (30/APRIL/2021)
select location , date , total_cases, new_cases , total_deaths ,(total_deaths/total_cases)*100 as Death_Percentage
FROM [Covid-19_DataExploration]..CovidDeaths$
where location like '%egypt%'
AND continent is not null
order by 1,2


-- LOOKING AT THE TOTAL_CASES VS POPULATION
-- SHOWS WHAT PERCENTAGE OF POPULATION GOT COVID (30/APRIL/2021)
select location , date ,population, total_cases ,(total_cases/population)*100 as Percent_Population_Infected
FROM [Covid-19_DataExploration]..CovidDeaths$
--where location like '%egypt%'
where continent is not null
order by 1,2


--LOOKING AT COUNTRIES WITH HEIEST INFECTION RATE COMPARED TO POPULATION

select location , population , MAX(total_cases) AS heiest_infection_count, MAX((total_cases/population))*100 as Percent_Population_Infected
FROM [Covid-19_DataExploration]..CovidDeaths$
where continent is not null
group by  location , population
order by Percent_Population_Infected desc

--LOOKING AT THE COUNTRIES WITH HIGHEST DEATHS COUNT PER LOCATION

select location  , MAX(cast(total_deaths as int)) AS heiest_death_count
FROM [Covid-19_DataExploration]..CovidDeaths$
where continent is not null
group by  location
order by heiest_death_count desc


--LOOKING AT THE continents WITH HIGHEST DEATHS COUNT PER POPULATION

select continent , MAX(cast(total_deaths as int)) AS heiest_death_count
FROM [Covid-19_DataExploration]..CovidDeaths$
where continent is not null
group by  continent
order by heiest_death_count desc



Select DEA.continent , DEA.location , DEA.date , population , VAC.new_vaccinations
, SUM(cast(VAC.new_vaccinations as int)) OVER (partition by DEA.location order by DEA.location , DEA.date)
AS Rolling_People_Vaccinations --, (Rolling_People_Vaccinations/population)*100
From [Covid-19_DataExploration]..CovidDeaths$ DEA
join [Covid-19_DataExploration]..CovidVaccinations$ VAC
	on DEA.location = VAC.location
	AND DEA.date = VAC.date
where DEA.continent is not null
--and DEA.location like '%Albania%'
order by 2,3

-- USE CTE

with popvsvac (continent , location , date , population , new_vaccinations , RollingPeapleVaccinations)
as(
Select DEA.continent , DEA.location , DEA.date , population , VAC.new_vaccinations
, SUM(cast(VAC.new_vaccinations as int)) OVER (partition by DEA.location order by DEA.location , DEA.date)
AS Rolling_People_Vaccinations --, (Rolling_People_Vaccinations/population)*100
From [Covid-19_DataExploration]..CovidDeaths$ DEA
join [Covid-19_DataExploration]..CovidVaccinations$ VAC
	on DEA.location = VAC.location
	AND DEA.date = VAC.date
where DEA.continent is not null)
--and DEA.location like '%Albania%'
select * , (RollingPeapleVaccinations/population)*100 AS Rolling_People_Vaccinations_Percentage
from popvsvac


--TEMP TABLE
drop table if exists #percentagepopulationvaccinated
create table #percentagepopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
RollingPeapleVaccinated numeric
)

insert into #percentagepopulationvaccinated
Select DEA.continent , DEA.location , DEA.date , population , VAC.new_vaccinations
, SUM(cast(VAC.new_vaccinations as int)) OVER (partition by DEA.location order by DEA.location , DEA.date)
AS Rolling_People_Vaccinations
From [Covid-19_DataExploration]..CovidDeaths$ DEA
join [Covid-19_DataExploration]..CovidVaccinations$ VAC
	on DEA.location = VAC.location
	AND DEA.date = VAC.date
--where DEA.continent is not null

select* ,(RollingPeapleVaccinated/population)*100 AS Rolling_People_Vaccinations_Percentage
from #percentagepopulationvaccinated



--Creating View to store data later for visualizations
/*
Go
Create View
percentagepopulationvaccinated as
Select DEA.continent , DEA.location , DEA.date , population , VAC.new_vaccinations
, SUM(cast(VAC.new_vaccinations as int)) OVER (partition by DEA.location order by DEA.location , DEA.date)
AS Rolling_People_Vaccinations --, (Rolling_People_Vaccinations/population)*100
From [Covid-19_DataExploration]..CovidDeaths$ DEA
join [Covid-19_DataExploration]..CovidVaccinations$ VAC
	on DEA.location = VAC.location
	AND DEA.date = VAC.date
where DEA.continent is not null
*/

