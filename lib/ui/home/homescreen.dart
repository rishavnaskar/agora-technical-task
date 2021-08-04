import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fourleggedlove/utils/common.dart';
import 'package:fourleggedlove/utils/constants.dart';
import 'package:lottie/lottie.dart';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Common _common = Common();

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _common.background,
        elevation: 0,
        title: Text(
          "Active Users",
          style: TextStyle(
            color: _common.blue,
            fontFamily: "Nexa",
          ),
        ),
      ),
      backgroundColor: _common.background,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          width: double.infinity,
          height: height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 4,
                    child: Text(
                      "Do remember to bring your cute little pet along with you!",
                      style: TextStyle(
                        fontFamily: "Poppins",
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                  Flexible(
                    child: Lottie.asset(
                      "assets/dog.json",
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      .where("email",
                          isNotEqualTo:
                              FirebaseAuth.instance.currentUser!.email)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting)
                      return Center(child: _common.progressIndicator());
                    if (snapshot.hasError)
                      return Center(
                        child: Icon(Icons.error, color: _common.blue),
                      );
                    if (snapshot.hasData) {
                      List documents = snapshot.data!.docs;
                      if (documents.isEmpty)
                        return Center(
                          child: Text(
                            "No active users found",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                              fontFamily: "Poppins",
                            ),
                          ),
                        );
                      else {
                        return ListView.separated(
                          itemCount: documents.length,
                          separatorBuilder: (context, index) => Divider(),
                          itemBuilder: (context, index) => Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Color(0xff31343c),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListHeadingRowWidget(
                                  documents: documents,
                                  common: _common,
                                  index: index,
                                ),
                                SizedBox(height: 20),
                                Text(
                                  subtitleText[Random().nextInt(3)],
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    color: Colors.grey[350],
                                    fontFamily: "Poppins",
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 10),
                                ImagesWidget(
                                  height: height,
                                  documents: documents,
                                  width: width,
                                  index: index,
                                ),
                                SizedBox(height: 20),
                                Text(
                                  "More about me",
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    color: Colors.grey[350],
                                    fontFamily: "Poppins",
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  documents[index]["bio"],
                                  textAlign: TextAlign.start,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: _common.purple,
                                    fontFamily: "Poppins",
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    }
                    return Container();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<String> subtitleText = [
    "Check out my cuties! 😍",
    "This is how my babies look like ☺",
    "Aren\'t they so adorable? 🥰"
  ];
}

class ListHeadingRowWidget extends StatelessWidget {
  const ListHeadingRowWidget({
    Key? key,
    required this.documents,
    required Common common,
    required this.index,
  })  : _common = common,
        super(key: key);

  final List documents;
  final Common _common;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(
            documents[index]["avatarUrl"],
          ),
        ),
        SizedBox(width: 20),
        Text(
          documents[index]["name"],
          style: TextStyle(
            color: _common.purpleLight,
            fontFamily: "Poppins",
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        Spacer(),
        IconButton(
          onPressed: () async {
            final res = await FirebaseFirestore.instance
                .collection("users")
                .doc(documents[index]["email"])
                .get();
            if (res.data()!.containsKey(inCallWith)) {
              if (res[inCallWith] != FirebaseAuth.instance.currentUser!.email) {
                navigateToCallPage(res);
              } else
                _common.displayToast("User already in a call", context);
            } else
              navigateToCallPage(res);
          },
          icon: Icon(CupertinoIcons.videocam),
          color: _common.blue,
          iconSize: 34,
          enableFeedback: true,
          tooltip: "Video call button",
        ),
      ],
    );
  }

  navigateToCallPage(DocumentSnapshot<Map<String, dynamic>> res) {
    const String _chars = 'abcdefghijklmnopqrstuvwxyz';
    Random _rnd = Random();
    final String channel = String.fromCharCodes(
      Iterable.generate(
        6,
        (_) => _chars.codeUnitAt(
          _rnd.nextInt(_chars.length),
        ),
      ),
    );

    res.reference.update({
      inCallWith: FirebaseAuth.instance.currentUser!.email,
      channelName: channel,
    }).whenComplete(
      () => FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.email)
          .update({
        inCallWith: res.id,
        channelName: channel,
      }),
    );
  }
}

class ImagesWidget extends StatelessWidget {
  const ImagesWidget({
    Key? key,
    required this.height,
    required this.documents,
    required this.width,
    required this.index,
  }) : super(key: key);

  final double height;
  final List documents;
  final double width;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: height * 0.2,
        child: ListView.separated(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, i) => ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              documents[index]["images"][i],
              fit: BoxFit.fill,
              height: height * 0.3,
              width: width * 0.3,
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                }
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
            ),
          ),
          separatorBuilder: (context, i) => SizedBox(width: 10),
          itemCount: documents[index]["images"].length,
        ),
      ),
    );
  }
}
