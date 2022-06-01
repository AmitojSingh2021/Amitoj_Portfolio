

	---Explore COVID dataset---

Select * 
	From portfolio_project.dbo.coviddeaths 
	where continent is not null
	order by location, date;

	--- Continent-wise total death rate---

Select continent, 
	MAX(cast(total_deaths as int)) as death_continent 
	From portfolio_project.dbo.coviddeaths 
	where continent is not null 
	group by continent 
	order by death_continent desc;

	---Country-wise total death count---

Select location, 
	MAX(cast(total_deaths as int)) as TotalDeathCount
	From portfolio_project.dbo.coviddeaths
	Where total_deaths is not null
	Group by Location
	order by TotalDeathCount desc;

	---Country-wise population died (countries with 50 million or more population, only)---

Select location, population, max(cast(total_deaths as int)) as total_deaths, 
	round((max(cast(total_deaths as int))/population)*100,4) as PercentPopulationDied
	From portfolio_project.dbo.coviddeaths 
	where population >50000000 and total_deaths is not null
	group by location, population
	order by PercentPopulationDied desc;

	---Country-wise population infected (countries with 50 million or more population, only)---

Select location, population, sum(cast(new_cases as int)) as total_cases, 
	round((sum(cast(new_cases as int))/population)*100,2) as PercentPopulationInfected
	From portfolio_project.dbo.coviddeaths 
	where population >50000000 
	group by location, population 
	order by PercentPopulationInfected desc;

	---Explore COVID vaccinations dataset---

Select * 
	From portfolio_project.dbo.covidvaccines 
	where continent is not null
	order by location, date 
	offset 0 rows fetch first 25 rows only;

	---Total doses administrated vs population country-wise analysis---

with tda as (Select location,continent, max(date) as date, max(population) as population, 
	max(sum(cast(new_vaccinations as bigint)))
	over (partition by location order by location) as total_doses_administrated 
	From portfolio_project.dbo.covidvaccines 
	where population >50000000 and continent is not null and new_vaccinations is not null
	group by location, continent
	)
	select *, round((total_doses_administrated /population)*100,4) 
	as PercentPopulationdoses from tda order by PercentPopulationdoses desc;

	--- People fully vaccinated vs population---

with tfv as (select location, continent, max(date) as date, 
	max(population) as population, 
	max(cast(people_fully_vaccinated as int)) as people_fully_vaccinated
	From portfolio_project.dbo.covidvaccines 
	where population >50000000 and 
	people_fully_vaccinated is not null and 
	continent is not null 
	group by location, continent
	)
	select *, round((people_fully_vaccinated /population)*100,2) 
	as PercentPopulationFullyVaccinated from tfv order by PercentPopulationFullyVaccinated  desc;

	--- Analyzed US Covid death and vaccines dataset by creating temp table----

drop table if exists #US_coviddeaths;

Create table #US_coviddeaths 
	(
	location nvarchar(255),
	continent nvarchar(255),
	Date date,
	population numeric,
	RollingNewCases numeric,
	total_deaths numeric
	);

Insert into #US_coviddeaths
	Select location, continent, date, population,
	sum(convert(int, new_cases)) 
	over (partition by location order by location, date) as RollingNewCases,
	total_deaths
	From portfolio_project.dbo.coviddeaths 
	where continent is not null and total_deaths is not null and location like '%states%' 
	order by location, date
	offset 0 rows Fetch first 841 rows only;

Select * From #US_coviddeaths;

	--- United states death rate---
select location, 
	MAX((100*total_deaths)/population) as Death_rate 
	From  #US_coviddeaths
	group by location;

	---United states infection rate---

select location, 
	MAX((100*RollingNewCases)/population) as Infection_rate 
	From  #US_coviddeaths
	group by location;

	--- United states vaccination analysis---

drop table if exists #US_covidvaccines;

Create table #US_covidvaccines 
	(
	location nvarchar(255),
	continent nvarchar(255),
	date date,
	population numeric,
	doses_administrated numeric,
	Rolling_doses_administrated numeric,
	people_fully_vaccinated numeric
	);

Insert into #US_covidvaccines
	Select location, continent, 
	date, population, new_vaccinations,
	SUM(CONVERT(int,new_vaccinations)) 
	OVER (order by date) as Rolling_doses_administrated,
	people_fully_vaccinated
	From portfolio_project.dbo.covidvaccines 
	where continent is not null and 
	new_vaccinations is not null and
	location like '%states%' 
	order by location, date
	offset 0 rows Fetch first 841 rows only;

Select * From #US_covidvaccines;

	---United states total doses administrated---

select location, continent, max(cast(Rolling_doses_administrated as int)/population)*100 
	as PercentDosesAdministrated from #US_covidvaccines group by location, continent order by PercentDosesAdministrated desc;

	--- People fully vaccinated vs population---

select continent, date, round((people_fully_vaccinated /population)*100,2) 
	as PercentPopulationFullyVaccinated 
	from #US_covidvaccines
	order by date desc;

