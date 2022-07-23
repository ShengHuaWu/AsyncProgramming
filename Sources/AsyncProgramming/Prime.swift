import Foundation

func isPrime(_ p: Int) -> Bool {
    if p <= 1 { return false }
    if p <= 3 { return true }
    for i in 2...Int(sqrtf(Float(p))) {
        if p % i == 0 { return false }
    }
    return true
}

func nthPrime(_ n: Int) {
    let start = Date()
    var primeCount = 0
    var prime = 2
    while primeCount < n {
        defer { prime += 1 }
        if isPrime(prime) {
            primeCount += 1
        }
    }
    print(
        "\(n)th prime", prime-1,
        "time", Date().timeIntervalSince(start)
    )
}

func asyncNthPrime(_ n: Int) async {
    let start = Date()
    var primeCount = 0
    var prime = 2
    while primeCount < n {
        defer { prime += 1 }
        if isPrime(prime) {
            primeCount += 1
        } else if prime.isMultiple(of: 1_000) {
            await Task.yield()
        }
    }
    print(
        Thread.current,
        "\(n)th prime", prime-1,
        "time", Date().timeIntervalSince(start)
    )
}
