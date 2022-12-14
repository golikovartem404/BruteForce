//
//  ViewController.swift
//  GCD-HomeWork-BruteForce
//
//  Created by User on 10.10.2022.
//

import UIKit
import SnapKit

class MainViewController: UIViewController {

    // MARK: - Properties

    private var isBlack: Bool = false {
        didSet {
            if isBlack {
                self.view.backgroundColor = .black
                self.passwordLabel.textColor = .white
                self.resetButton.setTitleColor(UIColor.white, for: .normal)
                self.startBruteForceButton.setTitleColor(UIColor.white, for: .normal)
                self.stopBruteForceButton.setTitleColor(UIColor.white, for: .normal)
                self.changeBackgroundColorButton.setTitleColor(UIColor.white, for: .normal)
            } else {
                self.view.backgroundColor = .white
                self.passwordLabel.textColor = .black
                self.resetButton.setTitleColor(UIColor.black, for: .normal)
                self.startBruteForceButton.setTitleColor(UIColor.black, for: .normal)
                self.stopBruteForceButton.setTitleColor(UIColor.black, for: .normal)
                self.changeBackgroundColorButton.setTitleColor(UIColor.black, for: .normal)
            }
        }
    }

    private var stoppedBruteForce = false

    // MARK: - Outlets

    private lazy var passwordLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        label.textAlignment = .center
        return label
    }()

    private lazy var passwordTextField: UITextField = {
        let textfield = UITextField()
        textfield.backgroundColor = .systemGray6
        textfield.placeholder = "Write password here"
        textfield.isSecureTextEntry = true
        textfield.borderStyle = .roundedRect
        textfield.returnKeyType = .done
        textfield.delegate = self
        return textfield
    }()

    private lazy var passwordBruteForceProgress: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.isHidden = true
        return activityIndicator
    }()

    private lazy var resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Reset", for: .normal)
        button.setTitleColor(UIColor.black, for:   .normal)
        button.addTarget(self, action: #selector(reset), for: .touchUpInside)
        return button
    }()

    private lazy var startBruteForceButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.addTarget(self, action: #selector(startBruteForce), for: .touchUpInside)
        return button
    }()

    private lazy var stopBruteForceButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Stop", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.addTarget(self, action: #selector(stopBruteForce), for: .touchUpInside)
        return button
    }()

    private lazy var changeBackgroundColorButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Change color", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.addTarget(self, action: #selector(changeColor), for: .touchUpInside)
        return button
    }()

    private lazy var buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 7
        return stack
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupHierarchy()
        setupLayout()
    }

    // MARK: - View Setups

    private func setupHierarchy() {
        view.addSubview(passwordLabel)
        view.addSubview(passwordTextField)
        view.addSubview(passwordBruteForceProgress)
        view.addSubview(resetButton)
        buttonStack.addArrangedSubview(startBruteForceButton)
        buttonStack.addArrangedSubview(stopBruteForceButton)
        buttonStack.addArrangedSubview(changeBackgroundColorButton)
        view.addSubview(buttonStack)
    }

    private func setupLayout() {

        passwordLabel.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.centerX)
            make.width.equalTo(view.snp.width).multipliedBy(0.7)
            make.top.equalTo(view.snp.centerY).multipliedBy(0.4)
        }

        passwordTextField.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(view)
            make.width.equalTo(view.snp.width).multipliedBy(0.7)
        }

        passwordBruteForceProgress.snp.makeConstraints { make in
            make.centerY.equalTo(passwordTextField.snp.centerY)
            make.right.equalTo(passwordTextField.snp.right).offset(-10)
        }

        resetButton.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.centerY.equalTo(view.snp.centerY).multipliedBy(1.1)
        }

        buttonStack.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.centerY.equalTo(view.snp.centerY).multipliedBy(1.4)
            make.width.equalTo(view.snp.width).multipliedBy(0.9)
        }
    }

    // MARK: - Actions for buttons

    @objc private func reset() {
        passwordLabel.text = ""
        passwordLabel.textColor = .black
        passwordTextField.isSecureTextEntry = true
        passwordTextField.text = ""
        stoppedBruteForce = false
    }

    @objc private func startBruteForce() {
        if passwordTextField.text == "" {
            let alert = UIAlertController(
                title: "Error",
                message: "Please write password!",
                preferredStyle: .alert
            )
            let actionOK = UIAlertAction(
                title: "Ok",
                style: .default,
                handler: nil
            )
            alert.addAction(actionOK)
            present(alert, animated: true)
        } else {
            if let password = passwordTextField.text {
                let queue = DispatchQueue(
                    label: "bruteforce",
                    qos: .background,
                    attributes: .concurrent
                )
                queue.async {
                    self.bruteForce(passwordToUnlock: password)
                }
                self.passwordBruteForceProgress.isHidden = false
                self.passwordBruteForceProgress.startAnimating()
            }
        }
    }

    @objc private func stopBruteForce() {
        stoppedBruteForce = true
        self.passwordBruteForceProgress.isHidden = true
        self.passwordBruteForceProgress.stopAnimating()
    }

    @objc private func changeColor() {
        isBlack.toggle()
    }

    // MARK: - Change interface method

    func changeInterfaceWhen(password secretKey: String, isHacked: Bool) {
        if isHacked {
            let successText = "Password is found:\n\(secretKey)"
            self.passwordLabel.text = successText
            self.passwordLabel.textColor = .systemGreen
            self.passwordTextField.isSecureTextEntry = false
            self.passwordBruteForceProgress.isHidden = true
            self.passwordBruteForceProgress.stopAnimating()
        } else {
            let failureText = "Password \n\(secretKey)\n not hacked"
            self.passwordLabel.text = failureText
            self.passwordLabel.textColor = .systemRed
        }
    }

    // MARK: - BruteForce method functions

    private func bruteForce(passwordToUnlock: String) {

        let allowedCharacters: [String] = String().printable.map { String($0) }
        var password: String = ""

        while password != passwordToUnlock {
            if stoppedBruteForce {
                DispatchQueue.main.async {
                    self.changeInterfaceWhen(password: self.passwordTextField.text ?? "", isHacked: false)
                }
                break
            }
            password = generateBruteForce(password, fromArray: allowedCharacters)
            DispatchQueue.main.async {
                self.passwordLabel.text = password
            }
        }

        if !stoppedBruteForce {
            DispatchQueue.main.async {
                self.changeInterfaceWhen(password: password, isHacked: true)
            }
        }
    }

    private func indexOf(character: Character, _ array: [String]) -> Int {
        return array.firstIndex(of: String(character))!
    }

    private func characterAt(index: Int, _ array: [String]) -> Character {
        return index < array.count ? Character(array[index])
                                   : Character("")
    }

    private func generateBruteForce(_ string: String, fromArray array: [String]) -> String {

        var initialPasswordString: String = string

        if initialPasswordString.count <= 0 {
            initialPasswordString.append(characterAt(index: 0, array))
        } else {
            initialPasswordString.replace(at: initialPasswordString.count - 1,
                                          with: characterAt(index: (indexOf(character: initialPasswordString.last ?? Character(""), array) + 1) % array.count, array))
            if indexOf(character: initialPasswordString.last ?? Character(""), array) == 0 {
                initialPasswordString = String(generateBruteForce(String(initialPasswordString.dropLast()), fromArray: array)) + String(initialPasswordString.last ?? Character(""))
            }
        }
        return initialPasswordString
    }
}

extension MainViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
