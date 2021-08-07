import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

class _EditProfileState extends State<EditProfile> {
  final Common _common = Common();
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _textEditingController = TextEditingController();
  bool _isLoading = false;
  List<File> _pickedImages = [];

  @override
  Widget build(BuildContext context) {
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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: height * 0.06),
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: pickImage,
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
                            SizedBox(height: 10),
                            Text(
                              "Tap to add",
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontFamily: "Poppins",
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 20),
                      Flexible(
                        child: Container(
                          height: height * 0.2,
                          child: ListView.separated(
                            physics: BouncingScrollPhysics(),
                            shrinkWrap: true,
                            primary: false,
                            addAutomaticKeepAlives: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: _pickedImages.length,
                            separatorBuilder: (context, index) =>
                                SizedBox(width: 20),
                            itemBuilder: (context, index) => Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: height * 0.16,
                                  height: height * 0.16,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.grey[400],
                                    image: DecorationImage(
                                      image: FileImage(_pickedImages[
                                          _pickedImages.length - index - 1]),
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: height * 0.08),
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
                      color: Colors.grey[350],
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
                          EdgeInsets.symmetric(horizontal: 30, vertical: 5),
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
            ),
          ),
        ),
      ),
    );
  }

  pickImage() async {
    List<XFile>? images = await _imagePicker.pickMultiImage();
    if (images != null) {
      setState(() {
        images.forEach((element) => _pickedImages.add(File(element.path)));
      });
    }
  }

  uploadData() async {
    setState(() => _isLoading = true);
    if (_textEditingController.text.isEmpty)
      return _common.displayToast("Enter your bio!", context);

    if (_pickedImages.isEmpty)
      return _common.displayToast("Add atleast one image", context);

    firebase_storage.FirebaseStorage storage =
        firebase_storage.FirebaseStorage.instance;
    try {
      List<String> downloadUrls = [];
      final currentUser = FirebaseAuth.instance.currentUser!;
      if (_pickedImages.isNotEmpty)
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
                pref.setBool(profileVisited, true);
              });
            },
          );
        });
      else
        FirebaseFirestore.instance
            .collection("users")
            .doc(currentUser.email)
            .update({"bio": _textEditingController.text});
    } on FirebaseException catch (e) {
      print("ERROR");
      print(e);
      setState(() => _isLoading = false);
      return _common.displayToast("Something went wrong", context);
    }
  }
}
