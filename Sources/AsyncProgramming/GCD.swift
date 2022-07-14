import Foundation

// Conclusions:
//
// 1. In order to be able to split off new child execution contexts that inherit the specifics,
//    we need to have access to the parent queue.
//
// 2. There is no way to have the cancellation of one work item
//    to trick down to “child” work items created.
//
// 3. GCD has the problem of accidentally exploding the number of threads in use
//    if you are not careful
//
// 4. GCD does not give us the tools to allow cooperating with other work items. 

func gcdBasics() {
    // A serial queue will spawn only one thread
    let queue = DispatchQueue(label: "basics", attributes: .concurrent)
    
    for n in 1 ... 5 {
        queue.async {
            print(n, Thread.current)
        }
    }
}

func gcdScheduleNonblocking() {
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
        
        // This will be printed after sleeping,
        // even though item has been cancelled already
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
    
    Thread.sleep(forTimeInterval: 0.3)
    item.cancel()
}

let requestIdKey = DispatchSpecificKey<UUID>()

func gcdSpecificAndGroup() {
    let requestId = UUID()
    // We have to use a concurrent queue for waiting
    // Otherwise, there will be a deadlock
    let queue = DispatchQueue(label: "request-\(requestId)", attributes: .concurrent)
    // Serve the same purpose of thread dictionary but it's type safe
    queue.setSpecific(key: requestIdKey, value: requestId)
    
    let item = DispatchWorkItem {
        _ = gcdResponse(for: .init(url: .init(string: "https://www.pointfree.co")!), queue: queue)
    }
    queue.async(execute: item)
}

func gcdTarget() {
    let queue1 = DispatchQueue(label: "queue1")
    let idKey = DispatchSpecificKey<Int>()
    let dateKey = DispatchSpecificKey<Date>()
    queue1.setSpecific(key: idKey, value: 42)
    queue1.setSpecific(key: dateKey, value: Date())
    
    queue1.async {
        print("queue1", "id", DispatchQueue.getSpecific(key: idKey) ?? "nil")
        print("queue1", "date", DispatchQueue.getSpecific(key: dateKey) ?? "nil")
        
        let queue2 = DispatchQueue(label: "queue2", target: queue1)
        queue2.setSpecific(key: idKey, value: 1729)
        queue2.async {
            print("queue2", "id", DispatchQueue.getSpecific(key: idKey) ?? "nil")
            print("queue2", "date", DispatchQueue.getSpecific(key: dateKey) ?? "nil")
        }
    }
}

func gcdExpensiveness() {
    // This could still cause thread explosion
    for n in 0 ..< workCount {
        DispatchQueue(label: "queue-\(n)").async {
            print(Thread.current)
            while true {}
        }
    }
}

func gcdBlocking() {
    // Like operation queues,
    // a small number of threads are created,
    // but then they are tied up forever
    // so that no other work items are getting an opportunity to execute.
    let queue = DispatchQueue(label: "concurrent-queue", attributes: .concurrent)
    for n in 0 ..< workCount {
        queue.async {
            print(n, Thread.current)
            while true {}
        }
    }
}

func gcdDataRacing() {
    class Counter {
        let queue = DispatchQueue(label: "counter", attributes: .concurrent)
        var count = 0
        func increment() {
            // Use `barrier` to wait until a queue has executed all of its work
            // before it executes its next unit of work.
            // It's similar to lock.
            self.queue.sync(flags: .barrier) {
                self.count += 1
            }
        }
    }
    
    let counter = Counter()
    
    let queue = DispatchQueue(label: "concurrent-queue", attributes: .concurrent)
    
    for _ in 0 ..< workCount {
        queue.async {
            counter.increment()
        }
    }
    
    Thread.sleep(forTimeInterval: 1)
    print("counter.count", counter.count)
}
