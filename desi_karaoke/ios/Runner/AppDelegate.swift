import Flutter
import UIKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    var spacesFileRepository: SpacesFileRepository?
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        let methodChannel = FlutterMethodChannel(
            name: "desikaraoke.com/filedownloader",
            binaryMessenger: controller.binaryMessenger
        )
        GeneratedPluginRegistrant.register(with: self)
        methodChannel.setMethodCallHandler {
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            let args = call.arguments as? [String: String]
            switch call.method {
            case "getDownloadUrl":
                self.getDownloadURL(path: args?["path"] as String?, result: result)
            case "getFileFromDo":
                self.getFile(path: args?["path"] as String?, result: result)
            default: ()
            }
        }
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func getDownloadURL(path: String?, result: @escaping FlutterResult) {
        if spacesFileRepository == nil {
            spacesFileRepository = SpacesFileRepository()
        }
        spacesFileRepository?.getPresignedUrl(path: path ?? "nofile", callback: {
            (item1: NSURL?, _: Error?) -> Void in result(item1?.absoluteString)
        })
    }

    func getFile(path: String?, result: @escaping FlutterResult) {
        if spacesFileRepository == nil {
            spacesFileRepository = SpacesFileRepository()
        }
        spacesFileRepository?.downloadExampleFile(path: path ?? "nofile", callback: {
            (data: Data?, _: Error?) -> Void in result(data)
        })
    }
}
