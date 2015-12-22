### Strava - Data Processing and Cleaning ###
library(RPostgreSQL)

lb <- read.csv("strava_leaderboards_11_29.csv")
seg <- read.csv("strava_segments_12_14.csv")
seg_lat_lon <- read.csv("strava_segments_11_28.csv")

### Extract lat/lon and bind to segment ###
latlong <- toString(seg_lat_lon$segments.start_latlng[1])
latlong_split <- strsplit(latlong, 'c')
latlong_vector <- unlist(latlong_split)
latlong_vector <- latlong_vector[-1]
seg_test <- cbind(seg, latlong=latlong_vector)

latlong_columns <- data.frame(do.call('rbind', strsplit(as.character(seg_test$latlong),',',fixed=TRUE)))[,c(1,2)]
colnames(latlong_columns) <- c("lat", "lon")
latlong_columns$lat <- gsub("\\(", "", latlong_columns$lat)
latlong_columns$lon <- gsub("\\)", "", latlong_columns$lon)

seg_merge <- cbind(seg, latlong_columns)

### Deduplicate Segments and Efforts ###
lb$unique_id <- paste0(lb$segments.id, '_',lb$entries.rank)
lb <- lb[,-1]
lb_dedup <- unique(lb)

efforts <- unique(lb_dedup[,c(1,20)])
seg_dedup <- unique(seg_merge[,-c(1,2)])

### Assign score ###
efforts_merge <- merge(efforts, seg_dedup, by.x="segments.id", by.y="segments.id",
                       all.x=F, all.y=F)
efforts_merge$effort_count <- as.numeric(as.character(efforts_merge$effort_count))

### Load into PostgreSQL ###
con <- dbConnect(PostgreSQL(), user= "postgres", password="ENTER PASSWORD", dbname='strava')
efforts_clean <- efforts_merge[!is.na(efforts_merge$effort_count),]
dbWriteTable(con, "efforts", efforts_clean)

### dbGetQuery(con, 'select * from efforts limit 10') ###
dbDisconnect(con)
