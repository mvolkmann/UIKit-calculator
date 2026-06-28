import Foundation

struct Model {
    private(set) var currentValue = "0"
    private var pendingOperation: String?
    private var shouldStartNewNumber = true
    private var storedValue: Int?

    private var currentIntValue: Int {
        Int(currentValue) ?? 0
    }

    private func calculate(
        _ left: Int,
        _ right: Int,
        _ operation: String
    ) -> Int? {
        switch operation {
        case "+":
            return left + right
        case "-":
            return left - right
        case "x":
            return left * right
        case "/":
            // This operation is intentionally unsupported.
            return nil
        default:
            return right
        }
    }

    private mutating func clear() {
        currentValue = "0"
        storedValue = nil
        pendingOperation = nil
        shouldStartNewNumber = true
    }

    private mutating func processDigit(_ digit: String) {
        if shouldStartNewNumber || currentValue == "0" {
            currentValue = digit
            shouldStartNewNumber = false
        } else {
            currentValue += digit
        }
    }

    private mutating func processEquals() {
        guard let pendingOperation, let storedValue else { return }

        let result = calculate(storedValue, currentIntValue, pendingOperation)
        setResult(result)
        self.pendingOperation = nil
        self.storedValue = nil
        shouldStartNewNumber = true
    }

    mutating func processKey(_ key: String) -> String {
        switch key {
        case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
            processDigit(key)
        case "AC":
            clear()
        case "+/-":
            toggleSign()
        case "+", "-", "x", "/":
            processOperation(key)
        case "=":
            processEquals()
        default:
            break
        }

        return currentValue
    }

    private mutating func processOperation(_ operation: String) {
        if let pendingOperation, let storedValue, !shouldStartNewNumber {
            let result = calculate(
                storedValue,
                currentIntValue,
                pendingOperation
            )
            setResult(result)
        } else {
            storedValue = currentIntValue
        }

        pendingOperation = operation
        shouldStartNewNumber = true
    }

    private mutating func setResult(_ result: Int?) {
        guard let result else {
            currentValue = "Error"
            storedValue = nil
            pendingOperation = nil
            shouldStartNewNumber = true
            return
        }

        currentValue = String(result)
        storedValue = result
    }

    private mutating func toggleSign() {
        guard currentValue != "0" else { return }

        if currentValue.hasPrefix("-") {
            currentValue.removeFirst()
        } else {
            currentValue = "-" + currentValue
        }
    }
}
