import Foundation
import StoreKit

let store_product_ids = [
        "com.amberbio.product.svm",
        "com.amberbio.product.knn",
        "com.amberbio.product.pca",
        "com.amberbio.product.anova",
        "com.amberbio.product.kmeans",
        "com.amberbio.product.sammon",
        "com.amberbio.product.som",
        "com.amberbio.product.bundle_2015"
]

let store_initially_locked_page_names = [
        "svm_factor_selection",
        "knn_factor_selection",
        "pca",
        "anova_factor_selection",
        "k_meanns_clustering_selection",
        "sammon",
        "som"
]

let store_product_id_to_page_names = [
        "com.amberbio.product.svm" : ["svm_factor_selection"],
        "com.amberbio.product.knn" : ["knn_factor_selection"],
        "com.amberbio.product.pca" : ["pca"],
        "com.amberbio.product.anova" : ["anova_factor_selection"],
        "com.amberbio.product.kmeans" : ["k_meanns_clustering_selection"],
        "com.amberbio.product.sammon" : ["sammon"],
        "com.amberbio.product.som" : ["som"],
        "com.amberbio.product.bundle_2015": ["svm_factor_selection", "knn_factor_selection", "pca", "anova_factor_selection", "k_meanns_clustering_selection", "sammon", "som"]
]

class Store: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {

        let database: Database

        var request_products_pending = false
        var restoring_pending = false

        var purchased_product_ids = [] as Set<String>

        var products = [] as [SKProduct]
        var purchased_products = [] as [SKProduct]
        var products_to_purchase = [] as [SKProduct]

        var locked_modules = [] as [String]
        var unlocked_modules = [] as [String]

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
                locked_page_names = Set<String>(store_initially_locked_page_names)
                for product_id in purchased_product_ids {
                        if let page_names = store_product_id_to_page_names[product_id] {
                                for page_name in page_names {
                                        locked_page_names.remove(page_name)
                                }
                        }
                }

                purchased_products = []
                for product in products {
                        let product_id = product.productIdentifier
                        if purchased_product_ids.contains(product_id) {
                                if product_id == "com.amberbio.product.bundle_2015" {
                                        purchased_products = [product] + purchased_products
                                } else {
                                        purchased_products.append(product)
                                }
                        }
                }

                products_to_purchase = []
                if !purchased_product_ids.contains("com.amberbio.product.bundle_2015") {
                        for product in products {
                                let product_id = product.productIdentifier
                                if !purchased_product_ids.contains(product_id) {
                                        if product_id == "com.amberbio.product.bundle_2015" {
                                                products_to_purchase = [product] + products_to_purchase
                                        } else {
                                                products_to_purchase.append(product)
                                        }
                                }
                        }
                }

                locked_modules = []
                unlocked_modules = []
                for product in products {
                        let product_id = product.productIdentifier
                        if product_id != "com.amberbio.product.bundle_2015" {
                                let page_name = store_product_id_to_page_names[product_id]![0]
                                if !locked_page_names.contains(page_name) {
                                        unlocked_modules.append(product.localizedTitle)
                                } else {
                                        locked_modules.append(product.localizedTitle)
                                }
                        }
                }
        }

        func get_purchased_product_ids() {
                let product_ids = sqlite_get_store_product_ids(database: database)
                purchased_product_ids = Set<String>(product_ids)
        }

        func insert_purchased_product_id(product_id product_id: String) {
                if store_product_ids.indexOf(product_id) != nil {
                        sqlite_insert_store_product_id(database: database, store_product_id: product_id)
                        purchased_product_ids.insert(product_id)
                        set_all()
                }
        }

        func conditional_render() {
                if state.page_state.name == "module_store" {
                        state.render()
                }
        }
}
