import Foundation

func unstructuredProgramming() {
    // "Finished" and "After" will be printed before the current thread
    defer { print("Finished") }
    
    print("Before")
    Thread.detachNewThread {
        print(Thread.current)
    }
    print("After")
}

func structuredTasks() {
    RequestData.$requestId.withValue(UUID()) {
        RequestData.$startDate.withValue(Date()) {
            let task = Task {
                try await structuredTasksResponse(for: .init(url: .init(string: "http://pointfree.co")!))
            }
            Thread.sleep(forTimeInterval: 0.1)
            task.cancel() // This will NOT cancell the child tasks
        }
    }
}

func structuredCancellableTasks() {
    RequestData.$requestId.withValue(UUID()) {
        RequestData.$startDate.withValue(Date()) {
            let task = Task {
                try await structuredCancellableTasksResponse(for: .init(url: .init(string: "http://pointfree.co")!))
            }
            Thread.sleep(forTimeInterval: 0.1)
            task.cancel()
        }
    }
}

func taskGroup() {
    var sum = 0
    for n in 1 ... 1000 {
        Thread.detachNewThread {
            Thread.sleep(forTimeInterval: 0.3)
            sum += n // Race condition (aka not thread safe)
        }
    }
    Thread.sleep(forTimeInterval: 1.1)
    print("sum with thread", sum)
    
    Task {
        let sum = await withTaskGroup(of: Int.self, returning: Int.self) { group in
            for n in 1 ... 1000 {
                group.addTask {
                    // This will NOT be cancelled if the parent task is cancelled
                    // We have to check `group.isCancelled` by ourselves
                    try? await Task.sleep(nanoseconds: NSEC_PER_SEC)
                    return n
                }
            }
            
            var sum = 0
            // Extract the values from the group with `for await`
            for await num in group {
                sum += num
            }
            
            return sum
        }
        
        print("sum with task group", sum)
    }
    
    let task = Task {
        let sum = try await withThrowingTaskGroup(of: Int.self, returning: Int.self) { group in
            for n in 1 ... 1000 {
                group.addTask {
                    // This will be cancelled if the parent task is cancelled
                    try await Task.sleep(nanoseconds: NSEC_PER_SEC)
                    return n
                }
            }
            
            var sum = 0
            for try await num in group {
                sum += num
            }
            
            return sum
        }
        // This won't be run if the parent task is cancelled
        print("sum with throwing task group", sum)
    }
    Thread.sleep(forTimeInterval: 0.1)
    task.cancel()
}
