SELECT * INTO CovidProject.dbo.CovidDeaths FROM CovidDeaths
SELECT * INTO CovidProject.dbo.CovidVaccinations FROM CovidVaccinations

-- remove extra unnecessary 0s and decimal places from affected columns not correctly identified in import

UPDATE CovidDeaths
SET population = CAST(population AS float)

UPDATE CovidDeaths
SET total_cases = CAST(total_cases AS float)

UPDATE CovidDeaths
SET new_cases = CAST(new_cases AS float)

UPDATE CovidDeaths
SET new_cases_smoothed = CAST(new_cases_smoothed AS float)

UPDATE CovidDeaths
SET total_deaths = CAST(total_deaths AS float)

UPDATE CovidDeaths
SET new_deaths = CAST (new_deaths AS float)

UPDATE CovidDeaths
SET new_deaths_smoothed = CAST (new_deaths_smoothed AS float)

UPDATE CovidDeaths
SET total_cases_per_million = CAST(total_cases_per_million AS float)

UPDATE CovidDeaths
SET new_cases_per_million = CAST(new_cases_per_million AS float)



SELECT * FROM CovidDeaths

SELECT * FROM CovidVaccinations

