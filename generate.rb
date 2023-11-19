# This script reads a zip file containing CSV files and generates GeoJSON data for each "pos" file.
# It uses the 'zip', 'stringio', and 'json' libraries.
# The main function is 'jump_into', which recursively jumps into nested zip files and processes the "pos" files.
# The generated GeoJSON data is printed to the console.

require 'zip'
require 'stringio'
require 'json'

SRC_PATH = 'address_all.csv.zip'

# Recursively jumps into nested zip files and processes the "pos" files.
# @param [Zip::InputStream] stream - The input stream of the zip file
def jump_into(stream)
  while entry = stream.get_next_entry
    if /.zip$/.match(entry.name.downcase)
      jump_into(Zip::InputStream.open(StringIO.new(stream.read)))
    elsif /pos/.match(entry.name.downcase)
      first = true
      keys = []
      layer = ''
      stream.each_line {|l|
        l.force_encoding('utf-8')
        if first
          layer = entry.name.downcase.split('_pos_')[0].split('_')[-1]
          keys = l.strip.split(',')
          first = false
        else
          geojson = {
            :type => 'Feature',
            :tippecanoe => {
              :layer => layer
            }
          }
          geojson[:properties] = keys.zip(l.strip.split(',')).to_h
          geojson[:geometry] = {
            :type => 'Point',
            :coordinates => [
              geojson[:properties].delete('代表点_経度').to_f,
              geojson[:properties].delete('代表点_緯度').to_f
            ]
          }
          print JSON.dump(geojson), "\n"
        end
      }
    end
  end
end

# Open the zip file and call the 'jump_into' function to process the files
Zip::InputStream.open(File.open(SRC_PATH)) {|stream|
  jump_into(stream)
}
