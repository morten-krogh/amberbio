import UIKit

class MoleculeWebSearch {

        let system_urls = [
                "http://www.google.com/search?q="
        ]

//        var molecule

        var custom_urls = [] as [String]

        init() {
                reset()
        }

        func reset() {

        }

        func url(molecule_index molecule_index: Int) -> NSURL? {
                let molecule_name = state.molecule_names[molecule_index]
                let url = system_urls[0] + molecule_name
                return NSURL(string: url)
        }

        func open_url(molecule_index molecule_index: Int) {
                if let url = url(molecule_index: molecule_index) {
                        UIApplication.sharedApplication().openURL(url)
                }
        }
}
