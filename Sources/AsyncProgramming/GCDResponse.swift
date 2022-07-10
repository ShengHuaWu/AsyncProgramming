import Foundation

private func makeDatabaseQuery() {
    // `requestIdKey` will be implicitly carried with the execution context
    // so that anyone operating in this same context can retrieve it
    let requestId = DispatchQueue.getSpecific(key: requestIdKey)!
    print(requestId, "Making database query")
    Thread.sleep(forTimeInterval: 0.5)
    print(requestId, "Finished database query")
}

private func makeNetworkRequest() {
    let requestId = DispatchQueue.getSpecific(key: requestIdKey)!
    print(requestId, "Making network request")
    Thread.sleep(forTimeInterval: 0.5)
    print(requestId, "Finished network request")
}

func gcdResponse(for request: URLRequest, queue: DispatchQueue) -> HTTPURLResponse {
    let group = DispatchGroup()
    
    // Two child execution contexts inherit some of the properties
    // from a parent execution context
    let databaseQueue = DispatchQueue(label: "database-query", target: queue)
    databaseQueue.async(group: group) {
        makeDatabaseQuery()
    }
    
    let networkQueue = DispatchQueue(label: "network-request", target: queue)
    networkQueue.async(group: group) {
        makeNetworkRequest()
    }
    
    group.wait()
    
    return .init()
}
