import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'widgets/device_card.dart';
import 'video_camera.dart'; // Importez la page de la caméra

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  setCurrentIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart-Home'),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                const Text(
                  'Welcome Home, Sidy',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    children: const <Widget>[
                      // DeviceCard(
                      //   icon: Icons.thermostat,
                      //   title: 'Temperature',
                      // ),
                      // DeviceCard(
                      //   icon: Icons.water_damage,
                      //   title: 'Humidity',
                      // ),
                      DeviceCard(
                        icon: Icons.door_front_door_outlined,
                        title: 'Door',
                        isSwitch: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const VideoCameraPage(), // Affiche le contenu de la page de la caméra
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        onTap: (index) => setCurrentIndex(index),
        backgroundColor: Colors.blue,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 600),
        height: 50,
        items: const <Widget>[
          Icon(
            Icons.home,
            color: Color.fromARGB(255, 2, 38, 68),
          ),
          Icon(
            Icons.video_camera_front_outlined,
            color: Color.fromARGB(255, 164, 7, 5),
          ),
        ],
      ),
    );
  }
}
