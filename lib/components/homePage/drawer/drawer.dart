import 'package:flutter/material.dart';
import 'package:unfuckyourlife/components/homePage/drawer/channelComponent/channelComponent.dart';
import 'package:unfuckyourlife/model/database/channelClass/channel.dart';
import 'package:unfuckyourlife/model/database/retrieve.dart';

import 'dart:async';

import 'package:unfuckyourlife/model/notification/notifications.dart';

class DrawerWithChannels extends StatefulWidget {
  const DrawerWithChannels({super.key});

  @override
  State<StatefulWidget> createState() {
    return _DrawerWithChannelsState();
  }
}

class _DrawerWithChannelsState extends State<DrawerWithChannels> {
  List<Channel> channels = [];

  final newChannelNameController = TextEditingController();
  final newChannelDescriptionController = TextEditingController();

  TimeOfDay notifyAt = const TimeOfDay(hour: 12, minute: 0);

  @override
  void initState() {
    super.initState();
    retrieveChannelsAndAssingThem();
  }

  Future retrieveChannelsAndAssingThem() async {
    List channelsMaped = await retrieveChannels();
    List<Channel> newChannel = [];
    for (Map<String, dynamic> channelMap in channelsMaped) {
      newChannel.add(Channel(channelMap["id"], channelMap["name"],
          channelMap["notifier"], channelMap["isCustom"] == 1 ? true : false));
    }

    setState(() {
      channels = newChannel;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 15,
            ),
            const Text(
              "Channels:",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 60,
                  fontWeight: FontWeight.w100),
            ),
            ElevatedButton(
                onPressed: () => {
                      _showMyDialog(),
                    },
                child: const Text("Add new channel.")),
            Expanded(
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  if (channels[index].isCustom == false) {
                    return TodoButton(channel: channels[index]);
                  }
                  return null;
                },
                itemCount: channels.length,
              ),
            ),
          ],
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
                  child: const Text('Create'),
                  onPressed: () {
                    // TODO: Create new channel
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

  void addNewChannel() {
      DateTime startNotifyingAt = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        notifyAt.hour,
        notifyAt.minute,
      );

    // The zeros will be set in function
    Channel newChannel = Channel(0, newChannelNameController.text, 0, false);

    createNewChannel(newChannel, startNotifyingAt);
  }
}
