import Foundation

func file_create_temp_path() -> String {
        let file_name = generate_random_id()
        let path = NSTemporaryDirectory().stringByAppendingPathComponent(file_name)
        return path
}

func file_create_temp(file_name file_name: String, content: NSData) -> NSURL? {
        let file_manager = NSFileManager.defaultManager()

        let path = NSTemporaryDirectory().stringByAppendingPathComponent(file_name)
        let file_creation_success = file_manager.createFileAtPath(path, contents: content, attributes: nil)
        if file_creation_success {
                return NSURL.fileURLWithPath(path, isDirectory: false)
        } else {
                return nil
        }
}

func file_create_temp_path(content content: NSData) -> String {
        let path = file_create_temp_path()
        let file_manager = NSFileManager.defaultManager()
        file_manager.createFileAtPath(path, contents: content, attributes: nil)
        return path
}

func file_exists(path path: String) -> Bool {
        return NSFileManager.defaultManager().fileExistsAtPath(path)
}

func file_remove(url url: NSURL) {
        do {
                try NSFileManager.defaultManager().removeItemAtURL(url)
        } catch _ {
        }
}

func file_remove(path path: String) {
        do {
                try NSFileManager.defaultManager().removeItemAtPath(path)
        } catch _ {
        }
}

func file_fetch_and_remove(url url: NSURL) -> (file_name: String, content: NSData)? {
        let file_manager = NSFileManager.defaultManager()
        if let path = url.path {
                if let content = file_manager.contentsAtPath(path) {
                        do {
                                try file_manager.removeItemAtURL(url)
                        } catch _ {
                        }
                        return (path.lastPathComponent, content)
                } else {
                        return nil
                }
        } else {
                return nil
        }
}

func fetch_app_directory() -> NSURL? {
        let file_manager = NSFileManager.defaultManager()

        let possibleURLs = file_manager.URLsForDirectory(NSSearchPathDirectory.ApplicationSupportDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask) as [NSURL]

        var app_directory = nil as NSURL?

        if !possibleURLs.isEmpty {
                let app_support_directory = possibleURLs[0]
                if let appBundleID = NSBundle.mainBundle().bundleIdentifier {
                        app_directory = app_support_directory.URLByAppendingPathComponent(appBundleID)
                        do {
                                try file_manager.createDirectoryAtURL(app_directory!, withIntermediateDirectories: true, attributes: nil)
                        } catch _ {
                        }
                }
        }

        return app_directory
}

func path_to_file_in_app_directory(file_name file_name: String) -> String {
        let app_directory = fetch_app_directory()!
        return app_directory.URLByAppendingPathComponent(file_name).path!
}
