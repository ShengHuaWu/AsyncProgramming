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
