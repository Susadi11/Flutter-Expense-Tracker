import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

class OnboardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: "Welcome to Pennywise",
          body: "Your personal expense tracker to manage and save money efficiently.",
          image: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: Image.asset("assets/images/onboarding1.png", height: 200.0),
            ),
          ),
          decoration: PageDecoration(
            titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
            bodyTextStyle: TextStyle(fontSize: 19.0),
            pageColor: Colors.white,
          ),
        ),
        PageViewModel(
          title: "Track Your Expenses",
          body: "Easily log and categorize your daily expenses.",
          image: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: Image.asset("assets/images/onboarding2.png", height: 200.0),
            ),
          ),
          decoration: PageDecoration(
            titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
            bodyTextStyle: TextStyle(fontSize: 19.0),
            pageColor: Colors.white,
          ),
        ),
        PageViewModel(
          title: "Sync Across Devices",
          body: "Keep your data safe and synchronized with cloud storage.",
          image: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: Image.asset("assets/images/onboarding3.png", height: 200.0),
            ),
          ),
          decoration: PageDecoration(
            titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
            bodyTextStyle: TextStyle(fontSize: 19.0),
            pageColor: Colors.white,
          ),
        ),
        PageViewModel(
          title: "Get Insights",
          body: "Analyze your spending habits and save more with detailed insights.",
          image: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: Image.asset("assets/images/onboarding4.png", height: 200.0),
            ),
          ),
          decoration: PageDecoration(
            titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
            bodyTextStyle: TextStyle(fontSize: 19.0),
            pageColor: Colors.white,
          ),
        ),
      ],
      onDone: () => _finishOnboarding(context),
      onSkip: () => _finishOnboarding(context),
      showSkipButton: true,
      skip: Text(
        "Skip",
        style: TextStyle(
          color: Colors.black,
        ),
      ),
      next: Text(
        "Next",
        style: TextStyle(
          color: Colors.black,
        ),
      ),
      done: Text(
        "Done",
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      dotsDecorator: DotsDecorator(
        size: Size(10.0, 10.0),
        color: Colors.black, // Color of inactive dots
        activeColor: Color(0xFFC2AA81), // Color of active dot
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
      globalBackgroundColor: Colors.white,
    );
  }

  void _finishOnboarding(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTimeUser', false);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => AuthCheckScreen()),
    );
  }
}