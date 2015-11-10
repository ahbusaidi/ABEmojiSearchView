//
//  ABEmoji.swift
//  EmoticonSearch
//
//  Created by Ahmed Al-Busaidi on 11/9/15.
//  Copyright © 2015 Ahmed Al-Busaidi. All rights reserved.
//

import UIKit

class ABEmoji: NSObject {
    var name: NSString!
    var emoji: NSString!
    init(name: NSString, emoji: NSString) {
        super.init()
        self.name = name
        self.emoji = emoji
    }
    
    override var description: String {
        return "\(self.emoji) \(self.name)"
    }
}
