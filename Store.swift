import Foundation
import StoreKit

let store_product_ids = [
        "com.amberbio.product.svm",
        "com.amberbio.product.knn",
        "com.amberbio.product.pca",
        "com.amberbio.product.anova",
        "com.amberbio.product.bundle_1"
]

let store_initially_locked_page_names = [
        "svm_factor_selection",
        "knn_factor_selection",
        "pca",
        "anova_factor_selection"
]

let store_product_id_to_page_names = [
        "com.amberbio.product.svm" : ["svm_factor_selection"],
        "com.amberbio.product.knn" : ["knn_factor_selection"],
        "com.amberbio.product.pca" : ["pca"],
        "com.amberbio.product.anova" : ["anova_factor_selection"],
        "com.amberbio.product.bundle_1": ["svm_factor_selection", "knn_factor_selection", "pca", "anova_factor_selection"]
]

class Store: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {

        let database: Database

        var request_products_pending = false
        var restoring_pending = false

        var purchased_product_ids = [] as Set<String>

        var products = [] as [SKProduct]
        var modules_to_purchase = [] as [SKProduct]
        var bundles_to_purchase = [] as [SKProduct]
        var purchased_modules = [] as [SKProduct]

        var locked_page_names = [] as Set<String>

        init(database: Database) {
                self.database = database
                super.init()
                get_purchased_product_ids()
                set_all()
        }

        func request_products() {
                let products_request = SKProductsRequest(productIdentifiers: Set<String>(store_product_ids))
                products_request.delegate = self
                products_request.start()
                request_products_pending = true
        }

        func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
                self.products = response.products
                set_all()
//                for invalid_product_id in response.invalidProductIdentifiers {
//                        print("Invalid product id: \(invalid_product_id)")
//                }

                request_products_pending = false
                conditional_render()
        }

        func buy(product product: SKProduct) {
                let payment = SKMutablePayment(product: product)
                SKPaymentQueue.defaultQueue().addPayment(payment)
        }

        func restore() {
                SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
                restoring_pending = true
                conditional_render()
        }

        func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
                print("payment queue updated transactions")
                for transaction in transactions {
                        print(transaction.payment.productIdentifier)
                        switch transaction.transactionState {
                        case .Purchasing:
                                print("purchasing")
                                break
                        case .Deferred:
                                print("Deferred")
                                break
                        case .Failed:
                                print("Failed")
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

        func set_all() {
                locked_page_names = Set<String>(store_initially_locked_page_names)
                for product_id in purchased_product_ids {
                        if let page_names = store_product_id_to_page_names[product_id] {
                                for page_name in page_names {
                                        locked_page_names.remove(page_name)
                                }
                        }
                }

                modules_to_purchase = []
                bundles_to_purchase = []
                purchased_modules = []
                for product in products {
                        let product_id = product.productIdentifier
                        if product_id != "com.amberbio.product.bundle_1", let page_name = store_product_id_to_page_names[product_id]?[0] {
                                if locked_page_names.contains(page_name) {
                                        modules_to_purchase.append(product)
                                } else {
                                        purchased_modules.append(product)
                                }
                        } else {
                                if locked_page_names.count >= 2 {
                                        bundles_to_purchase.append(product)
                                }
                        }
                }
        }

        func get_purchased_product_ids() {
                let product_ids = sqlite_get_store_product_ids(database: database)
                purchased_product_ids = Set<String>(product_ids)
        }

        func insert_purchased_product_id(product_id product_id: String) {
                sqlite_insert_store_product_id(database: database, store_product_id: product_id)
                purchased_product_ids.insert(product_id)
                set_all()
        }

        func conditional_render() {
                if state.page_state.name == "module_store" {
                        state.render()
                }
        }
}
