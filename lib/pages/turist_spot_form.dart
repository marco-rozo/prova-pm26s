import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:prova_pm26s/dao/turist_spots_dao.dart';
import 'package:prova_pm26s/model/turist_spots.dart';
import 'package:prova_pm26s/provider/cep_provider.dart';
import 'package:prova_pm26s/widgets/custom_button.dart';
import 'package:prova_pm26s/widgets/custom_text_form_field.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class TuristSpotForm extends StatefulWidget {
  final TuristSpots? turistSpots;
  const TuristSpotForm({
    super.key,
    this.turistSpots,
  });

  @override
  State<TuristSpotForm> createState() => _TuristSpotFormState();
}

class _TuristSpotFormState extends State<TuristSpotForm> {
  bool _isLoading = false;
  bool _isSearchedCep = false;

  final _formKey = GlobalKey<FormState>();

  TextEditingController _nameEditingController = TextEditingController();
  TextEditingController _diferentialEditingController = TextEditingController();
  TextEditingController _workingHoursEditingController =
      TextEditingController();
  TextEditingController _cepEditingController = TextEditingController();
  TextEditingController _urlPhotoEditingController = TextEditingController();
  TextEditingController _latitudeEditingController = TextEditingController();
  TextEditingController _longitudeEditingController = TextEditingController();

  final _dao = TuristSpotsDao();

  void showSnackBar(String message, bool status) {
    final snackBar = SnackBar(
      content: Text(
        message,
        textAlign: TextAlign.center,
      ),
      backgroundColor: status ? Colors.green[400] : Colors.red[400],
      margin: const EdgeInsets.only(right: 8, left: 8, bottom: 20),
      behavior: SnackBarBehavior.floating,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.turistSpots != null) {
      _nameEditingController.text = widget.turistSpots?.name ?? '';
      _cepEditingController.text = widget.turistSpots?.cep ?? '';
      _diferentialEditingController.text =
          widget.turistSpots?.differential ?? '';
      _latitudeEditingController.text = widget.turistSpots?.latitude ?? '';
      _longitudeEditingController.text = widget.turistSpots?.longitude ?? '';
      _urlPhotoEditingController.text = widget.turistSpots?.urlPhoto ?? '';
      _workingHoursEditingController.text =
          widget.turistSpots?.workingHours ?? '';
      _isSearchedCep = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: widget.turistSpots != null
            ? Text("Editar ${widget.turistSpots!.id}")
            : Text("Cadastrar"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Container(
          width: _width,
          height: _height,
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.only(
                right: 32,
                left: 32,
                bottom: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 16,
                  ),
                  //Nome
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          child: CustomTextFormField(
                            isEnable: true,
                            inputController: _nameEditingController,
                            labelText: "Insira a Nome",
                            onTapCallBack: () => print('description'),
                            icon: Icons.edit,
                            obscureText: false,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Campo obrigatório.';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  //Diferenciais
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          child: CustomTextFormField(
                            inputController: _diferentialEditingController,
                            labelText: "Insira os diferenciais",
                            onTapCallBack: () => print('differentials'),
                            icon: Icons.text_fields_rounded,
                            isEnable: true,
                            obscureText: false,
                            minLines: 2,
                            maxLines: 3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  //Horario de funcionamento
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          child: CustomTextFormField(
                            isEnable: true,
                            inputController: _workingHoursEditingController,
                            labelText: "Insira o horario de funcionamento",
                            onTapCallBack: () => print('workingHours'),
                            icon: Icons.timer_outlined,
                            obscureText: false,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  //CEP
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          child: CustomTextFormField(
                            isEnable: true,
                            inputController: _cepEditingController,
                            labelText: "Insira o CEP",
                            onTapCallBack: () => print('cep'),
                            icon: Icons.pin_drop_rounded,
                            obscureText: false,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Campo obrigatório.';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  //URL FOTO
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          child: CustomTextFormField(
                            isEnable: true,
                            inputController: _urlPhotoEditingController,
                            labelText: "Insira um link para Foto",
                            onTapCallBack: () => print('urlPhoto'),
                            icon: Icons.photo_camera,
                            obscureText: false,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Campo obrigatório.';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),

                  _latitudeEditingController.text != ''
                      ? SizedBox(
                          height: 8,
                        )
                      : Container(),
                  //LATITUDE
                  _latitudeEditingController.text != ''
                      ? Row(
                          children: [
                            Expanded(
                              child: Container(
                                child: CustomTextFormField(
                                  inputController: _latitudeEditingController,
                                  labelText: "Latitude",
                                  isEnable: false,
                                  onTapCallBack: () => print('Latitude'),
                                  icon: Icons.pin_drop_rounded,
                                  obscureText: false,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Container(),
                  _longitudeEditingController.text != ''
                      ? SizedBox(
                          height: 8,
                        )
                      : Container(),
                  //LONGITUDE
                  _longitudeEditingController.text != ''
                      ? Row(
                          children: [
                            Expanded(
                              child: Container(
                                child: CustomTextFormField(
                                  inputController: _longitudeEditingController,
                                  labelText: "Longitude",
                                  isEnable: false,
                                  onTapCallBack: () => print('Longitude'),
                                  icon: Icons.pin_drop_rounded,
                                  obscureText: false,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Container(),
                  CustomButton(
                    isLoading: false,
                    onPressedCallBack: () {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          _isLoading = true;
                        });
                        // _searchCep(_cepEditingController.text);
                        _getLocationByCep(_cepEditingController.text);
                      }
                    },
                    title: "Buscar CEP",
                  ),
                  _isSearchedCep
                      ? CustomButton(
                          isLoading: false,
                          onPressedCallBack: () {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                _isLoading = true;
                              });
                              save();
                            }
                          },
                          title: "Salvar",
                        )
                      : Container(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _searchCep(String cep) async {
    setState(() {
      _isLoading = true;
    });

    //Function para consumo de uma API Rest
    CepProvider cepProvider = CepProvider();

    await cepProvider.getCepData(cep).then((data) async {
      print(data);

      setState(() {
        _isLoading = false;
      });
    });
  }

  void save() {
    TuristSpots turistSpots = new TuristSpots(
      id: widget.turistSpots?.id,
      name: _nameEditingController.text.toString(),
      cep: _cepEditingController.text.toString(),
      //se for edição não altera na data de criação
      createAt: widget.turistSpots?.id != null
          ? widget.turistSpots!.createAt
          : DateTime.now(),
      differential: _diferentialEditingController.text.toString(),
      workingHours: _workingHoursEditingController.text.toString(),
      latitude: _latitudeEditingController.text,
      longitude: _longitudeEditingController.text,
      urlPhoto: _urlPhotoEditingController.text,
    );

    print(turistSpots);
    _dao.save(turistSpots).then((status) {
      if (status) {
        Navigator.of(context).pop(status);
        showSnackBar("Sucesso ao cadastrar Ponto Turistico", status);
      } else {
        showSnackBar("Erro ao cadastrar Ponto Turistico", status);
      }
    });
  }

  _getLocationByCep(String cep) async {
    try {
      List<Location> l = await locationFromAddress(cep);
      if (l.length > 0) {
        Location location = l[0];
        setState(() {
          _latitudeEditingController.text = location.latitude.toString();
          _longitudeEditingController.text = location.longitude.toString();
        });
      }

      print(l);
    } catch (e) {
      print(e);
    }

    setState(() {
      _isSearchedCep = true;
    });
  }
}
