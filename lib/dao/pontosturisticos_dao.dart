import '../database/database_provider.dart';
import '../model/pontos_turisticos.dart';

class PontosTuristicosDao {
  final databaseProvider = DatabaseProvider.instance;

  Future<bool> salvar(PontosTuristicos pontosTuristicos) async {
    final database = await databaseProvider.database;
    final valores = pontosTuristicos.toMap();
    if (pontosTuristicos.id == 0) {
      pontosTuristicos.id = await database.insert(PontosTuristicos.NOME_TABELA, valores);
      return true;
    } else {
      final registrosAtualizados = await database.update(
        PontosTuristicos.NOME_TABELA,
        valores,
        where: '${PontosTuristicos.CAMPO_ID} = ?',
        whereArgs: [pontosTuristicos.id],
      );
      return registrosAtualizados > 0;
    }
  }

  Future<bool> remover(int id) async {
    final database = await databaseProvider.database;
    final registrosAtualizados = await database.delete(
      PontosTuristicos.NOME_TABELA,
      where: '${PontosTuristicos.CAMPO_ID} = ?',
      whereArgs: [id],
    );
    return registrosAtualizados > 0;
  }

  Future<List<PontosTuristicos>> listar({
    String filtro = '',
    String campoOrdenacao = PontosTuristicos.CAMPO_ID,
    bool usarOrdemDecrescente = false,
  }) async {
    String? where;
    if (filtro.isNotEmpty) {
      where = "UPPER(${PontosTuristicos.CAMPO_DESCRICAO}) LIKE '${filtro.toUpperCase()}%'";
    }
    var orderBy = campoOrdenacao;
    if (usarOrdemDecrescente) {
      orderBy += ' DESC';
    }
    final database = await databaseProvider.database;
    final resultado = await database.query(
      PontosTuristicos.NOME_TABELA,
      columns: [
        PontosTuristicos.CAMPO_ID,
        PontosTuristicos.CAMPO_DESCRICAO,
        PontosTuristicos.CAMPO_NOME,
        PontosTuristicos.CAMPO_DIFERENCIAIS,
        PontosTuristicos.CAMPO_INCLUSAO,
        PontosTuristicos.CAMPO_LATITUDE,
        PontosTuristicos.CAMPO_LONGITUDE,
        PontosTuristicos.CAMPO_CEP,
      ],
      where: where,
      orderBy: orderBy,
    );
    return resultado.map((m) => PontosTuristicos.fromMap(m)).toList();
  }
}
