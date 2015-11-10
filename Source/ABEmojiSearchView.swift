//
//  ABEmojiSearchView.swift
//  EmoticonSearch
//
//  Created by Ahmed Al-Busaidi on 11/9/15.
//  Copyright © 2015 Ahmed Al-Busaidi. All rights reserved.
//

import UIKit

protocol ABEmojiSearchViewDelegate:NSObjectProtocol{
    func emojiSearchViewWillAppear(emojiSearchView : ABEmojiSearchView)
    func emojiSearchViewDidAppear(emojiSearchView:ABEmojiSearchView)
    func emojiSearchViewWillDisappear(emojiSearchView:ABEmojiSearchView)
    func emojiSearchViewDidDisappear(emojiSearchView:ABEmojiSearchView )
}

class ABEmojiSearchView: UIView,UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UITextViewDelegate {

    var appearAnimationBlock: (() -> Void)?
    var disappearAnimationBlock: (() -> Void)?
    
    var textView: UITextView!
    var textViewDelegate: UITextViewDelegate!
    
    var textField: UITextField!
    var textFieldDelegate: UITextFieldDelegate!
    
    var dividerView: UIView = {
        let _dividerView = UIView(frame: CGRectMake(0, 0, 0, 0.5))
        _dividerView.backgroundColor = UIColor(white: 205.0/255.0, alpha: 1.0)
        _dividerView.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        return _dividerView
    }()
    
    lazy var manager = ABEmojiManager()
    var currentSearchRange: NSRange!
    
    var tableView: UITableView!
    var delegate: ABEmojiSearchViewDelegate!
    
    var headerTitle:NSString!{
        didSet{
            self.tableView.reloadData()
        }
    }
    var font: UIFont! {
        didSet{
            self.tableView.reloadData()
        }
    }
    
