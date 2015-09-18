import UIKit

class RemoveMoleculesState: PageState {

        var selected_rows = [] as Set<Int>

        override init() {
                super.init()
                name = "remove_molecules"
                title = astring_body(string: "Remove molecules")
                info = "Create a new data set with fewer molecules.\n\nThe highlighted molecules will be removed.\n\nHighlight and dehighlight molecules by tapping."
        }
}

class RemoveMolecules: Component { //, UITableViewDataSource, UITableViewDelegate {

        






}