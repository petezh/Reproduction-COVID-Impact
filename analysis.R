
library(ggplot2)

setwd('C:\\Users\\thepe\\Documents\\GitHub\\acre-cutler')
# load GDP projections
GDP_projections <- read.csv("data/analysis/projections.csv")

# load COVID impairment data
crit_severe <- read.csv("data/analysis/impairment.csv")

# load COVID deaths data
covid_deaths <- read.csv("data/analysis/covid_deaths.csv")
covid_deaths$End.Date = as.Date(covid_deaths$End.Date, "%m/%d/%Y")

# set VSL
VSL <- 7000000

# set value of year of life
VYL <- 100000

# 1.Lost GDP

# plot GDP forecasts
ggplot(data = GDP_projections, aes(x = Year)) + 
  geom_line(aes(y = Pre.Covid), color = "darkred") + 
  geom_line(aes(y = Post.Covid), color="steelblue", linetype="twodash") 

# calculate GDP losses, convert to billions
GDP_losses = sum(GDP_projections$Pre.Covid-GDP_projections$Post.Covid)*1000000000

# 2. Cost of premature mortality

# plot COVID death counts
ggplot(data = covid_deaths, aes(x = End.Date, y = COVID.19.Deaths)) + 
  geom_line()



# 190k deaths as of 10-25-2020, 52 weeks at 5000 deaths
current_deaths = sum(subset(covid_deaths, End.Date <= as.Date("2020-09-25"), select=c('COVID.19.Deaths')))
future_deaths =  52*5000
total_deaths = current_deaths+future_deaths

# add 40% excess deaths, 630000 not 625000
total_deaths <- 1.4*total_deaths

# convert to VTL with 7 million estimate
value_deaths <- VSL*total_deaths


# 3. Cost of Health Impairments

current_crit_severe = sum(crit_severe$Severe.Critical)
# disagreement: using COVID current/forecast deaths, not excess. also, 250k is a rounddown
total_crit_severe = current_crit_severe*(current_deaths + future_deaths)/current_deaths
impairments = 1/3*total_crit_severe
value_impairments = 0.35 * VSL * impairments

# 4. Mental Health Impairment

anx_dep_increase = .409-.11

# disagreement: adult population is 251M, not 266M, https://www.kff.org/other/state-indicator/distribution-by-age/
adult_pop = 250744800
new_anx_dep = anx_dep_increase * adult_pop
value_mentalhealth = new_anx_dep * 0.2 * VYL

# summation
total_value = GDP_losses + value_deaths + value_impairments + value_mentalhealth
total_value
