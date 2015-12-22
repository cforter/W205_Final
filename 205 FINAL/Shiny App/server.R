shinyServer(function(input, output, session) {
  library(ggplot2)
  library(scales)
  library(maps)
  library(RPostgreSQL)
  con <- dbConnect(PostgreSQL(), user= "postgres", password="ENTER PASSWORD", dbname='strava')
  
  output$distPlot <- renderPlot({
    width  <- session$clientData$output_distPlot_width
    height <- session$clientData$output_distPlot_height
    
    if(input$climb == 'All') {
      query <- paste0("select * from efforts ",
                      "where \"segments.distance\"::numeric > ", toString(input$seg_length[1] / 0.000621371),
                      "and \"segments.distance\"::numeric <=", toString(input$seg_length[2]/ 0.000621371),
                      "order by effort_count::numeric desc")
      seg_subset <- dbGetQuery(con, query)
    }
    else {
      query <- paste0("select * from efforts ",
                      "where \"segments.distance\"::numeric > ", toString(input$seg_length[1] / 0.000621371),
                      "and \"segments.distance\"::numeric <=", toString(input$seg_length[2]/ 0.000621371),
                      "and \"segments.climb_category\" = ",input$climb)
      seg_subset <- dbGetQuery(con, query)
    }
    
    ggplot(seg_subset, aes(x=effort_count)) + geom_histogram(fill="#009291", colour="#ABBFC6", outlier.colour="#009291") +
      ggtitle("Number of Attempts") +
      scale_x_continuous(limits = c(0, 6000)) +
      theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
            panel.background = element_blank(), axis.line = element_blank(),
            axis.text.x=element_text(),
            axis.text.y=element_text(),
            axis.ticks=element_blank(),
            axis.title.x=element_blank(),
            axis.title.y=element_blank(),
            title=element_text(size=16, colour="#009291")
      )
    
  })
  
  output$n_observations <- renderText({
    if(input$climb == 'All') {
      paste("n =",
            toString(nrow(
              dbGetQuery(con, paste0('select * from efforts
                                     where segments.distance > ', input$seg_length[1],
                                     ' and segments.distance <', input$seg_length[2])))))
    }
    else{
      paste("n =",
            toString(nrow(
              dbGetQuery(con, paste0('select * from efforts
                                     where segments.distance > ', input$seg_length[1],
                                     ' and segments.distance <', input$seg_length[2],
                                     ' and segments.climb_category = ',input$climb)))))
    }
  })
  
  output$mapAll <- renderPlot({
    if(input$climb == 'All') {
      query <- paste0("select * from efforts ",
                      "where \"segments.distance\"::numeric > ", toString(input$seg_length[1] / 0.000621371),
                      "and \"segments.distance\"::numeric <=", toString(input$seg_length[2]/ 0.000621371),
                      "order by effort_count::numeric desc")
      seg_subset <- dbGetQuery(con, query)
    }
    else {
      query <- paste0("select * from efforts ",
                      "where \"segments.distance\"::numeric > ", toString(input$seg_length[1] / 0.000621371),
                      "and \"segments.distance\"::numeric <=", toString(input$seg_length[2]/ 0.000621371),
                      "and \"segments.climb_category\" = ",input$climb)
      seg_subset <- dbGetQuery(con, query)
    }
    
    m <- borders("state", fill = "lightgray", plot = FALSE, region='california')
    ggplot() + m +
      geom_point(data = seg_subset, aes(x = lon, y = lat), shape=21,
                 fill="#009291", col="#ABBFC6", size=1) +
      ggtitle("") +
      theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
            panel.background = element_blank(), axis.line = element_blank(),
            axis.text.x=element_blank(),
            axis.text.y=element_blank(),
            axis.ticks=element_blank(),
            axis.title.x=element_blank(),
            axis.title.y=element_blank(),
            title=element_text(size=12, colour="#899DA4"),
            panel.background = element_rect(colour = "#FFFFFF", fill ="#FFFFFF"),
            plot.background = element_rect(colour = "#FFFFFF", fill ="#FFFFFF"),
            legend.background = element_rect(colour = "#FFFFFF", fill ="#FFFFFF")
            #plot.margin = unit(c(2.3333,.6,2.3333,.6), "cm")
      )
  },res=140)
  
  output$mapTop <- renderPlot({
    if(input$climb == 'All') {
      query <- paste0("select * from efforts ",
                      "where \"segments.distance\"::numeric > ", toString(input$seg_length[1] / 0.000621371),
                      "and \"segments.distance\"::numeric <=", toString(input$seg_length[2]/ 0.000621371),
                      "order by effort_count::numeric desc")
      seg_subset <- dbGetQuery(con, query)
    }
    else {
      query <- paste0("select * from efforts ",
                      "where \"segments.distance\"::numeric > ", toString(input$seg_length[1] / 0.000621371),
                      "and \"segments.distance\"::numeric <=", toString(input$seg_length[2]/ 0.000621371),
                      "and \"segments.climb_category\" = ",input$climb)
      seg_subset <- dbGetQuery(con, query)
    }
    
    seg_subset_rm <- aggregate(seg_subset$effort_count ~ seg_subset$segments.name +
                                 seg_subset$segments.climb_category + seg_subset$segments.distance +
                                 seg_subset$lat + seg_subset$lon, FUN=max)
    
    final_table <- seg_subset_rm[order(seg_subset_rm$`seg_subset$effort_count`, decreasing=T)[1:20],]
    
    m <- borders("state", fill = "lightgray", plot = FALSE, region='california')
    ggplot() + m +
      geom_point(data = final_table, aes(x = `seg_subset$lon`, y = `seg_subset$lat`), shape=21,
                 fill="#F26B21", col="#ABBFC6", size=3) +
      ggtitle("") +
      theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
            panel.background = element_blank(), axis.line = element_blank(),
            axis.text.x=element_blank(),
            axis.text.y=element_blank(),
            axis.ticks=element_blank(),
            axis.title.x=element_blank(),
            axis.title.y=element_blank(),
            title=element_text(size=12, colour="#899DA4"),
            panel.background = element_rect(colour = "#FFFFFF", fill ="#FFFFFF"),
            plot.background = element_rect(colour = "#FFFFFF", fill ="#FFFFFF"),
            legend.background = element_rect(colour = "#FFFFFF", fill ="#FFFFFF")
      )
  },res=140)
  
  output$table <- renderTable({
    if(input$climb == 'All') {
      query <- paste0("select * from efforts ",
                      "where \"segments.distance\"::numeric > ", toString(input$seg_length[1] / 0.000621371),
                      "and \"segments.distance\"::numeric <=", toString(input$seg_length[2]/ 0.000621371),
                      "order by effort_count::numeric desc")
      seg_subset <- dbGetQuery(con, query)
    }
    else {
      query <- paste0("select * from efforts ",
                      "where \"segments.distance\"::numeric > ", toString(input$seg_length[1] / 0.000621371),
                      "and \"segments.distance\"::numeric <=", toString(input$seg_length[2]/ 0.000621371),
                      "and \"segments.climb_category\" = ",input$climb)
      seg_subset <- dbGetQuery(con, query)
    }
    seg_subset_rm <- aggregate(seg_subset$effort_count ~ seg_subset$segments.name +
                                 seg_subset$segments.climb_category + seg_subset$segments.distance, FUN=max)
    final_table <- seg_subset_rm[order(seg_subset_rm$`seg_subset$effort_count`, decreasing=T)[1:20],]
    final_table
  })
  session$onSessionEnded(function() {dbDisconnect(con)})
  
  })

