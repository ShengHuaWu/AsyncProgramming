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
