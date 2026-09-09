import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// MQTT ayarlarını yapılandırmak için bir ekran, Kullanıcı broker adresini, topic'i, kullanıcı adını ve şifreyi girebilir. 
//Bu ayarlar SharedPreferences kullanılarak saklanır ve uygulama başlatıldığında yüklenir.(Bir kez girmek yeterlidir.)
class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _brokerController = TextEditingController();
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _userController = TextEditingController(); // Yeni
  final TextEditingController _passController = TextEditingController();  // Yeni

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Kayıtlı ayarları yükle
  _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _brokerController.text = prefs.getString('broker') ?? 'broker.hivemq.com';
      _topicController.text = prefs.getString('topic') ?? 'plant/moisture';
      _userController.text = prefs.getString('username') ?? ''; // Yükle
      _passController.text = prefs.getString('password') ?? ''; // Yükle
    });
  }

  // Ayarları kaydet
  _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('broker', _brokerController.text);
    await prefs.setString('topic', _topicController.text);
    await prefs.setString('username', _userController.text); // Kaydet
    await prefs.setString('password', _passController.text); // Kaydet
    Navigator.pop(context, true); // Ayarların güncellendiğini haber ver
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("MQTT Settings")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: ListView(
          children: [
            TextField(controller: _brokerController, decoration: InputDecoration(labelText: "Broker Address")),
            TextField(controller: _topicController, decoration: InputDecoration(labelText: "Topic")),
            TextField(controller: _userController, decoration: InputDecoration(labelText: "Username")),
            TextField(controller: _passController, obscureText: true, decoration: InputDecoration(labelText: "Password")),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _saveSettings, child: Text("Save Settings")),
          ],
        ),
      ),
    );
  }
}