    var textColor: UIColor! {
        didSet{
            self.tableView.reloadData()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        tableView = UITableView()
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.frame = self.bounds;
        tableView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth,
            UIViewAutoresizing.FlexibleHeight]
        tableView.registerClass(ABEmojiSearchResultTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(ABEmojiSearchResultTableViewCell))
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = 44.0
        
        self.alpha = 0.0
        self.font = UIFont.systemFontOfSize(17.0)
        self.textColor = UIColor.darkTextColor()
        self.addSubview(self.tableView)
        self.addSubview(self.dividerView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    func searchWithText(searchText: NSString){
        self.manager.searchWithText(searchText)
        if (self.manager.numberOfSearchResults() > 0){
            self.tableView.reloadData()
            self.appear()
        }else{
            self.disappear()
        }
    }
    
    func installOnTextField(textField: UITextField){
        self.textView = nil
        self.textViewDelegate = nil
        self.textFieldDelegate = textField.delegate
        self.textField = textField
        self.textField.delegate = self
    }
    
    func installOnTextView(textView : UITextView)
    {
        self.textField = nil
        self.textFieldDelegate = nil
        self.textViewDelegate = textView.delegate
        self.textView = textView
        self.textView.delegate = self
    }
    
    func appear(){
        if self.delegate != nil && self.delegate.respondsToSelector("emojiSearchViewWillAppear:"){
            self.delegate.emojiSearchViewWillAppear(self)
        }
        if (self.appearAnimationBlock != nil){
            self.appearAnimationBlock!()
        }else{
            self.alpha = 1.0
            self.appearAnimationDidFinish()
        }
    }
    
    func appearAnimationDidFinish(){
        if self.delegate != nil && self.delegate.respondsToSelector("emojiSearchViewDidAppear:"){
            self.delegate.emojiSearchViewDidAppear(self)
        }
    }
    
    func disappear() {
        if ((self.delegate?.respondsToSelector(Selector("emojiSearchViewWillDisappear:"))) != nil) {
            self.delegate.emojiSearchViewWillDisappear(self)
        }
        if (self.disappearAnimationBlock != nil) {
            self.disappearAnimationBlock!();
        } else {
            self.alpha = 0.0;
            self.disappearAnimationDidFinish()
        }
    }
    
    func disappearAnimationDidFinish() {
        if self.delegate != nil && self.delegate.respondsToSelector("emojiSearchViewDidDisappear:") {
            self.delegate.emojiSearchViewDidDisappear(self)
        }
        self.manager.clear()
        self.currentSearchRange = NSMakeRange(0, 0)
        self.tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.manager.numberOfSearchResults()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = NSStringFromClass(ABEmojiSearchResultTableViewCell)
        let cell = self.tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! ABEmojiSearchResultTableViewCell
        cell.emoji = self.manager.emojiAtIndex(indexPath.row)
        cell.textLabel?.font = self.font
        cell.textLabel?.textColor = self.textColor
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let replacementString = NSString(format: "%@ ", (self.manager.emojiAtIndex(indexPath.row)?.emoji)!)
        let extendedRange = NSMakeRange(self.currentSearchRange.location - 1, self.currentSearchRange.length + 1)
        
        if self.textField != nil {
            self.textField.text = (self.textField.text! as NSString).stringByReplacingCharactersInRange(extendedRange, withString: replacementString as String)
        }
        if self.textView != nil{
            self.textView.text = (self.textView.text! as NSString).stringByReplacingCharactersInRange(extendedRange, withString: replacementString as String)
        }
        self.tableView.deselectRowAtIndexPath(indexPath, animated: false)
        self.disappear()
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.headerTitle == nil{
            return ""
        }else{
            return self.headerTitle as String
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if self.textFieldDelegate != nil &&  self.textFieldDelegate.respondsToSelector("textFieldDidBeginEditing:"){
            self.textFieldDelegate.textFieldDidBeginEditing!(textField)
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if self.textFieldDelegate != nil && self.textFieldDelegate.respondsToSelector("textFieldDidEndEditing:"){
            self.textFieldDelegate.textFieldDidBeginEditing!(textField)
        }
    }
 
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        self.handleString(textField.text!, replacementString: string, range: range)
        if (self.textFieldDelegate != nil && self.textFieldDelegate.respondsToSelector("textField:shouldChangeCharactersInRange:replacementString:")) {
            return self.textFieldDelegate.textField!(textField, shouldChangeCharactersInRange: range, replacementString: string)
        } else {
            return true
        }
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if (self.textFieldDelegate != nil && self.textFieldDelegate.respondsToSelector("textFieldShouldBeginEditing:")) {
            return self.textFieldDelegate.textFieldShouldBeginEditing!(textField)
        } else {
            return true
        }
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        if (self.textFieldDelegate != nil && self.textFieldDelegate.respondsToSelector("textFieldShouldClear:")) {
            return self.textFieldDelegate.textFieldShouldClear!(textField)
        } else {
            return true
        }
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        if (self.textFieldDelegate != nil && self.textFieldDelegate.respondsToSelector("textFieldShouldEndEditing:")) {
            return self.textFieldDelegate.textFieldShouldEndEditing!(textField)
        } else {
            return true
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (self.textFieldDelegate != nil && self.textFieldDelegate.respondsToSelector("textFieldShouldReturn:")) {
            return self.textFieldDelegate.textFieldShouldReturn!(textField)
        } else {
            return true
        }
    }
    
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        if (self.textViewDelegate != nil && self.textViewDelegate.respondsToSelector("textViewShouldBeginEditing:")) {
            return self.textViewDelegate.textViewShouldBeginEditing!(textView);
        } else {
            return true
        }
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if (self.textViewDelegate != nil && self.textViewDelegate.respondsToSelector("textViewDidBeginEditing:")) {
            self.textViewDelegate.textViewDidBeginEditing!(textView)
        }
    }
    
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        if (self.textViewDelegate != nil && self.textViewDelegate.respondsToSelector("textViewShouldEndEditing:")) {
            return self.textViewDelegate.textViewShouldEndEditing!(textView)
        } else {
            return true
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if (self.textViewDelegate != nil && self.textViewDelegate.respondsToSelector("textViewDidEndEditing:")) {
            self.textViewDelegate.textViewDidEndEditing!(textView);
        }
    }

    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        self.handleString(textView.text, replacementString: text, range: range)
        if (self.textViewDelegate != nil && self.textViewDelegate.respondsToSelector("textView:shouldChangeTextInRange:replacementText:")) {
            return self.textViewDelegate.textView!(textView, shouldChangeTextInRange: range, replacementText: text)
        } else {
            return true
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        if (self.textViewDelegate != nil && self.textViewDelegate.respondsToSelector("textViewDidChange:")) {
            self.textViewDelegate.textViewDidChange!(textView);
        }
    }
    
    func textViewDidChangeSelection(textView: UITextView) {
        if (self.textViewDelegate != nil && self.textViewDelegate.respondsToSelector("textViewDidChangeSelection:")) {
            self.textViewDelegate.textViewDidChangeSelection!(textView);
        }
    }
    
    func textView(textView: UITextView, shouldInteractWithTextAttachment textAttachment: NSTextAttachment, inRange characterRange: NSRange) -> Bool {
        if (self.textViewDelegate != nil && self.textViewDelegate.respondsToSelector("textView:shouldInteractWithTextAttachment:inRange:")) {
            return self.textViewDelegate.textView!(textView, shouldInteractWithTextAttachment: textAttachment, inRange: characterRange)
        } else {
            return true
        }
    }
    
    
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        if (self.textViewDelegate != nil && self.textViewDelegate.respondsToSelector("textView:shouldInteractWithURL:inRange:")) {
            return self.textViewDelegate.textView!(textView, shouldInteractWithURL: URL, inRange: characterRange)
        } else {
            return true
        }
    }
    
    
    func handleString(string: NSString, replacementString: NSString, range:NSRange){
        let newString = string.stringByReplacingCharactersInRange(range, withString: replacementString as String) as NSString
        let searchLength = range.location + replacementString.length
        let colonRange = newString.rangeOfString("@", options: NSStringCompareOptions.BackwardsSearch, range: NSMakeRange(0, searchLength))
        let spaceRange = newString.rangeOfString(" ", options: NSStringCompareOptions.BackwardsSearch, range: NSMakeRange(0, searchLength))
        if (colonRange.location != NSNotFound && (spaceRange.location == NSNotFound || colonRange.location > spaceRange.location)) {
            self.searchWithColonLocation(colonRange.location, string: newString)
        } else {
            self.disappear()
        }
    }
    
    
    func searchWithColonLocation(colonLocation : Int, string:NSString){
        let searchRange = NSMakeRange(colonLocation + 1, string.length - colonLocation - 1);
        let spaceRange = string.rangeOfString(" ", options: NSStringCompareOptions.CaseInsensitiveSearch, range: searchRange)
        
        var searchText:NSString!
        if (spaceRange.location == NSNotFound) {
            searchText = string.substringFromIndex(colonLocation + 1)
        } else {
            searchText = string.substringWithRange(NSMakeRange(colonLocation + 1, spaceRange.location - colonLocation - 1))
        }
        self.currentSearchRange = NSMakeRange(colonLocation + 1, searchText.length)
        self.searchWithText(searchText)
    }
    
}
