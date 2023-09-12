set.seed(123)  #For static reproducibility

#COdata <- read.csv("/Users/rachel/Documents/GitHub/Craft-Supplies-Inventory/data/RandomCO_City_Lat_Long.csv")


generate_random_addresses <- function(n) {
  addresses <- data.frame(
    street_address = character(n),
    city = character(n),
    zip_code = character(n),
    latitude = numeric(n),
    longitude = numeric(n),
    stringsAsFactors = FALSE
  )
  
  for (i in 1:n) {
    street_address <- paste(sample(1:9999, 1), sample(c("Main St", "Oak Ave", "Cedar Rd", "Hollywood Blvd", "Jason Rd", "Lincoln Rd", "Speer Blvd", "Platte Street", "19th Street", "54th Ave", "12th Street", "92nd Ave", "14th Ave", "20th Street"), 1))
    city <- sample(COdata$Location, 1)
    zip_code <- sample(c("80000", "80300", "80900", "80134", "80173", "80729", "80920"), 1)
    latitude <- sample(COdata$Latitude, 1)
    longitude <- sample(COdata$Longitude, 1)
    
    addresses[i, ] <- c(street_address, city, zip_code, latitude, longitude)
  }
  
  return(addresses)
}

random_addresses <- generate_random_addresses(500)
print(random_addresses)

write.csv(random_addresses, "/Users/rachel/Documents/GitHub/Craft-Supplies-Inventory/data/Random_CO_Address.csv")




city_options <- c("Denver", "Colorado Springs", "Aurora", "Fort Collins", "Lakewood", "Thornton", "Westminster", "Arvada", "Centennial", "Pueblo", "Boulder", "Greeley")
lat <- c(39.739, 38.834, 39.729, 40.585, 39.705, 39.868, 39.837, 39.803, 39.579, 38.254, 40.015, 40.423)
long <- c(-104.985, -104.821, -104.832, -105.084, -105.081, -104.972, -105.037, -105.087, -104.877, -104.609, -105.271, -104.709)

location_df <- data.frame(city_options, lat, long)

set.seed(124)

# Create an empty dataframe to store the random rows
random_rows <- data.frame()

# Number of times to pick a random row
num_iterations <- 500

# Loop to pick random rows
for (i in 1:num_iterations) {
  # Generate a random index
  random_index <- sample(nrow(location_df), 1)
  
  # Extract the random row using the generated index
  random_row <- location_df[random_index, ]
  
  # Append the random row to the 'random_rows' dataframe
  random_rows <- rbind(random_rows, random_row)
}

# Print the resulting dataframe with random rows
print(random_rows)
write.csv(random_rows, "/Users/rachel/Documents/GitHub/Craft-Supplies-Inventory/data/Random_CO_Address.csv")

