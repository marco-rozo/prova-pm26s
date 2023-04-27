import 'package:flutter/material.dart';
// import 'package:flutter_maps_app/widgets/custom_tf.dart'; // Stores the Google Maps API Key
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'dart:math' show cos, sqrt, asin;

import 'package:prova_pm26s/secrets.dart';
import 'package:prova_pm26s/service/distance_calc_service.dart';
import 'package:prova_pm26s/widgets/custom_text_form_field.dart';
import 'package:prova_pm26s/widgets/custom_tf.dart';

class MapViewPage extends StatefulWidget {
  final String longitudeDest;
  final String latitudeDest;

  const MapViewPage({
    super.key,
    required this.longitudeDest,
    required this.latitudeDest,
  });

  @override
  _MapViewPageState createState() => _MapViewPageState();
}

class _MapViewPageState extends State<MapViewPage> {
  CameraPosition _initialLocation = CameraPosition(target: LatLng(0.0, 0.0));
  late GoogleMapController mapController;
  // GoogleMapController mapController = GoogleMapController();

  late Position _currentPosition;
  String _currentAddress = '';

  final startAddressController = TextEditingController();
  final destinationAddressController = TextEditingController();

  final startAddressFocusNode = FocusNode();
  final destinationAddressFocusNode = FocusNode();

  String _startAddress = '';
  String _destinationAddress = '';
  String? _placeDistance;

  Set<Marker> markers = {};

