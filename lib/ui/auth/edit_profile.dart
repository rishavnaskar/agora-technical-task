import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fourleggedlove/utils/common.dart';
import 'package:fourleggedlove/utils/constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile>
    with AutomaticKeepAliveClientMixin {
  late final Common _common;
  late final ImagePicker _imagePicker;
  late final TextEditingController _textEditingController;
  bool _isLoading = false;
  List<File> _pickedImages = [];
  late final FirebaseFirestore firestoreInstance;
  late final FirebaseAuth firebaseAuthInstance;
  late final Stream<DocumentSnapshot<Map<String, dynamic>>> snapshots;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: _common.background,
      body: ModalProgressHUD(
        inAsyncCall: _isLoading,
        progressIndicator: _common.progressIndicator(),
        child: SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            width: double.infinity,
            height: height,
            child: StreamBuilder<DocumentSnapshot>(
              stream: snapshots,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return Center(child: _common.progressIndicator());
                if (snapshot.hasError)
                  return Icon(Icons.error, color: Colors.white);
                if (snapshot.hasData) {
                  final List images = (snapshot.data!.data() as Map)["images"];
                  _textEditingController.text =
                      (snapshot.data!.data() as Map)["bio"];
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: height * 0.03),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              firebaseAuthInstance.currentUser!.displayName!,
                              style: TextStyle(
                                fontFamily: "Nexa",
                                color: Colors.white70,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              firebaseAuthInstance.currentUser!.email!,
                              style: TextStyle(
                                fontFamily: "Poppins",
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: height * 0.05),
                        Text(
                          "Make your profile stand out!",
                          style: TextStyle(
                            color: _common.blue,
                            fontFamily: "Nexa",
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          "Add a bio and some images. Make your profile extra ordinary",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontFamily: "Poppins",
                          ),
                        ),
                        SizedBox(height: 40),
                        Container(
                          height: height * 0.2,
                          width: double.infinity,
                          child: ListView.separated(
                            physics: BouncingScrollPhysics(),
                            shrinkWrap: true,
                            primary: false,
                            addAutomaticKeepAlives: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: images.length + 1,
                            separatorBuilder: (context, index) =>
                                SizedBox(width: 20),
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return InkWell(
                                  onTap: () => pickImage(),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Column(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Lottie.asset(
                                          "assets/person.json",
                                          fit: BoxFit.contain,
                                          height: height * 0.16,
                                        ),
                                      ),
                                      Flexible(child: SizedBox(height: 10)),
                                      Flexible(
                                        child: Text(
                                          "Tap to add",
                                          style: TextStyle(
                                            color: Colors.grey[500],
                                            fontFamily: "Poppins",
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: height * 0.16,
                                      height: height * 0.16,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: Colors.grey[400],
                                        image: DecorationImage(
                                          image: NetworkImage(
                                            images[images.length - index],
                                          ),
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                    Flexible(child: SizedBox(height: 2)),
                                    Flexible(
                                      flex: 4,
                                      child: IconButton(
                                        onPressed: () => deleteImage(
                                            images,
                                            images.length - index - 1,
                                            snapshot),
                                        icon: Icon(CupertinoIcons.delete),
                                        color: _common.blue,
                                        iconSize: 16,
                                      ),
                                    ),
                                  ],
                                );
                              }
                            },
                          ),
                        ),
                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "${_pickedImages.length > 0 ? _pickedImages.length : 'No'} new images selected",
                              style: TextStyle(
                                color: _pickedImages.length > 0
                                    ? Colors.white
                                    : Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(width: 10),
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
                              onPressed: () {
                                setState(() => _pickedImages.clear());
                                _common.displayToast(
                                  "Images removed from selection",
                                  context,
                                );
                              },
                              icon: Icon(CupertinoIcons.delete_solid),
                              iconSize: 12,
                              color: _pickedImages.length > 0
                                  ? Colors.white
                                  : Colors.white70,
                            ),
                          ],
                        ),
                        SizedBox(height: height * 0.07),
                        Text(
                          "Let\'s write a beautiful bio",
                          style: TextStyle(
                            color: _common.blue,
                            fontFamily: "Nexa",
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(height: 30),
                        TextField(
                          controller: _textEditingController,
                          maxLines: null,
                          autocorrect: true,
                          style: TextStyle(
                            color: _common.blueLightest,
                            fontFamily: "Poppins",
                          ),
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            labelText: "Bio",
                            labelStyle: TextStyle(
                              color: _common.blueLightest,
                              fontFamily: "Poppins",
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey[350]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey[350]!),
                            ),
                          ),
                        ),
                        SizedBox(height: height * 0.08),
                        Center(
                          child: ElevatedButton(
                            onPressed: uploadData,
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                Colors.blue[800],
                              ),
                              padding: MaterialStateProperty.all(
                                EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 5),
                              ),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                            child: Text(
                              "Update",
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: "Poppins",
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return Container();
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    firestoreInstance = FirebaseFirestore.instance;
    firebaseAuthInstance = FirebaseAuth.instance;
    _textEditingController = TextEditingController();
    _common = Common();
    _imagePicker = ImagePicker();
    snapshots = firestoreInstance
        .collection("users")
        .doc(firebaseAuthInstance.currentUser!.email)
        .snapshots();
  }

  pickImage() async {
    List<XFile>? xFileImages = await _imagePicker.pickMultiImage();
    if (xFileImages != null) {
      xFileImages.forEach((element) => _pickedImages.add(File(element.path)));
      _pickedImages = _pickedImages.toSet().toList();
      setState(() {});
    }
  }

  uploadData() async {
    setState(() => _isLoading = true);
    if (_textEditingController.text.isEmpty && _pickedImages.isEmpty) {
      setState(() => _isLoading = false);
      return _common.displayToast("Atleast make a change first!", context);
    }

    firebase_storage.FirebaseStorage storage =
        firebase_storage.FirebaseStorage.instance;
    try {
      List<String> downloadUrls = [];
      final currentUser = FirebaseAuth.instance.currentUser!;
      if (_pickedImages.isNotEmpty) {
        _pickedImages.forEach((element) async {
          await storage
              .ref('${currentUser.email}/${element.path}')
              .putFile(element)
              .then((snapshot) async =>
                  downloadUrls.add(await snapshot.ref.getDownloadURL()))
              .whenComplete(
            () {
              FirebaseFirestore.instance
                  .collection("users")
                  .doc(currentUser.email)
                  .update({"bio": _textEditingController.text});
              return FirebaseFirestore.instance
                  .collection("users")
                  .doc(currentUser.email)
                  .update({
                "images": FieldValue.arrayUnion(downloadUrls)
              }).whenComplete(() async {
                setState(() => _isLoading = false);
                StreamingSharedPreferences pref =
                    await StreamingSharedPreferences.instance;
                pref.setInt(profileVisited, 1);
                _pickedImages.clear();
                _common.displayToast("Updated profile", context);
              });
            },
          );
        });
      } else {
        FirebaseFirestore.instance
            .collection("users")
            .doc(currentUser.email)
            .update({"bio": _textEditingController.text}).whenComplete(() {
          setState(() => _isLoading = false);
          _pickedImages.clear();
          return _common.displayToast("Updated bio", context);
        }).catchError((err) {
          setState(() => _isLoading = false);
          _pickedImages.clear();
          return _common.displayToast("Something went wrong", context);
        });
      }
    } on FirebaseException catch (e) {
      print("ERROR");
      print(e);
      setState(() => _isLoading = false);
      _pickedImages.clear();
      return _common.displayToast("Something went wrong", context);
    }
  }

  deleteImage(List images, int index,
      AsyncSnapshot<DocumentSnapshot<Object?>> snapshot) {
    snapshot.data!.reference.update({
      "images": FieldValue.arrayRemove([images[index]])
    });
    images.removeAt(index);
    snapshot.data!.reference.update(
      {"images": FieldValue.arrayUnion(images)},
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();
    _textEditingController.dispose();
  }
}
