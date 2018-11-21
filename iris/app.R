# ui.R
library(shiny)
library(shinydashboard)
library(DT)
library(shinythemes)


ui <- fluidPage(
  titlePanel("Iris k-means clustering"),
  theme = shinythemes::shinytheme("sandstone"),
  sidebarLayout(
             sidebarPanel(
               a(img(src="http://stat545.com/Classroom/stat-545.png",height=200,width=200),
                 href="http://stat545.com/Classroom/",target="black"),
               
               conditionalPanel(
                 'input.dataset === "cluster"',
                 selectInput("xcol","X Variable",names(iris)),
                 selectInput("ycol","Y Variable",names(iris),selected="Sepal.Width"),
                 numericInput("clusters","Cluster count",3,min=2,max=9)),
               
               conditionalPanel(
                 'input.dataset === "iris data"',
                   checkboxInput("select", "select/deselect all"),
                   h4("selected_rows:"),
                   verbatimTextOutput("selected_rows", TRUE),
                 
                   checkboxGroupInput('show_vars', 'Columns in iris to show:',
                                    names(iris), selected = names(iris)),
                 
                   downloadButton('downloadData', 'Download'),width = 3)
                   
               ),
             
             mainPanel(
               tabsetPanel(
                 id = 'dataset',
                 tabPanel("cluster", plotOutput("plot")),
                 tabPanel("iris data", DT::dataTableOutput("dt")))
             )
             
    
  ))

# server.R
server <- function(input,output){
  # apply k means clustering
  cluster <- reactive({
    kmeans(iris[,1:4],input$clusters)
  })
  
  # plot the clusering result
  output$plot <- renderPlot({
    plot(iris[,c(input$xcol,input$ycol)],
         col=cluster()$cluster)
    points(cluster()$centers[,c(input$xcol,input$ycol)],
           col=1:input$clusters,pch="*",cex=4)
  })
  
  ## draw an interactive table
  output$dt <- DT::renderDataTable({
    
    ## the selected column will be changed color
    datatable(iris[, input$show_vars], 
              options = list(lengthMenu = c(5, 30, 60), 
                             pageLength = 5, 
                             orderClasses = TRUE))
    
  })
  
  ## response to the checkboxInput
  dt_proxy <- DT::dataTableProxy("dt")
  observeEvent(input$select, {
    if (isTRUE(input$select)) {
      DT::selectRows(dt_proxy, input$dt_rows_all)
    } else {
      DT::selectRows(dt_proxy, NULL)
    }
  })
  output$selected_rows <- renderPrint(print(input$dt_rows_selected))
  
  
  ## download data
  output$downloadData <- downloadHandler(
    filename = function() { paste('iris_table','.csv', sep='') },
    content = function(file){
      fname <- paste(file,"csv",sep=".")
      wb <- loadWorkbook(fname, create = TRUE)
      createSheet(wb, name = "Sheet1")
      writeWorksheet(wb, tabel(), sheet = "Sheet1") 
      saveWorkbook(wb)
      file.rename(fname,file)
    }
  )
  
 
  
}

# Run the application 
shinyApp(ui = ui, server = server)

