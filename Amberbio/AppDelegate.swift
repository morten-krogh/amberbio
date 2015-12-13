import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

        var window: UIWindow?

        func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

                state_init()

                let screen: CGRect = UIScreen.mainScreen().bounds
                window = UIWindow(frame: screen)
                window!.backgroundColor = UIColor.whiteColor()

                window!.rootViewController = state.root_component
                window!.makeKeyAndVisible()
                
                state.render()

                return true
        }

        func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
                if let (file_name, content) = file_fetch_and_remove(url: url) {
                        state.insert_file(name: file_name, type: "imported", data: content)
                        state.navigate(page_state: ImportDataState())
                        state.render()
                        return true
                } else {
                        return false
                }
        }

        func applicationWillResignActive(application: UIApplication) {}

        func applicationDidEnterBackground(application: UIApplication) {}

        func applicationWillEnterForeground(application: UIApplication) {
                print("app delegate application will enter foreground")
                state.donation_manager.app_will_enter_foreground()
                state.render()
        }

        func applicationDidBecomeActive(application: UIApplication) {}

        func applicationWillTerminate(application: UIApplication) {}
}
