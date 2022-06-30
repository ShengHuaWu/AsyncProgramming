import Foundation

// Conclusions:
//
// 1. Threads don’t support the notion of child threads so that things
// like priority, cancellation, and thread dictionaries
// don’t trickle down to threads created from other threads.
//
// 2. It’s easy to accidentally explode the number of threads being used.
//
// 3. It’s hard to coordinate between threads.
//
// 4. Threaded code looks very different from unthreaded code.
//
// 5. The tools for synchronizing between threads are crude.

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

let workCount = 1_000

func threadExpensiveness() {
    for n in 0..<workCount {
      Thread.detachNewThread {
        print(n, Thread.current)
        // TODO: do serious work to load and index a webpage
        while true {}
      }
    }
}

func threadDataRace() {
    class Counter {
        let lock = NSLock()
        private(set) var count = 0
        func increment() {
            self.lock.lock()
            defer { self.lock.unlock() }
            self.count += 1
        }
    }
    
    let counter = Counter()
    for _ in 0..<workCount {
        Thread.detachNewThread {
            Thread.sleep(forTimeInterval: 0.01)
            counter.increment()
        }
    }
    
    Thread.sleep(forTimeInterval: 0.5)
    print("count", counter.count)
}
