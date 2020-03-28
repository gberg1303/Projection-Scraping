import sys
import requests
from bs4 import BeautifulSoup
import pandas
import csv
import numpy
from tabulate import tabulate
from io import StringIO

week = "draft"
### Set Base URLs
positions = {'QB', 'RB', 'WR', 'K', 'DST'}
qb_url = "https://www.fantasypros.com/nfl/projections/qb.php?week="
rb_url = "https://www.fantasypros.com/nfl/projections/rb.php?week="
wr_url = "https://www.fantasypros.com/nfl/projections/wr.php?week="
te_url = "https://www.fantasypros.com/nfl/projections/te.php?week="
k_url = "https://www.fantasypros.com/nfl/projections/k.php?week="
dst_url = "https://www.fantasypros.com/nfl/projections/dst.php?week="

### Download The Data
qb_df = []
url = '%s%s' % (qb_url, week)
qb_website = requests.get(url)
qb_website_data = BeautifulSoup(qb_website.content, "lxml")
qb_df = qb_website_data.find_all('table')[0] 
qb_df = pandas.read_html(str(qb_df))
#print(tabulate(qb_df[0], headers='keys', tablefmt='psql') )
qb_df = tabulate(qb_df[0], headers='keys', tablefmt='psql')
qb_df = pandas.read_csv(qb_df)
#print(qb_df)
qb_df.to_csv('test.csv')