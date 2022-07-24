import Foundation

private func databaseQuery() async throws {
    let requestId = RequestData.requestId!
    print(requestId, "Making database query")
    try await Task.sleep(nanoseconds: 500_000_000)
    print(requestId, "Finished database query")
}

private func networkRequest() async throws {
    let requestId = RequestData.requestId!
    print(requestId, "Making network request")
    try await Task.sleep(nanoseconds: 500_000_000)
    print(requestId, "Finished network request")
}

@Sendable func taskResponse(for request: URLRequest) async throws -> HTTPURLResponse {
    let requestId = RequestData.requestId!
    let start = RequestData.startDate!
    defer { print(requestId, "Request finished in", Date().timeIntervalSince(start)) }
    
    Task { print(RequestData.requestId!, "Track analytics") } // Fire-and-forget
    
    // These two will run serially
    try await databaseQuery()
    try await networkRequest()
    
    // TODO: return real response
    return .init()
}

func structuredTasksResponse(for request: URLRequest) async throws -> HTTPURLResponse {
    let requestId = RequestData.requestId!
    let start = RequestData.startDate!
    defer { print(requestId, "Request finished in", Date().timeIntervalSince(start)) }
    
    Task { print(RequestData.requestId!, "Track analytics") } // Fire-and-forget
    
    // These two tasks will run in parallel but these will be unstructured
    // In addition, spawning new tasks will break the cancellation rule,
    // which means cancelling the parent task won't cancel these two
    let databaseTask = Task {
        try await databaseQuery()
    }
    let networkTask = Task {
        try await networkRequest()
    }
    // These two lines will brige the tasks back to structured programming
    try await databaseTask.value
    try await networkTask.value
    
    return .init()
}

func structuredCancellableTasksResponse(for request: URLRequest) async throws -> HTTPURLResponse {
    let requestId = RequestData.requestId!
    let start = RequestData.startDate!
    defer { print(requestId, "Request finished in", Date().timeIntervalSince(start)) }
    
    Task { print(RequestData.requestId!, "Track analytics") } // Fire-and-forget
    
    // "async let" will run the tasks in parallel and keep the structured programming
    // In addition, the cancellation rule works fine
    async let databaseResponse = databaseQuery()
    async let networkResponse = networkRequest()
    // Access the value with "try await"
    try await print(databaseResponse)
    try await print(networkResponse)
    
    // The above can also be achived by
    // withTaskCancellationHandler(handler:, operation:)
    // However, it is lack of ergonomic
    
    return .init()
}
