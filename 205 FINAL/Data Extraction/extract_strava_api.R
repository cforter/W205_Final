### Data Extraction From Strava API ###
library(httr)
library(jsonlite)

# Functions for retreiving leaderboard data from Strava
# get_leaderboard takes a segment ID (unquoted) and an access token (quoted) as arguments
# shiny app: http://www.r-bloggers.com/how-to-host-your-shiny-app-on-amazon-ec2-for-mac-osx/

### Get Leaderboard ###
get_leaderboard <- function(id, access_token, page) {
  # Initial GET request and parsing JSON 
  data <- GET(paste0("https://www.strava.com/api/v3/segments/", id, "/leaderboard"), 
              add_headers(Authorization = paste0("Bearer ",access_token)), query = list(page = page, per_page = 200))
  leaderboard <- fromJSON(toString(data))
  # Convert list to data frame
  df <- try(as.data.frame(leaderboard))
  df
}

### Explore Segments ###
explore <- function(access_token, string_coord) {
  data <- GET(paste0("https://www.strava.com/api/v3/segments/explore"), 
      add_headers(Authorization = paste0("Bearer ", access_token)), 
      query = list(bounds=string_coord, activity_type = "running"))
  segs <- fromJSON(toString(data))
  # Convert list to data frame
  df <- as.data.frame(segs)
  df
}

### Collect Segment Data ###
# Latitude: 32° 30' N to 42° N
#	Longitude: 114° 8' W to 124° 24' W
# http://www.mapsofworld.com/usa/states/california/lat-long.html

# Function to create mutually exclusive sub regions  
squares <- function(coords) {
  lat_seq <- seq(from = coords[1], to = coords[3], by=.1)
  lon_seq <- seq(from = coords[2], to = coords[4], by=.1)
  values <- list()
  for(i in 1:(length(lon_seq)-1)) {
    for(k in 1:(length(lat_seq)-1)) {
      values[[k + (20*(i-1))]] <- c(lat_seq[i], lon_seq[k], lat_seq[i+1], lon_seq[k+1])
    }
  }
  values
}

# Coordinates of California, broken into 9 quadrants
ca_1 <- c(40,-124,42,-122)
ca_2 <- c(40,-122,42,-120)
ca_3 <- c(38,-124,40,-122)
ca_4 <- c(38,-122,40,-120)
ca_5 <- c(36,-122,38,-120)
ca_6 <- c(36,-120,38,-118)
ca_7 <- c(34,-122,36,-120)
ca_8 <- c(34,-120,36,-118)
ca_9 <- c(34,-118,36,-116)

# 9 quadrants of Califonia each broken into 400 sub regions
squares_ca1 <- squares(ca_1)
squares_ca2 <- squares(ca_2)
squares_ca3 <- squares(ca_3)
squares_ca4 <- squares(ca_4)
squares_ca5 <- squares(ca_5)
squares_ca6 <- squares(ca_6)
squares_ca7 <- squares(ca_7)
squares_ca8 <- squares(ca_8)
squares_ca9 <- squares(ca_9)

california <- c(squares_ca1, squares_ca2, squares_ca3,
          squares_ca4, squares_ca5, squares_ca6,
          squares_ca7, squares_ca8, squares_ca9)

# Create data frame of segements to append to 
segments <- explore("INSERT_KEY_HERE",toString(ca_1))

# Retreive all CA segments, respecting Strava's rate limits
current_count <- 0
for(i in 401:length(california)) {
  current_count <- current_count + 1
  if(current_count == 575) {
    Sys.sleep(60*16)
    current_count <- 0
  }
  print(toString(california[[i]]))
  segments <- rbind(segments,
           explore("INSERT KEY HERE",
                  toString(california[[i]])))
  print(nrow(segments))
  print(length(unique(segments$segments.id)))
}

### Convert to data frame ###
segments_df <- as.data.frame(segments)
segments_df$segments.start_latlng <- toString(segments_df$segments.start_latlng)
segments_df$segments.end_latlng <- toString(segments_df$segments.end_latlng)

### Get leaderboards of all segments ###
# Creat data frames fro appending
leaderboards <- get_leaderboard(segments$segments.id[1], 
                        "INSERT KEY HERE", 1)
leaderboards$segments.id <- rep(segments$segments.id[1], nrow(leaderboards))

nrow(leaderboards) # = 35

current_count <- 0
total_count <- 0

# Retreive all CA leaderboards, respecting Strava's rate limits
for(i in unique(segments_df$segments.id)) {
  current_count <- current_count + 1
  total_count <- total_count + 1
  if(total_count >= 25000) {
    break
  }
  if(current_count >= 550) {
    Sys.sleep(61*15)
    current_count <- 0
  }
  index <- 1
  new_leaderboard <- get_leaderboard(i, 
                     "INSERT KEY HERE", index)
  if(class(new_leaderboard) != 'try-error') {
    while((nrow(new_leaderboard) / 200 / index) >= 1) { # If there are multiple pages get all pages
      index <- index + 1
      new_leaderboard <- rbind(new_leaderboard,
                               get_leaderboard(i, 
                                               "INSERT KEY HERE", index))
      total_count <- total_count + 1
      current_count <- current_count + 1
    }
    new_leaderboard$segments.id <- rep(i, nrow(new_leaderboard))
    leaderboards <- rbind(leaderboards, new_leaderboard)
    print(nrow(new_leaderboard))
  }
}

### Add unique ID that concatenates athlete ID and segment ID ###
leaderboards$uniqueid <- paste0(leaderboards$segments.id,leaderboards$entries.athlete_id)

### Write to CSV ###
write.csv(segments_df[,-c(7,8)], "strava_segments_11_28.csv") # don't include lat/lon
write.csv(leaderboards, "strava_leaderboards_11_29.csv")
write.csv(segments_df, "strava_segments_12_14.csv") # include lat/lon

