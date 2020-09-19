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
source("./R/functions.R")

# Define UI for application that draws a histogram

ui <- navbarPage("KBO 그래프",theme = shinytheme("cerulean"),
                 tabPanel("팀 그래프",
                          sidebarLayout(sidebarPanel(navlistPanel(
                              widths = c(12,12),"원하는 팀을 선택하세요",
                              tabPanel(selectInput("team","Select Team",unique(scoreboard$팀))),
                              tags$a(h3("자료출처:KBO"),href = "https://www.koreabaseball.com/")
                              
                          )),
                          mainPanel(navbarPage(title="그래프 종류",
                                               tabPanel("팀 승패 그래프",plotOutput("w_l_plot")),
                                               tabPanel("팀 득점 그래프",plotOutput("r_plot")),
                                               tabPanel("팀 실책 그래프",plotOutput("e_plot"))))
                          )),
                 tabPanel("선수 그래프")
)



# Define server logic required to draw a histogram
server <- function(input, output, session) {
    observe({
        win_lose_data <- get_win_lose_data(input$team)
        run_error_data <- get_run_error_data(input$team)
        
        output$w_l_plot <- renderPlot({
            ggplot(win_lose_data$win,aes(x=year,y=sum))+ geom_line(aes(colour = 'blue'))+
                geom_line(data = win_lose_data$lose,aes(x=year,y=sum,colour = 'red'))+
                scale_x_continuous("year",limits = c(2010,2021),breaks = seq(2010,2020,2))+
                scale_color_discrete(name = "Win_or_Lose", labels = c("Win", "Lose"))
            
        })
        output$r_plot <- renderPlot({
            ggplot(run_error_data$run,aes(x=year,y=r_sum))+ geom_line(aes(colour = 'Run'))+
                scale_x_continuous("year",limits = c(2010,2021),breaks = seq(2010,2020,2))
        })
        output$e_plot <- renderPlot({
            ggplot(run_error_data$error,aes(x=year,y=e_sum))+ geom_line(aes(colour = 'Error'))+
                scale_x_continuous("year",limits = c(2010,2021),breaks = seq(2010,2020,2))
        })
    })
    
}


# Run the application 
shinyApp(ui = ui, server = server)
