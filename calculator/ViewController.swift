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

    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
        configureButtonActions()
        configureAppearance()
        displayLabel.text = model.currentValue
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateLayoutForCurrentSize()
        updateButtonCornerRadii()
    }

    private func backgroundColor(for button: UIButton) -> UIColor {
        guard let title = button.currentTitle else {
            return unsupportedButtonColor
        }
        let unsupported = unsupportedButtonLabels.contains(title)
        let isNumber = Int(title) != nil
        return unsupported ? unsupportedButtonColor :
            isNumber ? numberButtonColor : operatorButtonColor
    }

    @objc private func buttonTapped(_ sender: UIButton) {
        processButton(sender)
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
            button.isEnabled = !isUnsupportedButton(button)
            button.clipsToBounds = true
        }
    }

    // Doing this in the code instead of in the storyboard
    // removes the need to manually configure each button
    // and will make it easier to support new buttons in the future.
    private func configureButtonActions() {
        for button in buttons {
            button.addTarget(
                self,
                action: #selector(buttonTapped(_:)),
                for: .touchUpInside
            )
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

    private func isUnsupportedButton(_ button: UIButton) -> Bool {
        guard let title = button.currentTitle else { return false }
        return unsupportedButtonLabels.contains(title)
    }

    private func processButton(_ button: UIButton) {
        guard let key = button.currentTitle else { return }
        displayLabel.text = model.processKey(key)
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

    private func updateButtonCornerRadii() {
        for button in buttons {
            button.layer.cornerRadius = button.bounds.height / 2
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
}
