require 'zip'
require 'stringio'
require 'json'

SRC_PATH = 'address_all.csv.zip'

def jump_into(stream)
  while entry = stream.get_next_entry
    if /.zip$/.match(entry.name.downcase)
      jump_into(Zip::InputStream.open(StringIO.new(stream.read)))
    elsif /pos/.match(entry.name.downcase)
      first = true
      keys = []
      stream.each_line {|l|
        l.force_encoding('utf-8')
        if first
          keys = l.strip.split(',')
          first = false
        else
          geojson = {
            :type => 'Feature',
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

Zip::InputStream.open(File.open(SRC_PATH)) {|stream|
  jump_into(stream)
}
