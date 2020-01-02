//
//  KeyboardViewController.swift
//  Keyboard
//
//  Created by Zixuan on 12/25/19.
//  Copyright © 2019 Zixuan. All rights reserved.
//

import UIKit

class KeyboardViewController: UIInputViewController, KeyboardViewDelegate, KeyboardViewDatasource, UICollectionViewDelegate, UICollectionViewDataSource {

    public var keyboardView: KeyboardView!
    public var selectionView: UICollectionView = { //init the selection view
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(KeyboardSelectionViewCell.self, forCellWithReuseIdentifier: "cell")
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
                
        return cv
    }()
    
    let mainLayout = [["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"],
                      [" a", "s", "d", "f", "g", "h", "j", "k", "l "],
                      ["Shift", "z", "x", "c", "v", "b", "n", "m", "BackSpace"],
                      ["ModeChange", "Space", "Return"]]
    let numberLayout = [["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"],
                        ["-", "/", "：", "；", "（", "）", "$", "@", "“", "”"],
                        ["SwitchKey", "。", "，", "、", "？", "！", ".", "BackSpace"],
                        ["ModeChange", "Space", "Return"]]
    let symbolLayout = [["【", "】", "｛", "｝", "#", "%", "^", "*", "+", "="],
                        ["_", "—", "\\", "｜", "～", "《", "》", "€", "&", "·"],
                        ["SwitchKey", "…","，", "^_^", "？", "！", "‘", "BackSpace"],
                        ["ModeChange", "Space", "Return"]]
    
    let data = ["你好", "您好", "我好", "他好", "她好", "她好", "你好", "您好", "我好", "他好", "她好", "她好"]
    
    public enum Mode {
        case main
        case number
        case symbol
    }
    
    public var mode: Mode = .main
    
    public var shouldLayoutKeyboardConstraintsAutomatically: Bool = true
    private var layoutConstrained: Bool = false
    
    private var proxy: UITextDocumentProxy!
    private var deleteTimer: Timer? // timer for implementing long-pressed backspace
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        proxy = self.textDocumentProxy as UITextDocumentProxy
        
