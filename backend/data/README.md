Report routing reads municipalities.geojson from this directory, or the file named by
RASD_MUNICIPALITIES_GEOJSON. Supply verified municipal or municipal-area boundaries as a
WGS84 GeoJSON FeatureCollection of Polygon or MultiPolygon features. Each feature needs
a string properties.municipalityId equal to the corresponding employees.municipalityId
in Firestore. A municipal-area feature can also carry a string properties.area_id.

Restart the backend after replacing the file. A missing or invalid dataset returns 503
on submission. A location outside coverage or shared by different municipalities
returns 422 before an image upload or report write. On a shared boundary between
two areas of the same municipality the municipality is saved and area_id is null.
