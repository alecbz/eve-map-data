require 'json'
require 'fileutils'
require 'sqlite3'

DB_NAME = "./rubicon12.sqlite"

DB = SQLite3::Database.new(DB_NAME)
DB.results_as_hash = true

REGIONS = {}

DB.execute("select * from mapRegions") do |region|
  REGIONS[region['regionID']] = region['regionName']
end

def edge_to_dict(edge)
  {
    :from => edge['fromSolarSystemID'],
    :to => edge['toSolarSystemID'],
  }
end

def node_to_dict(node)
  {
    :name => node['solarSystemName'],
    :security => node['security'],
    :region => REGIONS[node['regionID']],
  }
end

def region_map(region_id)
  map = {:nodes => {}, :edges => []}

  query = 'select * from mapSolarSystemJumps where fromRegionID == ?1 and toRegionID == ?1'
  DB.execute(query, region_id) do |edge|
    map[:edges].push(edge_to_dict(edge))
  end

  query = 'select * from mapSolarSystems where regionID == ?'
  DB.execute(query, region_id) do |node|
    map[:nodes][node['solarSystemID']] = node_to_dict(node)
  end

  map
end

def universe_map
  map = {:nodes => {}, :edges => []}

  DB.execute("select * from mapSolarSystemJumps") do |edge|
    map[:edges].push({
      :from => edge['fromSolarSystemID'],
      :to => edge['toSolarSystemID'],
    })
  end

  DB.execute("select * from mapSolarSystems") do |node|
    map[:nodes][node['solarSystemID']] = {
      :name => node['solarSystemName'],
      :security => node['security'],
      :region => REGIONS[node['regionID']],
    }
  end

  map
end

def generate_json(prefix, map)
  File.open("data/#{prefix}_pretty.json", 'w') do |f|
    f.puts JSON.pretty_generate(map)
  end

  File.open("data/#{prefix}.json", 'w') do |f|
    f.puts map.to_json
  end
end

DATA_DIR = './data'
FileUtils.rm_rf DATA_DIR
FileUtils.mkdir_p DATA_DIR

puts "Generating universe map"
generate_json('universe', universe_map)

REGIONS.each do |id, name|
  puts "Generating region map for #{name}"
  generate_json(name.downcase.gsub(/ /, '_'), region_map(id))
end
