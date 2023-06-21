


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';


import '../model/cep_model.dart';
import '../services/cep_service.dart';

class CepFragment extends StatefulWidget{
  static const title = 'Consultar Cep';

  @override
  State<StatefulWidget> createState() => _CepFragmentState();
}

class _CepFragmentState extends State<CepFragment>{
  final _service = CepService();
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _cepFormater = MaskTextInputFormatter(
    mask: '#####-###',
    filter: {'#' : RegExp(r'[0-9]')}
  );
  var _loading = false;
  Cep? _cep;

  Widget build(BuildContext context){
    return Padding(
        padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Form(
            key: _formKey,
              child: TextFormField(
                controller: _controller,
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
                  if(value == null || value.isEmpty ||
                      !_cepFormater.isFill()){
                    return 'Informe um cep válido!';
                  }
                  return null;
                },
              ),
          ),
          Container(height: 10),
          ..._buildWidgets(),
        ],
      ),
    );
  }

  Future<void> _findCep() async {
    if(_formKey.currentState == null || !_formKey.currentState!.validate()){
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
          content: Text('Ocorreu um erro, tente novamente! \n'
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