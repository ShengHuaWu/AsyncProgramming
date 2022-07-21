import Foundation

func sendableBasics() {
    // Sendable protocol allows us to prove to the compiler
    // that values of a specific type are safe to be passed across concurrent boundaries
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

struct User {}

// @Sendable attribute allows us to prove to the compiler
// that functions can be safely used from multiple concurrent contexts.
struct DatabaseClient {
    
    // You can also use @Sendable to help make types
    // that hold onto closures conform to the Sendable protocol.
    var fetchUsers: @Sendable () async throws -> [User]
    var createUser: @Sendable (User) async throws -> Void
}

extension DatabaseClient {
    static let live = Self(
        fetchUsers: { fatalError() },
        createUser: { _ in fatalError() }
    )
}

func atSendable() {
    func perform(client: DatabaseClient, work: @escaping @Sendable () -> Void) {
        // If you can prove to the compiler that your closure is @Sendable,
        // then the function you are invoking can be free to use
        // that closure in any concurrent way it wants without leading to a race condition
        Task {
            _ = try await client.fetchUsers()
        }
        Task {
            _ = try await client.fetchUsers()
        }
    }
}
