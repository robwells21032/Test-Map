# My First Choropleth Map #
# Based on the awesome tutorials of Andrew Ban Tran
# http://learn.r-journalism.com/en/mapping/
# Sept 18, 2018 

#--------------#
#Map of Ark Subprime #
#-------------#
install.packages("ggmap")
install.packages("formattable")
library(tigris)
library(sf)
library(ggplot2)
library(readr)
library(dplyr)
library(tidyr)
library(ggmap)
library(DT)
library(knitr)

subprime <- read_csv("/Users/robwells/Dropbox/R Class Aug 2018/2010-15 Mapped Subprime.csv")
head(subprime)

ggplot(ar) + 
  geom_sf() +
  theme_void() +
  theme(panel.grid.major = element_line(colour = 'transparent')) +
  labs(title="Arkansas counties")

ggplot(ar_merged) + 
  geom_sf() +
  geom_point(data=subprime, aes(x=Longitude, y=Latitude), size=ar_merged$Subp_PCT, color="yellow") +
  theme_void() +
  theme(panel.grid.major = element_line(colour = 'transparent')) +
  labs(title="subprime lending")

library(viridis)


#Choropleth
ar %>% 
  leaflet() %>% 
  addTiles() %>% 
  addPolygons(popup=~NAME)

#Merge with AR Geo Data by County Name
ar_merged <- geo_join(ar, subprime, "NAME", "County")
  
colnames(ar_merged)[12] <- "Subp_PCT"

#Format Data into Percent
library(formattable)
ar_merged$PCT <- percent(ar_merged$Subp_PCT)

#Color palette
pal <- colorNumeric("Reds", domain=ar_merged$Subp_PCT)
popup_sb <- paste0("Total: ", 
                   as.character(ar_merged$NAME), 
                   " County- ",  
                   as.character(ar_merged$PCT),
                   " of all mortgages were subprime")

# Mapping it with the new tiles CartoDB.Positron
leaflet() %>%
  addProviderTiles("CartoDB.Positron") %>%
  setView(-91.224, 34.741, zoom = 7.4) %>% 
  addPolygons(data = ar_merged , 
              fillColor = ~pal(ar_merged$Subp_PCT), 
              fillOpacity = 0.7, 
              weight = 0.2, 
              smoothFactor = 0.2, 
              popup = ~popup_sb) %>%
  addLegend(pal = pal, 
            values = ar_merged$PCT, 
            position = "bottomright", 
            title = "Subprime % All Loans")

# Holy shit this thing actually works #
# I still have a lot of work to do but I got something acceptable running #