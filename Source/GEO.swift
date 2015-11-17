import UIKit

enum GEOStatus {
        case Input
        case Downloading
        case Importing
}

class GEOState: PageState {

        var state = GEOStatus.Input
        var geo_id = ""

        override init() {
                super.init()
                name = "geo"
                title = astring_body(string: "Gene expression omnibus")
                info = "Download data set and series records from Gene expression omnibus (GEO).\n\nRDatasets have ids of the form GDSnnnnn.\n\nSeries have ids of the form GSEnnnn.\n\n"
        }
}

class GEO: Component {

        var geo_state: GEOState!

        let info_label = UILabel()
        let message_label = UILabel()
        let text_field = UITextField()
        let submit_button = UIButton(type: .System)

        override func viewDidLoad() {
                super.viewDidLoad()


        }

        override func viewWillLayoutSubviews() {
                super.viewWillLayoutSubviews()


        }

        override func render() {
                geo_state = state.page_state as! GEOState




        }














}
