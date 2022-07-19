import Foundation

func sendableBasics() {
    // The Sendable protocol indicates that value of the given type can
    // be safely used in concurrent code.
    //
    // We personally feel quite confident this type is safe to use from multiple threads,
    // and so we can tell the compiler to just trust us
    // that it’s actually sendable by marking the class as unchecked
    class Counter: @unchecked Sendable {
        let lock = NSLock()
        var count = 0
        func increment() {
            self.lock.lock()
            defer { self.lock.unlock() }
            self.count += 1
        }
    }

    let counter = Counter()

    for _ in 0 ..< workCount {
        Task {
            counter.increment()
        }
    }

    Thread.sleep(forTimeInterval: 2)
    print("counter.count", counter.count)
}
