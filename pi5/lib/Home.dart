import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:pi5/Rastreio.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class homePageState extends StatefulWidget {
  const homePageState({Key? key}) : super(key: key);

  @override
  State<homePageState> createState() => _homePageStateState();
}

class _homePageStateState extends State<homePageState> {
  Map<dynamic, dynamic> caminhoneiros = {};
  int _count = 0;
  @override
  void initState() {
    _count = 0;
    caminhoneiros = {};
    dados();
    super.initState();
  }

  void dados() async {
    FirebaseDatabase db = FirebaseDatabase.instance;

    DatabaseReference dbref = db.ref("caminhoneiro/");
    DataSnapshot a = await dbref.get();
    Map<dynamic, dynamic> partial = a.value as Map<dynamic, dynamic>;
    setState(() {
      caminhoneiros = partial;
      _count = partial.length;
    });
  }

  @override
  Widget build(BuildContext context) {
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
        title: Row(children: const [
          Icon(
            LineAwesomeIcons.car,
            color: Colors.black,
          ),
          Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text(
                "Acompanhamento de veículos",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.w400),
              ))
        ]),
      ),
      body: Container(
        padding: const EdgeInsets.all(8),
        alignment: Alignment.center,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  "Olá!",
                  style: TextStyle(fontSize: 22),
                )
              ],
            ),
            Padding(
                padding: const EdgeInsets.only(top: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text("Selecione seu nome na lista para iniciar a viagem."),
                  ],
                )),
            Expanded(
                child: ListView.builder(
              shrinkWrap: true,
              itemCount: _count,
              itemBuilder: (context, index) {
                if (_count > 0) {
                  return Row(children: [
                    Expanded(
                        child: Card(
                            elevation: 5,
                            child: InkWell(
                                hoverColor: Colors.blueGrey,
                                onTap: () {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => rastreioPage(
                                            caminhoneiro: caminhoneiros[
                                                caminhoneiros.keys
                                                    .elementAt(index)]),
                                      ));
                                },
                                child: Row(children: [
                                  Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(children: [
                                        const Icon(LineAwesomeIcons.user_tie),
                                        Text(
                                          caminhoneiros[caminhoneiros.keys
                                              .elementAt(index)]["nome"],
                                        )
                                      ]))
                                ])))),
                  ]);
                } else {
                  return const Text("Lista vazia");
                }
              },
            ))
          ],
        ),
      ),
    );
  }
}
