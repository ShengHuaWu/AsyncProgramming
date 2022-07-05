import Foundation

func operationQueueBasics() {
    let queue = OperationQueue()
    
    for n in 1 ... 5 {
        queue.addOperation {
            print(n, Thread.current)
        }
    }
}

func operationPriorityAndCancellation() {
    let queue = OperationQueue()
    
    let operation = BlockOperation()
    operation.addExecutionBlock { [unowned operation] in
        let start = Date()
        defer { print("Finished in", Date().timeIntervalSince(start)) }
        
        Thread.sleep(forTimeInterval: 1)
        
        // Have to check this manually
        // Otherwise, the code will continue even if the operation is cancelled
        // Furthermore, we have to capture `operation` from outside
        guard !operation.isCancelled else {
            print("Cancelled")
            return
        }
        
        print(Thread.current)
    }
    operation.qualityOfService = .background
    
    queue.addOperation(operation)
    
    Thread.sleep(forTimeInterval: 0.1)
    operation.cancel() // This won't just cancel the execution block
}

func operationCoordination() {
    let queue = OperationQueue()
    
    /*
     A ➡️ B
    ⬇️    ⬇️
     C ➡️ D
     */
    let operationA = BlockOperation {
        print("A")
        Thread.sleep(forTimeInterval: 1)
    }
    let operationB = BlockOperation {
        print("B")
    }
    let operationC = BlockOperation {
        print("C")
    }
    let operationD = BlockOperation {
        print("D")
    }
    
    operationB.addDependency(operationA)
    operationC.addDependency(operationA)
    operationD.addDependency(operationB)
    operationD.addDependency(operationC)
    
    queue.addOperation(operationA)
    queue.addOperation(operationB)
    queue.addOperation(operationC)
    queue.addOperation(operationD)
}
