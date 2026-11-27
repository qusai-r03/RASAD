"""Match WGS84 GPS coordinates to server-managed municipality boundaries."""

import json
import os
from functools import lru_cache
from pathlib import Path

from shapely.geometry import Point, shape
from shapely.errors import ShapelyError


class BoundaryConfigurationError(ValueError):
    pass


class LocationOutsideCoverage(ValueError):
    pass


@lru_cache(maxsize=1)
def _load_boundaries(path):
    try:
        data = json.loads(Path(path).read_text(encoding="utf-8-sig"))
        if data["type"] != "FeatureCollection" or not data["features"]:
            raise ValueError("Expected a populated FeatureCollection")
        boundaries = []
        for feature in data["features"]:
            props = feature["properties"]
            municipality = props["municipalityId"]
            area = props.get("area_id")
            if not isinstance(municipality, str) or not municipality.strip():
                raise ValueError("Missing municipalityId")
            if area is not None and (not isinstance(area, str) or not area.strip()):
                raise ValueError("Invalid area_id")
            geom = shape(feature["geometry"])
            if geom.geom_type not in {"Polygon", "MultiPolygon"} or geom.is_empty or not geom.is_valid:
                raise ValueError("Invalid municipality polygon")
            west, south, east, north = geom.bounds
            if not (-180 <= west <= east <= 180 and -90 <= south <= north <= 90):
                raise ValueError("Expected longitude/latitude coordinates")
            boundaries.append((geom, municipality, area))
        return boundaries
    except (OSError, ValueError, TypeError, AttributeError, KeyError, IndexError, ShapelyError) as error:
        raise BoundaryConfigurationError("Municipality boundary data unavailable or invalid") from error


def resolve_location(latitude, longitude):
    default = Path(__file__).resolve().parents[1] / "data" / "municipalities.geojson"
    boundaries = _load_boundaries(os.environ.get("RASD_MUNICIPALITIES_GEOJSON", str(default)))
    point = Point(longitude, latitude)
    matches = [(municipality, area) for polygon, municipality, area in boundaries if polygon.covers(point)]
    municipalities = {municipality for municipality, _ in matches}
    if len(municipalities) != 1:
        raise LocationOutsideCoverage("No unique municipality for this location")
    areas = {area for _, area in matches if area is not None}
    return municipalities.pop(), areas.pop() if len(areas) == 1 else None
