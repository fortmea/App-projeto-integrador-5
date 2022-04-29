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
  late StreamSubscription<Position> positionStream;
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
    positionStream.cancel();
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
    timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_rastreando == true) {
        print("hehe");
        updateCoordenadas();
      }
    });
    positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) async {
      setState(() {
        posicao = (position == null
            ? 'Unknown'
            : '${position.latitude.toString()}, ${position.longitude.toString()}');
      });
    });

    return Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                  center: Alignment.topLeft,
                  focal: Alignment.bottomRight,
                  radius: 20,
                  colors: <Color>[Colors.white, Colors.grey]),
            ),
          ),
          title: Row(children: [
            const Icon(
              LineAwesomeIcons.box,
              color: Colors.black,
            ),
            Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  "Frete de " + widget.caminhoneiro["nome"],
                  style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                      fontSize: 16),
                ))
          ]),
          actions: [
            IconButton(
                onPressed: () {
                  positionStream.cancel();
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
                children: [Text("Sua posição: " + posicao)],
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
                        style: ElevatedButton.styleFrom(primary: Colors.black),
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
                            ? const Text("Interromper viagem")
                            : const Text("Iniciar viagem"),
                        icon: const Icon(LineAwesomeIcons.truck),
                      ),
                    ],
                  )),
            ])));
  }
}
