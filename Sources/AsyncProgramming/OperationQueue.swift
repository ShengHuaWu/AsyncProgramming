import Foundation

func operationQueueBasics() {
    let queue = OperationQueue()
    
    for n in 1 ... 5 {
        queue.addOperation {
            print(n, Thread.current)
        }
    }
}
