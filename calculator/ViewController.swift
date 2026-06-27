//
//  ViewController.swift
//  calculator
//
//  Created by Mark Volkmann on 6/27/26.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet private weak var displayLabel: UILabel!

    private var currentValue = "0"
    private var storedValue: Int?
    private var pendingOperation: String?
    private var shouldStartNewNumber = true

    override func viewDidLoad() {
        super.viewDidLoad()
        updateDisplay()
    }

    @IBAction private func digitButtonTapped(_ sender: UIButton) {
        guard let digit = sender.currentTitle else { return }

        if shouldStartNewNumber || currentValue == "0" {
            currentValue = digit
            shouldStartNewNumber = false
        } else {
            currentValue += digit
        }

        updateDisplay()
    }

    @IBAction private func clearButtonTapped(_ sender: UIButton) {
        currentValue = "0"
        storedValue = nil
        pendingOperation = nil
        shouldStartNewNumber = true
        updateDisplay()
    }

    @IBAction private func signButtonTapped(_ sender: UIButton) {
        guard currentValue != "0" else { return }

        if currentValue.hasPrefix("-") {
            currentValue.removeFirst()
        } else {
            currentValue = "-" + currentValue
        }

        updateDisplay()
    }

    @IBAction private func percentButtonTapped(_ sender: UIButton) {
        currentValue = String(currentIntValue / 100)
        shouldStartNewNumber = true
        updateDisplay()
    }

    @IBAction private func decimalButtonTapped(_ sender: UIButton) {
        // Floating point values are intentionally unsupported.
    }

    @IBAction private func operationButtonTapped(_ sender: UIButton) {
        guard let operation = sender.currentTitle else { return }

        if let pendingOperation, let storedValue, !shouldStartNewNumber {
            let result = calculate(storedValue, currentIntValue, pendingOperation)
            setResult(result)
        } else {
            storedValue = currentIntValue
        }

        pendingOperation = operation
        shouldStartNewNumber = true
    }

    @IBAction private func equalsButtonTapped(_ sender: UIButton) {
        guard let pendingOperation, let storedValue else { return }

        let result = calculate(storedValue, currentIntValue, pendingOperation)
        setResult(result)
        self.pendingOperation = nil
        self.storedValue = nil
        shouldStartNewNumber = true
    }

    private var currentIntValue: Int {
        Int(currentValue) ?? 0
    }

    private func calculate(_ left: Int, _ right: Int, _ operation: String) -> Int? {
        switch operation {
        case "+":
            return left + right
        case "-":
            return left - right
        case "x":
            return left * right
        case "/":
            guard right != 0 else { return nil }
            return left / right
        default:
            return right
        }
    }

    private func setResult(_ result: Int?) {
        guard let result else {
            currentValue = "Error"
            storedValue = nil
            pendingOperation = nil
            shouldStartNewNumber = true
            updateDisplay()
            return
        }

        currentValue = String(result)
        storedValue = result
        updateDisplay()
    }

    private func updateDisplay() {
        displayLabel.text = currentValue
    }
}
