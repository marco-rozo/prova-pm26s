import 'dart:math' show cos, sqrt, asin;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:prova_pm26s/secrets.dart';

class DistanceCalcService {
  Future<double> calculateDistance(
    String currentAddress,
    String startAddress,
    String destinationAddress,
    double destinationLong,
    double destinationLat,
    double? startLong,
    double? startLat,
    Position currentPosition,
    List<LatLng> polylineCoordinates,
  ) async {
    try {
      // Recuperando marcadores de endereços
      List<Location> startPlacemark = await locationFromAddress(startAddress);
      List<Location> destinationPlacemark =
          await locationFromAddress(destinationAddress);

      // se a posição ATUAL do usuário for a posição INICIAL
      // usa-se as coordenadas recuperadas da posição atual
      // em vez das coordenadas do endereço,
      // pois possui uma melhor precisão.
      double startLatitude = startAddress == currentAddress
          ? currentPosition.latitude
          : startPlacemark[0].latitude;

      double startLongitude = startAddress == currentAddress
          ? currentPosition.longitude
          : startPlacemark[0].longitude;

      double destinationLatitude = destinationPlacemark[0].latitude;
      double destinationLongitude = destinationPlacemark[0].longitude;

      String startCoordinatesString = '($startLatitude, $startLongitude)';
      String destinationCoordinatesString =
          '($destinationLatitude, $destinationLongitude)';

      print(
        'START COORDINATES: ($startLatitude, $startLongitude)',
      );
      print(
        'DESTINATION COORDINATES: ($destinationLatitude, $destinationLongitude)',
      );

      // Calculando para verificar a posição em relação ao quadro
      // e zoom da câmera de acordo.
      double miny = (startLatitude <= destinationLatitude)
          ? startLatitude
          : destinationLatitude;
      double minx = (startLongitude <= destinationLongitude)
          ? startLongitude
          : destinationLongitude;
      double maxy = (startLatitude <= destinationLatitude)
          ? destinationLatitude
          : startLatitude;
      double maxx = (startLongitude <= destinationLongitude)
          ? destinationLongitude
          : startLongitude;

      double southWestLatitude = miny;
      double southWestLongitude = minx;

      double northEastLatitude = maxy;
      double northEastLongitude = maxx;

      // Calculando a distância entre as posições inicial e final
      // com caminho reto, sem considerar nenhuma rota.
      // double distanceInMeters = await Geolocator.bearingBetween(
      //   startLatitude,
      //   startLongitude,
      //   destinationLatitude,
      //   destinationLongitude,
      // );

      await _createPolylines(startLatitude, startLongitude, destinationLatitude,
          destinationLongitude, polylineCoordinates);

      double totalDistance = 0.0;

      // Calculando a distância total adicionando a distância
      // entre pequenos segmentos
      for (int i = 0; i < polylineCoordinates.length - 1; i++) {
        totalDistance += _coordinateDistance(
          polylineCoordinates[i].latitude,
          polylineCoordinates[i].longitude,
          polylineCoordinates[i + 1].latitude,
          polylineCoordinates[i + 1].longitude,
        );
      }
      return totalDistance;
    } catch (e) {
      print(e);
    }
    return 0;
  }

  double _coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  _createPolylines(
      double startLatitude,
      double startLongitude,
      double destinationLatitude,
      double destinationLongitude,
      List<LatLng> polylineCoordinates) async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      Secrets.API_KEY, // Google Maps API Key
      PointLatLng(startLatitude, startLongitude),
      PointLatLng(destinationLatitude, destinationLongitude),
      travelMode: TravelMode.driving,
    );

    Map<PolylineId, Polyline> polylines = {};

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    PolylineId id = PolylineId('poly');
    Polyline polyline = Polyline(
      polylineId: id,
      // color: Colors.red,
      points: polylineCoordinates,
      width: 3,
    );
    polylines[id] = polyline;
  }
}
