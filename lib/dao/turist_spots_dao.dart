import 'package:prova_pm26s/database/database_provider.dart';
import 'package:prova_pm26s/model/turist_spots.dart';
import 'package:sqflite/sqflite.dart';

class TuristSpotsDao {
  final dbProvider = DatabaseProvider.instance;

  Future<bool> save(TuristSpots turistSpots) async {
    final database = await dbProvider.database;
    final values = turistSpots.toMap();
    if (turistSpots.id == null) {
      turistSpots.id = await database.insert(TuristSpots.TABLE_NAME, values);
      return true;
    } else {
      final recordsUpdated = await database.update(
        TuristSpots.TABLE_NAME,
        values,
        where: '${TuristSpots.FIELD_ID} = ?',
        whereArgs: [turistSpots.id],
      );
      return recordsUpdated > 0;
    }
  }

  Future<bool> remove(int id) async {
    final database = await dbProvider.database;
    final recordsUpdated = await database.delete(
      TuristSpots.TABLE_NAME,
      where: '${TuristSpots.FIELD_ID} = ?',
      whereArgs: [id],
    );
    return recordsUpdated > 0;
  }

  Future<List<TuristSpots>> getAll() async {
    //* OPTEI POR FAZER O FILTRO DE PESQUISA E A ORDENAÇÃO DIRETO NA PAGE, PELA LISTA.
    final database = await dbProvider.database;
    final records = await database.query(
      TuristSpots.TABLE_NAME,
      columns: [
        TuristSpots.FIELD_ID,
        TuristSpots.FIELD_NAME,
        TuristSpots.FIELD_CEP,
        TuristSpots.FIELD_WORKING_HOURS,
        TuristSpots.FIELD_DIFFERENTIAL,
        TuristSpots.FIELD_URL_PHOTO,
        TuristSpots.FIELD_CREATE_AT,
        TuristSpots.FIELD_LATITUDE,
        TuristSpots.FIELD_LONGITUDE,
      ],
      // where: where,
      // orderBy: orderBy,
    );
    return records.map((m) => TuristSpots.fromMap(m)).toList();
  }
}
