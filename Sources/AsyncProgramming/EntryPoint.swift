import Foundation

// This type can provide the async context at the application launch point.
// Currently, Swift does not support the async context at `main.swift`.
// However, it will support the async context in the future version.
@main
struct Main {
    static func main() async throws {
        // Every task in the group will be executed on the main thread without blocking it
        await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask { @MainActor in
                while true {
                    try await Task.sleep(nanoseconds: NSEC_PER_SEC / 4)
                    print(Thread.current, "Timer ticked")
                }
            }
            
            group.addTask { @MainActor in
//                nthPrime(1_000_000) // This will block the main thread
                await asyncNthPrime(1_000_000)
            }
            
            for n in 0 ..< workCount {
                group.addTask { @MainActor in
                    _ = try await URLSession.shared
                        .data(from: .init(string: "http://ipv4.download.thinkbroadband.com/1MB.zip")!)
                    print(Thread.current, "Download finished", n)
                }
            }
        }
        
        try await Task.sleep(nanoseconds: NSEC_PER_SEC * 4)
    }
}
