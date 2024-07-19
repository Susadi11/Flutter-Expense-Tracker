import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'login.dart';

class EditProfile extends StatefulWidget {
  final String username;
  final String email;

  const EditProfile({Key? key, required this.username, required this.email})
      : super(key: key);

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _auth = FirebaseAuth.instance;
  final _passwordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _passwordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  void showToast({required String message}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black,
      textColor: Colors.white,
    );
  }

  Future<void> _changePassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_newPasswordController.text != _confirmNewPasswordController.text) {
        showToast(message: "New password and confirmation do not match.");
        return;
      }
      try {
        User? user = _auth.currentUser;
        if (user != null) {
          // Reauthenticate user
          final cred = EmailAuthProvider.credential(
              email: widget.email, password: _passwordController.text);
          await user.reauthenticateWithCredential(cred);

          // Change password
          await user.updatePassword(_newPasswordController.text);
          showToast(message: "Password changed successfully");

          // Sign out and navigate to login page
          await _auth.signOut();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Login()),
            (Route<dynamic> route) => false,
          );
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'wrong-password') {
          showToast(message: "The current password is incorrect.");
        } else if (e.code == 'user-mismatch') {
          showToast(message: "The email does not match the current user.");
        } else if (e.code == 'invalid-credential') {
          showToast(message: "The credential is malformed or has expired.");
        } else {
          showToast(message: "Error: ${e.toString()}");
        }
      } catch (e) {
        showToast(message: "Error: ${e.toString()}");
      }
    }
  }

  Future<void> _deleteAccount() async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete your account? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    ) ?? false;

    if (confirmDelete) {
      try {
        User? user = _auth.currentUser;
        if (user != null) {
          await user.delete();
          showToast(message: "Account deleted successfully");

          // Sign out and navigate to login page
          await _auth.signOut();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Login()),
            (Route<dynamic> route) => false,
          );
        }
      } catch (e) {
        showToast(message: "Error: ${e.toString()}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Change Password',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                cursorColor: Color(0xFFC2AA81),
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFC2AA81)),
                  ),
                  floatingLabelStyle: TextStyle(color: Color(0xFFC2AA81)),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your current password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _newPasswordController,
                cursorColor: Color(0xFFC2AA81),
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFC2AA81)),
                  ),
                  floatingLabelStyle: TextStyle(color: Color(0xFFC2AA81)),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your new password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _confirmNewPasswordController,
                cursorColor: Color(0xFFC2AA81),
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFC2AA81)),
                  ),
                  floatingLabelStyle: TextStyle(color: Color(0xFFC2AA81)),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your new password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _changePassword,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    foregroundColor: Colors.black, // Set text color to black
                  ),
                  child: const Text('Change Password'),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _deleteAccount,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.black, // Set text color to black
                  ),
                  child: const Text('Delete Account'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
