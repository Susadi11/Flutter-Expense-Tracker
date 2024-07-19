import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

import 'login.dart';
import 'settings_screen.dart';
import 'edit_profile.dart';
import 'home_screen.dart';
import 'statistics_screen.dart';

class Profile extends StatefulWidget {
  final String username;
  final String email;
  final String userId;  // Add this line

  const Profile({
    Key? key,
    required this.username,
    required this.email,
    required this.userId,  // Add this line
  }) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  int _selectedIndex = 2; // Set to 2 for Profile

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: _TopPortion(email: widget.email),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    widget.username,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.email,
                    style: Theme.of(context).textTheme.bodyMedium!,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FloatingActionButton.extended(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfile(
                                username: widget.username,
                                email: widget.email,
                              ),
                            ),
                          );
                        },
                        heroTag: 'edit',
                        label: const Text(
                          "Edit",
                          style: TextStyle(color: Colors.black), // Set text color to black
                        ),
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.black, // Set icon color to black
                        ),
                        backgroundColor: Color(0xFFC2AA81),
                      ),
                      const SizedBox(width: 16.0),
                      FloatingActionButton.extended(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Login()),
                            (Route<dynamic> route) => false,
                          );
                        },
                        heroTag: 'signout',
                        backgroundColor: Colors.red,
                        label: const Text(
                          "Sign Out",
                          style: TextStyle(color: Colors.black), // Set text color to black
                        ),
                        icon: const Icon(
                          Icons.exit_to_app,
                          color: Colors.black, // Set icon color to black
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        animationDuration: const Duration(seconds: 1),
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen(userId: widget.userId)),  // Update this line
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => StatisticsScreen(userId: widget.userId)),
            );
          }
        },
        destinations: [
    NavigationDestination(
      icon: Icon(Icons.home_outlined, color: Colors.grey),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.bar_chart, color: Colors.grey),
      label: 'Statistics',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline, color: Color(0xFFC2AA81)),
      label: 'Profile',
    ),
        ],
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        indicatorColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }
}

class _TopPortion extends StatefulWidget {
  final String email;

  const _TopPortion({Key? key, required this.email}) : super(key: key);

  @override
  _TopPortionState createState() => _TopPortionState();
}

class _TopPortionState extends State<_TopPortion> {
  File? _backgroundImage;
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    final prefs = await SharedPreferences.getInstance();
    final backgroundImagePath =
        prefs.getString('${widget.email}_backgroundImagePath');
    final profileImagePath =
        prefs.getString('${widget.email}_profileImagePath');

    setState(() {
      if (backgroundImagePath != null) {
        _backgroundImage = File(backgroundImagePath);
      }
      if (profileImagePath != null) {
        _profileImage = File(profileImagePath);
      }
    });
  }

  Future<void> _pickImage(ImageSource source, String imageType) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        if (imageType == 'background') {
          _backgroundImage = File(pickedFile.path);
          prefs.setString(
              '${widget.email}_backgroundImagePath', pickedFile.path);
        } else {
          _profileImage = File(pickedFile.path);
          prefs.setString('${widget.email}_profileImagePath', pickedFile.path);
        }
      });
    }
  }

  void _showImageOptions(File? image, String imageType) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (image != null)
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => Scaffold(
                          appBar: AppBar(
                            title: Text(imageType == 'background' ? 'Background Image' : 'Profile Image'),
                          ),
                          body: Center(
                            child: InteractiveViewer(
                              panEnabled: true,
                              boundaryMargin: EdgeInsets.all(20),
                              minScale: 0.5,
                              maxScale: 4,
                              child: Image.file(image),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Image.file(image),
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () async {
                      setState(() {
                        if (imageType == 'background') {
                          _backgroundImage = null;
                          SharedPreferences.getInstance().then((prefs) {
                            prefs.remove('${widget.email}_backgroundImagePath');
                          });
                        } else {
                          _profileImage = null;
                          SharedPreferences.getInstance().then((prefs) {
                            prefs.remove('${widget.email}_profileImagePath');
                          });
                        }
                      });
                      Navigator.of(context).pop();
                    },
                    child: const Text('Remove'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _pickImage(ImageSource.gallery, imageType);
                    },
                    child: const Text('Add New'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          onTap: () => _showImageOptions(_backgroundImage, 'background'),
          child: Container(
            margin: const EdgeInsets.only(bottom: 50),
            decoration: BoxDecoration(
              color: Colors.black,
              image: DecorationImage(
                fit: BoxFit.cover,
                image: _backgroundImage != null
                    ? FileImage(_backgroundImage!)
                    : const NetworkImage(
                        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQMrYE5dTA2hr1JGLuYZQv_L218986OZ0ogjDPSdIolTV1_pmLVtDRjd1gcTu4cJ9b2CV8&usqp=CAU',
                      ) as ImageProvider<Object>,
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () => _showImageOptions(_profileImage, 'profile'),
            child: SizedBox(
              width: 150,
              height: 150,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: _profileImage != null
                            ? FileImage(_profileImage!)
                            : const NetworkImage(
                                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQMrYE5dTA2hr1JGLuYZQv_L218986OZ0ogjDPSdIolTV1_pmLVtDRjd1gcTu4cJ9b2CV8&usqp=CAU',
                              ) as ImageProvider<Object>,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      child: IconButton(
                        icon: Icon(Icons.camera_alt, color: Color(0xFFC2AA81)),
                        onPressed: () =>
                            _pickImage(ImageSource.gallery, 'profile'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
