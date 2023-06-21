import 'package:flutter/material.dart';
import 'package:gerenciador_pontos_turisticos/pages/filtro_page.dart';
import 'package:gerenciador_pontos_turisticos/pages/lista_pontos_turisticos_page.dart';

void main() {
  runApp(const AppPontosTuristicos());
}

class AppPontosTuristicos extends StatelessWidget {
  const AppPontosTuristicos({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Administrador de Pontos Turísticos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(

        primarySwatch: Colors.cyan,
      ),
      home: ListaPontosTuristicosPage(),
      routes: {
        FiltroPage.routeName: (BuildContext context) => FiltroPage(),
      },
    );
  }
}
