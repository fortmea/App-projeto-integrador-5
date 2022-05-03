import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pi5/Home.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class rastreioPage extends StatefulWidget {
  rastreioPage({Key? key, required this.caminhoneiro}) : super(key: key);
  final Map<dynamic, dynamic> caminhoneiro;
  @override
  State<rastreioPage> createState() => _rastreioPageState();
}

class _rastreioPageState extends State<rastreioPage> {
  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100,
  );

  String posicao = "";
  Map<dynamic, dynamic> veiculo = {};
  String idVeiculo = "";
  bool _rastreando = false;
  Timer? timer;
  void permissao() async {
    LocationPermission permission = await Geolocator.requestPermission();
  }

  @override
  void initState() {
    permissao();
    posicao = "";
    idVeiculo = "";
    veiculo = {"modelo": "", "placa": ""};
    _rastreando = false;

    dados();
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void updateCoordenadas() {
    FirebaseDatabase.instance
        .ref('caminhao/$idVeiculo/coordenada')
        .set(posicao);
  }

  void dados() async {
    FirebaseDatabase db = FirebaseDatabase.instance;

    DatabaseReference dbref = db.ref("garagem/");
    DataSnapshot a = await dbref.get();
    Map<dynamic, dynamic> partial = a.value as Map<dynamic, dynamic>;
    for (int i = 0; i < partial.length; i++) {
      if (partial[partial.keys.elementAt(i)]["caminhoneiro"]["cpf"] ==
          widget.caminhoneiro["cpf"]) {
        String placa = partial[partial.keys.elementAt(i)]["caminhao"]["placa"];
        DatabaseReference dbrefcaminhao = db.ref("caminhao/");
        DataSnapshot b = await dbrefcaminhao.get();
        Map<dynamic, dynamic> partialcaminhao =
            b.value as Map<dynamic, dynamic>;
        for (int x = 0; x < partialcaminhao.length; x++) {
          if (partialcaminhao[partialcaminhao.keys.elementAt(x)]["placa"] ==
              placa) {
            setState(() {
              veiculo = partialcaminhao[partialcaminhao.keys.elementAt(x)];
              idVeiculo = partialcaminhao.keys.elementAt(x);
            });
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      Position position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          posicao =
              '${position.latitude.toString()}, ${position.longitude.toString()}';
        });
      }
      if (_rastreando == true) {
        updateCoordenadas();
      }
    });

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: const Icon(
            LineAwesomeIcons.box,
            color: Colors.black,
          ),
          title: Text(
            "Frete de " + widget.caminhoneiro["nome"],
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const homePageState(),
                      ));
                },
                icon: const Icon(
                  LineAwesomeIcons.times,
                  color: Colors.black,
                ))
          ],
        ),
        body: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  (posicao != "")
                      ? Text("Sua posição: " + posicao)
                      : const Text("")
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LineAwesomeIcons.user_tie),
                  Text("CPF: " + widget.caminhoneiro["cpf"])
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  (veiculo["placa"] != "")
                      ? Text(
                          veiculo["modelo"] + " - Placa: " + veiculo["placa"])
                      : const Text("")
                ],
              ),
              Padding(
                  padding: const EdgeInsets.only(top: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            primary: Colors.white, elevation: 10),
                        onPressed: () {
                          if (_rastreando == false) {
                            setState(() {
                              _rastreando = true;
                            });
                          } else {
                            setState(() {
                              _rastreando = false;
                            });
                          }
                        },
                        label: _rastreando
                            ? const Text(
                                "Interromper viagem",
                                style: TextStyle(color: Colors.black),
                              )
                            : const Text("Iniciar viagem",
                                style: TextStyle(color: Colors.black)),
                        icon: const Icon(
                          LineAwesomeIcons.truck,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  )),
            ])));
  }
}
