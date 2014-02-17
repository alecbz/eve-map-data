require 'json'
require 'sqlite3'

DB_NAME = "./rubicon12.sqlite"

db = SQLite3::Database.new(DB_NAME)
db.results_as_hash = true

regions = {}

db.execute("select * from mapRegions") do |region|
  regions[region['regionID']] = region['regionName']
end

map = {:nodes => {}, :edges => []}

db.execute("select * from mapSolarSystemJumps") do |edge|
  map[:edges].push({
    :from => edge['fromSolarSystemID'],
    :to => edge['toSolarSystemID'],
  })
end

db.execute("select * from mapSolarSystems") do |node|
  map[:nodes][node['solarSystemID']] = {
    :name => node['solarSystemName'],
    :security => node['security'],
    :region => regions[node['regionID']],
  }
end

def generate_json(prefix, data)
  File.open("#{prefix}_pretty.json", 'w') do |f|
    f.puts JSON.pretty_generate(map)
  end

  File.open("#{prefix}.json", 'w') do |f|
    f.puts map.to_json
  end
end

generate_json('map', map)
