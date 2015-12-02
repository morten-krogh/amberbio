import Foundation
import StoreKit

let store_product_ids = [
        "com.amberbio.product.ads",
        "com.amberbio.product.donation_1",
        "com.amberbio.product.donation_2",
        "com.amberbio.product.donation_3",
        "com.amberbio.product.donation_4",
        "com.amberbio.product.donation_5",
        "com.amberbio.product.donation_6",
        "com.amberbio.product.donation_7",
        "com.amberbio.product.donation_8"
]

class Store: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver, AdBuddizDelegate {

        let database: Database

        var request_products_pending = false
        var restoring_pending = false

        var purchased_product_ids = [] as Set<String>

        let ads_time_first_showing = 5.0
        let ads_time_other_showings = 5.0
        var ads_removed = false
        var ads_first_ad = true
        var ads_time_of_last = NSDate()
        var ad_should_be_shown_now = false
        var ad_shown = false
        var ad_was_shown = false
        var store_active = false

        var products = [] as [SKProduct]

        var remove_ads_product: SKProduct?
        var donations = [] as [SKProduct]

        init(database: Database) {
                self.database = database
                super.init()
                get_purchased_product_ids()
                set_all()
                if !ads_removed {
                        AdBuddiz.setDelegate(self)
                }
        }

        func app_did_become_active() {
                ads_first_ad = true
                ads_time_of_last = NSDate()
        }

        func ads_check() {
                if ad_was_shown {
                        ad_was_shown = false
                        ads_time_of_last = NSDate()
                } else if !ads_removed && !store_active && state.page_state.name == "home" && AdBuddiz.isReadyToShowAd() {
                        let time_since_last = NSDate().timeIntervalSinceDate(ads_time_of_last)
                        if time_since_last > ads_time_other_showings || (ads_first_ad && time_since_last > ads_time_first_showing) {
                                ads_first_ad = false
                                ad_should_be_shown_now = true
                                state.page_state = ModuleStoreState()
                        }
                }

                if store_active && state.page_state.name != "module_store" {
                        store_active = false
                }
        }

        func show_ad() -> Bool {
                store_active = true
                if ad_should_be_shown_now && !ad_shown && AdBuddiz.isReadyToShowAd() {
                        ad_shown = true
                        ad_should_be_shown_now = false
                        return true
                } else {
                        return false
                }
        }

        func didHideAd() {
                ad_shown = false
                ad_was_shown = true
                state.render()
        }

        func didFailToShowAd(error: AdBuddizError) {
                ad_shown = false
                ad_was_shown = true
                state.render()
        }

        func request_products() {
                let products_request = SKProductsRequest(productIdentifiers: Set<String>(store_product_ids))
                products_request.delegate = self
                products_request.start()
                request_products_pending = true
                restoring_pending = false
        }

        func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
                self.products = response.products
                set_all()
                for invalid_product_id in response.invalidProductIdentifiers {
                        print("Invalid product id: \(invalid_product_id)")
                }

                request_products_pending = false
                conditional_render()
        }

        func buy(product product: SKProduct) {
                print(SKPaymentQueue.canMakePayments())

                let payment = SKMutablePayment(product: product)
                SKPaymentQueue.defaultQueue().addPayment(payment)
        }

        func restore() {
                SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
                restoring_pending = true
                conditional_render()
        }

        func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
                for transaction in transactions {
                        switch transaction.transactionState {
                        case .Purchasing:
                                break
                        case .Deferred:
                                break
                        case .Failed:
                                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                        case .Purchased:
                                insert_purchased_product_id(product_id: transaction.payment.productIdentifier)
                                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                        case .Restored:
                                insert_purchased_product_id(product_id: transaction.payment.productIdentifier)
                                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                        }
                }
                restoring_pending = false
                conditional_render()
        }

        func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue) {
                if restoring_pending {
                        restoring_pending = false
                        conditional_render()
                }
        }

        func paymentQueue(queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: NSError) {
                restoring_pending = false
                conditional_render()
        }

        func set_all() {
                donations = []
                for product in products {
                        let product_id = product.productIdentifier
                        if product_id.hasPrefix("com.amberbio.product.donation") {
                                donations.append(product)
                        } else {
                                remove_ads_product = product
                        }
                }

                if purchased_product_ids.contains("com.amberbio.product.ads") {
                        ads_removed = true
                }
        }

        func get_purchased_product_ids() {
                let product_ids = sqlite_get_store_product_ids(database: database)
                purchased_product_ids = Set<String>(product_ids)
        }

        func insert_purchased_product_id(product_id product_id: String) {
                if product_id == "com.amberbio.product.ads" {
                        if store_product_ids.indexOf(product_id) != nil {
                                sqlite_insert_store_product_id(database: database, store_product_id: product_id)
                                purchased_product_ids.insert(product_id)
                                set_all()
                        }
                }
        }

        func conditional_render() {
                if state.page_state.name == "module_store" {
                        state.render()
                }
        }
}
