# if you haven't installed these libraries, use 
# install.packages("tidyverse")
# install.packages("magrittr")
library(tidyverse)
library(magrittr)

# Clone the repo from xxxx
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

pmCompareCols <- pmComparison %>%
    pivot_wider(names_from = sensor, values_from = pm25)

# Take a look at the new dataframe.
head(pmCompareCols)

# and continue your comparison code below...

###############################################################################

# The reason you converted the dataframe to a "wide" format is because this 
# makes it much easier to plot two columns against each other. To compare the 
# sensor readings between DEQ and PMS5003 devices, create a scatterplot of
# one reading versus the other. Add a line of best fit with geom_smooth().

ggplot(pmCompareCols, aes(x = pms5003, y = deq)) + 
    geom_point() + 
    geom_smooth(method = 'lm', formula = y ~ x) + 
    labs(x = "PMS5003", y = "DEQ")

# To determine the coefficients -- and thus the equation -- of the trend line, 
# use lm(y ~ x). The term y ~ x means you are looking for an equation of best
# fit where y is proportional to x. This means an equation of the form
# y = mx + b

x <- pmCompareCols$pms5003
y <- pmCompareCols$deq

slopeIntercept <- lm(y ~ x)
print(slopeIntercept)

# the correlation coefficient tells you how strong the relationship -- or 
# correlation -- is between x and y (the PMS5003 and the DEQ reference monitor.
print(cor(x, y))

# the slope and intercept are stored in the coefficients variable. Store these
# numbers with the names m and b
b <- slopeIntercept$coefficients[1]
m <- slopeIntercept$coefficients[2]

# Our equation tells us what we need to do to the PMS5003 data to get the DEQ 
# data. Now that we have the coefficients of our equation, we can transform 
# the PMS5003 data by plugging it into the equation using mutate().

pmCorrected <- pmCompareCols %>%
    mutate(pmsCorrected = m * pms5003 + b)

ggplot(pmCorrected, aes(x = pmsCorrected, y = deq)) + 
    geom_point() + 
    geom_smooth(method = 'lm', formula = y ~ x) + 
    labs(x = "PMS5003 (corrected)", y = "DEQ") + 
    coord_fixed(1) + 
    theme(
        panel.grid.minor = element_blank()
    )

# Finally, convert the corrected data set back into a "long" format. This format
# is useful for plotting the sensor readings side by side over time.

pmCorrectedLong <- pmCorrected %>%
    pivot_longer(cols = c(deq, pms5003, pmsCorrected),
    names_to = "sensor", values_to = "pm25")

# Now plot the data. The data points will be colored based on the type of 
# sensor making the readings.

ggplot(pmCorrectedLong, aes(x = date, y = pm25, color = sensor)) + 
    geom_point() + 
    labs(x = "Date (2020)", y = "PM2.5 Concentration", color = "Sensor type")

