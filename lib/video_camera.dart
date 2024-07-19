import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;

class VideoCameraPage extends StatefulWidget {
  const VideoCameraPage({super.key});

  @override
  _VideoCameraPageState createState() => _VideoCameraPageState();
}

class _VideoCameraPageState extends State<VideoCameraPage> {
  late WebSocketChannel channel;
  bool faceDetected = false;
  Uint8List? frameData;
  Timer? frameUpdateTimer;

  @override
  void initState() {
    super.initState();
    channel = IOWebSocketChannel.connect('ws://10.0.2.2:8765');
    channel.stream.listen((event) {
      final data = jsonDecode(event);
      if (mounted) {
        setState(() {
          faceDetected = data['face_detected'];
          frameData = base64Decode(data['frame']);
        });

        // Si le visage est détecté, envoyez la requête pour ouvrir la porte
        if (faceDetected) {
          openDoor();
        }
      }
    }, onError: (error) {
      print('Error: $error');
    }, onDone: () {
      print('WebSocket connection closed');
    });

    frameUpdateTimer =
        Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (mounted) {
        if (frameData != null) {
          setState(() {});
        }
      }
    });
  }

  Future<void> openDoor() async {
    try {
      final response = await http.get(Uri.parse('http://172.20.10.5/open'));
      if (response.statusCode == 200) {
        print('Door opened');
      } else {
        print('Failed to open door, status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to open door, error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Camera'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Container(
                height: 500,
                color: Colors.black,
                child: frameData != null
                    ? Image.memory(
                        frameData!,
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                      )
                    : const CircularProgressIndicator(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              faceDetected ? "Face Detected" : "No Face Detected",
              style: TextStyle(
                color: faceDetected ? Colors.green : Colors.red,
                fontSize: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    frameUpdateTimer?.cancel();
    channel.sink.close();
    super.dispose();
  }
}
