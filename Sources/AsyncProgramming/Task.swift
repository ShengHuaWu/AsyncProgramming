import Foundation

func taskBasics() {
    let t1: Task<(), Never> = Task {
        print(Thread.current)
    }
    print(Thread.current, t1)
    
    let t2: Task<Int, Never> = Task {
        return 42
    }
    print(Thread.current, t2)
    
    let t3: Task<(), Error> = Task {
        struct SomeError: Error {}
        throw SomeError()
    }
    print(Thread.current, t3)
    
    @Sendable func doSomethingAsync() async {
        print(Thread.current, "Do something async")
    }
    
    Task {
        await doSomethingAsync()
    }
    
    // Tasks seem to be capable of solving the thread explosion problem
    // by using a pool of threads,
    // all without having to manage an auxiliary object
    // like an operation queue or dispatch queue.
    for n in 0 ..< workCount {
        Task {
            print(n, Thread.current)
        }
    }
}

func taskSchedulingNonblocking() {
    // It’s possible for suspended tasks to be resumed on a different thread.
    // This means we should not make any assumptions about
    // adjacent lines of code executing on the same thread.
    for n in 1 ... workCount {
        Task {
            let current = Thread.current
            try await Task.sleep(nanoseconds: NSEC_PER_SEC)
            if current != Thread.current {
                print(n, "Thread changed from", current, "to", Thread.current)
            }
        }
    }
}

func taskPriorityAndCancellation() {
    Task(priority: .low) {
        print("low")
    }
    Task(priority: .high) {
        print("high")
    }
    
    let t1 = Task {
        // It's still cooperative cancellation.
        // This means cancelling the task does not just immediately stop execution,
        // which would be dangerous if we opened resources that need to be closed.
        guard !Task.isCancelled else {
            print("Cancelled!")
            return
        }
        print(Thread.current)
    }
    t1.cancel()
    
    let t2 = Task {
        try Task.checkCancellation() // Better than `Task.isCancelled`
        print(Thread.current)
    }
    t2.cancel()
    
    @Sendable func doSomethingAsync() async throws {
        // This (and all other async APIs) can detect when cancellation happened,
        // early out of its execution, and throw an error
        try await Task.sleep(nanoseconds: NSEC_PER_SEC)
        
        // This will NOT be executed if the task has been cancelled
        print(Thread.current, "do something async")
    }
    
    let t3 = Task {
        let start = Date()
        
        // This will be printed immediately after task is cancelled,
        // even though the sleeping does not finish
        defer { print("Task finished in", Date().timeIntervalSince(start)) }
        
        try await doSomethingAsync()
        
        print(Thread.current)
    }

    Thread.sleep(forTimeInterval: 0.1)
    t3.cancel()
    
    // There is a way to get the current task,
    // but you have to invoke a function with a closure
    // and that closure is handed the current task if it exists.
    Task {
        withUnsafeCurrentTask { task in
            print(task ?? "nil")
        }
    }
    
    // At the root level of the executable there is no task context,
    // so there it will be nil
    withUnsafeCurrentTask { task in
      print(task ?? "nil") // nil
    }
}

enum RequestData {
    @TaskLocal static var requestId: UUID!
    @TaskLocal static var startDate: Date!
}

// So it seems that task local values permeate deeply throughout the system.
// They not only cross from one asynchronous context to another,
// but they even travel to new tasks spun up inside an existing task context.
func taskLocals() {
    enum MyLocals {
        @TaskLocal static var id: Int!
    }
    
    @Sendable func doSomethingAsync() async {
      print("doSomethingAsync:", MyLocals.id!)
    }
    
    print("before:", MyLocals.id ?? "nil")
    MyLocals.$id.withValue(42) {
        print("withValue:", MyLocals.id!)
        
        // Whenever you start a new task it automatically inherits
        // all of the task locals available at that moment
        Task {
            
            // We can also nest withValue in order to create even smaller
            // and more focused scoped changes to task locals
            MyLocals.$id.withValue(1729) {
                Task {
                    try await Task.sleep(nanoseconds: 2 * NSEC_PER_SEC)
                    print("Task 2:", MyLocals.id!)
                }
            }
            
            try await Task.sleep(nanoseconds: NSEC_PER_SEC)
            Task {
                print("Task:", MyLocals.id!)
                await doSomethingAsync()
            }
        }
    }
    print("after:", MyLocals.id ?? "nil")
    
    RequestData.$requestId.withValue(UUID()) {
        RequestData.$startDate.withValue(Date()) {
            Task {
                try await taskResponse(for: .init(url: .init(string: "http://pointfree.co")!))
            }
        }
    }
}
