#code adapted from https://www.analyticsvidhya.com/blog/2016/02/time-series-forecasting-codes-python/
#to use this sign up for quandl for free at quandl.com
import quandl
import numpy as np 
import pandas as pd 
import matplotlib.pyplot as plt 
from statsmodels.tsa.stattools import adfuller
data = quandl.get("BITSTAMP/USD")
data.head(3)
#for this time series I will be using the lows
#note that if you use a different variable to forecast you may need 
#to use a different transform or no transform at all
#time series of raw low variable
plt.plot(data['Low'])
plt.title('Lows')
plt.show()

#want a stationary time series because time series models rely on this assumption, clearly this has increasing mean
#get rolling means
rollmean = pd.rolling_mean(data['Low'], window=12)
rollstd = pd.rolling_std(data['Low'], window=12)

plt.plot(data['Low'], color='blue',label='Original')
plt.plot(rollmean, color='red', label='Rolling Mean')
plt.plot(rollstd, color='black', label = 'Rolling Std')
plt.legend(loc='best')
plt.title('Rolling Mean & Standard Deviation')
plt.show()

print('Results of Dickey-Fuller Test for Raw Low Data:')
dftest = adfuller(data['Low'], autolag='AIC')
dfoutput = pd.Series(dftest[0:4], index=['Test Statistic','p-value','#Lags Used','Number of Observations Used'])
for key,value in dftest[4].items():
    dfoutput['Critical Value (%s)'%key] = value
print(dfoutput) 
#the test statistic is greater than the critical values so we 
#cannot say it is stationary
#means we need some sort of transformation
log_low = np.log(data['Low'])
plt.plot(log_low)
plt.title('Log Transform of Lows')
plt.show()
expwighted_avg = pd.ewma(log_low, halflife=12)
plt.plot(log_low)
plt.plot(expwighted_avg, color='red')
plt.title('EWMA of Log Transform')
plt.show()
ts_log_ewma_diff = log_low - expwighted_avg

rollmean = pd.rolling_mean(ts_log_ewma_diff, window=12)
rollstd = pd.rolling_std(ts_log_ewma_diff, window=12)

plt.plot(ts_log_ewma_diff, color='blue',label='Original')
plt.plot(rollmean, color='red', label='Rolling Mean')
plt.plot(rollstd, color='black', label = 'Rolling Std')
plt.legend(loc='best')
plt.title('Rolling Mean & Standard Deviation of Difference Between Log and EWMA of Log')
plt.show()

print('Results of Dickey-Fuller Test for Log Transform of Lows:')
dftest = adfuller(ts_log_ewma_diff, autolag='AIC')
dfoutput = pd.Series(dftest[0:4], index=['Test Statistic','p-value','#Lags Used','Number of Observations Used'])
for key,value in dftest[4].items():
    dfoutput['Critical Value (%s)'%key] = value
print(dfoutput) 
#the test statistic is less than the critical values at all the confidence levels so the model is stationary
