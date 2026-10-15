
#!/usr/bin/env bash
set -e

# Run from the folder containing this script.
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

# Export my analysis results to GeoJSON for the webmap.
python - <<'PY'
import geopandas as gpd

gdf = gpd.read_parquet(
    "../nyc-spatial-analysis/data/processed/hydrant_density.parquet"
)

gdf = gdf.to_crs(epsg=4326)
gdf = gdf.rename(columns={"density_per_km2": "hydrants_per_km2"})

gdf.to_file("neighborhood_density.geojson", driver="GeoJSON")

print(f"Exported {len(gdf)} neighborhood areas to GeoJSON.")
PY

# Convert the GeoJSON to PMTiles.
tippecanoe \
    -z12 \
    -Z8 \
    --no-feature-limit \
    --no-tile-size-limit \
    -l neighborhood_density \
    --coalesce-densest-as-needed \
    -o neighborhood_density.pmtiles \
    --force \
    neighborhood_density.geojson

echo "Created neighborhood_density.pmtiles"