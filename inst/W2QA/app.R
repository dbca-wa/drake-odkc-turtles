#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)


# Define UI for application that draws a histogram
ui <- navbarPage("WAMTRAM QA",

                 tabPanel("Places",
                          mainPanel(plotOutput("plot"))),

                 tabPanel("Plot",
                          sidebarLayout(
                            sidebarPanel(radioButtons(
                              "plotType", "Plot type",
                              c("Scatter" = "p", "Line" = "l")
                            )),
                            mainPanel(plotOutput("plot"))
                          )))

# Define server logic required to draw a histogram


server <- function(input, output, session) {



  output$plot <- renderPlot({
    plot(cars, type = input$plotType)
  })

  output$summary <- renderPrint({
    summary(cars)
  })

  output$table <- DT::renderDataTable({
    DT::datatable(cars)
  })
}



# Run the application
shinyApp(ui = ui, server = server)
