get:
	curl -O https://catalog.registries.digital.go.jp/rsc/address/address_all.csv.zip
convert:
	ruby generate.rb | tippecanoe -f -o a.pmtiles

