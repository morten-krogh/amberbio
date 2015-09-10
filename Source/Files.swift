import Foundation

func file_create_temp_file_url(file_name file_name: String) -> NSURL {
        let directory_url = NSURL(fileURLWithPath: NSTemporaryDirectory())
        let file_url = directory_url.URLByAppendingPathComponent(file_name)
        return file_url
}

func file_create_temp_file_url() -> NSURL {
        let file_name = generate_random_id()
        return file_create_temp_file_url(file_name: file_name)
}

func file_create_temp_path() -> String {
        return file_create_temp_file_url().path!
}

func file_create_temp_file_url(file_name file_name: String, content: NSData) -> NSURL? {
        let file_url = file_create_temp_file_url(file_name: file_name)
        let file_creaton_success = NSFileManager.defaultManager().createFileAtPath(file_url.path!, contents: content, attributes: nil)
        return file_creaton_success ? file_url : nil
}

func file_create_temp_file_url(content content: NSData) -> NSURL {
        let file_name = generate_random_id()
        return file_create_temp_file_url(file_name: file_name, content: content) ?? NSURL()
}

func file_exists(url url: NSURL) -> Bool {
        if let path = url.path {
                return NSFileManager.defaultManager().fileExistsAtPath(path)
        } else {
                return false
        }
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
        if let path = url.path, let file_name = url.lastPathComponent {
                if let content = file_manager.contentsAtPath(path) {
                        do {
                                try file_manager.removeItemAtURL(url)
                        } catch _ {
                        }
                        return (file_name, content)
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

func file_app_directory_url(file_name file_name: String) -> NSURL {
        let app_directory = fetch_app_directory()!
        return app_directory.URLByAppendingPathComponent(file_name)
}
