import 'package:flutter/material.dart';
import 'package:unfuckyourlife/components/homePage/drawer/channelComponent/channelComponent.dart';
import 'package:unfuckyourlife/model/database/channelClass/channel.dart';
import 'package:unfuckyourlife/model/database/retrieve.dart';

import 'dart:async';

import 'package:unfuckyourlife/model/notification/notifications.dart';

class DrawerWithChannels extends StatefulWidget {
  final Function updateChannel;
  const DrawerWithChannels({super.key, required this.updateChannel});

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

  Future<List<Channel>> retrieveChannelsAndAssingThem() async {
    List channelsMaped = await retrieveChannels();
    print(channelsMaped);
    List<Channel> newChannel = [];
    for (Map<String, dynamic> channelMap in channelsMaped) {
      newChannel.add(Channel(channelMap["id"], channelMap["name"],
          channelMap["notifier"], channelMap["isCustom"] == 1 ? true : false));
    }
    print(newChannel);
    return newChannel;
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
              child: FutureBuilder(
                future: retrieveChannelsAndAssingThem(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<Channel>> snapshot) {
                  if (snapshot.hasData) {
                    channels = snapshot.data as List<Channel>;
 
                    List<Widget> widgets = [];

                    for (Channel x in channels) {
                      print(x.isCustom);
                      if (x.isCustom != true){
                        print("ADDDDDIDNG ");
                        widgets.add(TodoButton(channel: x, updateState: widget.updateChannel,));
                      }
                    }

                    return ListView(
                      physics: const NeverScrollableScrollPhysics(),
                      children: [...widgets],
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
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
                  onPressed: () async {
                    DateTime startNotifyingAt = DateTime(
                      DateTime.now().year,
                      DateTime.now().month,
                      DateTime.now().day,
                      notifyAt.hour,
                      notifyAt.minute,
                    );

                    // TODO: Impelement the description

                    // The only thing that is needed is name and is custom, so does not matter much
                    Channel channel =
                        Channel(0, newChannelNameController.text, 0, false);
                    await createNewChannel(channel, startNotifyingAt);

                    retrieveChannelsAndAssingThem();

                    // Update Channels so you can see them immadietly in the AlertDialog while adding new Todo
                    widget.updateChannel();

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
