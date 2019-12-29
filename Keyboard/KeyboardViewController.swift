//
//  KeyboardViewController.swift
//  Keyboard
//
//  Created by Zixuan on 12/25/19.
//  Copyright © 2019 Zixuan. All rights reserved.
//

import UIKit

class KeyboardViewController: UIInputViewController, KeyboardViewDelegate, KeyboardViewDatasource {

    var nextKeyboardButton: UIButton!
    public var keyboardView: KeyboardView!
    let keysLayout = [["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"],
                         ["A", "S", "D", "F", "G", "H", "J", "K", "L"],
                         ["Z", "X", "C", "V", "B", "N", "M"]]
    
    public var shouldLayoutKeyboardConstraintsAutomatically: Bool = true
    private var layoutConstrained: Bool = false
    
    private var proxy: UITextDocumentProxy!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* next button */
        self.nextKeyboardButton = UIButton(type: .system)
        
        self.nextKeyboardButton.setTitle(NSLocalizedString("Next Keyboard", comment: "Title for 'Next Keyboard' button"), for: [])
        self.nextKeyboardButton.sizeToFit()
        self.nextKeyboardButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.nextKeyboardButton.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
        
        self.view.addSubview(self.nextKeyboardButton)
        
        self.nextKeyboardButton.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.nextKeyboardButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        proxy = self.textDocumentProxy as UITextDocumentProxy
        
        setupKeyboard()
        self.keyboardView.reloadKeys()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let newHeight: CGFloat = 270
        let heightConstraint = NSLayoutConstraint(item: self.view!, attribute:NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem:nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1.0, constant: newHeight)
        heightConstraint.priority = UILayoutPriority(rawValue: 999)
        self.view.addConstraint(heightConstraint)
    }
    
    func setupKeyboard() {
        self.keyboardView = KeyboardView()
        self.keyboardView.delegate = self
        self.keyboardView.datasource = self
        self.keyboardView.backgroundColor = UIColor.lightGray
        
        self.view.addSubview(keyboardView)
        self.view.setNeedsUpdateConstraints()
    }
    
    public override func updateViewConstraints() {
        // Add custom view sizing constraints here
        super.updateViewConstraints()
        
        if !layoutConstrained {
            if shouldLayoutKeyboardConstraintsAutomatically {
                let left = NSLayoutConstraint(item: self.keyboardView!, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1.0, constant: 0.0)
                let top = NSLayoutConstraint(item: self.keyboardView!, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0.0)
                let right = NSLayoutConstraint(item: self.keyboardView!, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1.0, constant: 0.0)
                let bottom = NSLayoutConstraint(item: self.keyboardView!, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0.0)
                left.priority = UILayoutPriority(rawValue: 999)
                right.priority = UILayoutPriority(rawValue: 999)
                bottom.priority = UILayoutPriority(rawValue: 999)
                top.priority = UILayoutPriority(rawValue: 999)
                self.view.addConstraints([left, right, top, bottom])
            }
            layoutConstrained = true
        }
    }
    
    override func viewWillLayoutSubviews() {
        self.nextKeyboardButton.isHidden = !self.needsInputModeSwitchKey
        super.viewWillLayoutSubviews()
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
        
        var textColor: UIColor
        let proxy = self.textDocumentProxy
        if proxy.keyboardAppearance == UIKeyboardAppearance.dark {
            textColor = UIColor.white
        } else {
            textColor = UIColor.black
        }
        self.nextKeyboardButton.setTitleColor(textColor, for: [])
    }

    /// setup keyboard layout
    /* return numbers of rows in keyboard */
    func numberOfRowsInKeyboardView(keyboardView: KeyboardView) -> Int {
        return self.keysLayout.count
    }
    
    /* returm numbers of keys in specific row */
    func keyboardView(keyboardView: KeyboardView, numberOfKeysInRow row: Int) -> Int {
        return self.keysLayout[row].count
    }
    
    /* return keyboardkeyview of specific key */
    func keyboardView(keyboardView: KeyboardView, keyAtIndexPath indexPath: NSIndexPath) -> KeyboardKeyView? {
        return KeyboardKeyView(keyType: .Character,
                               keyCap: self.keysLayout[indexPath.section][indexPath.item],
                               outputString: self.keysLayout[indexPath.section][indexPath.item])
    }
    
    ///handle input event
    @objc func keyPressed(key: KeyboardKeyView) {
        proxy.insertText(key.outputString ?? "")
    }
    
    @objc func specialKeyPressed(key: KeyboardKeyView) {
        
    }
    
    @objc func backspaceKeyPressed(key: KeyboardKeyView) {
        
    }
    
    @objc func spaceKeyPressed(key: KeyboardKeyView) {
        
    }
    
    @objc func shiftKeyPressed(key: KeyboardKeyView) {
        
    }
    
    @objc func returnKeyPressed(key: KeyboardKeyView) {
        
    }
    
    @objc func modeChangeKeyPressed(key: KeyboardKeyView) {
        
    }
    
    @objc func nextKeyboardKeyPressed(key: KeyboardKeyView) {
        
    }
}
