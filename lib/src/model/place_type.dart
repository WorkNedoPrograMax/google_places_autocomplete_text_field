sealed class PlaceType {
  const PlaceType();
}

class City extends PlaceType {
  const City();
}

class Street extends PlaceType {
  final String city;
  const Street({
    required this.city,
  });
}

class Building extends PlaceType {
  final String city;
  final String street;
  const Building({
    required this.city,
    required this.street,
  });
}

class PostalCode extends PlaceType {
  const PostalCode();
}
