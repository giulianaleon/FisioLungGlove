import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

String table = "table";
String idColumn = "idColumn";
String nameColumn = "nameColumn";
String emailColumn = "emailColumn";
String sexoColumn = "sexoColumn";
String idadeColumn = "idadeColumn";
String cpfColumn = "cpfColumn";
String crefitoColumn = "crefitoColumn";
String senhaColumn = "senhaColumn";

class Profissionais {

  static final Profissionais _instance = Profissionais.internal();

  factory Profissionais() => _instance;

  Profissionais.internal();

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
   final path = join(databasesPath, "profissionais.db");

   return await openDatabase(
       path, version: 1, onCreate: (Database db, int newerVersion) async {
     await db.execute(
         "CREATE TABLE $table($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $emailColumn TEXT, $sexoColumn TEXT, $idadeColumn TEXT, $cpfColumn TEXT, $crefitoColumn TEXT, $senhaColumn TEXT)"
     );
   });
 }
}

class Profissional {

  int id;
  String nome;
  String email;
  String sexo;
  String idade;
  String cpf;
  String crefito;
  dynamic senha;

  Profissional.fromMap (Map map)  {
    id = map[idColumn];
    nome = map [nameColumn];
    email = map[emailColumn];
    sexo = map [sexoColumn];
    idade = map[idadeColumn];
    cpf = map [cpfColumn];
    crefito = map [crefitoColumn];
    senha = map[senhaColumn];
  }

  Map toMap(){
    Map<String, dynamic> map = {
      nameColumn = nome,
      emailColumn = email,
      sexoColumn = sexo,
      idadeColumn = idade,
      cpfColumn = cpf,
      crefitoColumn = crefito,
      senhaColumn = senha,
    } as Map<String, dynamic>;
    if(id != null){
      map[idadeColumn] = id;
    }
    return map;
  }

}