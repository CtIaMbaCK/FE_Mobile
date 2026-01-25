import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Load Google Maps API Key từ .env
    if let path = Bundle.main.path(forResource: ".env", ofType: nil),
       let contents = try? String(contentsOfFile: path),
       let apiKey = contents.components(separatedBy: "\n")
         .first(where: { $0.hasPrefix("GOOGLE_MAPS_API_KEY=") })?
         .replacingOccurrences(of: "GOOGLE_MAPS_API_KEY=", with: "") {
      GMSServices.provideAPIKey(apiKey)
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
