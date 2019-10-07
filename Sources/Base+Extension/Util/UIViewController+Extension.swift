//
//  UIViewController+Extension.swift
//  CoreBaseExtension
//
//  Created by Robert Nguyen on 1/11/17.
//  Copyright © 2017 Robert Nguyen. All rights reserved.
//

public extension UINavigationController {
    func popViewController(animated: Bool, completion: @escaping ()->()) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        popViewController(animated: animated)
        CATransaction.commit()
        CATransaction.setCompletionBlock(nil)
    }
}

public extension UIViewController {
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }

    func canPerformSegue(withIdentifier id: String) -> Bool {
        guard let segues = self.value(forKey: "storyboardSegueTemplates") as? [NSObject] else { return false }
        return segues.first { $0.value(forKey: "identifier") as? String == id } != nil
    }
}
