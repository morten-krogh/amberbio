import UIKit

let adbuddiz_publisherkey = "fa82bb57-40fd-4de6-876b-8d5f97400a79"

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

        func applicationWillEnterForeground(application: UIApplication) {}

        func applicationDidBecomeActive(application: UIApplication) {
                AdBuddiz.setPublisherKey(adbuddiz_publisherkey)
                AdBuddiz.setTestModeActive()  // remove
                AdBuddiz.setLogLevel(ABLogLevelInfo) // remove
                AdBuddiz.cacheAds()
                state.store.app_did_become_active()
        }

        func applicationWillTerminate(application: UIApplication) {}
}
