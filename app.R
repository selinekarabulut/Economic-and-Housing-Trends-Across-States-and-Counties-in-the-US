library(shiny)
library(plotly)
library(dplyr)
library(tibble)
library(tidyr)  # For reshaping the data
library(DT)
library(shinythemes)  # For custom themes
library(ggplot2)
library(scales)

# Load data
data <- read.csv("merged_dataset.csv")

# Reshape the data to create a unified Year column
data_long <- data %>%
  pivot_longer(
    cols = starts_with("home_value_") | starts_with("percentage_of_") | starts_with("total_population_") | starts_with("median_income_"),
    names_to = c("Variable", "Year"),
    names_pattern = "(.+)_(\\d{4})",
    values_to = "Value"
  ) %>%
  pivot_wider(names_from = Variable, values_from = Value)

# Define UI
ui <- fluidPage(
  theme = shinytheme("spacelab"),  # Apply a custom theme
  titlePanel("Economic and Housing Trends Across States and Counties in the US"),
  sidebarLayout(
    sidebarPanel(
      selectInput("state", "Select State:", choices = unique(data$State)),
      selectInput("county", "Select County:", choices = NULL),
      hr(),
      h4("Filters"),
      sliderInput("yearRange", "Select Year Range:", min = 2012, max = 2022, value = c(2012, 2022)),
      downloadButton("downloadData", "Download Data")
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Trends",
                 h4("Summary Statistics"),
                 verbatimTextOutput("summaryStats"),  # Display summary statistics
                 plotlyOutput("linePlot"),
                 plotlyOutput("povertyPlot")
        ),
        tabPanel("Data Table",
                 DTOutput("dataTable")
        ),
        tabPanel("Regression Analysis",
                 h4("Explore Relationships"),
                 selectInput("xVariable", "Select X Variable:", choices = names(data_long)[!names(data_long) %in% c("Year", "RegionName", "State")]),
                 selectInput("yVariable", "Select Y Variable:", choices = names(data_long)[!names(data_long) %in% c("Year", "RegionName", "State")]),
                 radioButtons("regType", "Select Regression Type:", choices = c("Linear" = "lm", "LOESS" = "loess")),
                 plotlyOutput("regressionPlot")
        ),
        tabPanel("About",
                 p("* This dashboard presents trends in socioeconomic indicators, demographic data, and housing values across various states and counties."),
                 p(HTML("* The socioeconomic and demographic data are sourced from the American Community Survey (ACS) by the US Census Bureau, and the housing value data are from Zillow's <a href='https://www.zillow.com/research/data/' target='_blank'>Zillow Home Value Index (ZHVI)</a>.")),
                 p(HTML("<a href='https://www.census.gov/data/developers/data-sets/acs-5year.html' target='_blank'>American Community Survey 5 year estimates (ACS)</a>")),
                 p("* Use the filters to narrow down the data range and download options to save the data. "),
                 p("* % of Persons Below Poverty is calculated as under_poverty (B17001_002E: the estimated number of individuals whose income in the past 12 months is below the poverty level)/poverty_status (B17001_001E:the total population for whom poverty status is determined)"),
                 p("* The 'Regression Analysis' tab offers insights into the relationships between various socioeconomic indicators through linear regression and LOESS (Local Polynomial Regression). Users can select variables to analyze trends and forecast potential changes. Linear regression provides a way to predict a dependent variable based on the value of an independent variable, assuming a linear relationship. LOESS, on the other hand, is used for more complex, non-linear data that cannot be fitted well by a linear model."),
                 p("* These tools help identify and visualize trends, correlations, and potential causations, enabling more informed decisions and analyses.")
        )
      )
    )
  )
)

