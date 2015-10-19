import Foundation

class MoleculeWebSearch {

        let system_urls = [
                "http://www.google.com/search?q="
        ]

        var molecule

        var custom_urls = [] as [String]

        init() {
                reset()
        }

        func reset() {

        }

        func url(molecule_index molecule_index: Int) -> NSURL {

                let molecule_name = state.molecule_names[molecule_index]
                let url = system_urls[0] + molecule_name
                return NSURL(string: url)

        }

        func web_search(molecule_index molecule_index) {
                


        }

}