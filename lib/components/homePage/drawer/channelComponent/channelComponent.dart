import 'package:flutter/material.dart';
import 'package:unfuckyourlife/model/database/channelClass/channel.dart';
import 'package:unfuckyourlife/model/database/delete.dart';
import 'package:unfuckyourlife/model/database/retrieve.dart';
import 'package:unfuckyourlife/model/database/update.dart';
import 'package:unfuckyourlife/model/notification/notifications.dart';

class TodoButton extends StatefulWidget {
  final Channel channel;
  final Function updateState;

  const TodoButton({super.key, required this.channel, required this.updateState});

  @override
  State<StatefulWidget> createState() => _TodoButtonState();
}

class _TodoButtonState extends State<TodoButton> {
  final newChannelNameController = TextEditingController();
  final newChannelDescriptionController = TextEditingController();

  TimeOfDay notifyAt = const TimeOfDay(hour: 12, minute: 0);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: _showMyDialog,
        child: Card(
          color: Colors.grey,
          child: Padding(
            padding:
                const EdgeInsets.only(left: 15, right: 15, top: 1, bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.channel.name,
                        maxLines: 3,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    widget.channel.id != 1 ? IconButton(
                      onPressed: () async {
                        // Delete channel
                        await deleteChannel(widget.channel);
                        // Update channels state
                        widget.updateState();
                      },
                      icon: const Icon(Icons.delete),
                      color: const Color.fromARGB(255, 183, 14, 14),
                    ) : const SizedBox(),
                  ],
                ),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: retrieveNotificationsById(widget.channel.notification),
                  builder: ((context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(
                          "${snapshot.data![0]["hour"]}:${snapshot.data![0]["minute"]}");
                    } else {
                      return const CircularProgressIndicator();
                    }
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> selectTime(BuildContext context) async {
              final TimeOfDay? pickedS = await showTimePicker(
                context: context,
                initialTime: notifyAt,
              );

              if (pickedS != null) {
                setState(() {
                  notifyAt = pickedS;
                });
              }
            }

            return AlertDialog(
              title: const Text('Create new channel'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Channel name',
                        ),
                        controller: newChannelNameController,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Channel notification message',
                        ),
                        controller: newChannelDescriptionController,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => selectTime(context),
                      child: Text(notifyAt.format(context)),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Edit'),
                  onPressed: () async {
                    print(await NotificationService().getActiveNotifications());
                    // Delete the notification
                    NotificationService()
                        .cancelNotification(widget.channel.notification);
                    // Reschedule it
                    DateTime startNotifyingAt = DateTime(
                      DateTime.now().year,
                      DateTime.now().month,
                      DateTime.now().day,
                      notifyAt.hour,
                      notifyAt.minute,
                    );

                    // Id is meant an id of a channel.
                    createPeriodicallNotificationWithTimeCalculation(
                        widget.channel, widget.channel.id, startNotifyingAt);

                    // Update Notification row with right time:
                    updateNotificationById(widget.channel.id, startNotifyingAt);

                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
