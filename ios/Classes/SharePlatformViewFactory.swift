
//
//  SharePlatformViewFactory.swift
//  flutter_to_airplay
//
//  Created by Junaid Rehmat on 22/08/2020.
//

import Foundation
import Flutter

class SharePlatformViewFactory: NSObject, FlutterPlatformViewFactory {
    let _messenger: FlutterBinaryMessenger
    let pluginInstance: SwiftFlutterToAirplayPlugin  // Add a reference to the plugin instance

    init(messenger: FlutterBinaryMessenger & NSObjectProtocol, pluginInstance: SwiftFlutterToAirplayPlugin) {
        _messenger = messenger
        self.pluginInstance = pluginInstance  // Initialize the plugin instance
    }

    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        let arguments = args as! [String: Any]
        
        if let viewClass = arguments["class"] as? String {
            if viewClass == "AirplayRoutePicker" {
                // Pass the pluginInstance when creating the FlutterRoutePickerView
                let pickerView = FlutterRoutePickerView(
                    messenger: _messenger,
                    viewId: viewId,
                    arguments: arguments,
                    pluginInstance: pluginInstance
                )
                pickerView.hidePicker()
                return pickerView
            }
            else if viewClass == "FlutterAVPlayerView" {
                let pickerView = FlutterAVPlayer(frame: frame, viewIdentifier: viewId, arguments: arguments, binaryMessenger: _messenger)
                return pickerView
            }
        }
        
        return UIView() as! FlutterPlatformView
    }
    
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}
