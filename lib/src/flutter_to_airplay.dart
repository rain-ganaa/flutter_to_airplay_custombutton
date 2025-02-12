import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

/// This widget represents the Airplay route picker view.
class FlutterRoutePickerView extends StatelessWidget {
  const FlutterRoutePickerView({
    Key? key,
    this.tintColor,
    this.activeTintColor,
    this.backgroundColor,
  }) : super(key: key);

  /// Tint color of the Airplay button (default: black).
  final Map<String, int>? tintColor;

  /// Active tint color of the Airplay button (default: blue).
  final Map<String, int>? activeTintColor;

  /// Background color for the route picker (default: transparent).
  final Map<String, int>? backgroundColor;

  // Method to create params for native iOS code.
  Map getCreateParams() {
    Map params = {
      'class': 'FlutterRoutePickerView',
      'tintColor': tintColor,
      'activeTintColor': activeTintColor,
      'backgroundColor': backgroundColor,
    };
    return params;
  }

  @override
  Widget build(BuildContext context) {
    return UiKitView(
      viewType: 'airplay_route_picker_view', // Native view type identifier
      creationParams: getCreateParams(),
      creationParamsCodec: StandardMessageCodec(), // Decode message between Flutter and iOS
    );
  }
}

class FlutterToAirplay {
  static const String name = 'flutter_to_airplay'; // Add this line to define `name`
  static const MethodChannel _channel = MethodChannel(name); // Use `name` here

  static Map<String, dynamic> colorToParams(Color color) {
    return {
      'red': color.red,
      'green': color.green,
      'blue': color.blue,
      'alpha': color.alpha,
    };
  }

  /// Changes the button image on the native side
  static Future<void> changeButtonImage(String imageName, double imageSizePercent) async {
    try {
      await _channel.invokeMethod('changeButtonImage', {
        'imageName': imageName,
        'imageSizePercent': imageSizePercent,
      });
    } on PlatformException catch (e) {
      print("Failed to change button image: '${e.message}'.");
    }
  }
}
