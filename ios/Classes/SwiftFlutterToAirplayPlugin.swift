import Flutter
import UIKit

public class SwiftFlutterToAirplayPlugin: NSObject, FlutterPlugin {

  // Add a property to store the reference of FlutterRoutePickerView
  private var flutterRoutePickerView: FlutterRoutePickerView?

  // Register the plugin with the Flutter registrar
  public static func register(with registrar: FlutterPluginRegistrar) {
    // Create the plugin instance once
    let instance = SwiftFlutterToAirplayPlugin()

    // Register platform views with the plugin instance
    registrar.register(
        SharePlatformViewFactory(messenger: registrar.messenger(), pluginInstance: instance), // Pass pluginInstance here
        withId: "airplay_route_picker_view",
        gestureRecognizersBlockingPolicy: FlutterPlatformViewGestureRecognizersBlockingPolicy(rawValue: 0))

    registrar.register(
        SharePlatformViewFactory(messenger: registrar.messenger(), pluginInstance: instance), // Pass pluginInstance here
        withId: "flutter_avplayer_view",
        gestureRecognizersBlockingPolicy: FlutterPlatformViewGestureRecognizersBlockingPolicy(rawValue: 0))

    // Register method channel with the same instance
    let channel = FlutterMethodChannel(name: "flutter_to_airplay", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  // Handle method calls from Flutter
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if call.method == "changeButtonImage" {
      if let args = call.arguments as? [String: Any], 
         let imageName = args["imageName"] as? String,
         let imageSizePercent = args["imageSizePercent"] as? CGFloat {
        // Change the button image based on the name and size
        changeButtonImage(imageName: imageName, imageSizePercent: imageSizePercent)
        result(nil)
      } else {
        result(FlutterError(code: "INVALID_ARGUMENT", message: "Image name or size is missing", details: nil))
      }
    } else if call.method == "showAirPlayPicker" {
        self.flutterRoutePickerView?.showAirPlayPicker()
        result(nil)
    }else {
      result(FlutterMethodNotImplemented)
    }
  }
  // Method to change the button image
  private func changeButtonImage(imageName: String, imageSizePercent: CGFloat) {
    // Retrieve the FlutterRoutePickerView instance and update the image
    if let view = flutterRoutePickerView {
      // Update the image and background color
      let newSize = view.frameSize/100 * imageSizePercent
      view.buttonImageView.image = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
      view.buttonImageView.frame = CGRect(x: view.frameSize/2-newSize/2, y: view.frameSize/2-newSize/2, width: newSize, height:newSize)
        view.hidePicker()
    } else {
      print("FlutterRoutePickerView is nil.")
    }
  }

  // Store the reference of FlutterRoutePickerView
  func storeFlutterRoutePickerView(view: FlutterRoutePickerView) {
    self.flutterRoutePickerView = view
    print("FlutterRoutePickerView stored: \(view)")
  }
}
