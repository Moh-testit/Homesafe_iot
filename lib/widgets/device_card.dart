import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DeviceCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final bool isSwitch;

  const DeviceCard({
    super.key,
    required this.icon,
    required this.title,
    this.isSwitch = false,
  });

  @override
  _DeviceCardState createState() => _DeviceCardState();
}

class _DeviceCardState extends State<DeviceCard> {
  bool _isSwitched = false;
  String doorStatus = 'Unknown';

  @override
  void initState() {
    super.initState();
    fetchDoorStatus(); // Fetch initial door status when widget initializes
  }

  Future<void> fetchDoorStatus() async {
    try {
      print('Attempting to fetch door status...');
      final response = await http.get(Uri.parse('http://172.20.10.14/status'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Door Status: $data');
        setState(() {
          doorStatus = data['status'];
          _isSwitched = doorStatus.toLowerCase() == 'open';
        });
      } else {
        print(
            'Failed to load door status with status code: ${response.statusCode}');
        throw Exception('Failed to load door status');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> setDoorStatus(bool open) async {
    try {
      final action = open ? 'open' : 'close';
      print('Setting door status to $action...');
      final response = await http.get(Uri.parse('http://172.20.10.14/$action'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Door Status: $data'); // Log the response
        setState(() {
          doorStatus = data['status'];
          _isSwitched = doorStatus.toLowerCase() == 'open';
        });
      } else {
        print(
            'Failed to set door status with status code: ${response.statusCode}');
        throw Exception('Failed to set door status');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(widget.icon, size: 50),
          Text(widget.isSwitch ? '${widget.title} $doorStatus' : widget.title),
          if (widget.isSwitch)
            Switch(
              value: _isSwitched,
              onChanged: (bool value) {
                setState(() {
                  _isSwitched = value;
                });
                setDoorStatus(value); // Set the door status based on switch
              },
            ),
        ],
      ),
    );
  }
}
