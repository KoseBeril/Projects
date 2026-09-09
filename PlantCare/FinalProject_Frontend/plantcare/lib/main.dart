import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'chatbot_screen.dart';
import 'schedule_screen.dart';

void main() => runApp(PlantCareApp());

// PlantCareApp sınıfı, uygulamanın ana widget'ıdır ve MaterialApp widget'ını döndürür. Bu widget, uygulamanın genel temasını ve navigasyonunu yönetir.
class PlantCareApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PlantCare AI',
      theme: ThemeData(
        primaryColor: Color(0xFF2D5A27),
        scaffoldBackgroundColor: Color.fromARGB(255, 152, 213, 163),
        fontFamily: 'Poppins', // fontFamily burada, doğrudan ThemeData içinde olmalı
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: Color.fromARGB(255, 120, 192, 138),
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
        ),
        cardTheme: CardThemeData( 
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: const Color.fromARGB(255, 243, 244, 243),
        ),
      ),
      home: MainNavigation(),
    );
  }
}

// Ana sayfa navigasyonu için StatefulWidget
class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}

// _MainNavigationState sınıfı, MainNavigation widget'ının durumunu yönetir, yani hangi sayfanın gösterileceğini belirler.
class _MainNavigationState extends State<MainNavigation> {
  int _index = 0;
  // Sayfa listesi
  final List<Widget> _pages = [
    DashboardScreen(), 
    ChatbotScreen(), 
    ScheduleScreen()
  ];

  // Widget build metodu
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_rounded), label: "Chatbot"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: "Schedule"),
        ],
      ),
    );
  }
}