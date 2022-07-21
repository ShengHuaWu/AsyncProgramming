import Foundation

func actorBasics() {
    // We don’t want to literally lock
    // so that we can hold up the thread while another thread does its work.
    actor CounterActor {
        var count = 0
        var maximum = 0
        func increment() {
            self.count += 1
            self.computeMax()
        }
        func decrement() {
            self.count -= 1
        }
        
        private func computeMax() {
            self.maximum = Swift.max(self.count, self.maximum)
        }
    }
    
    let counter = CounterActor()
    
    for _ in 0 ..< workCount {
        Task {
            // You can only invoke the increment method if you are in an asynchronous context
            await counter.increment()
        }
        Task {
            await counter.decrement()
        }
    }
    
    Thread.sleep(forTimeInterval: 1)
    Task {
        await print("counter.count", counter.count)
        
        // This won't be a determined value, but it isn't race condition either
        // We have 1,000 increment tasks and 1,000 decrement tasks running concurrently,
        // and the order that they run is not going to be deterministic.
        await print("counter.maximum", counter.maximum)
    }
}
