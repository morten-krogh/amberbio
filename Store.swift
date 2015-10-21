import Foundation
import StoreKit

let store_product_ids = [
        "com.amberbio.product.svm",
        "com.amberbio.product.pca"
]

class Store: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {

        var request_products_pending = false
        var purchased_product_ids = [] as Set<String>

        var purchased_products = [] as [SKProduct]
        var unpurchased_products = [] as [SKProduct]

        func request_products() {
                let products_request = SKProductsRequest(productIdentifiers: Set<String>(store_product_ids))
                products_request.delegate = self
                products_request.start()
                request_products_pending = true
        }

        func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
                set_products(products: response.products)
                for invalid_product_id in response.invalidProductIdentifiers {
                        print("Invalid product id: \(invalid_product_id)")
                }

                request_products_pending = false
                if state.page_state.name == "store_front" {
                        state.render()
                }
        }

        func set_products(products products: [SKProduct]) {
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

        func buy(product product: SKProduct) {
                let payment = SKMutablePayment(product: product)
                SKPaymentQueue.defaultQueue().addPayment(payment)
        }

        func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
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
                                break
                        case .Purchased:
                                print("Purchased")
                                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                        case .Restored:
                                print("Restored")
                                break
                        }




                }
        }






}
