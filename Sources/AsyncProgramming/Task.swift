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
