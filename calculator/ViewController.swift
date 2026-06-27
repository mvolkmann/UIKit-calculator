import UIKit

class ViewController: UIViewController {
    @IBOutlet private var displayLabel: UILabel!

    private static func rgb(
        _ red: CGFloat,
        _ green: CGFloat,
        _ blue: CGFloat
    ) -> UIColor {
        UIColor(red: red / 255, green: green / 255, blue: blue / 255, alpha: 1)
    }

    private let operatorButtonColor = rgb(143, 194, 243)
    private let numberButtonColor = rgb(203, 221, 247)

    private var mainStack: UIStackView? {
        displayLabel.superview as? UIStackView
    }

    private var rowStacks: [UIStackView] {
        mainStack?.arrangedSubviews.compactMap { $0 as? UIStackView } ?? []
    }

    private var buttons: [UIButton] {
        rowStacks.flatMap { row in
            row.arrangedSubviews.compactMap { $0 as? UIButton }
        }
    }

    private var mainStackWidthConstraint: NSLayoutConstraint?
    private var mainStackCenterConstraint: NSLayoutConstraint?

    private var currentValue = "0"
    private var storedValue: Int?
    private var pendingOperation: String?
    private var shouldStartNewNumber = true

    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
        configureAppearance()
        updateDisplay()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateLayoutForCurrentSize()
        updateButtonCornerRadii()
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

    @IBAction private func clearButtonTapped(_: UIButton) {
        currentValue = "0"
        storedValue = nil
        pendingOperation = nil
        shouldStartNewNumber = true
        updateDisplay()
    }

    @IBAction private func signButtonTapped(_: UIButton) {
        guard currentValue != "0" else { return }

        if currentValue.hasPrefix("-") {
            currentValue.removeFirst()
        } else {
            currentValue = "-" + currentValue
        }
        updateDisplay()
    }

    @IBAction private func percentButtonTapped(_: UIButton) {
        currentValue = String(currentIntValue / 100)
        shouldStartNewNumber = true
        updateDisplay()
    }

    @IBAction private func decimalButtonTapped(_: UIButton) {
        // Floating point values are intentionally unsupported.
    }

    @IBAction private func operationButtonTapped(_ sender: UIButton) {
        guard let operation = sender.currentTitle else { return }

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

    @IBAction private func equalsButtonTapped(_: UIButton) {
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

    private func configureLayout() {
        guard let mainStack else { return }

        mainStackCenterConstraint = mainStack.centerXAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.centerXAnchor
        )
        mainStackWidthConstraint = mainStack.widthAnchor
            .constraint(equalToConstant: 0)
    }

    private func configureAppearance() {
        view.backgroundColor = .white

        displayLabel.textColor = operatorButtonColor
        displayLabel.font = .systemFont(ofSize: 72, weight: .regular)

        for button in buttons {
            button.tintColor = .white
            button.setTitleColor(.white, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 28, weight: .bold)
            button.backgroundColor = backgroundColor(for: button)
            button.clipsToBounds = true
        }
    }

    private func updateLayoutForCurrentSize() {
        guard mainStack != nil else { return }

        let isLandscape = view.bounds.width > view.bounds.height
        let safeWidth = view.safeAreaLayoutGuide.layoutFrame.width
        let horizontalMargin: CGFloat = 20
        let stackWidth = min(
            safeWidth - (horizontalMargin * 2),
            isLandscape ? 722 : safeWidth
        )
        let rowHeight = isLandscape ? 48 : (stackWidth - 30) / 4

        displayLabel.font = .systemFont(
            ofSize: isLandscape ? 62 : 72,
            weight: .regular
        )
        setDisplayHeight(isLandscape ? 110 : 150)
        setRowsHeight(rowHeight)

        setMainStackHorizontalEdgeConstraints(active: isLandscape)
        mainStackCenterConstraint?.isActive = isLandscape
        mainStackWidthConstraint?.isActive = isLandscape
        if isLandscape {
            mainStackWidthConstraint?.constant = stackWidth
        }
    }

    private func setDisplayHeight(_ height: CGFloat) {
        displayLabel.constraints
            .first { $0.firstAttribute == .height }
            .map { $0.constant = height }
    }

    private func setRowsHeight(_ height: CGFloat) {
        for row in rowStacks {
            row.constraints
                .first { $0.firstAttribute == .height }
                .map { $0.constant = height }
        }
    }

    private func setMainStackHorizontalEdgeConstraints(active: Bool) {
        view.constraints
            .filter {
                $0.identifier == "main-leading" || $0
                    .identifier == "main-trailing"
            }
            .forEach { $0.isActive = active }
    }

    private func updateButtonCornerRadii() {
        for button in buttons {
            button.layer.cornerRadius = button.bounds.height / 2
        }
    }

    private func backgroundColor(for button: UIButton) -> UIColor {
        switch button.currentTitle {
        case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
            return numberButtonColor
        default:
            return operatorButtonColor
        }
    }
}
