import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

        var window: UIWindow?

        func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

                let xml_path = NSBundle.mainBundle().pathForResource("App_Store_Pricing_Matrix", ofType: "xlsx")
                let spreadsheet = BRAOfficeDocumentPackage.open(xml_path)

                let worksheet = spreadsheet.workbook.worksheets[0] as! BRAWorksheet


                //                65let row = worksheet.rows[4] as! BRARow

                //                for cell in row.cells {
                //                        print(cell, cell.stringValue)
                //                }

                for i in 0 ..< worksheet.rows.count {
                        let row = worksheet.rows[i] as! BRARow
                        print(row.cells.count)
                }


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

        func applicationDidBecomeActive(application: UIApplication) {}

        func applicationWillTerminate(application: UIApplication) {}
}
