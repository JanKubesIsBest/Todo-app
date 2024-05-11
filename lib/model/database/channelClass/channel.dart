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

  Channel(this.id, this.name, this.isCustom, this.hour, this.minute);


  /// Used, if the channel was not yet created. 
  /// Creates 2 notifications ahead
  Future<void> createItself() async {
    // Add to the database
    final Database db = await openOurDatabase();
    
    final DateTime now = DateTime.now();
    DateTime showNotif = DateTime(now.year, now.month, now.day, hour, minute);

    // Check if the date is not in the future
    if (now.difference(showNotif).inSeconds < 0) {
      showNotif.add(const Duration(days: 1));
    }

    insertChannel(db, this, showNotif);

    // Make a notifications for next to days

    for (int x = 1; x < 3; x++) {
      insertNotification(db, showNotif.add(Duration(days: x * 1)), this);
    }
  }
}