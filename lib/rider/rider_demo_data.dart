class RiderPlace {
  const RiderPlace(
    this.id,
    this.name,
    this.address,
    this.latitude,
    this.longitude,
  );
  final String id, name, address;
  final double latitude, longitude;
}

const demoPickup = RiderPlace(
  'pickup',
  'Current location',
  'F-8, Islamabad',
  33.7095,
  73.0375,
);
const demoPlaces = [
  RiderPlace('centaurus', 'Centaurus Mall', 'F-8, Islamabad', 33.7077, 73.0498),
  RiderPlace(
    'safa',
    'Safa Gold Mall',
    'F-7 Markaz, Islamabad',
    33.7216,
    73.0554,
  ),
  RiderPlace(
    'airport',
    'Islamabad International Airport',
    'ISB, Islamabad',
    33.5492,
    72.8257,
  ),
  RiderPlace(
    'mosque',
    'Faisal Mosque',
    'Shah Faisal Avenue, Islamabad',
    33.7295,
    73.0372,
  ),
  RiderPlace(
    'daman',
    'Daman-e-Koh',
    'Margalla Hills, Islamabad',
    33.7383,
    73.0555,
  ),
];

const demoCars = [
  (33.7148, 73.0296, 145.0),
  (33.7045, 73.0426, 325.0),
  (33.6987, 73.0230, 55.0),
  (33.7009, 73.0560, 150.0),
];
