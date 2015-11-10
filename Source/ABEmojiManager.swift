//
//  ABEmojiManager.swift
//  EmoticonSearch
//
//  Created by Ahmed Al-Busaidi on 11/9/15.
//  Copyright © 2015 Ahmed Al-Busaidi. All rights reserved.
//

import UIKit

class ABEmojiManager: NSObject {

    lazy var allEmoji = NSArray()
    var searchedEmoji: NSArray!
    lazy var topEmoji:NSArray = NSArray()
    
    override init() {
        super.init()
        self.loadEmoji()
    }
    
    func loadEmoji(){
        let filePath = NSBundle.mainBundle().pathForResource("AllEmoji", ofType: "json") // Maybe
        let emojiDictionary = try! NSJSONSerialization.JSONObjectWithData(NSData(contentsOfFile: filePath!)!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
        for name in emojiDictionary {
            let key = name.key as! NSString
            self.allEmoji = self.allEmoji.arrayByAddingObject(ABEmoji(name: key, emoji: emojiDictionary.valueForKey(key as String) as! (String)))
        }
        self.allEmoji = self.allEmoji.sortedArrayUsingComparator({ (obj1:AnyObject, obj2:AnyObject) -> NSComparisonResult in
            let emo1 = obj1 as! ABEmoji
            let emo2 = obj2 as! ABEmoji
            return (emo1.name as String).compare(emo2.name as String)
        })
        for name in self.topEmojiList() {
            let key = name as! NSString
            self.topEmoji = self.topEmoji.arrayByAddingObject(ABEmoji(name: key, emoji: emojiDictionary.valueForKey(key as String) as! (String)))
        }
    }
    
    func searchWithText(searchText : NSString) {
        if (searchText.length == 0){
            self.searchedEmoji = nil
        }else{
            let predicate = NSPredicate(block: { (evaluatedObject:AnyObject, bindings:[String : AnyObject]?) -> Bool in
                let evaluatedEmoji = evaluatedObject as! ABEmoji
                return evaluatedEmoji.name.lowercaseString.containsString(searchText.lowercaseString)
            })
            self.searchedEmoji = self.allEmoji.filteredArrayUsingPredicate(predicate)
        }
    }
    
    func numberOfSearchResults() -> NSInteger {
        if ((self.searchedEmoji) != nil){
            print("srached: \(self.searchedEmoji.count)")
            return self.searchedEmoji.count
        }else{
            print("top: \(self.topEmoji.count)")
            return self.topEmoji.count
        }
    }
    
    func emojiAtIndex(index : NSInteger) -> ABEmoji? {
        if ((self.searchedEmoji) != nil){
            if(index < self.searchedEmoji.count){
                return self.searchedEmoji[index] as? ABEmoji
            }else{
                return nil
            }
        }else{
            if(index < self.topEmoji.count){
                return self.topEmoji[index] as? ABEmoji
            }  else{
                return nil
            }
        }
    }
    
    func clear(){
        self.searchedEmoji = nil
    }
    
    func topEmojiList() -> NSArray{
        return ["pizza",
            "cab",
            "beers",
            "wine",
            "icecream",
            "confetti",
            "drumstick",
            "beer",
            "ramen",
            "rooster",
            "dancers",
            "cocktail",
            "football",
            "fork_and_knife",
            "basketball",
            "dancer",
            "tv",
            "sushi",
            "burger"];
        
    }
}
