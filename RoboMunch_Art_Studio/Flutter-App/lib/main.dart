import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io'; // 'File' hatasını çözmek için
import 'package:record/record.dart'; // 'AudioRecorder', 'RecordConfig' ve 'AudioEncoder' hataları için
import 'package:path_provider/path_provider.dart'; // 'getTemporaryDirectory' hatası için

void main() {
  runApp(const RoboMunchApp());
}

class RoboMunchApp extends StatelessWidget {
  const RoboMunchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RoboMunch AI',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1E140F), // Koyu kahve arka plan
      ),
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // IP Tanımlamaları 
  final String backendLocalUrl = "http://:8000"; // Bilgisayarın Yerel IP'si
  final String backendCloudUrl = "https://.onrender.com"; // Bulut VM IP'si

  final AudioRecorder _audioRecorder = AudioRecorder();
  final TextEditingController _promptController = TextEditingController();
  final TextEditingController _chatController = TextEditingController();
  
  List<Map<String, String>> chatMessages = [
    {"sender": "MUNCH", "text": "A surreal portrait of a steampunk cyborg puzzle..."}
  ];
  
  Uint8List? _imageBytes; // Üretilen resmin byte dizisi
  bool _isLoadingImage = false;
  bool _isLoadingChat = false;
  bool _isRecording = false;

  // --- TASK 1: LOCAL BACKEND İSTEKLERİ ---
  
  // Ses kaydı ve Metne Çevirme (Speech-to-Text)
  // --- Ses Kaydı ve Sunucudaki Wav2Vec2 Modeline Gönderme ---
  void _listenVoice() async {
    try {
      // 1. Mikrofon izni kontrolü
      if (await _audioRecorder.hasPermission()) {
        if (!_isRecording) {
          // --- KAYDI BAŞLATMA ---
          final directory = await getTemporaryDirectory();
          final String filePath = '${directory.path}/audio_input.wav';

          // Modelin rahat okuması için standart WAV formatında kayıt başlatıyoruz
          await _audioRecorder.start(
            const RecordConfig(encoder: AudioEncoder.wav), 
            path: filePath
          );

          setState(() {
            _isRecording = true;
            _chatController.text = "Recording... Press the microphone again to stop.";
          });
        } else {
          // --- KAYDI DURDURMA VE SUNUCUYA GÖNDERME ---
          final String? path = await _audioRecorder.stop();
          setState(() {
            _isRecording = false;
            _isLoadingChat = true;
            _chatController.clear();
          });

          if (path != null) {
            // Kaydedilen ses dosyasını alıyoruz
            final audioFile = File(path);
            final uri = Uri.parse('$backendLocalUrl/api/speech-to-text'); // Django'daki endpoint'iniz
            final request = http.MultipartRequest('POST', uri);

            request.files.add(
              await http.MultipartFile.fromPath(
                'audio', // Django'da request.FILES['audio'] 
                audioFile.path,
              ),
            );

            final streamedResponse = await request.send();
            final response = await http.Response.fromStream(streamedResponse);

            if (response.statusCode == 200) {
              final Map<String, dynamic> data = jsonDecode(response.body);
              String recognizedText = data["text"]; // Django'dan dönen metin

              setState(() {
                // Sunucudan gelen metni direkt mesaj yazma alanına dolduruyoruz
                _chatController.text = recognizedText;
              });
            } else {
              throw Exception("Audio processing error: ${response.statusCode}");
            }
          }
        }
      }
    } catch (e) {
      print("Audio recording/server error: $e");
      setState(() {
        _isRecording = false;
        _isLoadingChat = false;
        _chatController.text = "Audio recognition failed.";
      });
    } finally {
      setState(() => _isLoadingChat = false);
    }
  }

  // LLM'e Mesaj Gönderme
  void _sendChatMessage() async {
    if (_chatController.text.trim().isEmpty) return;
    
    String userText = _chatController.text;
    setState(() {
      chatMessages.add({"sender": "YOU", "text": userText});
      _chatController.clear();
      _isLoadingChat = true;
    });

    try {
      // Örnek POST isteği
      final response = await http.post(
        Uri.parse('$backendLocalUrl/api/chat'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"message": userText}),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          chatMessages.add({"sender": "MUNCH", "text": data["reply"]});
        });
      }
    } catch (e) {
      setState(() {
        chatMessages.add({"sender": "MUNCH", "text": "Error: Failed to connect to local server."});
      });
    } finally {
      setState(() => _isLoadingChat = false);
    }
  }

  // Resim Üretme (Text-to-Image)
  
  void _paintImage() async {
  if (_promptController.text.trim().isEmpty) return;
  setState(() => _isLoadingImage = true);

  try {
    final response = await http.post(
      Uri.parse('$backendLocalUrl/api/paint'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"prompt": _promptController.text}),
    );

    if (response.statusCode == 200) {
      setState(() {
        // Gelen cevabı byte dizisi olarak kaydediyoruz
        _imageBytes = response.bodyBytes; 
      });
    }
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error occurred while generating image.')),
    );
  } finally {
    setState(() => _isLoadingImage = false);
  }
}

  // --- TASK 2: CLOUD BACKEND İSTEKLERİ ---
  
  void _colorizeOrResolution() async {
    if (_imageBytes == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('First, you need to generate an image in the Art Studio section!')),
      );
      return;
    }
    
    setState(() => _isLoadingImage = true); // Yükleniyor animasyonunu başlat

    try {
      // 1. ADIM: /convert/grayscale endpoint'ine resmi gönderip siyah-beyaz halini alma
      final uri = Uri.parse('$backendCloudUrl/convert/grayscale');
      final request = http.MultipartRequest('POST', uri);

      // Hafızadaki byte dizisini (Uint8List) sanki bir dosyaymış gibi isteğe ekliyoruz:
      request.files.add(
        http.MultipartFile.fromBytes(
          'image', // Django'nun request.FILES['image'] içinde beklediği anahtar kelime
          _imageBytes!,
          filename: 'input_image.png',
        ),
      );

      // İsteği gönderiyoruz
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        // Buluttan gelen siyah-beyaz resmin byte'larını ekrandaki resim kutusuna basıyoruz
        setState(() {
          _imageBytes = response.bodyBytes;
        });

        // 2. ADIM: /get/resolution endpoint'ini tetikleyip bilgi alma
        final resUri = Uri.parse('$backendCloudUrl/get/resolution');
        final resRequest = http.MultipartRequest('POST', resUri);
        
        resRequest.files.add(
          http.MultipartFile.fromBytes(
            'image',
            _imageBytes!, // Yeni güncellenen siyah-beyaz resmin byte'larını gönderiyoruz
            filename: 'grayscale_image.png',
          ),
        );

        final resStream = await resRequest.send();
        final resResponse = await http.Response.fromStream(resStream);

        if (resResponse.statusCode == 200) {
          final Map<String, dynamic> dimensions = jsonDecode(resResponse.body);
          
          // Gelen genişlik ve yükseklik bilgisini alt bildirim (SnackBar) olarak ekranda gösteriyoruz
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF4A2E20),
              content: Text(
                'Image Converted to Grayscale! Resolution: ${dimensions["width"]} x ${dimensions["height"]}',
                style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
              ),
            ),
          );
        }
      } else {
        throw Exception("Server error code returned: ${response.statusCode}");
      }
    } catch (e) {
      print("Cloud API error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cloud server error: The server might be offline, please try again later.')),
      );
    } finally {
      setState(() => _isLoadingImage = false); // Yükleniyor animasyonunu bitir
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF322018), Color(0xFF120A07)], 
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header 
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'ROBO MUNCH',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white70, fontFamily: 'serif'),
                    ),
                    const CircleAvatar(
                      backgroundColor: Colors.amber,
                      child: Icon(Icons.person, color: Colors.black),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                const Center(child: Text('Art Studio', style: TextStyle(color: Colors.grey, fontSize: 16))),
                const SizedBox(height: 10),

                // 1. Image Output Box
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
            ),
                  child: _isLoadingImage 
                    ? const Center(child: CircularProgressIndicator())
                    : (_imageBytes != null 
                      ? Image.memory(_imageBytes!, fit: BoxFit.cover) // Link yerine hafızadaki byte'tan okuyor
                      : const Center(child: Text('Image will be displayed here', style: TextStyle(color: Colors.white30)))),
                ),
                const SizedBox(height: 12),

                // 2. Prompt Input Box & Paint Button
                TextField(
                  controller: _promptController,
                  decoration: InputDecoration(
                    hintText: 'Type your prompt here...',
                    filled: true,
                    fillColor: const Color(0xFF231712),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.brush, color: Colors.amber),
                      onPressed: _paintImage,
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                ),
                const SizedBox(height: 8),

                // Colorize Button (Bulut Sunucusu İçin)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A2E20)),
                  onPressed: _colorizeOrResolution,
                  icon: const Icon(Icons.palette),
                  label: const Text('colorize (Cloud VM)'),
                ),

                const Divider(color: Colors.white24, height: 30),
                const Center(child: Text('Chat Studio', style: TextStyle(color: Colors.grey, fontSize: 16))),
                const SizedBox(height: 10),

                // 3. Chat Output Box
                Container(
                  height: 180,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF231712),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _isLoadingChat 
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          itemCount: chatMessages.length,
                          itemBuilder: (context, index) {
                            final msg = chatMessages[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Text(
                                '${msg["sender"]}: ${msg["text"]}',
                                style: TextStyle(
                                  color: msg["sender"] == "YOU" ? Colors.amber : Colors.white,
                                  fontWeight: msg["sender"] == "YOU" ? FontWeight.bold : FontWeight.normal
                                ),
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 12),

                // 4. Chat Input Box (Ses ve Gönder Butonlu Alt Panel)
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _isRecording ? Icons.stop_circle : Icons.mic, 
                        color: _isRecording ? Colors.red : Colors.amber
                      ),
                      onPressed: _listenVoice,
                      ),
                    Expanded(
                      child: TextField(
                        controller: _chatController,
                        decoration: InputDecoration(
                          hintText: 'Type your message here...',
                          filled: true,
                          fillColor: const Color(0xFF190F0B),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.amber),
                      onPressed: _sendChatMessage,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}