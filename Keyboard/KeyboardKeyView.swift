//
//  KeyboardKeyView.swift
//  Keyboard
//
//  Created by Zixuan on 12/29/19.
//  Copyright © 2019 Zixuan. All rights reserved.
//

import Foundation
import UIKit

public class KeyboardKeyView: UIControl {
    public enum KeyType {
        case Character
        case SpecialCharacter
        case Shift
        case Backspace
        case ModeChange
        case KeyboardChange
        case Period
        case Space
        case Return
        case SwitchKey
        case None
    }
    
    /* property */
    public var type: KeyType
    
    public var keyCap: String? {
        didSet {
            self.redrawText()
        }
    }
    
    public var outputString: String?
    
    public var shifted: Bool = false {
        willSet(newShift) {
            if newShift {
                self.textLabel.text = self.textLabel.text?.uppercased()
            } else {
                self.textLabel.text = self.textLabel.text?.lowercased()
            }
        }
    }
    
    public var color: UIColor? {
        didSet {
            self.backgroundColor = color
        }
    }
    
    var textLabel: UILabel = UILabel()
    public var selectedColor: UIColor?
    var contentInset: UIEdgeInsets?
    private var layoutConstrained: Bool = false
    
    
    /* init */
    public override init(frame: CGRect) {
        self.type = .None
        super.init(frame: frame)
        setup()
    }
    
    public convenience init() {
        self.init(frame: .zero)
        setup()
    }
    
    public convenience init(keyType: KeyType, keyCap: String, outputString: String) {
        self.init()
        
        self.type = keyType
        self.keyCap = keyCap
        self.outputString = outputString
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setup() {
        self.addTarget(self, action: #selector(pressed), for: .touchDown)
        self.addTarget(self, action: #selector(depressed), for: .touchUpInside)
        self.addTarget(self, action: #selector(cancelled), for: .touchUpOutside)
        self.addTarget(self, action: #selector(cancelled), for: .touchCancel)
        self.addTarget(self, action: #selector(cancelled), for: .touchDragExit)

        self.translatesAutoresizingMaskIntoConstraints = false
        self.textLabel.translatesAutoresizingMaskIntoConstraints = false
        
        setupDefaultLabel()
        redrawText()
    }
    
    /* drawing related method */
    private func redrawText() {
        if let cap = self.keyCap {
            self.textLabel.text = cap
        } else {
            // if key cap is set to nil
            self.textLabel.text = ""
        }
    }
    
    private func setupDefaultLabel() {
        self.textLabel.textAlignment = .center
        self.textLabel.textColor = UIColor.white
        self.textLabel.adjustsFontSizeToFitWidth = true
        self.addSubview(self.textLabel)
    }
    
    /* touch related method*/
    @objc public func pressed() {
        if let selected = self.selectedColor {
            self.backgroundColor = selected
        }
    }
    
    @objc public func depressed() {
        self.backgroundColor = color
    }
    
    @objc public func cancelled() {
        self.backgroundColor = color
    }
    
    /* constraint related */
    public override func updateConstraints() {
        super.updateConstraints()
        
        if !layoutConstrained {
            // Layout label's constraints
            self.addConstraints(self.constraintsForContentView(view: textLabel))
            layoutConstrained = true
        }
    }
    
    private func constraintsForContentView(view: UIView) -> [NSLayoutConstraint] {
        var ret: [NSLayoutConstraint] = []
        view.translatesAutoresizingMaskIntoConstraints = false
        
        var top: CGFloat = 0.0
        var left: CGFloat = 0.0
        var bottom: CGFloat = 0.0
        var right: CGFloat = 0.0
        
        //TODO: function unknown
        if let insets = contentInset {
            top = insets.top
            left = insets.left
            bottom = insets.bottom
            right = insets.right
        }
        
        let leftC = NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.left, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.left, multiplier: 1.0, constant: left)
        let topC = NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1.0, constant: top)
        let rightC = NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.right, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.right, multiplier: 1.0, constant: -bottom)
        let bottomC = NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1.0, constant: -right)
        
        ret += [leftC, topC, rightC, bottomC]
        
        return ret
    }
}

