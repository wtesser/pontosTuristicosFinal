import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maps_launcher/maps_launcher.dart';
import '../model/pontos_turisticos.dart';
import 'mapa_interno_page.dart';

class DetalhesPontosPage extends StatefulWidget {
  final PontosTuristicos pontos;

  const DetalhesPontosPage({Key? key, required this.pontos}) : super(key: key);

  @override
  _DetalhesPontosPageState createState() => _DetalhesPontosPageState();
}

class _DetalhesPontosPageState extends State<DetalhesPontosPage> {
  Position? _localizacaoAtual;
  var _distancia;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes'),
      ),
      body: _criarBody(),
    );
  }

  Widget _criarBody() => Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              children: [
                Campo(descricao: 'Código: '),
                Valor(valor: '${widget.pontos.id}'),
              ],
            ),
            Row(
              children: [
                Campo(descricao: 'Nome: '),
                Valor(valor: widget.pontos.nome),
              ],
            ),
            Row(
              children: [
                Campo(descricao: 'Descrição: '),
                Valor(valor: widget.pontos.descricao),
              ],
            ),
            Row(
              children: [
                Campo(descricao: 'Cep: '),
                Valor(valor: widget.pontos.cep),
              ],
            ),
            Row(
              children: [
                Campo(descricao: 'Data de Inclusão: '),
                Valor(valor: widget.pontos.prazoFormatado),
              ],
            ),
            Row(
              children: [
                Campo(descricao: 'Latitude: '),
                Valor(valor: widget.pontos.latitude),
              ],
            ),
            Row(
              children: [
                Campo(descricao: 'Longitude: '),
                Valor(valor: widget.pontos.longitude),
              ],
            ),
            Row(
              children: [
                Campo(descricao: 'Diferenciais: '),
                Valor(valor: widget.pontos.diferenciais),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(
                    Icons.map,
                    color: Colors.white,
                    size: 20,
                  ),
                  label: const Text('Mapa interno'),
                  onPressed: _abrirCoordenadasMapaInterno,
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: const Icon(
                    Icons.map_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                  label: const Text('Mapa externo'),
                  onPressed: _abrirCoordenadasMapaExterno,
                )
              ],
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(
                        Icons.route,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: const Text('Calculo da distância'),
                      onPressed: _calcularDistancia,
                    )
                  ],
                ),

                Container(
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(
                        8),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      ' ${_localizacaoAtual == null ? "--" : _distancia}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),

      );

  void _calcularDistancia() {
    _obterLocalizacaoAtual();
  }

  void _obterLocalizacaoAtual() async {
    bool servicoHabilitado = await _servicoHabilitado();
    if (!servicoHabilitado) {
      return;
    }
    bool permissoesPermitidas = await _verificaPermissoes();
    if (!permissoesPermitidas) {
      return;
    }
    Position posicao = await Geolocator.getCurrentPosition();
    setState(() {
      _localizacaoAtual = posicao;
      _distancia = Geolocator.distanceBetween(
          posicao!.latitude,
          posicao!.longitude,
          double.parse(widget.pontos.latitude),
          double.parse(widget.pontos.longitude));
      if (_distancia > 1000) {
        var _distanciaKM = _distancia / 1000;
        _distancia = "${double.parse((_distanciaKM).toStringAsFixed(2))}KM";
      } else {
        _distancia = "${_distancia.toStringAsFixed(2)}M";
      }
    });
  }

  Future<bool> _servicoHabilitado() async {
    bool servicoHabilitado = await Geolocator.isLocationServiceEnabled();
    if (!servicoHabilitado) {
      await _mostrarMensagemDialog(
          'Para utilizar este recurso, é necessário acessar as configurações e permitir a utilização do serviço de localização.');
      Geolocator.openAppSettings();
      return false;
    }
    return true;
  }

  Future<bool> _verificaPermissoes() async {
    LocationPermission permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
      if (permissao == LocationPermission.denied) {
        await _mostrarMensagemDialog('Falta de permissão');
        return false;
      }
    }
    if (permissao == LocationPermission.deniedForever) {
      await _mostrarMensagemDialog(
          'Para utilizar este recurso, é necessário acessar as configurações e permitir a utilização do serviço de localização.');
      Geolocator.openAppSettings();
      return false;
    }
    return true;
  }

  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensagem)));
  }

  Future<void> _mostrarMensagemDialog(String mensagem) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Atenção'),
          content: Text(mensagem),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _abrirCoordenadasMapaInterno() {
    if (widget.pontos.longitude == '' || widget.pontos.latitude == '') {
      return;
    }
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => MapaInternoPage(
                latitude: double.parse(widget.pontos.latitude),
                longitude: double.parse(widget.pontos.longitude))));
  }

  void _abrirCoordenadasMapaExterno() {
    if (widget.pontos.longitude == '' || widget.pontos.latitude == '') {
      return;
    }
    MapsLauncher.launchCoordinates(double.parse(widget.pontos.latitude),
        double.parse(widget.pontos.longitude));
  }
}

class Campo extends StatelessWidget {
  final String descricao;

  const Campo({Key? key, required this.descricao}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 10, top: 5, bottom: 5),
      child: Text(descricao, style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}

class Valor extends StatelessWidget {
  final String valor;

  const Valor({Key? key, required this.valor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 4,
      child: Text(valor),
    );
  }
}
