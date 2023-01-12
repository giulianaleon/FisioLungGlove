import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

String tablePaciente = "tablePaciente";
String idColumn = "idColumn";
String nameColumn = "nameColumn";
String sexoColumn = "sexoColumn";
String idadeColumn = "idadeColumn";
String pesoColumn = "pesoColumn";
String alturaColumn = "alturaColumn";
String cpfColumn = "cpfColumn";
String susColumn = "susColumn";
String telefoneColumn = "telefoneColumn";
String patologiaColumn = "patologiaColumn";

class Pacientes {

  static final Pacientes _instance = Pacientes.internal();

  factory Pacientes() => _instance;

  Pacientes.internal();

  Database _db;

  Future<Database> get db async {
    if (_db != null){
      return _db;
    } else {
      _db = await initDb();
      return _db;
    }
  }

  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, "pacientes.db");

    return await openDatabase(
        path, version: 1, onCreate: (Database db, int newerVersion) async {
      await db.execute(
          "CREATE TABLE $tablePaciente($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $sexoColumn TEXT, $idadeColumn TEXT, $pesoColumn TEXT, $alturaColumn TEXT, $cpfColumn TEXT, $susColumn TEXT, $telefoneColumn TEXT, $patologiaColumn TEXT)"
      );
    });
  }
}

class Paciente {

  int id;
  String nome;
  String sexo;
  String idade;
  String peso;
  String altura;
  String cpf;
  String sus;
  String telefone;
  String patologia;

  Paciente.fromMap (Map map)  {
    id = map[idColumn];
    nome = map [nameColumn];
    sexo = map [sexoColumn];
    idade = map[idadeColumn];
    cpf = map [cpfColumn];
    sus = map [susColumn];
    telefone = map[telefoneColumn];
  }

  Map toMap(){
    Map<String, dynamic> map = {
      nameColumn = nome,
      sexoColumn = sexo,
      idadeColumn = idade,
      cpfColumn = cpf,
      susColumn = sus,
      telefoneColumn = telefone,
      patologiaColumn = patologia,
    } as Map<String, dynamic>;
    if(id != null){
      map[idadeColumn] = id;
    }
    return map;
  }

}