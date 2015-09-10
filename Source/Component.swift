import UIKit

class Component: UIViewController, MoleculeRangeDelegate {

        func render() {}

        func finish() {}

        func search_action(search_string search_string: String) {}

        var molecule_range_active = false

        func molecule_range_select() {
                molecule_range_active = true
        }

        func molecule_range_cancel() {
                molecule_range_active = false
        }

        func molecule_range_create_data_set(index1 index1: Int, index2: Int) {
                
        }

}
