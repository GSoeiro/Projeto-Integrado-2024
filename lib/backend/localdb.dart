import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';

class BaseDeDados {
  static const nomeBD = "localdb.db";
  final int versao = 2;
  static Database? _basededados;
  static const String url = 'https://pint-backend-8vxk.onrender.com/';


  String formatDateTime(String? dateTimeString) {
    if (dateTimeString == null) return '';
    DateTime dateTime = DateTime.parse(dateTimeString);
    DateFormat dateFormat = DateFormat('dd-MM-yyyy');
    return dateFormat.format(dateTime);
  }

  Future<Database> get basededados async {
    if (_basededados != null) return _basededados!;
    _basededados = await _initDatabase();
    return _basededados!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), nomeBD);

    // Apaga a db e depois abre novamente (para teste, pelo menos comentar a linha quando for para dar flutter build apk --release)
    await deleteDatabase(path);
    return await openDatabase(
      path,
      version: versao,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> initDB() async {
    await basededados;
  }

  Future _onCreate(Database db, int version) async {
    await _createTables(db);
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Drop all tables
    await db.execute('DROP TABLE IF EXISTS COLABORADORLOCAL');
    await db.execute('DROP TABLE IF EXISTS CIDADE');
    await db.execute('DROP TABLE IF EXISTS CATEGORIA');
    await db.execute('DROP TABLE IF EXISTS SUBCATEGORIA');
    await db.execute('DROP TABLE IF EXISTS POST');
    await db.execute('DROP TABLE IF EXISTS QUESTIONARIO');
    await db.execute('DROP TABLE IF EXISTS OPCAO');
    await db.execute('DROP TABLE IF EXISTS VOTO');
    await db.execute('DROP TABLE IF EXISTS COMENTARIO');

    // Recreate all tables
    await _createTables(db);
  }

  Future _createTables(Database db) async {
    await db.execute('DROP TABLE IF EXISTS POST');
    await db.execute('''
    CREATE TABLE COLABORADORLOCAL (
      IDCOLABORADOR INTEGER PRIMARY KEY AUTOINCREMENT,
      EMAIL TEXT NOT NULL,
      NOME TEXT NOT NULL,
      TELEMOVEL TEXT NULL,
      CIDADE INTEGER NOT NULL,
      NOMECIDADE TEXT NULL,
      DATANASCIMENTO DATETIME NULL,
      DATAREGISTO DATETIME NULL,
      ULTIMOLOGIN DATETIME NULL,
      ATIVO INTEGER NOT NULL
    )
  ''');

    await db.execute('''
    CREATE TABLE CIDADE (
      IDCIDADE INTEGER PRIMARY KEY AUTOINCREMENT,
      NOME TEXT NULL
    )
  ''');

    await db.execute('''
    CREATE TABLE CATEGORIA (
      IDCATEGORIA INTEGER PRIMARY KEY AUTOINCREMENT,
      NOME TEXT NULL,
      DESCRICAO TEXT NULL
    )
  ''');

    await db.execute('''
    CREATE TABLE SUBCATEGORIA (
      IDSUBCATEGORIA INTEGER PRIMARY KEY AUTOINCREMENT,
      NOME TEXT NULL,
      DESCRICAO TEXT NULL,
      IDCATEGORIA INTEGER NOT NULL,
      FOREIGN KEY(IDCATEGORIA) REFERENCES CATEGORIA(IDCATEGORIA)
    )
  ''');

    await db.execute('''
    CREATE TABLE POST (
      IDPUBLICACAO INTEGER PRIMARY KEY AUTOINCREMENT,
      CIDADE INTEGER NULL,
      NOMECIDADE TEXT NULL,
      APROVACAO INTEGER NULL,
      COLABORADOR INTEGER NULL,
      NOMECOLABORADOR TEXT NULL,
      CATEGORIA INTEGER NULL,
      NOMECATEGORIA TEXT NULL,
      SUBCATEGORIA INTEGER NULL,
      NOMESUBCATEGORIA TEXT NULL,
      ESPACO INTEGER NULL,
      EVENTO INTEGER NULL,
      DATAPUBLICACAO DATETIME NULL,
      DATAULTIMAATIVIDADE DATETIME NULL,
      TITULO TEXT NULL,
      TEXTO TEXT NULL,
      RATING INT NULL,
      IMAGEM TEXT NULL,
      IDQUESTIONARIO INTEGER NULL,
      DATAEVENTO TEXT NULL,
      COORDENADAS TEXT NULL,
      WEBSITE TEXT NULL,
      VIEWS INTEGER NULL
    )
  ''');

    await db.execute('''
    CREATE TABLE QUESTIONARIO (
      IDQUESTIONARIO INTEGER PRIMARY KEY AUTOINCREMENT,
      NOME TEXT NULL
    )
  ''');

    await db.execute('''
    CREATE TABLE OPCAO (
      IDOPCAO INTEGER PRIMARY KEY AUTOINCREMENT,
      NOME TEXT NOT NULL,
      TIPOOPCAO INTEGER NOT NULL,
      QUESTIONARIO INTEGER NOT NULL,
      FOREIGN KEY(QUESTIONARIO) REFERENCES QUESTIONARIO(IDQUESTIONARIO)
    )
  ''');

    await db.execute('''
    CREATE TABLE VOTO (
      IDVOTO INTEGER PRIMARY KEY AUTOINCREMENT,
      IDCOLABORADOR INTEGER NULL,
      DATAVOTO DATETIME NULL,
      IDOPCOESESCOLHA INTEGER NOT NULL,
      FOREIGN KEY(IDCOLABORADOR) REFERENCES COLABORADORLOCAL(IDCOLABORADOR),
      FOREIGN KEY(IDOPCOESESCOLHA) REFERENCES OPCOESESCOLHA(IDOPCAO)
    )
  ''');

    await db.execute('''
    CREATE TABLE COMENTARIO (
      IDPOST INTEGER NOT NULL,
      APROVADO INTEGER NULL,
      IDCOLABORADOR INTEGER NULL,
      NOMECOLABORADOR TEXT NULL,
      DATACOMENTARIO DATETIME NULL,
      AVALIACAO REAL NULL,
      TEXTO TEXT NULL,
      FOREIGN KEY(IDPOST) REFERENCES POST(IDPUBLICACAO),
      FOREIGN KEY(IDCOLABORADOR) REFERENCES COLABORADORLOCAL(IDCOLABORADOR)
    )
  ''');

    await db.execute('''
    CREATE TABLE ESPAÇO (
      IDESPACO INTEGER NOT NULL,
      COORDENADAS TEXT NULL,
      WEBSITE TEXT NULL
    )
  ''');

    await db.execute('''
    CREATE TABLE EVENTO (
      IDEVENTO INTEGER NOT NULL,
      IDQUESTIONARIO INTEGER NOT NULL,
      DATAEVENTO TEXT NULL,
      ESTADO INTEGER NOT NULL,
      PRECO REAL NULL
    )
  ''');
  }

  Future<void> resetDatabase() async {
    String path = join(await getDatabasesPath(), nomeBD);

    // Apaga a db
    await deleteDatabase(path);

    // Restart db, ensure that basededados is ready before proceeding.
    _basededados = await _initDatabase();
  }

  Future<int> insertColaboradorLocal(Map<String, dynamic> colaborador) async {
    try {
      Database db = await basededados;

      return await db.insert('COLABORADORLOCAL', colaborador);
    } catch (e) {
      print("Error inserir colaborador: $e");
      return -1;
    }
  }

  Future<int> insertEspaco(Map<String, dynamic> space) async {
    try {
      Database db = await basededados;

      return await db.insert('ESPAÇO', space);
    } catch (e) {
      print("Erro ao inserir os espaços: $e");
      return -1;
    }
  }

  Future<List<Map<String, dynamic>>> mostrarEspaco() async {
    try {
      Database db = await basededados;
      List<Map<String, dynamic>> espaco =
          await db.rawQuery('SELECT * FROM ESPACO');

      return espaco;
    } catch (e) {
      print('Erro ao mostrar os espaços: $e');
      return [];
    }
  }

  Future<int> insertEvento(Map<String, dynamic> event) async {
    try {
      Database db = await basededados;
      if (event['DATAEVENTO'] is DateTime) {
        event['DATAEVENTO'] = formatDateTime(event['DATAEVENTO']);
      }

      return await db.insert('EVENTO', event);
    } catch (e) {
      return -1;
    }
  }

  Future<List<Map<String, dynamic>>> mostraEvento() async {
    try {
      Database db = await basededados;
      List<Map<String, dynamic>> evento =
          await db.rawQuery('SELECT * FROM EVENTO');
      ;
      return evento;
    } catch (e) {
      return [];
    }
  }

  Future<void> apagarVotos() async {
    try {
      Database db = await basededados;
      await db.rawQuery('DELETE FROM VOTO');
    } catch (e) {}
  }

  Future<int> insertVoto(Map<String, dynamic> voto) async {
    try {
      Database db = await basededados;
      await apagarVotos();
      return await db.insert('VOTO', voto);
    } catch (e) {
      print("Error inserir voto: $e");
      return -1;
    }
  }

  Future<List<Map<String, dynamic>>> mostrarVotos() async {
    try {
      Database db = await basededados;
      List<Map<String, dynamic>> votos =
          await db.rawQuery('SELECT * FROM VOTO');

      return votos;
    } catch (e) {
      print('Erro ao mostrar os votos: $e');
      return [];
    }
  }

  Future<void> apagarOpcoesEscolha() async {
    try {
      Database db = await basededados;
      await db.rawQuery('DELETE FROM OPCAO');
    } catch (e) {}
  }

  Future<int> insertOpcoesEscolha(Map<String, dynamic> opcao) async {
    try {
      Database db = await basededados;

      await apagarOpcoesEscolha();

      return await db.insert('OPCAO', opcao);
    } catch (e) {
      print("Error inserir OPCAO: $e");
      return -1;
    }
  }

  Future<List<Map<String, dynamic>>> mostrarOpcoesEscolha() async {
    try {
      Database db = await basededados;
      List<Map<String, dynamic>> opcoes =
          await db.rawQuery('SELECT * FROM OPCAO');

      return opcoes;
    } catch (e) {
      print('Erro ao mostrar as opcoes: $e');
      return [];
    }
  }

  Future<int> insertCidade(Map<String, dynamic> cidade) async {
    try {
      Database db = await basededados;

      return await db.insert('CIDADE', cidade);
    } catch (e) {
      print("Error inserir cidade: $e");
      return -1;
    }
  }

  Future<List<Map<String, dynamic>>> mostrarCidades() async {
    try {
      Database db = await basededados;
      List<Map<String, dynamic>> cidades =
          await db.rawQuery('SELECT * FROM CIDADE');

      return cidades;
    } catch (e) {
      print('Erro ao mostrar as cidades: $e');
      return [];
    }
  }

  Future<String?> getCategoryName(int categoriaId) async {
    try {
      final db = await basededados;
      var result = await db.query(
        'CATEGORIA',
        where: 'IDCATEGORIA = ?',
        whereArgs: [categoriaId],
      );
      if (result.isNotEmpty) {
        return result.first['NOME'] as String?;
      }
    } catch (e) {
      print("Erro a ir buscar o nome da categoria: $e");
    }
    return null;
  }

  Future<String?> getSubCategoryName(int subCategoriaId) async {
    try {
      final db = await basededados;
      var result = await db.query(
        'SUBCATEGORIA',
        where: 'IDSUBCATEGORIA = ?',
        whereArgs: [subCategoriaId],
      );
      if (result.isNotEmpty) {
        return result.first['NOME'] as String?;
      }
    } catch (e) {
      print("Erro a ir buscar o nome da subcategoria: $e");
    }
    return null;
  }

  Future<int> insertCategoria(Map<String, dynamic> categoria) async {
    try {
      Database db = await basededados;
      return await db.insert('CATEGORIA', categoria);
    } catch (e) {
      print("Error inserir categoria: $e");
      return -1;
    }
  }

  Future<List<Map<String, dynamic>>> mostrarCategorias() async {
    try {
      Database db = await basededados;
      List<Map<String, dynamic>> categorias =
          await db.rawQuery('SELECT * FROM CATEGORIA');
      return categorias;
    } catch (e) {
      print('Erro ao mostrar as categorias: $e');
      return [];
    }
  }

  Future<int> insertSubcategoria(Map<String, dynamic> subcategoria) async {
    Database db = await basededados;

    return await db.insert('SUBCATEGORIA', subcategoria);
  }

  Future<List<Map<String, dynamic>>> mostrarSubCategorias(
      int IDCategoria) async {
    try {
      Database db = await basededados;

      // Modify the query to filter by the provided category ID
      List<Map<String, dynamic>> subcategorias = await db.rawQuery(
          'SELECT * FROM SUBCATEGORIA WHERE IDCATEGORIA = ?',
          [IDCategoria] // "Passa"
          );
      return subcategorias;
    } catch (e) {
      print('Erro ao mostrar as subcategorias: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> mostrarSubCategoriass() async {
    try {
      Database db = await basededados;

      List<Map<String, dynamic>> subcategorias =
          await db.rawQuery('SELECT * FROM SUBCATEGORIA');
      return subcategorias;
    } catch (e) {
      print('Erro ao mostrar as subcategorias: $e');
      return [];
    }
  }

  Future<void> apagarPosts() async {
    try {
      Database db = await basededados;
      await db.rawQuery('DELETE FROM POST');
    } catch (e) {}
  }

  Future<int> insertPost(Map<String, dynamic> post) async {
    Database db = await basededados;

    if (post['DATAPUBLICACAO'] is DateTime) {
      post['DATAPUBLICACAO'] = formatDateTime(post['DATAPUBLICACAO']);
    }
    if (post['DATAULTIMAATIVIDADE'] is DateTime) {
      post['DATAULTIMAATIVIDADE'] = formatDateTime(post['DATAULTIMAATIVIDADE']);
    }
    if (post['DATAEVENTO'] is DateTime) {
      post['DATAEVENTO'] = formatDateTime(post['DATAEVENTO']);
    }
    return await db.insert('POST', post);
  }

  Future<List<Map<String, dynamic>>> mostrarPosts(int idcidade) async {
    try {
      Database db = await basededados;
      List<Map<String, dynamic>> posts =
          await db.rawQuery('SELECT * FROM POST');

      for(var post in posts){
         print(posts);
      }
      return posts;
    } catch (e) {
      print('Erro ao mostrar os posts: $e');
      return [];
    }
  }

  Future<void> apagarComentarios() async {
    try {
      Database db = await basededados;
      await db.rawQuery('DELETE FROM COMENTARIO');
    } catch (e) {}
  }

  Future<int> insertComentario(Map<String, dynamic> comentario) async {
    Database db = await basededados;

    if (comentario['DATACOMENTARIO'] is DateTime) {
      comentario['DATACOMENTARIO'] =
          formatDateTime(comentario['DATACOMENTARIO']);
    }

    return await db.insert('COMENTARIO', comentario);
  }

  Future<List<Map<String, dynamic>>> mostrarComentarios() async {
    try {
      Database db = await basededados;

      List<Map<String, dynamic>> comentarios =
          await db.rawQuery('SELECT * FROM COMENTARIO');

      return comentarios;
    } catch (e) {
      print('Erro ao mostrar os comentários: $e');
      return [];
    }
  }
}
