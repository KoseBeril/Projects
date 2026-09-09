import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'api_service.dart';
import 'mqtt_service.dart'; 
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService apiService = ApiService();
  final MqttService mqttService = MqttService();
  
  String soilMoisture = "Waiting for data...";

  @override
  void initState() {
    super.initState();
    _initMqtt();
  }

// MQTT bağlantısını başlatan fonksiyon
  Future<void> _initMqtt() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String broker = prefs.getString('broker') ?? 'broker.hivemq.com';
    String topic = prefs.getString('topic') ?? 'plant/moisture';
    String username = prefs.getString('username') ?? '';
    String password = prefs.getString('password') ?? '';
    print("Connecting to MQTT: $broker"); 

  bool connected = await mqttService.connect(
    broker, 
    "flutter_client_${DateTime.now().millisecondsSinceEpoch}",
    username,
    password
  );
    if (connected) {
      print("MQTT connection is successful!");
      mqttService.subscribe(topic);
      
      // MQTT'den gelen veriyi dinle
      mqttService.sensorStream.listen((data) {
        print("Incoming data: $data");
        if (mounted) {
          setState(() {
            // JSON formatı: {"value": 25.5, "unit": "celsius"}
            soilMoisture = "${data['value']} ${data['unit']}";
          });
        }
      });
    }
    else {
      print("MQTT connection failed.");
      setState(() => soilMoisture = "Connection Failed");
    }
  }

  // Yönerge penceresi fonksiyonu (kullanıcıya MQTT veri formatını gösterir)
  void _showMqttInstructions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("MQTT Data Format"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Please ensure that your sensor data follows this JSON structure:"),
            SizedBox(height: 10),
            Container(padding: EdgeInsets.all(8), color: Colors.grey[200], child: Text('{"value": 25.5, "unit": "%"}')),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text("Ok"))],
      ),
    );
  }

  Future<void> _scanAndIdentify(BuildContext context) async {
    // 1. İzin Kontrolü
    var status = await Permission.camera.request();
    
    if (status.isGranted) {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      
      // 2. Görüntü seçildiyse işlem yap
      if (image != null) {
        try {
          var result = await apiService.identifyPlant(File(image.path));
          
          showDialog(
            context: context, 
            builder: (ctx) => AlertDialog(
            title: Text("AI Analysis"),
            content: Text("Plant: ${result['plant_name']}\ Care: ${result['care_tips']}"),
            actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Ok"))],
          ),
        );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Connection error: $e"))
          );
        }
      }
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Camera permission cannot be obtained!"))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("PlantCare AI"),
        actions: [
          IconButton(
      icon: Icon(Icons.settings),
      onPressed: () async {
        // Ayarlar sayfasına git ve döndüğünde sayfayı yenile
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SettingsScreen()),
        );
        
        // Eğer ayarlardan geri döndüyse MQTT bağlantısını yeniden başlat
        if (result == true) {
          _initMqtt(); 
        }
      },
    ),
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: _showMqttInstructions, // Kullanıcı yönergeyi burada görür
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: LinearGradient(
                  colors: [Color(0xFF2D5A27), Color(0xFF4F8C48)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: () => _scanAndIdentify(context),
                  icon: Icon(Icons.camera_alt, size: 30, color: Colors.white),
                  label: Text("Scan Plant", style: TextStyle(color: Colors.white, fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 248, 250, 249).withOpacity(0.2),
                    elevation: 0,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Live Sensor Data", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 10),
            Card(
              child: ListTile(
                leading: Icon(Icons.water_drop, color: Colors.blue),
                title: Text("Sensor Data Incoming..."),
                // Artık burada 'soilMoisture' değişkenini kullanıyoruz
                trailing: Text(soilMoisture, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    mqttService.dispose(); // Sayfa kapanınca bağlantıyı kes
    super.dispose();
  }
}