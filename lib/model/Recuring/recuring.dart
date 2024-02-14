import 'package:unfuckyourlife/model/database/retrieve.dart';

class RecuringDurationWithName {
  // Id is assigned automatically
  final String name;
  final Duration durationOfRecuring;

  // Id is not required, bcs we don't even use it when building components.
  const RecuringDurationWithName({
    required this.durationOfRecuring, 
    required this.name, 

  });

}