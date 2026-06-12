/// Contract every route descriptor must satisfy. Keeps route definitions
/// uniform (a [name] for named navigation, a [path] for location-based).
abstract interface class Coordinate {
  String get name;
  String get path;
}
