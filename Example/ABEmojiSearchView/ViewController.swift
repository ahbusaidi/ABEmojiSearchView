//
//  ViewController.swift
//  ABEmojiSearchView
//
//  Created by Ahmed Al-Busaidi on 11/10/2015.
//  Copyright (c) 2015 Ahmed Al-Busaidi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let _emojiSearchView = ABEmojiSearchView()
        _emojiSearchView.frame = CGRectMake(0, 66.0, 400, 400);
        self.view.addSubview(_emojiSearchView)
        _emojiSearchView.installOnTextField(textField)
        
    }

}

