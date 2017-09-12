# Format:
# tiles = [
#     zoom => [
# 	    [ tx, ty, tz ],
# 	  ],
# 	  [
# 	    [ tx, ty, tz ],
# 	  ],
#     zoom => [
# 	    [ tx, ty, tz ],
# 	  ],
# 	  [
# 	    [ tx, ty, tz ],
# 	  ],
#     zoom => [
# 	    [ tx, ty, tz ],
# 	  ],
# 	  [
# 	    [ tx, ty, tz ],
# 	  ]
# ]

require 'rubygems'
require 'cloudmade'
require 'open-uri'
require 'fileutils'

min_long = -10.376632
max_long = 10.014504

min_lat = 40.755067
max_lat = 59.900361

zoom_values = [14,15]
#zoom_values = [12]


def returnTiles(latmin,latmax,lonmin,lonmax,zoom_values)

  CLOUDMADE_KEY = 'cloudmade has now shutdown'

  cm = CloudMade::Client.from_parameters(CLOUDMADE_KEY)

	tiles = []

  for zoom in zoom_values

    txmin = cm.tiles.xtile(lonmin,zoom)
    txmax = cm.tiles.xtile(lonmax,zoom)

    tymin = cm.tiles.ytile(latmax,zoom)
    tymax = cm.tiles.ytile(latmin,zoom)

    ntx = txmax - txmin + 1
    nty = tymax - tymin + 1

    tiles[zoom] = []
    
    for tx in txmin..txmax
      for ty in tymin..tymax
        puts zoom,tx,ty
        tiles[zoom].push([tx,ty,zoom])

        dst = "maptiles/#{zoom}/"
        dst2 = "maptiles/#{zoom}/#{tx}/"
        `mkdir -p #{dst2}`
        # File.chmod(0777, "maptiles/")
        # FileUtils.mkdir_p(File.dirname(dst))
        # File.chmod(0777, "maptiles/#{zoom}")
        # FileUtils.mkdir_p(File.dirname(dst2))
        unless File.exist?(dst2+ty.to_s+'.png') 
          open(dst2+ty.to_s+'.png', 'wb') do |file|
            file << open("http://b.tile.cloudmade.com/#{CLOUDMADE_KEY}/38509/256/#{zoom}/#{tx}/#{ty}.png").read
          end
        end
      end
    end

  end

  return tiles

end

returnTiles(min_lat, max_lat, min_long, max_long, zoom_values)

open('image.png', 'wb') do |file|
  file << open('http://example.com/image.png').read
end