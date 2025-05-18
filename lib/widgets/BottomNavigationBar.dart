import 'dart:io';
import 'package:flutter/material.dart';
import 'main_nav_screen.dart';   // Import your MainNavScreen
import '../screens/profile_screen.dart';  // Import ProfileScreen
import '../utils/classification_storage.dart';


class BottomNav extends StatefulWidget {
  final String email;
  final List<Map<String, dynamic>> classificationHistory;
  final List<File> pickedImages;

  const BottomNav({
    Key? key,
    required this.email,
    required this.classificationHistory,
    required this.pickedImages,
  }) : super(key: key);

  @override
  _BottomNavState createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;

  late List<Map<String, dynamic>> _classificationHistory;
  late List<File> _pickedImages;

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    // Initialize state variables from widget
    _classificationHistory = widget.classificationHistory;
    _pickedImages = widget.pickedImages;

    _screens = [
      MainNavScreen(
        email: widget.email,
        classificationHistory: _classificationHistory,
        pickedImages: _pickedImages,
        onClassificationDataUpdate: _updateClassificationData,
      ),
      ProfileScreen(
        email: widget.email,
        classificationHistory: _classificationHistory,
        pickedImages: _pickedImages,
      ),
    ];
  }

  void _updateClassificationData({
    required List<Map<String, dynamic>> updatedHistory,
    required List<File> updatedImages,
  }) {
    setState(() {
      _classificationHistory = updatedHistory;
      _pickedImages = updatedImages; 

    ClassificationStorage storage = ClassificationStorage();
    storage.classificationHistory = updatedHistory;
    storage.pickedImages = updatedImages;

    // Update ProfileScreen with new data
    _screens[1] = ProfileScreen(
      email: widget.email,
      classificationHistory: _classificationHistory,
      pickedImages: _pickedImages,
    );
      // Rebuild screens with updated data to keep in sync
      _screens = [
        MainNavScreen(
          email: widget.email,
          classificationHistory: _classificationHistory,
          pickedImages: _pickedImages,
          onClassificationDataUpdate: _updateClassificationData,
        ),
        ProfileScreen(
          email: widget.email,
          classificationHistory: _classificationHistory,
          pickedImages: _pickedImages,
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (newIndex) {
          setState(() {
            _selectedIndex = newIndex;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
