//
//  ViewController.swift
//  AppProject
//
//  Created by 吴天 on 2025/11/22.
//

import UIKit
import StaticLibraryProject

class ViewController: UIViewController {
    override func viewDidLoad() {
        let libObj = StaticLibraryProject()
        print("someBool default value: \(libObj.someBool)")
    }
}

