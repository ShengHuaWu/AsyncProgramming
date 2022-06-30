import Foundation

func makeDatabaseQuery() {
    let requestId = Thread.current.threadDictionary["requestId"] as! UUID
    print(requestId, "Making database query")
    Thread.sleep(forTimeInterval: 0.5)
    print(requestId, "Finished database query")
}

func makeNetworkRequest() {
    let requestId = Thread.current.threadDictionary["requestId"] as! UUID
    print(requestId, "Making network request")
    Thread.sleep(forTimeInterval: 0.5)
    print(requestId, "Finished network request")
}

func response(for request: URLRequest) -> HTTPURLResponse {
    let requestId = Thread.current.threadDictionary["requestId"] as! UUID
    
    let start = Date()
    defer { print(requestId, "Finished in", Date().timeIntervalSince(start)) }
    
    // Child threads have to add the entries manually from the parent
    let threadDictionary = Thread.current.threadDictionary as! [AnyHashable : Any]
    
    let databaseQueryThread = Thread { makeDatabaseQuery() }
    databaseQueryThread.threadDictionary.addEntries(from: threadDictionary)
    databaseQueryThread.start()
    
    let networkRequestThread = Thread { makeNetworkRequest() }
    networkRequestThread.start()
    networkRequestThread.threadDictionary.addEntries(from: threadDictionary)
    
    // Thread does NOT provide proper tool to coordinate async tasks
    while !databaseQueryThread.isFinished || !networkRequestThread.isFinished {
        Thread.sleep(forTimeInterval: 0.1)
    }
    
    print(requestId, "Completed in", Date().timeIntervalSince(start))
    
    // TODO: Construct response
    return .init()
}
