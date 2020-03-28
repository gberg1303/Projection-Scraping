from pandas.io.html import read_html
from selenium import webdriver
import time

### Load the Web Page
driver = webdriver.Chrome(executable_path='/Users/jonathangoldberg/Documents/chromedriver')
driver.get('https://fantasy.espn.com/football/players/projections')
time.sleep(10)

### Player Name
player_name = driver.find_element_by_xpath('//*[@id="espn-analytics"]/div/div[5]/div[2]/div[2]/div/div/div/div/div[1]/div/section/table/tbody/tr/td')
player_name_html = player_name.get_attribute('innerHTML')
player_name_df = read_html(player_name_html)[1]
print(player_name_df)

### Player Statistics
player_statistics = driver.find_element_by_xpath('//*[@id="espn-analytics"]/div/div[5]/div[2]/div[2]/div/div/div/div/div[1]/div/div/div[1]/section/table/tbody/tr/td')
player_statistics_html = player_statistics.get_attribute('innerHTML')
player_statistics_df = read_html(player_statistics_html)[1]
print(player_statistics_df)


### Close the Web Page
driver.close()