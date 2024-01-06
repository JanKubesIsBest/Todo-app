import 'package:flutter/material.dart';

class DrawerWithChannels extends StatelessWidget {
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
              " Channels:",
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
                  // Your list item
                },
                itemCount: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
