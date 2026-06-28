import Foundation

struct Model {
    // Specifying "private(set)" here means that
    // only this struct can set the value,
    // but other code can read the value.
    // ViewController does this in its viewDidLoad method.
    private(set) var displayValue = "0"

    private var leftOperand: Int?
    private var operation: String?
    private var shouldStartNewNumber = true

    private var currentIntValue: Int {
        Int(displayValue) ?? 0
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
        displayValue = "0"
        leftOperand = nil
        operation = nil
        shouldStartNewNumber = true
    }

    private mutating func processDigit(_ digit: String) {
        if shouldStartNewNumber || displayValue == "0" {
            displayValue = digit
            shouldStartNewNumber = false
        } else {
            displayValue += digit
        }
    }

    private mutating func processEquals() {
        guard let operation, let leftOperand else { return }

        let result = calculate(leftOperand, currentIntValue, operation)
        setResult(result)
        self.operation = nil
        self.leftOperand = nil
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

        return displayValue
    }

    private mutating func processOperation(_ operation: String) {
        if let storedOperation = self.operation, let leftOperand, !shouldStartNewNumber {
            let result = calculate(
                leftOperand,
                currentIntValue,
                storedOperation
            )
            setResult(result)
        } else {
            leftOperand = currentIntValue
        }

        self.operation = operation
        shouldStartNewNumber = true
    }

    private mutating func setResult(_ result: Int?) {
        guard let result else {
            displayValue = "Error"
            leftOperand = nil
            operation = nil
            shouldStartNewNumber = true
            return
        }

        displayValue = String(result)
        leftOperand = result
    }

    private mutating func toggleSign() {
        guard displayValue != "0" else { return }

        if displayValue.hasPrefix("-") {
            displayValue.removeFirst()
        } else {
            displayValue = "-" + displayValue
        }
    }
}
