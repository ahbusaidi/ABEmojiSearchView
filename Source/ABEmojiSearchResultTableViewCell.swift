//
//  ABEmojiSearchResultTableViewCell.swift
//  EmoticonSearch
//
//  Created by Ahmed Al-Busaidi on 11/9/15.
//  Copyright © 2015 Ahmed Al-Busaidi. All rights reserved.
//

import UIKit

class ABEmojiSearchResultTableViewCell: UITableViewCell {
    var emoji: ABEmoji! {
        didSet {
            self.textLabel?.text = emoji.description
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.contentView.backgroundColor = UIColor.clearColor()
    }
    
}
