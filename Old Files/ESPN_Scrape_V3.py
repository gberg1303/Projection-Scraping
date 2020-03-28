import requests

url = 'https://fantasy.espn.com/apis/v3/games/ffl/seasons/2019/segments/0/leaguedefaults/1?view=kona_player_info'

r = requests.get(url)
r = r.json()

slot_position_map = {
    1 : 'QB',
    2 : 'RB',
    3 : 'WR',
    4 : 'TE',
    5 : 'K'
}

stat_position_map = {
    23: 'Carries',
    24: 'Rushing Yards'
}

for player in r['players'][:100]:
    data = player['player']
    s = (f'Name: {data["fullName"]}\n'
         f'Position: {slot_position_map[data["defaultPositionId"]]}\n'
         f'Overall rank: {player["ratings"]["0"]["totalRanking"]}\n'
         f'Position rank: {player["ratings"]["0"]["positionalRanking"]}\n'
         f'Carries: {data["stats"][0]["stats"]}\n'
         )
    print(s)
   
print('Key guide:\n')
print('Big player object', list(r['players'][0].keys()), sep='\n', end='\n\n')
print('Sub player object', list(r['players'][0]['player'].keys()), sep='\n', end='\n\n')
print('Sub player stats object', list(r['players'][0]['player']['stats'][0].keys()), sep='\n', end='\n\n')
print('Sub player stats object1', list(r['players'][1]['player']['stats'][0].keys()), sep='\n', end='\n\n')
print('Sub player stats object2', list(r['players'][1]['player']['stats'][0]['stats'].keys()), sep='\n', end='\n\n')
#print('test', list(r['players'][1]['player']['stats'][0]['stats'][23], sep='\n', end='\n\n'))
#print('Sub player stats stats object', list(r[data["stats"]].keys()), sep='\n', end='\n\n')