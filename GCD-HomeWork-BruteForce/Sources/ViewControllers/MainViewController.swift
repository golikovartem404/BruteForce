//
//  ViewController.swift
//  GCD-HomeWork-BruteForce
//
//  Created by User on 10.10.2022.
//

import UIKit
import SnapKit

class MainViewController: UIViewController {

    private var isBlack: Bool = false {
        didSet {
            if isBlack {
                self.view.backgroundColor = .black
                self.passwordLabel.textColor = .white
            } else {
                self.view.backgroundColor = .white
                self.passwordLabel.textColor = .black
            }
        }
    }

    private var stoppedBruteForce = false

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
        button.setTitleColor(UIColor.systemBlue, for:   .normal)
        return button
    }()

    private lazy var startBruteForceButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start", for: .normal)
        button.setTitleColor(UIColor.systemBlue, for:   .normal)
        return button
    }()

    private lazy var stopBruteForceButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Stop", for: .normal)
        button.setTitleColor(UIColor.systemBlue, for:   .normal)
        return button
    }()

    private lazy var changeBackgroundColorButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Change color", for: .normal)
        button.setTitleColor(UIColor.systemBlue, for:   .normal)
        return button
    }()

    private lazy var buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 7
        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupHierarchy()
        setupLayout()
    }

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

    @objc func reset() {
        passwordLabel.text = ""
        passwordLabel.textColor = .black
        passwordTextField.isSecureTextEntry = true
        passwordTextField.text = ""
        stoppedBruteForce = false
    }

    @objc func startBruteForce() {
        if passwordTextField.text == "" {
            let alert = UIAlertController(title: "Error",
                                          message: "Please write password!",
                                          preferredStyle: .alert)
            let actionOK = UIAlertAction(title: "Ok",
                                         style: .default,
                                         handler: nil)
            alert.addAction(actionOK)
            present(alert, animated: true)
        } else {
            if let password = passwordTextField.text {
                let queue = DispatchQueue(label: "bruteforce",
                                          qos: .background,
                                          attributes: .concurrent)
                queue.async {
                    self.bruteForce(passwordToUnlock: password)
                }
                self.passwordBruteForceProgress.isHidden = false
                self.passwordBruteForceProgress.startAnimating()
            }
        }
    }

    @objc func stopBruteForce() {
        stoppedBruteForce = true
        self.passwordBruteForceProgress.isHidden = true
        self.passwordBruteForceProgress.stopAnimating()
    }

    @objc func changeColor() {
        isBlack.toggle()
    }

    func bruteForce(passwordToUnlock: String) {

        let ALLOWED_CHARACTERS:   [String] = String().printable.map { String($0) }

        var password: String = ""

        // Will strangely ends at 0000 instead of ~~~
        while password != passwordToUnlock { // Increase MAXIMUM_PASSWORD_SIZE value for more
            password = generateBruteForce(password, fromArray: ALLOWED_CHARACTERS)
//             Your stuff here
            print(password)
            // Your stuff here
        }

        print(password)
    }

    func indexOf(character: Character, _ array: [String]) -> Int {
        return array.firstIndex(of: String(character))!
    }

    func characterAt(index: Int, _ array: [String]) -> Character {
        return index < array.count ? Character(array[index])
                                   : Character("")
    }

    func generateBruteForce(_ string: String, fromArray array: [String]) -> String {
        var str: String = string

        if str.count <= 0 {
            str.append(characterAt(index: 0, array))
        }
        else {
            str.replace(at: str.count - 1,
                        with: characterAt(index: (indexOf(character: str.last!, array) + 1) % array.count, array))

            if indexOf(character: str.last!, array) == 0 {
                str = String(generateBruteForce(String(str.dropLast()), fromArray: array)) + String(str.last!)
            }
        }

        return str
    }
}
