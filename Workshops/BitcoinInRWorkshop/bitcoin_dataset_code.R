library(RJSONIO) #allows conversion to and from JS objects
url <- "https://www.bitstamp.net/api/transactions/" #url where we get transaction data from
bs_data <- fromJSON(url) # converts JSON content into R object, returns a list
library(plyr) #breaks down large objects into more manageable pieces, operates on them, then puts it 
#back together
bs_df2 <- ldply(bs_data,data.frame) #abstracted way make bs_data (check class of bs) to data frame
head(bs_df2) #type 0 for buy, 1 for sell
nullToNA <- function(x) { #turns nulls into NAs so all columns have same length
  x[sapply(x, is.null)] <- NA
  return(x)
}

url_m <- "http://api.bitcoincharts.com/v1/markets.json" #JSON page
mkt_data <- fromJSON(url_m) #converts into R object
mkt_data <- lapply(mkt_data,nullToNA) #eturns a list of the same length as X, 
#each element of which is the result of applying FUN to the corresponding element of X
#mkt_data is same as before but nulls are now NAs, more manageable to work with in R
mkt_df <- ldply(mkt_data, data.frame) #For each element of a list, 
#apply function then combine results into a data frame.
head(mkt_df)
# Code to read compressed .gz files
# http://api.bitcoincharts.com/v1/csv/ cache of bit csv files, other files with more recent zips
# Data Source
bitcoin_file <- "bitstampUSD.csv.gz" #choose file
URL <- "http://api.bitcoincharts.com/v1/csv" #choose source
source_file <- file.path(URL,bitcoin_file) #construct path to a file
# Data destination on local disk
dataDir <-"C:/Users/Ronnie/Downloads"
dest_file <- file.path(dataDir,bitcoin_file) #construct path to download on our computer
# Download to disk
download.file(source_file,destfile = dest_file) #check directory of dataDir after this


# Uncompress .gz file and read into a data frame
raw <- read.csv(gzfile(dest_file),header=FALSE) #takes a minute or two
head(raw,2)
names(raw) <- c("unixtime","price","amount") #names() is base R  function that sets names of data frame
raw$date <- as.Date(as.POSIXct(raw$unixtime, origin="1970-01-01")) #convert raw$unixttime
head(raw,2)
library(dplyr) #installing now because function overlap issues, fast library to work with data frames
#unlike plyr, dplyr only focuses on data frames 
library(xts) #good time series package
library(dygraphs) #good for graphing time series
data <- select(raw,-unixtime) #selects everything from raw except for unixtime
#rm(raw) for some reason do not need this??
data <- mutate(data,value = price * amount) #adds new variables from data object called value, check head
by_date <- group_by(data,date) #groups all data by day
daily <- summarise(by_date,count = n(), #use that var to summarize mean price, amount, value by day
                   m_price <-  mean(price, na.rm = TRUE),
                   m_amount <- mean(amount, na.rm = TRUE),
                   m_value <-  mean(value, na.rm = TRUE))

names(daily) <- c("date","count","m_value","m_price","m_amount") #m stands for mean
head(daily,2)


daily_ts <- xts(daily$m_value,order.by=daily$date) # Make the m_value variable into a time series object

# Plot with htmlwidget dygraph
dygraph(daily_ts,ylab="US Dollars", 
        main="Average Value of bitstampUSD Buys") %>%
  dySeries("V1",label="Avg_Buy") %>%
  dyRangeSelector(dateWindow = c("2011-09-13","2017-07-02"))

