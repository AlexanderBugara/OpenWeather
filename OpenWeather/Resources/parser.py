import json
import sqlite3

cities = json.load(open('city.list.json'))
db = sqlite3.connect("cities.db")

query = "insert into City values (?,?,?,?,?)"
columns = ['id', 'cityname', 'country', 'coord.lon', 'coord.lat']
for data in cities:
    c = db.cursor()
    c.execute(query, [data['id'], data['name'], data['country'], data['coord']['lon'], data['coord']['lat']])
    c.close()
db.commit()
db.close()