# Define server logic
server <- function(input, output, session) {
  
  # Update county dropdown based on selected state
  observe({
    state_data <- data[data$State == input$state,]
    updateSelectInput(session, "county", choices = unique(state_data$RegionName))
  })
  
  # Render income and home value plot
  output$linePlot <- renderPlotly({
    req(input$county)
    
    # Subset data based on selections
    filtered_data <- data_long %>%
      filter(State == input$state, RegionName == input$county, Year >= input$yearRange[1], Year <= input$yearRange[2])
    
    # Create line chart for income and home value
    plot_ly(data = filtered_data) %>%
      add_trace(x = ~Year, y = ~home_value, type = 'scatter', mode = 'lines+markers', name = 'Home Value ($)', marker = list(color = 'green')) %>%
      add_trace(x = ~Year, y = ~median_income, type = 'scatter', mode = 'lines+markers', name = 'Median Income ($)') %>%
      layout(title = paste("Median Income and Housing Value Trends for", input$county), xaxis = list(title = "Year"), yaxis = list(title = "Value"))
  })
  
  
  # Render poverty plot
  output$povertyPlot <- renderPlotly({
    req(input$county)
    
    # Subset data based on selections
    filtered_data <- data_long %>%
      filter(State == input$state, RegionName == input$county, Year >= input$yearRange[1], Year <= input$yearRange[2])
    
    # Create line chart for poverty percentage, demographic trends, and total population
    plot_ly(data = filtered_data) %>%
      add_trace(x = ~Year, y = ~percentage_of_persons_below_poverty, type = 'scatter', mode = 'lines+markers', name = '% of Persons Below Poverty', marker = list(color = 'red'), line = list(color = 'red')) %>%
      add_trace(x = ~Year, y = ~percentage_of_white, type = 'scatter', mode = 'lines+markers', name = '% White', marker = list(color = 'blue'), line = list(color = 'blue')) %>%
      add_trace(x = ~Year, y = ~percentage_of_black, type = 'scatter', mode = 'lines+markers', name = '% Black', marker = list(color = 'green'), line = list(color = 'green')) %>%
      add_trace(x = ~Year, y = ~percentage_of_american_indian_population, type = 'scatter', mode = 'lines+markers', name = '% of Native American', marker = list(color = 'purple'), line = list(color = 'purple')) %>%
      add_trace(x = ~Year, y = ~percentage_of_hispanics_and_latinos, type = 'scatter', mode = 'lines+markers', name = '% of Latino', marker = list(color = 'yellow'), line = list(color = 'yellow')) %>%
      add_trace(x = ~Year, y = ~percentage_of_asian_population, type = 'scatter', mode = 'lines+markers', name = '% of Asian', marker = list(color = 'cyan'), line = list(color = 'cyan')) %>%
      add_trace(x = ~Year, y = ~percentage_of_native_hawaiian_other_pacific_islander_population, type = 'scatter', mode = 'lines+markers', name = '% of Hawaiian and other Pacific Islander', marker = list(color = 'magenta'), line = list(color = 'magenta')) %>%
      add_trace(x = ~Year, y = ~percentage_of_college_educated, type = 'scatter', mode = 'lines+markers', name = '% of College Educated', marker = list(color = 'orange'), line = list(color = 'orange')) %>%
      add_trace(x = ~Year, y = ~total_population, yaxis = 'y2', type = 'scatter', mode = 'lines+markers', name = 'Total Population', marker = list(color = 'black'), line = list(color = 'black')) %>%
      layout(
        title = paste("Demographic and Socioeconomic Trends for", input$county),
        xaxis = list(title = "Year"),
        yaxis = list(title = "Percentage"),
        yaxis2 = list(title = "Total Population", overlaying = "y", side = "right", showgrid = FALSE),
        width = 1350,  # Increase the width of the plot
        legend = list(x = 1.1, y = 1)  # Move the legend to the right-hand side
      )
    
  })
  
  
  # Render data table
  output$dataTable <- renderDT({
    req(input$county)
    filtered_data <- data_long %>%
      filter(State == input$state, RegionName == input$county, Year >= input$yearRange[1], Year <= input$yearRange[2])
    datatable(filtered_data)
  })
  
  # Display summary statistics
  output$summaryStats <- renderPrint({
    req(input$county)
    library(tibble)
    
    filtered_data <- data_long %>%
      filter(State == input$state, RegionName == input$county, Year >= input$yearRange[1], Year <= input$yearRange[2])
    
    percentage_change <- function(x) {
      if(length(x) > 1) {
        (last(x) - first(x)) / first(x) * 100
      } else {
        NA
      }
    }
    
    absolute_change <- function(x) {
      if(length(x) > 1) {
        last(x) - first(x)
      } else {
        NA
      }
    }
    
    summary_stats <- filtered_data %>%
      reframe(
        `Home Value ($)` = list(percentage_change(home_value), absolute_change(home_value)),
        `Median Income ($)` = list(percentage_change(median_income), absolute_change(median_income)),
        `College Educated Population (%)` = list(percentage_change(percentage_of_college_educated), absolute_change(percentage_of_college_educated)),
        `Total Population` = list(percentage_change(total_population), absolute_change(total_population)),
        `Poverty Rate` = list(percentage_change(percentage_of_persons_below_poverty), absolute_change(percentage_of_persons_below_poverty)),
        `White Population (%)` = list(percentage_change(percentage_of_white), absolute_change(percentage_of_white)),
        `Black Population (%)` = list(percentage_change(percentage_of_black), absolute_change(percentage_of_black)),
        `Native American Population (%)` = list(percentage_change(percentage_of_american_indian_population), absolute_change(percentage_of_american_indian_population)),
        `Asian Population (%)` = list(percentage_change(percentage_of_asian_population), absolute_change(percentage_of_asian_population)),
        `Latino Population (%)` = list(percentage_change(percentage_of_hispanics_and_latinos), absolute_change(percentage_of_hispanics_and_latinos)),
        `Native Hawaiian&Pacific Islander Population (%)` = list(percentage_change(percentage_of_native_hawaiian_other_pacific_islander_population), absolute_change(percentage_of_native_hawaiian_other_pacific_islander_population))
      ) %>%
      t() %>%
      as.data.frame() %>%
      rownames_to_column(var = "Variable") %>%
      rename(`% Change` = V1, `Absolute Change` = V2) %>%
      mutate(
        `% Change` = paste0(round(as.numeric(`% Change`), 2), "%"),
        `Absolute Change` = round(as.numeric(`Absolute Change`), 2)
      )
    
    print(summary_stats %>% select(Variable, `% Change`, `Absolute Change`), row.names = FALSE)
    
  })
  
  # Existing observe for updating counties based on state selection
  observe({
    state_data <- data[data$State == input$state,]
    updateSelectInput(session, "county", choices = unique(state_data$RegionName))
  })
  
  # Set choices for xVariable and yVariable inputs based on the variables in the summary statistics
  observe({
    summary_vars <- c("home_value", "median_income", "percentage_of_college_educated", "total_population",
                      "percentage_of_persons_below_poverty", "percentage_of_white", "percentage_of_black",
                      "percentage_of_american_indian_population", "percentage_of_asian_population",
                      "percentage_of_hispanics_and_latinos", "percentage_of_native_hawaiian_other_pacific_islander_population")
    
    updateSelectInput(session, "xVariable", choices = summary_vars)
    updateSelectInput(session, "yVariable", choices = summary_vars)
  })
  
  # Dynamic data and plots refresh
  observeEvent(list(input$state, input$county, input$yearRange), {
    # Ensure input$county is available
    req(input$county)
    
    # Data filtered by state, county, and year range
    filtered_data <- data_long %>%
      filter(State == input$state, RegionName == input$county, Year >= input$yearRange[1], Year <= input$yearRange[2])
    
    # Update regression plot
    output$regressionPlot <- renderPlotly({
      req(input$xVariable, input$yVariable, input$regType)
      plot_ly(data = filtered_data, x = ~get(input$xVariable), y = ~get(input$yVariable), type = "scatter", mode = "markers") %>%
        add_lines(x = ~get(input$xVariable), y = fitted(eval(parse(text = input$regType))(get(input$yVariable) ~ get(input$xVariable), data = filtered_data)), name = "Regression Fit", line = list(color = "red", width = 2)) %>%
        layout(title = paste("Regression Analysis between", input$xVariable, "and", input$yVariable, "in", input$county, "in", input$state, "between",input$yearRange[1], "and", input$yearRange[2]),
               xaxis = list(title = input$xVariable),
               yaxis = list(title = input$yVariable),
               legend = list(orientation = "h", x = 0, y = -0.1))
    })
  })
  
  # Allow data download
  output$downloadData <- downloadHandler(
    filename = function() {
      paste("data_", Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      req(input$county)
      filtered_data <- data_long %>%
        filter(State == input$state, RegionName == input$county, Year >= input$yearRange[1], Year <= input$yearRange[2])
      write.csv(filtered_data, file, row.names = FALSE)
    }
  )
}

# Run the application
shinyApp(ui = ui, server = server)

