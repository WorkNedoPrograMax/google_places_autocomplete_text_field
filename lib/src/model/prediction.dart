import 'package:google_places_autocomplete_text_field/google_places_autocomplete_text_field.dart';

class PlacesAutocompleteResponse {
  List<Prediction>? predictions;
  String? status;

  PlacesAutocompleteResponse({
    this.predictions,
    this.status,
  });

  PlacesAutocompleteResponse.fromJson(Map<String, dynamic> json) {
    if (json['suggestions'] != null && json['suggestions'].length > 0) {
      predictions = [];
      json['suggestions'].forEach((v) {
        if (v['placePrediction'] != null) {
          predictions!.add(Prediction.fromJson(v['placePrediction']));
        }
      });
    }
  }
}

class Prediction {
  String? description;
  String? id;
  List<MatchedSubstrings>? matchedSubstrings;
  String? placeId;
  String? reference;
  StructuredFormatting? structuredFormatting;
  List<Terms>? terms;
  List<String>? types;
  String? lat;
  String? lng;

  Prediction({
    this.description,
    this.id,
    this.matchedSubstrings,
    this.placeId,
    this.reference,
    this.structuredFormatting,
    this.terms,
    this.types,
    this.lat,
    this.lng,
  });

  Prediction.fromJson(Map<String, dynamic> json) {
    placeId = json['placeId'];
    description = json['text'] != null ? json['text']['text'] : null;
    structuredFormatting = json['structuredFormat'] != null
        ? StructuredFormatting.fromJson(json['structuredFormat'])
        : null;
    types = json['types'].cast<String>();
    lat = json['lat'];
    lng = json['lng'];
  }
}

class MatchedSubstrings {
  int? length;
  int? offset;

  MatchedSubstrings({this.length, this.offset});

  MatchedSubstrings.fromJson(Map<String, dynamic> json) {
    length = json['length'];
    offset = json['offset'];
  }
}

class StructuredFormatting {
  String? mainText;

  String? secondaryText;

  StructuredFormatting({this.mainText, this.secondaryText});

  StructuredFormatting.fromJson(Map<String, dynamic> json) {
    mainText = json['mainText'] != null ? json['mainText']['text'] : null;
    secondaryText =
        json['secondaryText'] != null ? json['secondaryText']['text'] : null;
  }
}

class Terms {
  int? offset;
  String? value;

  Terms({this.offset, this.value});

  Terms.fromJson(Map<String, dynamic> json) {
    offset = json['offset'];
    value = json['value'];
  }
}

extension PredictionsExtension on List<Prediction> {
  void reformatDescriptionsBasedOnPlaceType(
      {PlaceType? type, String? country}) {
    if (type != null) {
      forEach((prediction) {
        switch (type) {
          case City():
          case Street():
          case PostalCode():
            prediction.description =
                prediction.structuredFormatting?.mainText ??
                    prediction.description;
            break;
          case Building():
            final text = prediction.structuredFormatting?.mainText ??
                prediction.description ??
                '';
            prediction.description = _extractBuildingNumber(
              text: text,
              country: country ?? '',
              city: type.city,
              street: type.street,
            );
            break;
        }
      });
    }

    _removeDuplicates();
  }

  void _removeDuplicates() {
    final seenDescriptions = <String?>{};
    removeWhere((prediction) {
      if (seenDescriptions.contains(prediction.description)) {
        return true;
      }
      seenDescriptions.add(prediction.description);
      return false;
    });
  }
}

String _extractBuildingNumber({
  required String text,
  required String country,
  required String city,
  required String street,
}) {
  // Remove the country name
  text = text.replaceFirst(country, '');

  // Remove the city name
  text = text.replaceFirst(city, '');

  // Remove the street name
  text = text.replaceFirst(street, '');

  // Trim whitespace
  text = text.trim();

  // Remove leading or trailing commas
  if (text.startsWith(',')) {
    text = text.substring(1).trim();
  }
  if (text.endsWith(',')) {
    text = text.substring(0, text.length - 1).trim();
  }

  return text;
}
