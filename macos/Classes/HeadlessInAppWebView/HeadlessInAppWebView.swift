//
//  HeadlessInAppWebView.swift
//  flutter_inappwebview
//
//  Created by Lorenzo Pichilli on 26/03/21.
//

import Foundation
import FlutterMacOS

public class HeadlessInAppWebView : Disposable {
    static let METHOD_CHANNEL_NAME_PREFIX = "com.pichillilorenzo/flutter_headless_inappwebview_"
    var id: String
    var channelDelegate: HeadlessWebViewChannelDelegate?
    var flutterWebView: FlutterWebViewController?
    
    public init(id: String, flutterWebView: FlutterWebViewController) {
        self.id = id
        self.flutterWebView = flutterWebView
        let channel = FlutterMethodChannel(name: HeadlessInAppWebView.METHOD_CHANNEL_NAME_PREFIX + id,
                                       binaryMessenger: SwiftFlutterPlugin.instance!.registrar!.messenger)
        self.channelDelegate = HeadlessWebViewChannelDelegate(headlessWebView: self, channel: channel)
    }
    
    public func onWebViewCreated() {
        channelDelegate?.onWebViewCreated();
    }
    
    public func prepare(params: NSDictionary) {
        if let view = flutterWebView?.view() {
            view.alphaValue = 0.01
            let initialSize = params["initialSize"] as? [String: Any?]
            if let size = Size2D.fromMap(map: initialSize) {
                setSize(size: size)
            } else {
                view.frame = CGRect(x: 0.0, y: 0.0, width: NSApplication.shared.mainWindow?.contentView?.bounds.width ?? 0.0,
                                    height: NSApplication.shared.mainWindow?.contentView?.bounds.height ?? 0.0)
            }
        }
    }
    
    public func setSize(size: Size2D) {
        if let view = flutterWebView?.view() {
            let width = size.width == -1.0 ? NSApplication.shared.mainWindow?.contentView?.bounds.width ?? 0.0 : CGFloat(size.width)
            let height = size.height == -1.0 ? NSApplication.shared.mainWindow?.contentView?.bounds.height ?? 0.0 : CGFloat(size.height)
            view.frame = CGRect(x: 0.0, y: 0.0, width: width, height: height)
        }
    }
    
    public func getSize() -> Size2D? {
        if let view = flutterWebView?.view() {
            return Size2D(width: Double(view.frame.width), height: Double(view.frame.height))
        }
        return nil
    }
    
    public func disposeAndGetFlutterWebView(withFrame frame: CGRect) -> FlutterWebViewController? {
        let newFlutterWebView = flutterWebView
        if let view = flutterWebView?.view() {
            // restore WebView frame and alpha
            view.frame = frame
            view.alphaValue = 1.0
            // remove from parent
            view.removeFromSuperview()
            dispose()
        }
        return newFlutterWebView
    }
    
    
    public func dispose() {
        channelDelegate?.dispose()
        channelDelegate = nil
        HeadlessInAppWebViewManager.webViews[id] = nil
        flutterWebView = nil
    }
    
    deinit {
        debugPrint("HeadlessInAppWebView - dealloc")
        dispose()
    }
}
