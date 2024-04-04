//
//  ViewController.swift
//  ActionSheetSample
//
//  Created by debugholic on 2024/04/04.
//

import UIKit
import ActionSheetSwift


extension String: ActionSheetItem {
    public var title: String {
        return self
    }
}


class ActionSheetItemView: UIView {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var button: UIButton!
}

class ViewController: UIViewController {
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var startButton: UIButton!
    
    @IBAction func touchUpInside(_ sender: Any) {
        if startButton === sender as? UIButton {
            var data = [String]()
            for subview in stackView.arrangedSubviews {
                if let textField = (subview as? ActionSheetItemView)?.textField {
                    if let text = textField.text, !text.isEmpty {
                        data.append(text)
                    } else if let placeholder = textField.placeholder {
                        data.append(placeholder)
                    }
                }
            }
            let viewController = ActionSheetViewController(data: data)
            for i in 0..<stackView.arrangedSubviews.count {
                if let button = (stackView.arrangedSubviews[i] as? ActionSheetItemView)?.button {
                    if button.isSelected {
                        viewController.selected = i
                        break
                    }
                }
            }
            
            viewController.dismissHandler = { selected in
                for subview in self.stackView.arrangedSubviews {
                    if let button = (subview as? ActionSheetItemView)?.button {
                        button.isSelected = false
                    }
                }

                if let selected = selected, selected < self.stackView.arrangedSubviews.count,
                   let button = (self.stackView.arrangedSubviews[selected] as? ActionSheetItemView)?.button {
                    button.isSelected = true
                }
            }
            present(viewController, animated: true)

            
        } else if let sender = sender as? UIButton, sender.isSelected == false {
            sender.isSelected = true
            for subview in stackView.arrangedSubviews {
                if let button = (subview as? ActionSheetItemView)?.button {
                    if sender !== button {
                        button.isSelected = false
                    }
                }
            }
        }
    }
}
