import UIKit

class ViewController: UIViewController {
    @IBOutlet private var displayLabel: UILabel!

    private let operatorButtonColor = UIColor(
        red: 143 / 255,
        green: 194 / 255,
        blue: 243 / 255,
        alpha: 1
    )
    private let numberButtonColor = UIColor(
        red: 203 / 255,
        green: 221 / 255,
        blue: 247 / 255,
        alpha: 1
    )

    private var mainStackView: UIStackView? {
        displayLabel.superview as? UIStackView
    }

    private var rowStackViews: [UIStackView] {
        mainStackView?.arrangedSubviews.compactMap { $0 as? UIStackView } ?? []
    }

    private var calculatorButtons: [UIButton] {
        rowStackViews.flatMap { row in
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
        guard let mainStackView else { return }

        mainStackCenterConstraint = mainStackView.centerXAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.centerXAnchor
        )
        mainStackWidthConstraint = mainStackView.widthAnchor
            .constraint(equalToConstant: 0)
    }

    private func configureAppearance() {
        view.backgroundColor = .white

        displayLabel.textColor = operatorButtonColor
        displayLabel.font = .systemFont(ofSize: 72, weight: .regular)

        for button in calculatorButtons {
            button.tintColor = .white
            button.setTitleColor(.white, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 28, weight: .bold)
            button.backgroundColor = backgroundColor(for: button)
            button.clipsToBounds = true
        }
    }

    private func updateLayoutForCurrentSize() {
        guard let mainStackView else { return }

        let isLandscape = view.bounds.width > view.bounds.height
        let safeWidth = view.safeAreaLayoutGuide.layoutFrame.width
        let horizontalMargin: CGFloat = 20
        let stackWidth = min(
            safeWidth - (horizontalMargin * 2),
            isLandscape ? 722 : safeWidth
        )
        let rowHeight = isLandscape ? 48 : (stackWidth - 30) / 4

        mainStackView.spacing = isLandscape ? 10 : 12
        displayLabel.font = .systemFont(
            ofSize: isLandscape ? 62 : 72,
            weight: .regular
        )
        setDisplayHeight(isLandscape ? 110 : 150)
        setRowsHeight(rowHeight)

        if isLandscape {
            setMainStackHorizontalEdgeConstraints(active: false)
            mainStackWidthConstraint?.constant = stackWidth
            mainStackCenterConstraint?.isActive = true
            mainStackWidthConstraint?.isActive = true
        } else {
            mainStackCenterConstraint?.isActive = false
            mainStackWidthConstraint?.isActive = false
            setMainStackHorizontalEdgeConstraints(active: true)
        }
    }

    private func setDisplayHeight(_ height: CGFloat) {
        displayLabel.constraints
            .first { $0.firstAttribute == .height }
            .map { $0.constant = height }
    }

    private func setRowsHeight(_ height: CGFloat) {
        for row in rowStackViews {
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
        for button in calculatorButtons {
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
