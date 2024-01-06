import 'package:flutter/material.dart';
import 'package:unfuckyourlife/model/database/channelClass/channel.dart';
import 'package:unfuckyourlife/model/database/retrieve.dart';

class DrawerWithChannels extends StatefulWidget {
  const DrawerWithChannels({super.key});

  @override
  State<StatefulWidget> createState() {
    return _DrawerWithChannelsState();
  }

}

class _DrawerWithChannelsState extends State<DrawerWithChannels> {
  List<Channel> channels = [];

@override
  void initState() {
    super.initState();
    retrieveChannelsAndAssingThem();
  }

  Future retrieveChannelsAndAssingThem() async {
    List channelsMaped = await retrieveChannels();
    List<Channel> newChannel = [];
    for (Map<String, dynamic> channelMap in channelsMaped) {
      newChannel.add(Channel(channelMap["id"], channelMap["name"], channelMap["notifier"], channelMap["isCustom"] == 1 ? true : false));
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
            Expanded(
              child: ListView.builder(
                physics:
                     NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  if (channels[index].isCustom == false) {
                    return ElevatedButton(onPressed: () {
                      print(channels[index].name);
                    }, child: Text(channels[index].name));
                  }
                },
                itemCount: channels.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
