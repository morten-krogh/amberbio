import Foundation
import StoreKit

let ads_time_first_showing = 60.0
let ads_time_other_showings = 180.0

let store_product_ids = [
        "com.amberbio.product.donation_1",
        "com.amberbio.product.donation_2",
        "com.amberbio.product.donation_3",
        "com.amberbio.product.donation_4",
        "com.amberbio.product.donation_5",
        "com.amberbio.product.donation_6",
        "com.amberbio.product.donation_7",
        "com.amberbio.product.donation_8"
]

class Store: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {

        let database: Database

        var request_products_pending = false

        var store_active = false

        var products = [] as [SKProduct]

        init(database: Database) {
                self.database = database
                super.init()
        }

        func request_products() {
                let products_request = SKProductsRequest(productIdentifiers: Set<String>(store_product_ids))
                products_request.delegate = self
                products_request.start()
                request_products_pending = true
        }

        func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
                self.products = response.products
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
                conditional_render()
        }

//        func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue) {
//                if restoring_pending {
//                        restoring_pending = false
//                        conditional_render()
//                }
//        }
//
//        func paymentQueue(queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: NSError) {
//                restoring_pending = false
//                conditional_render()
//        }

        func insert_purchased_product_id(product_id product_id: String) {
                
        }
        
        func conditional_render() {
                if state.page_state.name == "module_store" {
                        state.render()
                }
        }
}
