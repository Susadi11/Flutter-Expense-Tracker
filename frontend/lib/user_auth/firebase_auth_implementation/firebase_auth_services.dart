import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:expense_tracker/toast.dart';


class FirebaseAuthService {

  FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signUpWithEmailAndPassword(String email, String password) async {

    try {
      UserCredential credential =await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return credential.user;
    } on FirebaseAuthException catch (e) {

      if (e.code == 'email-already-in-use') {
        showToast(message: 'The email address is already in use.');
      } else {
        showToast(message: 'An error occurred: ${e.code}');
      }
    }
    return null;

  }

  Future<User?> signInWithEmailAndPassword(String email, String password) async {

    try {
      UserCredential credential =await _auth.signInWithEmailAndPassword(email: email, password: password);
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        showToast(message: 'Invalid email or password.');
      } else {
        showToast(message: 'An error occurred: ${e.code}');
      }

    }
    return null;

  }

  Future<User?> signInWithGoogle() async {
  try {
    print("Attempting to sign in with Google");
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      showToast(message: "Google sign-in was canceled");
      print("Google sign-in was canceled");
      return null;
    }

    print("Google sign-in successful, user: ${googleUser.email}");
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    print("GoogleAuth obtained, signing in with credential");
    UserCredential userCredential = await _auth.signInWithCredential(credential);
    print("Firebase sign-in successful, user: ${userCredential.user?.email}");
    return userCredential.user;
  } catch (e) {
    showToast(message: "Failed to sign in with Google: ${e.toString()}");
    print("Failed to sign in with Google: ${e.toString()}");
    return null;
  }
}

    Future<String> getUsernameFromFirestore(String uid) async {
  // Implement this method to fetch the username from Firestore
  // This is just an example, adjust it based on your actual data structure
  DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
  return userDoc.get('username') ?? '';
}


}