import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fourleggedlove/utils/common.dart';
import 'package:lottie/lottie.dart';

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
                        return Text(
                          "No active users found",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontFamily: "Poppins",
                          ),
                        );
                      else {
                        return ListView.builder(
                          itemCount: documents.length,
                          addAutomaticKeepAlives: true,
                          itemBuilder: (context, index) => Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey[350]!,
                                width: 0.5,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Flexible(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      documents[index]["avatarUrl"],
                                      fit: BoxFit.contain,
                                      loadingBuilder: (BuildContext context,
                                          Widget child,
                                          ImageChunkEvent? loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return Center(
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              _common.blue,
                                            ),
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(width: 30),
                                Flexible(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        documents[index]["name"],
                                        style: TextStyle(
                                          color: _common.purple,
                                          fontSize: 16,
                                          fontFamily: "Nexa",
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        documents[index]["email"],
                                        style: TextStyle(
                                          color: _common.purple,
                                          fontSize: 16,
                                          fontFamily: "Nexa",
                                        ),
                                      ),
                                    ],
                                  ),
                                )
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
}
