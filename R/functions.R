library(RSQLite)
library(dplyr)
library(tidyverse)
library(DBI)

scoreboard <- read.csv("./data/scoreboard.csv",stringsAsFactors = F)

con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
copy_to(con, scoreboard)
scoreboard_db <- tbl(con, "scoreboard")


get_win_lose_data  <- function(team){
  win <- data.frame()
  lose <- data.frame()
  for(i in 2010:2020){
    win <- rbind(win,scoreboard_db %>% 
                   filter(팀==team) %>%
                   filter(year == i) %>%
                   summarize(year=year,sum=sum(승패=="승")) %>%
                   collect())
    lose <- rbind(lose,scoreboard_db %>% 
                    filter(팀==team) %>%
                    filter(year == i) %>%
                    summarize(year=year,sum=sum(승패=="패")) %>%
                    collect())
  }
  return(list(win=win,lose=lose))
}

get_run_error_data <- function(team){
  run <- data.frame()
  error <- data.frame()
  for(i in 2010:2020){
    run <- rbind(run,scoreboard_db %>% 
                   filter(팀==team) %>%
                   filter(year == i) %>%
                   summarize(year=year,r_sum=sum(R)) %>%
                   collect())
    error <- rbind(error,scoreboard_db %>% 
                   filter(팀==team) %>%
                   filter(year == i) %>%
                   summarize(year=year,e_sum=sum(E)) %>%
                   collect())
  }
  return(list(run=run,error=error))
}
