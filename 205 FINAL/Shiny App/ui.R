# Define UI for application that draws a histogram
shinyUI(fluidPage(
  tags$head(
    tags$style(HTML("
                    @import url('//fonts.googleapis.com/css?family=Roboto+Slab');
                    @import url('//fonts.googleapis.com/css?family=Lato:300');
                    
                    body {
                    background-color: #FFFFFF;
                    font-family: 'Lato', sans-serif;
                    font-weight: 300;
                    line-height: 1.1;
                    font-size: 14pt;
                    color: #899DA4
                    }
                    
                    h1 {
                    font-family: 'Roboto Slab';
                    font-weight: 500;
                    line-height: 1.1;
                    color: #F26B21;
                    }
                    
                    h2 {
                    font-family: 'Lato', sans-serif;
                    font-weight: 300;
                    line-height: 1.1;
                    font-size: 12pt;
                    color: #899DA4;
                    }
                    shiny-plot-output {
                    background-color: #00EFD1;
                    }
                    
                    .test {
                    font-family: 'Roboto Slab', serif;
                    font-weight: 100;
                    line-height: 1.1;
                    font-size: 18pt;
                    margin-left: 500px;
                    text-align: left;
                    color: #899DA4;
                    }
                    
                    .well {
                    background-color: #FFFFFF;
                    }
                    
                    .irs-bar {
                    background-color: #F26B21;
                    }
                    
                    .irs-from {
                    background-color: #F26B21;
                    }
                    
                    .irs-to {
                    background-color: #F26B21;
                    }
                    
                    a {
                    color: #F26B21;
                    }
                    "))
    ),
  title="Strava Segements",
  # Application title
  titlePanel(h1("Strava Segements")), titlePanel(h2("Author: Carson Forter")),
  
  # Sidebar with a slider input for the number of bins
  sidebarLayout(
    sidebarPanel(
      sliderInput("seg_length",
                  h2("Segment Length in Miles"),
                  min = 0,
                  max = 10,
                  value = c(0,10),
                  step = .25),
      selectInput("climb",
                  h2("Select Climb Category"),
                  choices = c("All","0", "1", "2", "3", "4", "5")
      )),
    
    # Show a plot of the generated distribution
    mainPanel(
      tabsetPanel(
        tabPanel("Project Description", div(p(br(),
                                              "This project shows all of the Strava running segments in California and ranks them by their 
                                              competitiveness, defined as the nuber of athletes to attempt the segment. By default it shows
                                              the top 20 segments overall, but by tweaking the input parameters on the left you can 
                                              break the segments down by distance and elevation.",br(),br(), 
                                              "The architecture  of this project relies on R for accessing the Strava API and
                                              cleaning the data, PostgreSQL running on AWS EC2 for
                                              data storage and retrieval, and Shiny for serving the data and the UI")), 
                 width="300px"),
        tabPanel("Map - All", plotOutput("mapAll", height="800px", width="600px")),
        tabPanel("Map - Top 20", plotOutput("mapTop", height="800px", width="600px")),
        tabPanel("Table - Top 20", tableOutput('table')),
        tabPanel("Histogram of Scores - All", imageOutput("distPlot", height="550px", width="1000px"))
        ))
        )))
