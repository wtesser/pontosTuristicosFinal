import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gerenciador_pontos_turisticos/model/cep_model.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../model/pontos_turisticos.dart';
import '../services/cep_service.dart';

class ConteudoFormDialog extends StatefulWidget{
  final PontosTuristicos? pontoAtual;



  ConteudoFormDialog({Key? key, this.pontoAtual}) : super (key: key);

  @override
  ConteudoFormDialogState createState() => ConteudoFormDialogState();
}
class ConteudoFormDialogState extends State<ConteudoFormDialog>{
  final _service = CepService();
  final _cepFormater = MaskTextInputFormatter(
      mask: '#####-###',
      filter: {'#' : RegExp(r'[0-9]')}
  );
  var _loading = false;
  Cep? _cep;
  final formKey = GlobalKey<FormState>();
  final descricaoController = TextEditingController();
  final nomeController = TextEditingController();
  final inclusaoController = TextEditingController();
  final diferenciaisController = TextEditingController();
  final cepController = TextEditingController();
  final _dateFormat = DateFormat('dd/MM/yyyy');
  Position? localizacaoAtual;

  @override
  void initState(){
    super.initState();
    if(widget.pontoAtual != null){
      nomeController.text = widget.pontoAtual!.nome;
      descricaoController.text = widget.pontoAtual!.descricao;
      diferenciaisController.text = widget.pontoAtual!.diferenciais;
      cepController.text = widget.pontoAtual!.cep;
      inclusaoController.text = widget.pontoAtual!.prazoFormatado;
    }
  }

  Widget build(BuildContext context){
    return Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: nomeController,
              decoration: const InputDecoration(labelText: 'Nome'),
              validator: (String? valor) {
                if (valor == null || valor.isEmpty) {
                  return 'Nome';
                }
                return null;
              },
            ),
            TextFormField(
              controller: descricaoController,
              decoration: const InputDecoration(labelText: 'Descrição'),
              validator: (String? valor) {
                if (valor == null || valor.isEmpty) {
                  return 'Descrição';
                }
                return null;
              },
            ),
            TextFormField(
              controller: diferenciaisController,
              decoration: const InputDecoration(labelText: 'Diferenciais'),
              validator: (String? valor) {
                if (valor == null || valor.isEmpty) {
                  return 'Diferenciais';
                }
                return null;
              },
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: TextFormField(
                controller: cepController,
                decoration: InputDecoration(
                  labelText: 'CEP',
                  suffixIcon: _loading ? const Padding(
                    padding: EdgeInsets.all(10),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ) : IconButton(
                    onPressed: _findCep,
                    icon: const Icon(Icons.search),
                  ),
                ),
                inputFormatters: [_cepFormater],
                validator: (String? value){
                  if(value == null || value.isEmpty){
                    return 'Informe um cep válido!';
                  }
                  return null;
                },
              ),
            ),
            Container(height: 10),
            ..._buildWidgets(),
            Divider(color: Colors.white,),
            Row(
              children: [
                Icon(Icons.calendar_today),
                Text("Data: ${inclusaoController.text.isEmpty ? _dateFormat.format(DateTime.now()) : inclusaoController.text}")
              ],
            ),
          ],
        )
    );
  }

  bool dadosValidados() => formKey.currentState?.validate() == true;


  PontosTuristicos get novoPonto => PontosTuristicos(
      id: widget.pontoAtual?.id ?? 0,
      nome: nomeController.text,
      descricao: descricaoController.text,
      diferenciais: diferenciaisController.text,
      dataInclusao: DateTime.now(),
      latitude: '',
      longitude: '',
      cep: cepController.text,
  );
  Future<void> _findCep() async {
    if(formKey.currentState == null || !formKey.currentState!.validate()){
      return;
    }
    setState(() {
      _loading = true;
    });
    try{
      _cep = await _service.findCepAsObject(_cepFormater.getUnmaskedText());
    }catch(e){
      debugPrint(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Ocorreu um erro, tente noavamente! \n'
              'ERRO: ${e.toString()}')
      ));
    }
    setState(() {
      _loading = false;
    });
  }
  List<Widget> _buildWidgets(){
    final List<Widget> widgets = [];
    if(_cep != null){
      final map = _cep!.toJson();
      for(final key in map.keys){
        widgets.add(Text('$key:  ${map[key]}'));

      }
    }
    return widgets;
  }
}