import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_to_airplay/flutter_to_airplay.dart'; // Ensure this import is correct

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const platform = MethodChannel('flutter_to_airplay');

  @override
  void initState() {
    super.initState();

    // Ensure it runs after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _changeButtonImage('airplay', 100.0);
    });
  }

  Future<void> _changeButtonImage(String imageName, double imageSizePercent) async {
    try {
      await platform.invokeMethod('changeButtonImage', {
        'imageName': imageName,
        'imageSizePercent': imageSizePercent,
      });
      print("Successfully changed button image");
    } on PlatformException catch (e) {
      print("Failed to change button image: '${e.message}'.");
    }
  }

  Future<void> _showAirPlayPicker() async {
    try {
      await FlutterToAirplay.showAirPlayPicker(); // Call the method from FlutterToAirplay
      print("Successfully showed AirPlay picker");
    } on PlatformException catch (e) {
      print("Failed to show AirPlay picker: '${e.message}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AirPlay Route Picker')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          AirPlayRoutePickerView(
            tintColor: Colors.red,
            activeTintColor: Colors.green,
            backgroundColor: Colors.white,
          ),
          SizedBox(height: 20), // Reduced space for better UI
          ElevatedButton(
            onPressed: () {
              _changeButtonImage('airplay', 100.0);
            },
            child: Text('Change Button Image'),
          ),
          SizedBox(height: 20), // Added space between buttons
          ElevatedButton(
            onPressed: () {
              _showAirPlayPicker(); // Call the method to show AirPlay picker
            },
            child: Text('Show Picker'),
          ),
        ],
      ),
    );
  }
}