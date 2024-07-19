import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expense_tracker/user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:expense_tracker/toast.dart';
import 'package:expense_tracker/home_screen.dart';

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  final FocusNode _focusNodeUsername = FocusNode();
  final FocusNode _focusNodeEmail = FocusNode();
  final FocusNode _focusNodePassword = FocusNode();
  final FocusNode _focusNodeConfirmPassword = FocusNode();
  final TextEditingController _controllerUsername = TextEditingController();
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerConfirmPassword = TextEditingController();

  final Box _boxAccounts = Hive.box("accounts");
  bool _obscurePassword = true;
  bool isSigningUp = false;

  final FirebaseAuthService _auth = FirebaseAuthService();

  // Light shade of #C2AA81
  final Color _lightShadeC2AA81 = Color(0xFFE5D9C3);
  final Color _mainColor = Color(0xFFC2AA81);
  final Color _accentColor = Color.fromARGB(255, 0, 0, 0);

  @override
  void initState() {
    super.initState();
    _focusNodeUsername.addListener(() {
      setState(() {});
    });
    _focusNodeEmail.addListener(() {
      setState(() {});
    });
    _focusNodePassword.addListener(() {
      setState(() {});
    });
    _focusNodeConfirmPassword.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightShadeC2AA81,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            children: [
              const SizedBox(height: 100),
              Text(
                "Register",
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: _accentColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Create your account",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: _accentColor,
                ),
              ),
              const SizedBox(height: 35),
              TextFormField(
                controller: _controllerUsername,
                focusNode: _focusNodeUsername,
                keyboardType: TextInputType.name,
                cursorColor: Color(0xFFC2AA81),
                decoration: InputDecoration(
                  labelText: "Username",
                  prefixIcon: Icon(Icons.person_outline, color: _focusNodeUsername.hasFocus ? _mainColor : Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: _mainColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: _mainColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: _mainColor),
                  ),
                  labelStyle: TextStyle(color: _focusNodeUsername.hasFocus ? _mainColor : Colors.grey),
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter username.";
                  } else if (_boxAccounts.containsKey(value)) {
                    return "Username is already registered.";
                  }
                  return null;
                },
                onEditingComplete: () => _focusNodeEmail.requestFocus(),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _controllerEmail,
                focusNode: _focusNodeEmail,
                keyboardType: TextInputType.emailAddress,
                cursorColor: Color(0xFFC2AA81),
                decoration: InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email_outlined, color: _focusNodeEmail.hasFocus ? _mainColor : Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: _mainColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: _mainColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: _mainColor),
                  ),
                  labelStyle: TextStyle(color: _focusNodeEmail.hasFocus ? _mainColor : Colors.grey),
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter email.";
                  } else if (!(value.contains('@') && value.contains('.'))) {
                    return "Invalid email";
                  }
                  return null;
                },
                onEditingComplete: () => _focusNodePassword.requestFocus(),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _controllerPassword,
                obscureText: _obscurePassword,
                focusNode: _focusNodePassword,
                keyboardType: TextInputType.visiblePassword,
                cursorColor: Color(0xFFC2AA81),
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: Icon(Icons.password_outlined, color: _focusNodePassword.hasFocus ? _mainColor : Colors.grey),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: _focusNodePassword.hasFocus ? _mainColor : Colors.grey,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: _mainColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: _mainColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: _mainColor),
                  ),
                  labelStyle: TextStyle(color: _focusNodePassword.hasFocus ? _mainColor : Colors.grey),
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter password.";
                  } else if (value.length < 8) {
                    return "Password must be at least 8 characters.";
                  }
                  return null;
                },
                onEditingComplete: () => _focusNodeConfirmPassword.requestFocus(),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _controllerConfirmPassword,
                obscureText: _obscurePassword,
                focusNode: _focusNodeConfirmPassword,
                keyboardType: TextInputType.visiblePassword,
                cursorColor: Color(0xFFC2AA81),
                decoration: InputDecoration(
                  labelText: "Confirm Password",
                  prefixIcon: Icon(Icons.password_outlined, color: _focusNodeConfirmPassword.hasFocus ? _mainColor : Colors.grey),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: _focusNodeConfirmPassword.hasFocus ? _mainColor : Colors.grey,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: _mainColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: _mainColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: _mainColor),
                  ),
                  labelStyle: TextStyle(color: _focusNodeConfirmPassword.hasFocus ? _mainColor : Colors.grey),
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter password.";
                  } else if (value != _controllerPassword.text) {
                    return "Password doesn't match.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 50),
              Column(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _mainColor,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      _signUp();
                    },
                    child: isSigningUp
                        ? CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Register",
                            style: TextStyle(
                              color: Colors.black, // Set text color to black
                              fontSize: 18, // Increase font size
                              fontWeight: FontWeight.bold, // Make text bold
                            ),
                          ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account?"),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Login", style: TextStyle(color: _mainColor)),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _signUp() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        isSigningUp = true;
      });

      String username = _controllerUsername.text;
      String email = _controllerEmail.text;
      String password = _controllerPassword.text;

      User? user = await _auth.signUpWithEmailAndPassword(email, password);

      setState(() {
        isSigningUp = false;
      });

      if (user != null) {
        // Store the username in Firebase
        await user.updateDisplayName(username);

        _boxAccounts.put(username, password);

        showToast(message: "User is successfully created");

        // Navigate to home screen with user ID
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(userId: user.uid),
          ),
        );
      } else {
        showToast(message: "Some error happened");
      }
    }
  }

  @override
  void dispose() {
    _focusNodeUsername.dispose();
    _focusNodeEmail.dispose();
    _focusNodePassword.dispose();
    _focusNodeConfirmPassword.dispose();
    _controllerUsername.dispose();
    _controllerEmail.dispose();
    _controllerPassword.dispose();
    _controllerConfirmPassword.dispose();
    super.dispose();
  }
}
