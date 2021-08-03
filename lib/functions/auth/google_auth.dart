import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
    if (currentUser != null) {
      final matchedUsers = await instance
          .collection("users")
          .where("email", isEqualTo: currentUser.email)
          .get();

      if (matchedUsers.docs.isEmpty)
        instance.collection("users").add({
          "email": currentUser.email,
          "name": currentUser.displayName,
          "avatarUrl": currentUser.photoURL,
        });
    }
  }
}
