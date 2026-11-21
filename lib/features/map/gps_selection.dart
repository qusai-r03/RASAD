/// A GPS fix captured for a complaint, including its horizontal accuracy in meters.
class GpsSelection {
  final double latitude;
  final double longitude;
  final double accuracyMeters;

  const GpsSelection({
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
  });
}
