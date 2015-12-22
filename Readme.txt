Steps for running application on an AWS Linux Instance
1) Clone repo on linux server
2) Make sure you have RStudio, PostgreSQL, and Shiny are installed. Run the file install_R_Shiny.sh if necessary
3) Run the setup_postgresql_db.sh file to create a database 
4) Run load_packages. R to install necessary R packages
5) Obtain a Strava API key and plug it into extract_strava_api.R, then run the file to scrape all the data for the application. This takes some time due to rate limiting.
6) Run processing.R to clean and transform data, and load it into PostgreSQL
7) Make sure the Shiny App folder is in ~/srv/shiny-server
8) Set up permissions on AWS to accept incoming traffic on port 3838
9) Visit the public AWS url to see the app running. 