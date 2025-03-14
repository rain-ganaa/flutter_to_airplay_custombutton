import Foundation
import AVKit
import MediaPlayer
import Flutter

class FlutterRoutePickerView: NSObject, FlutterPlatformView {
    public var _flutterRoutePickerView: UIView
    private var _delegate: AVRoutePickerViewDelegate?
    public var buttonImageView: UIImageView!
    public var mainTintColor: UIColor!
    public var activeTintColor: UIColor!
    private var pluginInstance: SwiftFlutterToAirplayPlugin?
    public var frameSize: CGFloat!

    init(
        messenger: FlutterBinaryMessenger,
        viewId: Int64,
        arguments: Dictionary<String, Any>,
        pluginInstance: SwiftFlutterToAirplayPlugin
    ) {
        // Initialize the _flutterRoutePickerView first
        if #available(iOS 11.0, *) {
            let tempView: AVRoutePickerView = AVRoutePickerView(frame: .init(x: 0.0, y: 0.0, width: 44.0, height: 44.0))
            tempView.tintColor = .clear
            tempView.activeTintColor = .clear
            self._flutterRoutePickerView = tempView
            
        } else {
            let tempView = MPVolumeView(frame: .init(x: 0.0, y: 0.0, width: 44.0, height: 44.0))
            tempView.showsVolumeSlider = false
            tempView.tintColor = .clear
            self._flutterRoutePickerView = tempView
        }
        
        super.init()
        
        // Initialize buttonImageView
        self.pluginInstance = pluginInstance
        self.pluginInstance?.storeFlutterRoutePickerView(view: self)
        let _buttonImageView = UIImageView(frame: CGRect.zero)
        _buttonImageView.contentMode = .scaleAspectFit
        self.buttonImageView = _buttonImageView

        // Adjust buttonImageView frame based on _flutterRoutePickerView's size
        _buttonImageView.frame = CGRect(x: 0, y: 0, width: self._flutterRoutePickerView.frame.size.width, height: self._flutterRoutePickerView.frame.size.height)
        self._flutterRoutePickerView.addSubview(self.buttonImageView)
        hidePicker()
        
        // Set tint color and background color if available in arguments
        if #available(iOS 11.0, *) {
            if let tintColor = arguments["tintColor"] {
                let color = tintColor as! Dictionary<String, Any>
                self.mainTintColor = FlutterRoutePickerView.mapToColor(color)
                _buttonImageView.tintColor = self.mainTintColor
            }

            if let tintColor = arguments["activeTintColor"] {
                let color = tintColor as! Dictionary<String, Any>
                self.activeTintColor = FlutterRoutePickerView.mapToColor(color)
            }

            if let tintColor = arguments["backgroundColor"] {
                let color = tintColor as! Dictionary<String, Any>
                // self._flutterRoutePickerView.backgroundColor = FlutterRoutePickerView.mapToColor(color)
                _buttonImageView.backgroundColor = FlutterRoutePickerView.mapToColor(color)
            }

            if #available(iOS 13.0, *) {
                if let prioritizesVideoDevices = arguments["prioritizesVideoDevices"] as? Bool {
                    (self._flutterRoutePickerView as! AVRoutePickerView).prioritizesVideoDevices = prioritizesVideoDevices
                }
            }
            // Set up the delegate for the route picker
            self._delegate = FlutterRoutePickerDelegate(viewId: viewId, messenger: messenger, flutterRoutePickerView:self)
            (self._flutterRoutePickerView as! AVRoutePickerView).delegate = self._delegate
            self.frameSize = _flutterRoutePickerView.frame.size.height
            pluginInstance.storeFlutterRoutePickerView(view: self) 
        }
    }
    public func hidePicker(){
        self._flutterRoutePickerView.tintColor = .clear
        self._flutterRoutePickerView.backgroundColor = .clear
    }
    func view() -> UIView {
        return _flutterRoutePickerView
    }
    func showAirPlayPicker() {
        if let routePickerButton = _flutterRoutePickerView.subviews.first(where: { $0 is UIButton }) as? UIButton {
            routePickerButton.sendActions(for: .touchUpInside)
        }
    }
    static func mapToColor(_ map: Dictionary<String, Any>) -> UIColor {
        return UIColor(
            red: CGFloat(map["red"] as! Int) / 255,
            green: CGFloat(map["green"] as! Int) / 255,
            blue: CGFloat(map["blue"] as! Int) / 255,
            alpha: CGFloat(map["alpha"] as! Int) / 255
        )
    }
}

class FlutterRoutePickerDelegate: NSObject, AVRoutePickerViewDelegate {
    let _methodChannel: FlutterMethodChannel
    weak var flutterRoutePickerView: FlutterRoutePickerView?  // Make it weak to avoid strong reference cycle

    init(viewId: Int64, messenger: FlutterBinaryMessenger, flutterRoutePickerView: FlutterRoutePickerView) {
        _methodChannel = FlutterMethodChannel(name: "flutter_to_airplay#\(viewId)", binaryMessenger: messenger)
        self.flutterRoutePickerView = flutterRoutePickerView
        self.flutterRoutePickerView?._flutterRoutePickerView.tintColor = .clear
    }

    func routePickerViewWillBeginPresentingRoutes(_ routePickerView: AVRoutePickerView) {
        print("routePickerViewWillBeginPresentingRoutes")
        
        // Print the actual type of routePickerView
        print("routePickerView is of type: \(type(of: routePickerView))")
        
        // If the delegate is properly assigned, use it directly
        if let flutterRoutePickerView = self.flutterRoutePickerView {
            print("Using the stored FlutterRoutePickerView")
            flutterRoutePickerView.buttonImageView.tintColor = flutterRoutePickerView.activeTintColor
        } else {
            print("Failed to retrieve FlutterRoutePickerView")
        }

        _methodChannel.invokeMethod("onShowPickerView", arguments: nil)
    }

    func routePickerViewDidEndPresentingRoutes(_ routePickerView: AVRoutePickerView) {
        if let flutterRoutePickerView = self.flutterRoutePickerView {
            flutterRoutePickerView.buttonImageView.tintColor = flutterRoutePickerView.mainTintColor
        }
        _methodChannel.invokeMethod("onClosePickerView", arguments: nil)
    }
}
