import json
import pandas
import requests
projections_website = requests.get('https://fantasy.espn.com/apis/v3/games/ffl/seasons/2019/segments/0/leaguedefaults/1?view=kona_player_info')
projections_website_json = json.loads(projections_website.text)
print(projections_website_json)