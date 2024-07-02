# Shiny app to Explore Economic and Housing Trends Across States and Counties in the US (2012-2022)

I created a dashboard using the Shiny package in R software to present trends in socioeconomic indicators, demographic data, and housing values across various states and counties. This tool helps identify and visualize trends, correlations, and potential causations, enabling more informed decisions and analyses.

If interested, here is the link to the Shiny app.
[<img width="35px" src="assets/shiny-og-fb.jpg">](https://selinkarabulut.shinyapps.io/ushousinganddemographics/)

Overview
This Shiny application is designed to visualize and analyze socioeconomic and housing trends across various states and counties in the United States. The application leverages data from the American Community Survey (ACS) and the Zillow Home Value Index (ZHVI) to present a comprehensive view of changes in median home values, median incomes, demographic percentages, poverty rates, and educational attainment over time.

Key Features
User Interface (UI):

Theme: The app uses the 'spacelab' theme from shinythemes for a modern and clean look.
Title Panel: Displays the title of the app.
Sidebar Panel:
Dropdown menus to select a state and a county.
Slider to filter the data by a year range.
Button to download the filtered data.
Main Panel:

Tabs:
Trends Tab: Displays summary statistics and line plots for income and home value trends, and for poverty and demographic trends.
Data Table Tab: Shows the filtered data in a table format.
Regression Analysis Tab: Allows users to explore relationships between different variables using linear regression or LOESS.
About Tab: Provides information about the data sources, calculations, and the purpose of the dashboard.
Server Logic:

Data Loading and Reshaping: Loads the dataset and reshapes it to have a unified Year column.
Dynamic UI Updates: Updates the county dropdown based on the selected state.
Plot Rendering: Creates interactive plots using plotly to display trends in home values, incomes, poverty rates, and demographic changes.
Summary Statistics: Calculates and displays percentage and absolute changes in key indicators.
Regression Analysis: Allows for dynamic regression plots based on user-selected variables and regression type.
Data Download: Provides functionality to download the filtered data.
What Can Be Seen
Trends Over Time: Users can see how median home values, median incomes, and demographic percentages have changed over time for a selected county within a state.
Demographic and Socioeconomic Indicators: The app displays trends in poverty rates, educational attainment, and the composition of various demographic groups.
Summary Statistics: Users can view percentage and absolute changes in key indicators over the selected time range.
Regression Analysis: The app provides insights into the relationships between different socioeconomic indicators, allowing users to analyze trends and forecast potential changes.
Importance
Data-Driven Insights: The application provides a powerful tool for policymakers, researchers, and the general public to analyze socioeconomic and housing trends.
Informed Decision-Making: By visualizing data trends and relationships, users can make more informed decisions regarding economic policies, housing markets, and community planning.
Educational Value: The app serves as an educational resource for understanding how various factors like income, home values, and demographics interact and change over time.
Accessibility: The interactive nature of the app makes complex data more accessible and easier to understand, facilitating broader engagement with the information.
Overall, this Shiny application is a valuable resource for exploring and understanding the multifaceted economic and housing trends across the United States, providing essential insights for data-driven decision-making and policy development.





