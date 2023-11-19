get:
	curl -O https://catalog.registries.digital.go.jp/rsc/address/address_all.csv.zip
convert:
	ruby generate.rb | tippecanoe -f -o a.pmtiles --minimum-zoom=3 --maximum-zoom=14 --base-zoom=14 \
	-r2.0 --drop-densest-as-needed
	