  late PolylinePoints polylinePoints;
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // Método para pegar a localização atual
  _getCurrentLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        _currentPosition = position;
        print('CURRENT POS: $_currentPosition');
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 18.0,
            ),
          ),
        );
      });
      await _getAddress();
      if (widget.latitudeDest != null) {
        _getAddressDestination(
          double.parse(widget.latitudeDest),
          double.parse(widget.longitudeDest),
        );
      }
    }).catchError((e) {
      print(e);
    });
  }

  // Método para recuperar o endereço
  _getAddress() async {
    try {
      List<Placemark> p = await placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];
      print(place);

      setState(() {
        _currentAddress =
            "${place.street}, ${place.name}, ${place.locality}, ${place.postalCode}, ${place.country}";
        startAddressController.text = _currentAddress;
        _startAddress = _currentAddress;
      });
    } catch (e) {
      print(e);
    }
  }

  _getAddressDestination(double latitudeDest, double longitudeDest) async {
    try {
      List<Placemark> destinationPlacemark =
          await placemarkFromCoordinates(latitudeDest, longitudeDest);

      Placemark placeDestination = destinationPlacemark[0];
      print(placeDestination);

      setState(() {
        _destinationAddress =
            "${placeDestination.street}, ${placeDestination.name}, ${placeDestination.locality}, ${placeDestination.postalCode}, ${placeDestination.country}";
        destinationAddressController.text = _destinationAddress;
        _destinationAddress = _destinationAddress;
      });

      await Future.delayed(const Duration(seconds: 1), () => _showRoute());
    } catch (e) {
      print(e);
    }
  }

  _showRoute() async {
    startAddressFocusNode.unfocus();
    destinationAddressFocusNode.unfocus();
    setState(() {
      if (markers.isNotEmpty) markers.clear();
      if (polylines.isNotEmpty) polylines.clear();
      if (polylineCoordinates.isNotEmpty) polylineCoordinates.clear();
      _placeDistance = null;
    });

    _calculateDistance().then((isCalculated) {
      if (isCalculated) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Distancia calculada com sucesso'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao calcular distancia'),
          ),
        );
      }
    });
  }

  // Método para calcular a distância entre dois lugares
  Future<bool> _calculateDistance() async {
    try {
      // Recuperando marcadores de endereços
      List<Location> startPlacemark = await locationFromAddress(_startAddress);
      List<Location> destinationPlacemark =
          await locationFromAddress(_destinationAddress);

      // se a posição ATUAL do usuário for a posição INICIAL
      // usa-se as coordenadas recuperadas da posição atual
      // em vez das coordenadas do endereço,
      // pois possui uma melhor precisão.
      double startLatitude = _startAddress == _currentAddress
          ? _currentPosition.latitude
          : startPlacemark[0].latitude;

      double startLongitude = _startAddress == _currentAddress
          ? _currentPosition.longitude
          : startPlacemark[0].longitude;

      double destinationLatitude = destinationPlacemark[0].latitude;
      double destinationLongitude = destinationPlacemark[0].longitude;

      String startCoordinatesString = '($startLatitude, $startLongitude)';
      String destinationCoordinatesString =
          '($destinationLatitude, $destinationLongitude)';

      // Marcador de localização inicial
      Marker startMarker = Marker(
        markerId: MarkerId(startCoordinatesString),
        position: LatLng(startLatitude, startLongitude),
        infoWindow: InfoWindow(
          title: 'Inicial $startCoordinatesString',
          snippet: _startAddress,
        ),
        icon: BitmapDescriptor.defaultMarker,
      );

      // Marcador de localização do destino
      Marker destinationMarker = Marker(
        markerId: MarkerId(destinationCoordinatesString),
        position: LatLng(destinationLatitude, destinationLongitude),
        infoWindow: InfoWindow(
          title: 'Destino $destinationCoordinatesString',
          snippet: _destinationAddress,
        ),
        icon: BitmapDescriptor.defaultMarker,
      );

      // Adicionando os marcadores à lista
      markers.add(startMarker);
      markers.add(destinationMarker);

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

      // Enquadrar o mapa na tela
      mapController.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            northeast: LatLng(northEastLatitude, northEastLongitude),
            southwest: LatLng(southWestLatitude, southWestLongitude),
          ),
          100.0,
        ),
      );

      // Calculando a distância entre as posições inicial e final
      // com caminho reto, sem considerar nenhuma rota.
      // double distanceInMeters = await Geolocator.bearingBetween(
      //   startLatitude,
      //   startLongitude,
      //   destinationLatitude,
      //   destinationLongitude,
      // );

      await _createPolylines(startLatitude, startLongitude, destinationLatitude,
          destinationLongitude);

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

      setState(() {
        _placeDistance = totalDistance.toStringAsFixed(2);
        print('DISTANCE: $_placeDistance km');
      });

      return true;
    } catch (e) {
      print(e);
    }
    return false;
  }

  // Fórmula para calcular a distância entre duas coordenadas
  // https://stackoverflow.com/a/54138876/11910277
  double _coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  // Cria as linhas para mostrar a rota entre dois lugares
  _createPolylines(
    double startLatitude,
    double startLongitude,
    double destinationLatitude,
    double destinationLongitude,
  ) async {
    polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      Secrets.API_KEY, // Google Maps API Key
      PointLatLng(startLatitude, startLongitude),
      PointLatLng(destinationLatitude, destinationLongitude),
      travelMode: TravelMode.driving,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    PolylineId id = PolylineId('poly');
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.red,
      points: polylineCoordinates,
      width: 3,
    );
    polylines[id] = polyline;
  }

  @override
  void initState() {
    super.initState();
    //Ao iniciar busca a lattitude e longitude inicial
    // e a patir delas sera o endereço atual
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Container(
      height: height,
      width: width,
      child: Scaffold(
        key: _scaffoldKey,
        body: Stack(
          children: <Widget>[
            // Map View
            GoogleMap(
              markers: Set<Marker>.from(markers),
              initialCameraPosition: _initialLocation,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              mapType: MapType.normal,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: false,
              polylines: Set<Polyline>.of(polylines.values),
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
            ),
            // Bottões de zoom
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ClipOval(
                      child: Material(
                        color: Colors.blue.shade100, // button color
                        child: InkWell(
                          splashColor: Colors.blue, // inkwell color
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: Icon(Icons.add),
                          ),
                          onTap: () {
                            mapController.animateCamera(
                              CameraUpdate.zoomIn(),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    ClipOval(
                      child: Material(
                        color: Colors.blue.shade100, // button color
                        child: InkWell(
                          splashColor: Colors.blue, // inkwell color
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: Icon(Icons.remove),
                          ),
                          onTap: () {
                            mapController.animateCamera(
                              CameraUpdate.zoomOut(),
                            );
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            // Container com os campos de pesquisa
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.all(
                        Radius.circular(20.0),
                      ),
                    ),
                    width: width * 0.9,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          CustomTextField(
                              label: 'Inicio',
                              hint: 'Insira o local inicial',
                              isEnable: false,
                              prefixIcon: Icon(Icons.looks_one),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.my_location),
                                onPressed: () {
                                  startAddressController.text = _currentAddress;
                                  _startAddress = _currentAddress;
                                },
                              ),
                              controller: startAddressController,
                              focusNode: startAddressFocusNode,
                              width: width,
                              locationCallback: (String value) {
                                setState(() {
                                  _startAddress = value;
                                });
                              }),
                          SizedBox(height: 10),
                          CustomTextField(
                              label: 'Destino',
                              hint: 'Insira o local de destino',
                              isEnable: false,
                              prefixIcon: Icon(Icons.looks_two),
                              controller: destinationAddressController,
                              focusNode: destinationAddressFocusNode,
                              width: width,
                              locationCallback: (String value) {
                                setState(() {
                                  _destinationAddress = value;
                                });
                              }),
                          SizedBox(height: 10),
                          Visibility(
                            visible: _placeDistance == null ? false : true,
                            child: Text(
                              'Distancia: ${_placeDistance.toString().replaceAll('.', ',')} km',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: 5),
                          // ElevatedButton(
                          //   onPressed: (_startAddress != '' &&
                          //           _destinationAddress != '')
                          //       ? () async {
                          //           startAddressFocusNode.unfocus();
                          //           destinationAddressFocusNode.unfocus();
                          //           setState(() {
                          //             if (markers.isNotEmpty) markers.clear();
                          //             if (polylines.isNotEmpty)
                          //               polylines.clear();
                          //             if (polylineCoordinates.isNotEmpty)
                          //               polylineCoordinates.clear();
                          //             _placeDistance = null;
                          //           });

                          //           _calculateDistance().then((isCalculated) {
                          //             if (isCalculated) {
                          //               ScaffoldMessenger.of(context)
                          //                   .showSnackBar(
                          //                 SnackBar(
                          //                   content: Text(
                          //                       'Distance Calculated Sucessfully'),
                          //                 ),
                          //               );
                          //             } else {
                          //               ScaffoldMessenger.of(context)
                          //                   .showSnackBar(
                          //                 SnackBar(
                          //                   content: Text(
                          //                       'Error Calculating Distance'),
                          //                 ),
                          //               );
                          //             }
                          //           });
                          //         }
                          //       : null,
                          //   child: Padding(
                          //     padding: const EdgeInsets.all(8.0),
                          //     child: Text(
                          //       'Show Route'.toUpperCase(),
                          //       style: TextStyle(
                          //         color: Colors.white,
                          //         fontSize: 20.0,
                          //       ),
                          //     ),
                          //   ),
                          //   style: ElevatedButton.styleFrom(
                          //     primary: Colors.red,
                          //     shape: RoundedRectangleBorder(
                          //       borderRadius: BorderRadius.circular(20.0),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Mostrar botão de localização atual
            SafeArea(
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10.0, bottom: 10.0),
                  child: ClipOval(
                    child: Material(
                      color: Colors.orange.shade100, // button color
                      child: InkWell(
                        splashColor: Colors.orange, // inkwell color
                        child: SizedBox(
                          width: 60,
                          height: 60,
                          child: Icon(Icons.my_location),
                        ),
                        onTap: () {
                          mapController.animateCamera(
                            CameraUpdate.newCameraPosition(
                              CameraPosition(
                                target: LatLng(
                                  _currentPosition.latitude,
                                  _currentPosition.longitude,
                                ),
                                zoom: 18.0,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
