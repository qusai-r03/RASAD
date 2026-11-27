import json
import os
from pathlib import Path
from tempfile import TemporaryDirectory
import unittest
from unittest.mock import patch

from backend.reports.municipality_service import (
    BoundaryConfigurationError, LocationOutsideCoverage, resolve_location,
)


class MunicipalityTests(unittest.TestCase):
    def test_routing(self):
        def feature(west, municipality, area):
            ring = [[west, 31], [west + 1, 31], [west + 1, 32], [west, 32], [west, 31]]
            return {"type": "Feature", "properties": {"municipalityId": municipality, "area_id": area},
                    "geometry": {"type": "Polygon", "coordinates": [ring]}}

        with TemporaryDirectory() as folder:
            path = Path(folder) / "fixture.geojson"
            with patch.dict(os.environ, RASD_MUNICIPALITIES_GEOJSON=str(path)):
                with self.assertRaises(BoundaryConfigurationError):
                    resolve_location(31.5, 35.5)
                path.write_text(json.dumps({"type": "FeatureCollection", "features": [
                    feature(35, "a", "a1"), feature(36, "a", "a2"), feature(37, "b", "b1"),
                ]}))
                self.assertEqual(resolve_location(31.5, 35.5), ("a", "a1"))
                self.assertEqual(resolve_location(31.5, 36), ("a", None))
                with self.assertRaises(LocationOutsideCoverage):
                    resolve_location(31.5, 37)
                with self.assertRaises(LocationOutsideCoverage):
                    resolve_location(0, 0)
