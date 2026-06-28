import UIKit

class ViewController: UIViewController {
    @IBOutlet private var displayLabel: UILabel!

    private let numberButtonColor = rgb(203, 221, 247)
    private let operatorButtonColor = rgb(143, 194, 243)
    private let unsupportedButtonColor = UIColor.lightGray
    private let unsupportedButtonLabels: Set<String> = ["%", "/", "."]

    private var mainStackWidthConstraint: NSLayoutConstraint?
    private var mainStackCenterConstraint: NSLayoutConstraint?
    private var model = Model()

    // A computed property.
    private var buttons: [UIButton] {
        rowStacks.flatMap { row in
            row.arrangedSubviews.compactMap { $0 as? UIButton }
        }
    }

    // A computed property.
    private var mainStack: UIStackView? {
        displayLabel.superview as? UIStackView
    }

    // A computed property.
    private var rowStacks: [UIStackView] {
        mainStack?.arrangedSubviews.compactMap { $0 as? UIStackView } ?? []
    }

    private func backgroundColor(for button: UIButton) -> UIColor {
        guard let title = button.currentTitle else {
            return unsupportedButtonColor
        }
        if unsupportedButtonLabels.contains(title) {
            return unsupportedButtonColor
        }
        return Int(title) == nil ? operatorButtonColor : numberButtonColor
    }

    @IBAction private func clearButtonTapped(_ sender: UIButton) {
        processButton(sender)
    }

    private func configureAppearance() {
        view.backgroundColor = .white

        displayLabel.textColor = operatorButtonColor
        displayLabel.font = .systemFont(ofSize: 72, weight: .regular)

        for button in buttons {
            let isUnsupported = isUnsupportedButton(button)

            button.tintColor = .white
            button.setTitleColor(.white, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 28, weight: .bold)
            button.backgroundColor = backgroundColor(for: button)
            button.isEnabled = !isUnsupported
            button.alpha = isUnsupported ? 0.45 : 1
            button.clipsToBounds = true
        }
    }

    private func configureLayout() {
        guard let mainStack else { return }

        mainStackCenterConstraint = mainStack.centerXAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.centerXAnchor
        )
        mainStackWidthConstraint = mainStack.widthAnchor
            .constraint(equalToConstant: 0)
    }

    @IBAction private func decimalButtonTapped(_ sender: UIButton) {
        processButton(sender)
    }

    @IBAction private func digitButtonTapped(_ sender: UIButton) {
        processButton(sender)
    }

    @IBAction private func equalsButtonTapped(_ sender: UIButton) {
        processButton(sender)
    }

    private func isUnsupportedButton(_ button: UIButton) -> Bool {
        guard let title = button.currentTitle else { return false }
        return unsupportedButtonLabels.contains(title)
    }

    @IBAction private func operationButtonTapped(_ sender: UIButton) {
        processButton(sender)
    }

    @IBAction private func percentButtonTapped(_ sender: UIButton) {
        processButton(sender)
    }

    private func processButton(_ button: UIButton) {
        guard let key = button.currentTitle else { return }
        displayLabel.text = model.processKey(key)
    }

    private static func rgb(
        _ red: CGFloat,
        _ green: CGFloat,
        _ blue: CGFloat
    ) -> UIColor {
        UIColor(red: red / 255, green: green / 255, blue: blue / 255, alpha: 1)
    }

    private func setDisplayHeight(_ height: CGFloat) {
        displayLabel.constraints
            .first { $0.firstAttribute == .height }
            .map { $0.constant = height }
    }

    private func setMainStackHorizontalEdgeConstraints(active: Bool) {
        view.constraints
            .filter {
                $0.identifier == "main-leading" || $0
                    .identifier == "main-trailing"
            }
            .forEach { $0.isActive = active }
    }

    private func setRowsHeight(_ height: CGFloat) {
        for row in rowStacks {
            row.constraints
                .first { $0.firstAttribute == .height }
                .map { $0.constant = height }
        }
    }

    @IBAction private func signButtonTapped(_ sender: UIButton) {
        processButton(sender)
    }

    private func updateButtonCornerRadii() {
        for button in buttons {
            button.layer.cornerRadius = button.bounds.height / 2
        }
    }

    private func updateDisplay() {
        displayLabel.text = model.currentValue
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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateLayoutForCurrentSize()
        updateButtonCornerRadii()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
        configureAppearance()
        updateDisplay()
    }
}
