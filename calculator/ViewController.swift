import UIKit

class ViewController: UIViewController {
    @IBOutlet private var displayLabel: UILabel!

    // Creates a UIColor from 0-255 RGB component values.
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
    private var buttonCornerRadius: CGFloat = 0
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

    // Performs initial layout and button setup,
    // then shows the model's current value.
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
        configureButtons()
        displayLabel.text = model.currentValue
    }

    // Updates layout-dependent sizing after the view has laid out its subviews.
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateLayoutForCurrentSize()
        updateButtonCornerRadii()
    }

    // Returns the background color for a button based on its title.
    private func backgroundColor(for button: UIButton) -> UIColor {
        guard let title = button.currentTitle else {
            return unsupportedButtonColor
        }
        let unsupported = unsupportedButtonLabels.contains(title)
        let isNumber = Int(title) != nil
        return unsupported ? unsupportedButtonColor :
            isNumber ? numberButtonColor : operatorButtonColor
    }

    // Applies styling and touch handling to every calculator button.
    private func configureButtons() {
        let buttonFont = UIFont.systemFont(ofSize: 28, weight: .bold)
        for button in buttons {
            button.setTitleColor(.white, for: .normal)
            button.titleLabel?.font = buttonFont
            button.backgroundColor = backgroundColor(for: button)
            button.isEnabled = !isUnsupportedButton(button)
            button.addTarget(
                self,
                action: #selector(processButton(_:)),
                for: .touchUpInside
            )
        }
    }

    // Creates reusable constraints that are activated for landscape layout.
    // This is done in the updateLayoutForCurrentSize method.
    private func configureLayout() {
        guard let mainStack else { return }
        mainStackCenterConstraint = mainStack.centerXAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.centerXAnchor
        )
        mainStackWidthConstraint = mainStack.widthAnchor
            .constraint(equalToConstant: 0)
    }

    // Returns whether a button is supported.
    private func isUnsupportedButton(_ button: UIButton) -> Bool {
        guard let title = button.currentTitle else { return false }
        return unsupportedButtonLabels.contains(title)
    }

    // Sends the tapped button title to the model
    // and updates the display with the result.
    @objc private func processButton(_ button: UIButton) {
        guard let key = button.currentTitle else { return }
        displayLabel.text = model.processKey(key)
    }

    // Updates the display label's height constraint.
    // This is called when the layout changes between portrait and landscape.
    private func setDisplayHeight(_ height: CGFloat) {
        displayLabel.constraints
            .first { $0.firstAttribute == .height }
            .map { $0.constant = height }
    }

    // Activates or deactivates the storyboard constraints
    // that pin the main stack horizontally.
    // This is called in updateLayoutForCurrentSize
    // where the argument is true when in portrait mode.
    private func setMainStackHorizontalEdgeConstraints(active: Bool) {
        view.constraints
            .filter {
                $0.identifier == "main-leading" || $0
                    .identifier == "main-trailing"
            }
            .forEach { $0.isActive = active }
    }

    // Updates each row's height constraint.
    private func setRowsHeight(_ height: CGFloat) {
        for row in rowStacks {
            row.constraints
                .first { $0.firstAttribute == .height }
                .map { $0.constant = height }
        }
    }

    // Applies the current rounded corner radius to every button.
    private func updateButtonCornerRadii() {
        for button in buttons {
            button.layer.cornerRadius = buttonCornerRadius
        }
    }

    // Adjusts fonts, dimensions, and constraints for the current screen
    // orientation and size.
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
        buttonCornerRadius = rowHeight / 2

        setMainStackHorizontalEdgeConstraints(active: !isLandscape)
        mainStackCenterConstraint?.isActive = isLandscape
        mainStackWidthConstraint?.isActive = isLandscape
        if isLandscape {
            mainStackWidthConstraint?.constant = stackWidth
        }
    }
}
