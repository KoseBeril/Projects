import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
//import 'package:flutter/services.dart' show rootBundle;
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

// MQTT bağlantısını sağlamak ve gerekli işlemleri yapmak için bir servis sınıfı oluşturuyoruz. Bu sınıf, MQTT broker ile güvenli bir şekilde iletişim kurmamızı sağlar
// ve gelen mesajları dinleyerek uygulamamızda kullanılabilir hale getirir.

// Sertifika verisini doğrudan kod içinde tanımlıyoruz Bu sertifika Let's Encrypt'in ISRG Root X1 sertifikasıdır. Bu sertifika, TLS bağlantıları için güvenilir bir kök sertifika olarak kullanılır. Sertifika verisi PEM formatında ve çok satırlı bir string olarak tanımlanmıştır.
const String isrgRootX1Pem = '''-----BEGIN CERTIFICATE-----
 sertifika detayları buraya gelecek
-----END CERTIFICATE----- ''';

class MqttService {
  late MqttServerClient client;
  StreamSubscription? _subscription; // Dinleyiciyi yönetmek için

  final StreamController<Map<String, dynamic>> _sensorController = StreamController.broadcast();
  Stream<Map<String, dynamic>> get sensorStream => _sensorController.stream;

  Future<bool> connect(String broker, String clientId, String username, String password) async {
    client = MqttServerClient(broker, clientId);
    // MqttService içindeki connect metodunda şu değişiklikleri yap:
    client.port = 8883;   // Portu TLS için güncelle
    client.secure = true; 
    client.logging(on: true);

    final SecurityContext context = SecurityContext.defaultContext;
    final Uint8List certBytes = Uint8List.fromList(utf8.encode(isrgRootX1Pem));
    context.setTrustedCertificatesBytes(certBytes);
    client.securityContext = context;

  /* şu anlık gerekli değil, sertifika doğrulamasını atlamak için kullanılabilir

    client.onBadCertificate = (dynamic certificate) {
      return true; // Sertifikayı kontrol etmeden "güvenli kabul et"
    };
    client.logging(on: false);
  */
    final connMess = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .withWillTopic('willtopic')
        .withWillMessage('disconnected')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    client.connectionMessage = connMess;

    try {
      await client.connect(username, password);
      return client.connectionStatus!.state == MqttConnectionState.connected;
    } catch (e) {
      print("Connection Error: $e");
      return false;
    }
  }

  void subscribe(String topic) {
    // Eski aboneliği temizle
    _subscription?.cancel();

    client.subscribe(topic, MqttQos.atLeastOnce);

    _subscription = client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final MqttPublishMessage recMess = c![0].payload as MqttPublishMessage;
      final String payload = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      try {
        final Map<String, dynamic> data = jsonDecode(payload);
        _sensorController.add(data);
      } catch (e) {
        print("JSON decode error: $e");
      }
    });
  }
   // Publish mesajını göndermek için bir metod ekleyelim
  void publish(String topic, String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }

  // Bağlantıyı kapatmak ve kaynakları temizlemek için bir metod ekleyelim
  void dispose() {
    _subscription?.cancel();
    _sensorController.close();
    client.disconnect();
  }
}