import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:prova_pm26s/dao/turist_spots_dao.dart';
import 'package:prova_pm26s/model/turist_spots.dart';
import 'package:prova_pm26s/pages/map_view_page.dart';
import 'package:prova_pm26s/pages/turist_spot_form.dart';
import 'package:prova_pm26s/widgets/custom_bottom_modal.dart';
import 'package:prova_pm26s/widgets/custom_image_card.dart';
import 'package:prova_pm26s/widgets/custom_list_tile.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:map_launcher/map_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _dao = TuristSpotsDao();
  late Position _currentPosition;
  final _inputController = TextEditingController();

  bool _isLoading = false;
  final List<TuristSpots> allTuristSpotsList = [];
  List<TuristSpots> foundTuristSpotsList = [];

  // final List<TuristSpots> allTuristSpotsListTest = List<TuristSpots>.generate(
  //   5,
  //   (int index) => TuristSpots(
  //     id: index + 1,
  //     name: 'title$index',
  //     cep: '8993000$index',
  //     differential: 'differentials',
  //     createAt: DateTime.now(),
  //   ),
  // );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getCurrentLocation();
    _updateList();
  }

  Future<void> showBottomInfo(TuristSpots turistSpots, double distance) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      isScrollControlled: true,
      barrierColor: Colors.white.withOpacity(0.01),
      builder: (BuildContext context) {
        return CustomBottomModal(turistSpots: turistSpots, distance: distance);
      },
    );
  }

  List<PopupMenuEntry<String>> _optionsItensPopMenu() {
    return [
      PopupMenuItem<String>(
        value: 'SHOW',
        child: Row(
          children: const [
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                'Ver',
              ),
            )
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'DELETE',
        child: Row(
          children: const [
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                'Remover',
              ),
            )
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'EDIT',
        child: Row(
          children: const [
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                'Editar',
              ),
            )
          ],
        ),
      ),
      PopupMenuItem<String>(
        value: 'SHOW_MAP',
        child: Row(
          children: const [
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                'Ver no mapa',
              ),
            )
          ],
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home page"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => goToFormPage(null),
        tooltip: "New Turist Spot",
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Column(
          children: [
            TextField(
              autofocus: false,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                suffixIcon: _inputController.text != ''
                    ? IconButton(
                        onPressed: () => {
                          _inputController.text = '',
                          _filterList(_inputController.text)
                        },
                        icon: Icon(Icons.close),
                      )
                    : Icon(Icons.search),

                // icon: Icon(Icons.person),
                hintText: 'Pesquisar',
              ),
              controller: _inputController,
              onChanged: (value) => {
                _filterList(value),
              },
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: _isLoading
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Align(
                          alignment: AlignmentDirectional.center,
                          child: CircularProgressIndicator(),
                        ),
                        Align(
                          alignment: AlignmentDirectional.center,
                          child: Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Text(
                              'Loading list...',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        )
                      ],
                    )
                  : foundTuristSpotsList.isEmpty
                      ? const Center(
                          child: Text('No tourist spot registered :('))
                      : ListView.separated(
                          key: UniqueKey(),
                          separatorBuilder: (BuildContext context, int index) =>
                              const Divider(),
                          itemCount: foundTuristSpotsList.length,
                          itemBuilder: (context, index) {
                            final turistSpots = foundTuristSpotsList[index];
                            return PopupMenuButton<String>(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CustomImageCard(
                                  title: turistSpots.name,
                                  date: turistSpots.dateFormatted,
                                  subtitle: turistSpots.differential ?? '',
                                  urlImage: turistSpots.urlPhoto ??
                                      'http://via.placeholder.com/350x150',
                                ),
                              ),
                              itemBuilder: (BuildContext context) =>
                                  _optionsItensPopMenu(),
                              onSelected: (String selectedValue) {
                                if (selectedValue == 'DELETE') {
                                  _delete(turistSpots, index);
                                  print(turistSpots.id);
                                } else if (selectedValue == 'EDIT') {
                                  goToFormPage(turistSpots);
                                } else if (selectedValue == 'SHOW') {
                                  goToBottomModalInfo(turistSpots);
                                } else if (selectedValue == 'SHOW_MAP') {
                                  openMap(turistSpots);
                                }
                              },
                            );
                            // InkWell(
                            //   onTap: () => print(turistSpots),
                            //   child: CustomImageCard(
                            //     title: turistSpots.name,
                            //     date: turistSpots.dateFormatted,
                            //     subtitle: turistSpots.differential ?? '',
                            //     urlImage: turistSpots.urlPhoto ??
                            //         'http://via.placeholder.com/350x150',
                            //   ),
                            //  );

                            // CustomListTile(
                            //   title: turistSpots.name,
                            //   date: turistSpots.dateFormatted,
                            //   subtitle: turistSpots.differential ?? '',
                            // ),
                          },
                        ),
            )
          ],
        ),
      ),
    );
  }

  void openMap(TuristSpots turistSpots) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text('Aonde deseja abrir o mapa?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openMapApp(double.parse(turistSpots.latitude!),
                    double.parse(turistSpots.longitude!), turistSpots.name);
              },
              child: Text('Google Maps'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                goToMapPage(turistSpots);
              },
              child: Text('Aqui mesmo'),
            )
          ],
        );
      },
    );
  }

  Future<void> openMapApp(
      double latitude, double longitude, String name) async {
    final availableMaps = await MapLauncher.installedMaps;

    await availableMaps.first.showMarker(
      coords: Coords(latitude, longitude),
      title: name,
    );
  }

  void _updateList() async {
    setState(() {
      _isLoading = true;
    });
    final turistSpots = await _dao.getAll();
    setState(() {
      allTuristSpotsList.clear();
      foundTuristSpotsList.clear();
      if (turistSpots.isNotEmpty) {
        allTuristSpotsList.addAll(turistSpots);
        foundTuristSpotsList.addAll(turistSpots);
      }

      _isLoading = false;
    });
  }

  void _delete(TuristSpots turistSpots, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: const [
              Icon(
                Icons.warning,
                color: Colors.red,
              ),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text('Caution!'),
              ),
            ],
          ),
          content: Text('This record will be permanently deleted'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  allTuristSpotsList[index] = turistSpots;
                });
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (turistSpots.id == null) {
                  return;
                }
                _dao.remove(turistSpots.id!).then((success) {
                  if (success) _updateList();
                });

                // setState(() {
                //   allAttractionsList.remove(attraction);
                //   // allAttractionsList.removeAt(index);
                //   foundAttractionsList = allAttractionsList;
                // });
              },
              child: Text('Confirm'),
            )
          ],
        );
      },
    );
  }

  void goToBottomModalInfo(TuristSpots turistSpots) async {
    calcDistance(turistSpots, _currentPosition).then((value) {
      if (value != null) {
        showBottomInfo(turistSpots, value);
      }
    });
  }

  void goToFormPage(TuristSpots? turistSpots) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TuristSpotForm(
          turistSpots: turistSpots,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _isLoading = true;
      });

      _updateList();

      print(result);
    }
  }

  Future<double> calcDistance(
    TuristSpots turistSpots,
    Position currentPosition,
  ) async {
    double distanceInMeters = await Geolocator.distanceBetween(
      currentPosition.latitude,
      currentPosition.longitude,
      double.parse(turistSpots.latitude!),
      double.parse(turistSpots.longitude!),
    );

    double distanceKm = distanceInMeters / 1000;

    return distanceKm;
  }

  void goToMapPage(TuristSpots turistSpots) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MapViewPage(
          latitudeDest: turistSpots.latitude!,
          longitudeDest: turistSpots.longitude!,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _isLoading = true;
      });

      _updateList();

      print(result);
    }
  }

  _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        _currentPosition = position;
        _isLoading = false;

        print('CURRENT POS: $_currentPosition');
      });
    }).catchError((e) {
      print(e);
      setState(() {
        _isLoading = false;
      });
    });
  }

  void _filterList(String value) {
    List<TuristSpots> newList = [];

    newList = allTuristSpotsList.where((o) {
      if (o.name.contains(value)) {
        return true;
      }

      if (o.differential != null && o.differential!.contains(value)) {
        return true;
      }

      if (o.dateFormatted.contains(value)) {
        return true;
      }

      if (o.id.toString() == value) {
        return true;
      }

      return false;
    }).toList();

    setState(() {
      foundTuristSpotsList = newList;
    });
  }
}
