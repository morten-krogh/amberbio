import UIKit

class StoreFrontState: PageState {

        override init() {
                super.init()
                name = "store_Front"
                title = astring_body(string: "Store")
                info = "The store is used to buy modules.\n\nA bought module is unlocked on this device and other devices with the same Apple ID.\n\nAn unlocked module can be used forever.\n\nTap the button \"Restore modules\" to unlock modules that have been bought on another device or after reinstallation of the app."
        }
}

class StoreFront: Component {

        



}
