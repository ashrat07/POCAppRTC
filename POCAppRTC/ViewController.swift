//
//  ViewController.swift
//  POCAppRTC
//
//  Created by Ashish Rathore on 26/03/20.
//  Copyright © 2020 Microsoft. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let button = UIButton(type: .system)
        button.setTitle("Push", for: .normal)
        button.addTarget(self, action: #selector(push), for: .touchUpInside)
        self.view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    }

    @objc func push() {
        let viewController = WebViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
