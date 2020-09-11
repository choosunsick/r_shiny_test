#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(RSQLite)
library(dplyr)
library(tidyverse)
library(ggplot2)
library(shinythemes)
library(shinydashboard)

scoreboard <- read.csv("./data/scoreboard.csv",stringsAsFactors = F)
# Define UI for application that draws a histogram

ui <- navbarPage(theme = shinytheme("cerulean"),
                introjsUI(),
                tabPanel("Team Plot", "Plot tab contents..."),
                tabPanel("Player", "Player tab contents..."),
                titlePanel("팀 승패 그래프"),
                sidebarPanel(width = 4,
                                           h3("자료출처:"),
                                           a(h4("KBO"),href = "https://www.koreabaseball.com/"),
                                           h4("팀 선택 창에서 원하는 팀을 선택하세요.")
                ),
                fluidRow(column(6,align = 'left',
                                introBox(selectInput("team","Select Team",unique(scoreboard$팀)),
                                         data.step = 1,
                                         data.intro = "team_win_or_lose",
                                         plotOutput("plot"))
        ),
    )
)
                      

#ui <- fluidPage(theme = shinytheme("cerulean"),
#                sidebarLayout(
#                    sidebarPanel(width = 4,
#                                 h2("팀 승패 그래프"),
#                                 h3("자료출처:"),
#                                 a(h4("KBO"),href = "https://www.koreabaseball.com/"),
#                                 h4("아래의 팀 선택 창에서 원하는 팀을 선택해 주세요.")
#                                 ),
#                    
#                mainPanel(width = 10,
#                          selectInput("team","Select Team",unique(scoreboard$팀)),
#                          plotOutput("plot"),
#    )
    
#))



# Define server logic required to draw a histogram
server <- function(input, output, session) {
    con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
    copy_to(con, scoreboard)
    scoreboard_db <- tbl(con, "scoreboard")
    dta <- reactive({
        scoreboard_db 
    })

    observe({
        temp <- input$team
        win <- data.frame()
        lose <- data.frame()
        for(i in 2010:2020){
            win <- rbind(win,dta() %>% 
                filter(팀==temp) %>%
                filter(year == i) %>%
                summarize(year=year,sum=sum(승패=="승")) %>%
                collect())
            lose <- rbind(lose,dta() %>% 
                              filter(팀==temp) %>%
                              filter(year == i) %>%
                              summarize(year=year,sum=sum(승패=="패")) %>%
                              collect())
        }
        output$plot <- renderPlot({
            ggplot(win,aes(x=year,y=sum))+ geom_line(aes(colour = 'blue'))+
                geom_line(data = lose,aes(x=year,y=sum,colour = 'red'))+
                scale_x_continuous("year",limits = c(2010,2021),breaks = seq(2010,2020,2))+
                scale_color_discrete(name = "Win_or_Lose", labels = c("Win", "Lose"))
                
        })
    })
    
}


# Run the application 
shinyApp(ui = ui, server = server)
