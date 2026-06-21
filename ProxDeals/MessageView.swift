//
//  MessageView.swift
//  ProxDeals
//
//  A simple full-area overlay used for empty and error states.
//  Built in code so it needs no storyboard wiring.
//

import UIKit

final class MessageView: UIView {

    private let stack = UIStackView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let actionButton = UIButton(type: .system)
    private var action: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = .systemBackground

        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .label

        messageLabel.font = .systemFont(ofSize: 15)
        messageLabel.textAlignment = .center
        messageLabel.textColor = .secondaryLabel
        messageLabel.numberOfLines = 0

        actionButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        actionButton.addTarget(self, action: #selector(tapped), for: .touchUpInside)

        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(messageLabel)
        stack.addArrangedSubview(actionButton)

        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -24)
        ])
    }

    /// Configure the view. Pass a nil buttonTitle to hide the button.
    func configure(title: String, message: String,
                   buttonTitle: String?, action: (() -> Void)? = nil) {
        titleLabel.text = title
        messageLabel.text = message
        self.action = action
        if let buttonTitle = buttonTitle {
            actionButton.setTitle(buttonTitle, for: .normal)
            actionButton.isHidden = false
        } else {
            actionButton.isHidden = true
        }
    }

    @objc private func tapped() { action?() }
}