        setupKeyboard()
        self.keyboardView.reloadKeys()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
        /* set height of keyboard */
        let newHeight: CGFloat = 220
        let heightConstraint = NSLayoutConstraint(item: self.view!, attribute:NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem:nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1.0, constant: newHeight)
        heightConstraint.priority = UILayoutPriority(rawValue: 999)
        self.view.addConstraint(heightConstraint)
    }
    
    func setupKeyboard() {
        self.keyboardView = KeyboardView()
        self.keyboardView.delegate = self
        self.keyboardView.datasource = self
        self.keyboardView.backgroundColor = UIColor.clear
        
        self.selectionView.delegate = self
        self.selectionView.dataSource = self
        
        self.view.addSubview(keyboardView)
        self.view.addSubview(selectionView)
        self.view.setNeedsUpdateConstraints()
    }
    
    public override func updateViewConstraints() {
        // Add custom view sizing constraints here
        super.updateViewConstraints()
        
        if !layoutConstrained {
            if shouldLayoutKeyboardConstraintsAutomatically {
                /* setup constraint of selection view */
                selectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
                selectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
                selectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
                selectionView.bottomAnchor.constraint(equalTo: view.topAnchor, constant: 20.0).isActive = true
                
                /* setup constraint of keyboard view */
                let left = NSLayoutConstraint(item: self.keyboardView!, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1.0, constant: 0.0)
                let top = NSLayoutConstraint(item: self.keyboardView!, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0.0)
                let right = NSLayoutConstraint(item: self.keyboardView!, attribute: .right, relatedBy: .equal, toItem: self.selectionView, attribute: .right, multiplier: 1.0, constant: 0.0)
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
    
//    override func viewWillLayoutSubviews() {
//        self.nextKeyboardButton.isHidden = !self.needsInputModeSwitchKey
//        super.viewWillLayoutSubviews()
//    }
    
    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
    }

    /// setup keyboard layout
    /* return numbers of rows in keyboard */
    func numberOfRowsInKeyboardView(keyboardView: KeyboardView) -> Int {
        switch mode {
            case .main:
                return self.mainLayout.count
            case .symbol:
                return self.symbolLayout.count
            case .number:
                return self.numberLayout.count
        }
    }
    
    /* returm numbers of keys in specific row */
    func keyboardView(keyboardView: KeyboardView, numberOfKeysInRow row: Int) -> Int {
        switch mode {
            case .main:
                return self.mainLayout[row].count
            case .symbol:
                return self.symbolLayout[row].count
            case .number:
                return self.numberLayout[row].count
        }
    }
    
    /* return keyboardkeyview of specific key */
    func keyboardView(keyboardView: KeyboardView, keyAtIndexPath indexPath: NSIndexPath) -> KeyboardKeyView? {
        let key: KeyboardKeyView
        let currentLayout: [[String]]
        
        switch mode {
            case .main:
                currentLayout = mainLayout
            case .number:
                currentLayout = numberLayout
            case .symbol:
                currentLayout = symbolLayout
        }
        
        switch currentLayout[indexPath.section][indexPath.item] {
            case "Shift":
                key = KeyboardKeyView(keyType: .Shift,
                                      keyCap: "↑",
                                      outputString: "")
            case "BackSpace":
                key = KeyboardKeyView(keyType: .Backspace,
                                      keyCap: "←",
                                      outputString: "")
            case "KeyboardChange":
                key = KeyboardKeyView(keyType: .KeyboardChange,
                                      keyCap: "🌏",
                                      outputString: "")
            case "ModeChange":
                let keyCap = self.mode == .main ? "123" : "Pingying"
                key = KeyboardKeyView(keyType: .ModeChange,
                                      keyCap: keyCap,
                                      outputString: "")
            case "Space":
                key = KeyboardKeyView(keyType: .Space,
                                      keyCap: "",
                                      outputString: "")
            case "Return":
                key = KeyboardKeyView(keyType: .Return,
                                      keyCap: "⏎",
                                      outputString: "")
            case "SwitchKey":
                let keyCap = self.mode == .number ? "#+=" : "123"
                key = KeyboardKeyView(keyType: .SwitchKey,
                                      keyCap: keyCap,
                                      outputString: "")
            default:
                key = KeyboardKeyView(keyType: .Character,
                                      keyCap: currentLayout[indexPath.section][indexPath.item],
                                      outputString: currentLayout[indexPath.section][indexPath.item])
                if key.keyCap!.contains(" ") {
                    key.keyCap = key.keyCap!.replacingOccurrences(of: " ", with: "")
                    key.outputString = key.outputString!.replacingOccurrences(of: " ", with: "")
                    key.extraPadding = true
                }
        }
        
        return key
    }
    
    ///handle input event
    @objc func keyPressed(key: KeyboardKeyView) {
        proxy.insertText(key.outputString ?? "")
    }
    
    @objc func specialKeyPressed(key: KeyboardKeyView) {
        
    }
    
    @objc func backspaceKeyPressed(key: KeyboardKeyView) {
        proxy.deleteBackward()
    }
    
    @objc  func backspaceKeyLongPressed(status: Bool) {
        if status {
            deleteTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(backspaceKeyPressed(key:)), userInfo: nil, repeats: true)
        } else {
            deleteTimer?.invalidate()
        }
    }
    
    @objc func spaceKeyPressed(key: KeyboardKeyView) {
        proxy.insertText(" ")
    }
    
    @objc func shiftKeyPressed(key: KeyboardKeyView) {
        keyboardView.toggleShift()
    }
    
    @objc func returnKeyPressed(key: KeyboardKeyView) {
        UIDevice.current.playInputClick()
        proxy.insertText("\n")
    }
    
    @objc func modeChangeKeyPressed(key: KeyboardKeyView) {
        if mode == .main {
            mode = .number
        } else {
            mode = .main
        }
        keyboardView.reloadKeys()
    }
    
    @objc func nextKeyboardKeyPressed(key: KeyboardKeyView) {
        self.advanceToNextInputMode()
    }
    
    @objc func switchKeyPressed(key: KeyboardKeyView) {
        if mode == .number {
            mode = .symbol
        } else {
            mode = .number
        }
        keyboardView.reloadKeys()
    }
    
    /* controlling the selection view */
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = selectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! KeyboardSelectionViewCell
        
        cell.backgroundColor = .clear
        cell.label.text = data[indexPath.row]
        
        return cell
    }
}
