import Foundation

func gcdBasics() {
    // A serial queue will spawn only one thread
    let queue = DispatchQueue(label: "basics", attributes: .concurrent)
    
    for n in 1 ... 5 {
        queue.async {
            print(n, Thread.current)
        }
    }
}

func gcdNonblocking() {
    // Dispatch queues are capable of scheduling work to be performed in the future,
    // all without blocking the current thread.
    // The scheduling happens at a deeper level with the OS
    // so that we don’t need to waste time on the thread waiting for time to pass.
    let queue = DispatchQueue(label: "non-blocking")
    
    print("before scheduling")
    queue.asyncAfter(deadline: .now() + 1) {
        print("1 second passed")
    }
    print("after scheduling")
}

func gcdPriorityAndCancellation() {
    // Set the priority as `qos`
    let queue = DispatchQueue(label: "priority-and-cancellation", qos: .background)
    
    var item: DispatchWorkItem! // This is not a good practice
    item = DispatchWorkItem {
        defer { item = nil }
        
        let start = Date()
        defer { print("Finished in", Date().timeIntervalSince(start)) }
        
        Thread.sleep(forTimeInterval: 1)
        
        // Have to check this manually
        // Otherwise, the code will continue even if the item is cancelled
        // This cancellation process is cooperative
        guard !item.isCancelled else {
            print("Cancelled!")
            return
        }
        print(Thread.current)
    }
    
    queue.async(execute: item)
    
    Thread.sleep(forTimeInterval: 0.5)
    item.cancel()
}
