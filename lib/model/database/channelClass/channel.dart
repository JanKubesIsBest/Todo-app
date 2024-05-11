import 'package:sqflite/sqflite.dart';
import 'package:unfuckyourlife/model/database/insert_and_create.dart';
import 'package:unfuckyourlife/model/database/open_databases.dart';

/// Deadline is more like when the notificaton will be fired
class Channel {
  final int id;
  final String name;
  final int hour;
  final int minute;
  final bool isCustom;

  Channel(this.id, this.name, this.deadline, this.isCustom);

  Future<void> createItself() async {
    // Add to the database
    final Database db = await openOurDatabase();
    
    insertChannel(db, this, date);
    // Make a notifications for next to days
  }
}