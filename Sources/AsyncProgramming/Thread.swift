import Foundation

func threadBasics() {
    for n in 1 ... 5 {
        // Spawn 5 different threads, which could be resource-consuming
        Thread.detachNewThread {
            print(n, Thread.current)
        }
    }
}

func threadPriorityAndCancellation() {
    // The block argument of initializer is a lazy operation
    let thread = Thread {
        let start = Date()
        defer { print("Finished in", Date().timeIntervalSince(start)) }
        
        Thread.sleep(forTimeInterval: 1)
        
        // Have to check this manually
        // Otherwise, the code will continue even if the thread is cancelled
        guard !Thread.current.isCancelled else {
            print("Thread is cancelled")
            return
        }
        
        print(Thread.current)
    }
    
    thread.threadPriority = 0.75 // Between 0 to 1
    
    thread.start()
    Thread.sleep(forTimeInterval: 0.1)
    thread.cancel() // This won't stop the block because of sleeping
}

func threadDictionary() {
    let thread = Thread {
        let url = URL(string: "https://apple.com")!
        _ = response(for: .init(url: url))
    }
    
    thread.threadDictionary["requestId"] = UUID()
    thread.start()
}
