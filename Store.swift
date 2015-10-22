import Foundation
import StoreKit

let store_product_ids = [
        "com.amberbio.product.svm",
        "com.amberbio.product.pca"
]

let store_product_id_to_page_name = [
        "com.amberbio.product.svm" : "svm_factor_selection",
        "com.amberbio.product.pca" : "pca",
        "com.amberbio.product.pairwise-test" : "pairwise_factor"
]

class Store: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {

        var request_products_pending = false
        var purchased_product_ids = [] as Set<String>

        var products = [] as [SKProduct]
        var purchased_products = [] as [SKProduct]
        var unpurchased_products = [] as [SKProduct]

        var locked_page_names = [] as Set<String>

        override init() {
                super.init()
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
                                purchased(product_id: transaction.payment.productIdentifier)
                                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                                conditional_render()
                        case .Restored:
                                print("Restored")
                                break
                        }
                }
        }

        func purchased(product_id product_id: String) {
                purchased_product_ids.insert(product_id)
                set_all()
        }

        func set_all() {
                set_products(products: products)
                set_locked_page_names()
        }

        func set_products(products products: [SKProduct]) {
                self.products = products
                purchased_products = []
                unpurchased_products = []
                for product in products {
                        let product_id = product.productIdentifier
                        if purchased_product_ids.contains(product_id) {
                                purchased_products.append(product)
                        } else {
                                unpurchased_products.append(product)
                        }
                }
        }

        func set_locked_page_names() {
                locked_page_names.removeAll()
                for (product_id, page_name) in store_product_id_to_page_name {
                        if !purchased_product_ids.contains(product_id) {
                                locked_page_names.insert(page_name)
                        }
                }
        }


        func conditional_render() {
                if state.page_state.name == "module_store" {
                        state.render()
                }
        }
}
