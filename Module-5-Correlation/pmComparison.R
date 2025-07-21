# install or load required packages using pacman
if (!require("pacman")) install.packages("pacman")
pacman::p_load(pacman, tidyverse, magrittr, knitr)

# Clone the repo from https://github.com/ianeyk/Blueprint-Modules.git
# and load the file "pmComparison.RData"

# (change the path to the file you cloned.)
load("C:/dev/R/correlations/pmComparison.RData")

# This loads the dataframe pmComparison into memory. 
# pmComparison has a timestamp, a PM2.5 reading, and a sensor field.
# The sensor field tells you whether the reading was made by a DEQ
# reference monitor or a PMS5003 sensor.

# Take a look at the dataframe.
head(pmComparison)
size_sum(pmComparison)
print(paste(min(pmComparison$date), "to", max(pmComparison$date)))

# Now create a plot of DEQ and PMS5003 data. The way the dataframe is
# structured makes it easy to color the data points differently based
# on the value of the sensor column.

ggplot(pmComparison, aes(x = date, y = pm25, color = sensor)) + 
    geom_point() + 
    labs(x = "Date (2020)", y = "PM2.5 Concentration", color = "Sensor type")

# To get ready for the next step, you must convert the dataframe into a "wide"
# format. That is, create separate columns for the DEQ and PMS5003 sensor
# readings, so they can easily be plotted against each other. It is a subtle
# difference, but understanding this will make a huge difference in your ability
# to handle data.
# pivot_wider() converts the dataframe to a "wide" format.
# pivot_longer() is the opposite, in case you're wondering.

pmCompareCols <- pivot_wider(pmComparison, names_from = sensor, values_from = pm25)

# Take a look at the new dataframe.
head(pmCompareCols)

# and continue your comparison code below...