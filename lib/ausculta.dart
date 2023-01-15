import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:oscilloscope/oscilloscope.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:wave_progress_bars/wave_progress_bars.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({Key key, this.device}) : super(key: key);

  final BluetoothDevice device;

  @override
  _Ausculta createState() => _Ausculta();
}

class _Ausculta extends State<HomePage> {


  final String SERVICE_UUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  final String CHARACTERISTIC_UUID = "beb5483e-36e1-4688-b7f5-ea07361b26a8";
  bool isReady;
  bool ausculta;
  Stream<List<int>> stream;
  List<double> traceDust = [];

  @override
  void initState() {
    super.initState();
    isReady = false;
    ausculta = false;
    connectToDevice();
  }

  connectToDevice() async {
    if (widget.device == null) {
      _Pop();
      return;
    }

    new Timer(const Duration(seconds: 15), () {
      if (!isReady) {
        disconnectFromDevice();
        _Pop();
      }
    });

    await widget.device.connect();
    discoverServices();
  }

  disconnectFromDevice() {
    if (widget.device == null) {
      _Pop();
      return;
    }

    widget.device.disconnect();
  }

  discoverServices() async {
    if (widget.device == null) {
      _Pop();
      return;
    }

    List<BluetoothService> services = await widget.device.discoverServices();
    services.forEach((service) {
      if (service.uuid.toString() == SERVICE_UUID) {
        service.characteristics.forEach((characteristic) {
          if (characteristic.uuid.toString() == CHARACTERISTIC_UUID) {
            characteristic.setNotifyValue(!characteristic.isNotifying);
            stream = characteristic.value;

            setState(() {
              isReady = true;
            });
          }
        });
      }
    });

    if (!isReady) {
      _Pop();
    }
  }

  postData() async{
    try{   //200 - sucesso
      var response = await http.post(Uri.parse("https://jsonplaceholder.typicode.com/posts"), body:{
        "vetor_vibração": valoresSensor,
        "vibração_media": 12,          //alterar
        "tempo_total": 360             //alterar
      });
      print (response.body);
    }catch (e){
      print(e);
    }
  }

  Future<bool> _onWillPop() {
    return showDialog(
        context: context,
        builder: (context) =>
        AlertDialog(
          title: Text('Você tem certeza?'),
          content: Text('Desconectar o bluetooth e voltar?'),
          actions: <Widget>[
            FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('Não')),
            FlatButton(
                onPressed: () {
                  disconnectFromDevice();
                  Navigator.of(context).pop(true);
                },
                child: new Text('Sim')),
          ],
        ) ??
            false);
  }

  _Pop() {
    Navigator.of(context).pop(true);
  }

  String _dataParser(List<int> dataFromDevice) {
    return utf8.decode(dataFromDevice);
  }

  List<String> valoresSensor = [];
  List<double> valoresSensorDouble = [];

  //Juntando o código cadastrar sessão com a ausculta

  var carregando = false; //Para quando estiver carregando algo dentro do projeto
  var dados;
  var nome; //Unica variavel que quero buscar do banco
  List item = List();
  String nomeSelecionado;

  String _selectedLocation;

  var selectedCurrency, selectedType;

  // void registrar() async {
  //
  //   // FirebaseFirestore.instance.collection('sessao').add({
  //   //   'frequencia': valoresSensor,
  //   //   'data' : Timestamp.now(),
  //   // });
  //
  //   Fluttertoast.showToast(
  //       msg: "Registrado com sucesso!",
  //       toastLength: Toast.LENGTH_SHORT,
  //       gravity: ToastGravity.CENTER,
  //       timeInSecForIosWeb: 1,
  //       backgroundColor: Colors.lightGreen,
  //       textColor: Colors.white,
  //       fontSize: 16.0);
  //
  //   // Navigator.push(
  //   //   context,
  //   //   MaterialPageRoute(builder: (context) => Menu()),
  //   // );
  // }

  @override
  Widget build(BuildContext context) {

    MediaQueryData queryData = MediaQuery.of(context);

    Oscilloscope oscilloscope = Oscilloscope(
      showYAxis: true,
      padding: 0.0,
      backgroundColor: Colors.black,
      traceColor: Colors.white,
      yAxisMax: 10000.0,
      yAxisMin: 0.0,
      dataSet: traceDust,
    );

    WaveProgressBar wave = WaveProgressBar(
      listOfHeights: traceDust,
      width: queryData.size.width,
    );

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Vibração Torácica'),
          backgroundColor: const Color.fromRGBO(198, 204, 160, 71),
        ),
        body: Container(
            child: !isReady
                ? const Center(
              child: Text(
                "Aguarde...",
                style: TextStyle(fontSize: 24, color: Colors.red),
              ),
            )
                : Container(
              child: !ausculta
                  ? SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.9,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image:
                      AssetImage('assets/images/fundonovo.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
                      Card(
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            children: [
                              const SizedBox(height: 8),

                              const SizedBox(height: 20),

                              Row(
                                children: [
                                  const SizedBox(width: 100),
                                  TextButton(
                                    onPressed: () {
                                      setState((){
                                        ausculta = true;
                                      });
                                    },
                                    style: TextButton.styleFrom(
                                      backgroundColor:
                                      const Color.fromRGBO(
                                          198, 204, 160, 71),
                                      padding:
                                      const EdgeInsets.only(
                                          left: 30, right: 30),
                                      primary: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(
                                            15),
                                      ),
                                    ),
                                    child: const Text(
                                      'Iniciar',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  : Container(
                child: StreamBuilder<List<int>>(
                  stream: stream,
                  builder: (BuildContext context,
                      AsyncSnapshot<List<int>> snapshot) {
                    if (snapshot.hasError)
                      return Text('Error: ${snapshot.error}');

                    if (snapshot.connectionState ==
                        ConnectionState.active) {
                      var currentValue = _dataParser(snapshot.data);
                      print(currentValue);
                      traceDust
                          .add(double.tryParse(currentValue) ?? 0);
                      valoresSensor.add(currentValue);
                      valoresSensorDouble.add(double.parse(currentValue));

                      return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                flex: 1,
                                child: Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text('Dado Sonoro:',
                                          style:
                                          TextStyle(fontSize: 14)),
                                      Text('${currentValue}',
                                          style: TextStyle(
                                              fontWeight:
                                              FontWeight.bold,
                                              fontSize: 24)),
                                    ]),
                              ),
                              Expanded(
                                flex: 1,
                                child: oscilloscope,
                              ),

                              Expanded(child: Column(
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      setState((){
                                        ausculta = false;
                                        // registrar();
                                        postData();
                                      });
                                    },
                                    style: TextButton.styleFrom(
                                      backgroundColor:
                                      const Color.fromRGBO(
                                          198, 204, 160, 71),
                                      padding:
                                      const EdgeInsets.only(
                                          left: 30, right: 30),
                                      primary: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(
                                            15),
                                      ),
                                    ),
                                    child: const Text(
                                      'FINALIZAR SESSÃO',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),

                                ],

                              ),),
                            ],
                          ));
                    } else {
                      return Text('Verifique a conexão!');
                    }
                  },
                ),
              ),
            )),
      ),
    );
  }
}
