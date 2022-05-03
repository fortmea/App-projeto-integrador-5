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
  late TextEditingController _textEditingController;
  Map<dynamic, dynamic> caminhoneiros = {}; //Armazena dados mostrados
  Map<dynamic, dynamic> ocaminhoneiros =
      {}; //Armazena todos os dados, assim não é necessário fazer chamada no firebase sempre que fizer pequisa
  int _count = 0;
  double _elevation = 0;
  @override
  void initState() {
    _elevation = 0;
    _count = 0;
    caminhoneiros = {};
    dados();
    _textEditingController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  void search(query) {
    if (query != '') {
      Map<dynamic, dynamic> nmapa = {};
      for (int i = 0; i < ocaminhoneiros.length; i++) {
        if (ocaminhoneiros[ocaminhoneiros.keys.elementAt(i)]["nome"]
                .toString()
                .toLowerCase()
                .contains(query.toString().toLowerCase()) ==
            true) {
          nmapa[i] = ocaminhoneiros[ocaminhoneiros.keys.elementAt(i)];
        }
      }
      setState(() {
        caminhoneiros = nmapa;
      });
    } else {
      setState(() {
        caminhoneiros = ocaminhoneiros;
      });
    }
  }

  void dados() async {
    FirebaseDatabase db = FirebaseDatabase.instance;
    DatabaseReference dbref = db.ref("caminhoneiro/");
    DataSnapshot a = await dbref.get();
    Map<dynamic, dynamic> partial = a.value as Map<dynamic, dynamic>;
    ocaminhoneiros = partial;
    setState(() {
      caminhoneiros = partial;
      _count = partial.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: const Icon(
              LineAwesomeIcons.map_marked,
              color: Colors.black,
            ),
            title: const Text(
              "Acompanhamento de veículos",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.w400),
            )),
        body: Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.center,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    LineAwesomeIcons.truck_moving,
                    size: 48,
                  )
                ],
              ),
              Padding(
                  padding: const EdgeInsets.only(top: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                          "Selecione seu nome na lista para iniciar a viagem."),
                    ],
                  )),
              Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  child: Card(
                      elevation: _elevation,
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height / 16,
                        child: TextField(
                          onTap: () {
                            setState(() {
                              _elevation = 8.0;
                            });
                          },
                          onChanged: (value) {
                            search(value);
                          },
                          decoration: const InputDecoration(
                            labelText: 'Pesquise por nome',
                            suffixIcon: Icon(
                              LineAwesomeIcons.search,
                              color: Colors.black,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(8),
                          ),
                        ),
                      ))),
              Expanded(
                  child: ListView.builder(
                shrinkWrap: true,
                itemCount: caminhoneiros.length,
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
      ),
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        setState(() {
          _elevation = 0.0;
        });
      },
    );
  }
}
