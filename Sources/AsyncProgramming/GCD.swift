import Foundation

func gcdBasics() {
    // A serial queue will spawn only one thread
    let queue = DispatchQueue(label: "basics", attributes: .concurrent)
    
    for n in 1 ... 5 {
        queue.async {
            print(n, Thread.current)
        }
    }
}

func gcdNonblocking() {
    // Dispatch queues are capable of scheduling work to be performed in the future,
    // all without blocking the current thread.
    // The scheduling happens at a deeper level with the OS
    // so that we don’t need to waste time on the thread waiting for time to pass.
    let queue = DispatchQueue(label: "basics")
    
    print("before scheduling")
    queue.asyncAfter(deadline: .now() + 1) {
        print("1 second passed")
    }
    print("after scheduling")
}
