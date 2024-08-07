# Project Overview
---
This is a Data Exploration and Data Visualization project that I completed as part of the Data Analytics Bootcamp by Alex The Analyst. The project consists of 2 parts: Data Exploration with SQL and Data Visualization with Tableau. I looked into a Covid-19 dataset with data from all countries in the world day-by-day with metrics such as total infected, total deaths and vaccinations. The goal of this project is to showcase skills in ability to write SQL queries for getting a specific outcomes and gathering the data in an organized way that will later serve for our visualization in Tableau, which will showcase overall metrics, deaths by continent, a map of population infected by country, and a forecast of infected population in 5 sample countries: China, India, Mexico, United Kingdom and United States

Original Dataset Link: https://github.com/owid/covid-19-data/tree/master/public/data

Project-purpose Dataset (after simple data cleaning in Excel):
1. Covid Deaths: [https://github.com/AlexTheAnalyst/Por...](https://www.youtube.com/redirect?event=video_description&redir_token=QUFFLUhqa1F1WVphaVpNYnMtRDk1aGpIOHB0eG9jb2dDZ3xBQ3Jtc0tuUmN3a2NCMjBhelJUSTlYZXBjeE5DMTRYMmxMWjg3N0RJT2gtYVYtRkZSNktQWDdOMVVabnpIaXpUNi01OVhCa3V4UHpMdklMYl9IaEp5NG44djRQb2J1X2xCeTZ6b3NCQmNfeVduTFA3UkpaQ0owaw&q=https%3A%2F%2Fgithub.com%2FAlexTheAnalyst%2FPortfolioProjects%2Fblob%2Fmain%2FCovidDeaths.xlsx&v=qfyynHBFOsM) 
2. Covid Vaccinations: [https://github.com/AlexTheAnalyst/Por...](https://www.youtube.com/redirect?event=video_description&redir_token=QUFFLUhqbTNxeEI3NU5lekY0T1R4WF9iRHl1b2JhSW1Rd3xBQ3Jtc0trcjhlSWFRR2V0MFlQOVNIOFBXekIxMV9XN3RyMGlRVlh5am1FSEFBZ2NpQXRkRXZvQTREYmFNWDRSZGJLM2R4OGQ1UjluWVVKaFpYWlNnVldFU3NuelVMMGVnUTM2di1ET1ZFMXBDYTdTeFhzMzd3cw&q=https%3A%2F%2Fgithub.com%2FAlexTheAnalyst%2FPortfolioProjects%2Fblob%2Fmain%2FCovidVaccinations.xlsx&v=qfyynHBFOsM)

# Import Dataset
---
The SQL part of this project was done using SQL Server Management Studio. Steps to import dataset into SSMS:

1. Open "SQL Server 2022 Import and Export Data"
2. Click on Next
3. In the "Choose a Data Source" prompt, select "Microsoft Excel" and browse the file location in your computer and click on Next
4. In the "Choose a Destination" prompt, select "Microsoft OLE DB Driver for SQL Server" 
5. Verify that the server name is correct, and select which database you want to import the dataset into (I recommend creating a new database called "CovidProject")
6. In the "Specify Table Copy or Query" prompt, select "Copy data from one or more tables or views" and click on Next
7. Select the table(s) you want to import and click on Next
8. In the "Save and Run Package" prompt, select "Run immediately" and click on Next. Then wait for the process to finish.

Note: You will need to import 2 tables following these steps: 'CovidDeaths.xlsm' and 'CovidVaccinations.xlsm'
# SQL Queries Overview
---
The SQL Queries for this project are divided into 3 parts:

- Exploration Queries: Data exploration, understanding the data and how it can be grouped
- Setup Query: making some changes to the dataset, namely removing unnecessary decimal places and changing some column names to make them clearer
- Query for Tableau Visualization: query the important data that is going to be the base for our visualization in Tableau
## Exploration Queries
---
Here I will showcase the most important queries for exploration that I did and their outcomes and insights. To view all the queries in full detail, you can download the project files.

### Death Percentage
---
First, let's look at Total Deaths vs Total Cases. The following query shows the likelihood of dying if a person contracts Covid in a given country. The example uses the United States:

```SQL
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location = 'United States'
ORDER BY 1, 2
```

Sample output: 
![[Pasted image 20240806124613.png]]

### Infected Percentage
---
Percentage of Population that contracted the virus.

```sql
SELECT location, date, population, total_cases, (total_cases/population)*100 AS InfectedPercentage
FROM CovidDeaths
WHERE location = 'United States'
ORDER BY 1, 2
```

Sample Output:

![[Pasted image 20240806125201.png]]

### Global Numbers
---
Evolution of the total number of infected cases and total number of deaths, as well as death percentage accounting for the whole world.

```SQL
SELECT date, SUM(new_cases) AS total_cases_worldwide, SUM(CAST(new_deaths AS INT)) AS total_deaths_worldwide, SUM(CAST(new_deaths AS INT))/SUM(NULLIF(new_cases, 0)) *100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2 DESC
```


Sample output: 
![[Pasted image 20240806131243.png]]

### Total Population vs Vaccinations
---
Query that shows daily new vaccinations by country each day compared to country population

```SQL
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3
```

Sample output:
![[Pasted image 20240807112036.png]]

#### Rolling Count of New Vaccinations using CTE
---
This query will give a rolling count of vaccinations compared to country population by country and by date. Rolling count basically means adding up numbers from the new_vaccinations column as it goes further down, as this dataset contains data records by date, means each record of new_vaccinations is for the specific date indicated in the date column. 

```SQL
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/population)*100 
FROM PopvsVac
```


Sample output: 
![[Pasted image 20240807112922.png]]

#### Rolling Count of New Vaccinations using Temp Table
---
Essentially the same thing we did in the previous query but using a temp table instead.

```SQL
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
( 
continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/population)*100 AS RollingPeopleVaccinatedPercentage
FROM #PercentPopulationVaccinated
```

Sample Output: 
![[Pasted image 20240807113608.png]]

### Creating View for Tableau Visualization
---
This query creates a view to simplify the dataset for the purpose of visualization in Tableau

```SQL
CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
```

Sample Output:

![[Pasted image 20240807120444.png]]
# Tableau Visualizations Overview
---
**[Access Tableau Dashboard Here](https://public.tableau.com/app/profile/usama.labanieh/viz/CovidProjectViz_17136144374880/Dashboard1)**

This is a simple and informative Tableau Daashboard that showcases some interesting statistics about Covid-19 around the world. The Dashboard contains 4 visualization, which are as follows:

- Global Numbers Table: Total number of cases, deaths and death percentage based on numbers from the whole world

![[Pasted image 20240807124913.png]]

- Bar Chart of Deaths by Continent: Total number of deaths caused by Covid-19 by continent

![[Pasted image 20240807124933.png]]

- World Map of Infected Population by Country: using a color gradient, this map shows the percent of the population that has been infected with Covid-19. The darker the color, the higher the percentage

![[Pasted image 20240807124950.png]]

- Line Chart of Percent of Population Infected: using 5 sample countries: China, India, Mexico, United Kingdom and United States; we look at the progression of the percentage of people infected with Covid-19 from the total population. This chart also includes a forecast, which is a prediction of the future percentages in these countries based on the previous numbers.

![[Pasted image 20240807125006.png]]

To view the full dashboard and explore it more in detail, click on this [link](https://public.tableau.com/app/profile/usama.labanieh/viz/CovidProjectViz_17136144374880/Dashboard1)