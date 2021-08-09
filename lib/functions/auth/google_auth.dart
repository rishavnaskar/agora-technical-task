import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fourleggedlove/utils/constants.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

class GoogleAuth {
  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future signInUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final instance = FirebaseFirestore.instance;
    StreamingSharedPreferences prefs =
        await StreamingSharedPreferences.instance;
    if (currentUser != null) {
      final matchedUsers = await instance
          .collection("users")
          .where("email", isEqualTo: currentUser.email)
          .get();

      if (matchedUsers.docs.isEmpty) {
        instance.collection("users").doc(currentUser.email).set({
          "email": currentUser.email,
          "name": currentUser.displayName,
          "avatarUrl": currentUser.photoURL,
          inCallWith: "",
          channelName: "",
          "bio": "",
          "images": FieldValue.arrayUnion([]),
        });
        prefs.setInt(profileVisited, 0);
      } else
        prefs.setInt(profileVisited, 1);
    }
  }

  signOutUser() => FirebaseAuth.instance.signOut();
}
