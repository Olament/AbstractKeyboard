//
//  KeyboardView.swift
//  Keyboard
//
//  Created by Zixuan on 12/29/19.
//  Copyright © 2019 Zixuan. All rights reserved.
//

import Foundation
import UIKit

public protocol KeyboardViewDatasource {
    func numberOfRowsInKeyboardView(keyboardView: KeyboardView) -> Int
    func keyboardView(keyboardView: KeyboardView, numberOfKeysInRow row:Int) -> Int
    func keyboardView(keyboardView: KeyboardView, keyAtIndexPath indexPath: NSIndexPath) -> KeyboardKeyView?
}

@objc public protocol KeyboardViewDelegate {
    @objc optional func keyPressed(key: KeyboardKeyView)
    @objc optional func specialKeyPressed(key: KeyboardKeyView)
    @objc optional func backspaceKeyPressed(key: KeyboardKeyView)
    @objc optional func spaceKeyPressed(key: KeyboardKeyView)
    @objc optional func shiftKeyPressed(key: KeyboardKeyView)
    @objc optional func returnKeyPressed(key: KeyboardKeyView)
    @objc optional func modeChangeKeyPressed(key: KeyboardKeyView)
    @objc optional func switchKeyPressed(key: KeyboardKeyView)
    @objc optional func nextKeyboardKeyPressed(key: KeyboardKeyView)
}

public class KeyboardView: UIView {
    // background images and language
    
    var datasource: KeyboardViewDatasource?
    var delegate: KeyboardViewDelegate?
    
    var keyRows = [[KeyboardKeyView]]()
    private var layoutConstrained: Bool = false
    
    /* init */
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        keyRows = [[KeyboardKeyView]]()
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    public func reloadKeys() {
        // Remove existing keys
        removeKeys()
        keyRows = Array<Array<KeyboardKeyView>>()
        
        if let numRows = datasource?.numberOfRowsInKeyboardView(keyboardView: self) {
            for rowIndex in 0..<numRows {
                if let numKeys = datasource?.keyboardView(keyboardView: self, numberOfKeysInRow: rowIndex) {
                    for keyIndex in 0..<numKeys {
                        if let keyView = datasource?.keyboardView(keyboardView: self, keyAtIndexPath: NSIndexPath(item: keyIndex, section: rowIndex)) {
                            addKey(key: keyView, row: rowIndex)
                        }
                    }
                }
            }
        }
        
        layoutConstrained = false
        self.setNeedsUpdateConstraints()
    }
    
    ///MARK: Layout
    override public func updateConstraints() {
        super.updateConstraints()
        print("updating constraints in keyboardView")
        
        if !layoutConstrained {
            var lastRowView: UIView? = nil
            for (rowIndex, keyRow) in keyRows.enumerated() {
                var lastKeyView: UIView? = nil
                for (keyIndex, key) in keyRow.enumerated() {
                    
                    key.translatesAutoresizingMaskIntoConstraints = false
                    
                    var relativeWidth: CGFloat = 0.0;
                    switch key.type {
                    case .ModeChange:
                        relativeWidth = 2/8
                    case .KeyboardChange:
                        relativeWidth = 1/8
                    case .Space:
                        relativeWidth = 4/8
                    case .Return:
                        relativeWidth = 2/8
                    default:
                        relativeWidth = 0.0
                    }
                    
                    if let lastView = lastKeyView {
                        let left = NSLayoutConstraint(item: key, attribute: NSLayoutConstraint.Attribute.left, relatedBy: NSLayoutConstraint.Relation.equal, toItem: lastView, attribute: NSLayoutConstraint.Attribute.right, multiplier: 1.0, constant: 0.0)
                        let top = NSLayoutConstraint(item: key, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: lastView, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1.0, constant: 0.0)
                        let bottom = NSLayoutConstraint(item: key, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: lastView, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1.0, constant: 0.0)
                        var width: NSLayoutConstraint?
                        if relativeWidth == 0.0 {
                            width = NSLayoutConstraint(item: key, attribute: .width, relatedBy: .equal, toItem: lastView, attribute: .width, multiplier: 1.0, constant: 0.0)
                        } else {
                            width = NSLayoutConstraint(item: key, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: relativeWidth, constant: 0.0)
                        }
                        
                        self.addConstraints([left, top, bottom, width!])
                    } else {
                        let leftEdge = NSLayoutConstraint(item: key, attribute: NSLayoutConstraint.Attribute.left, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.left, multiplier: 1.0, constant: 0.0)
                        self.addConstraint(leftEdge)
                        
                        if let lastRow = lastRowView {
                            let top = NSLayoutConstraint(item: key, attribute: .top, relatedBy:.equal, toItem: lastRow, attribute: .bottom, multiplier: 1.0, constant: 0.0)
                            let height = NSLayoutConstraint(item: key, attribute: .height, relatedBy: .equal, toItem: lastRow, attribute: .height, multiplier: 1.0, constant: 0.0)

                            self.addConstraints([top, height])
                        } else {
                            let topEdge =  NSLayoutConstraint(item: key, attribute: .top, relatedBy:.equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 20.0)
                            self.addConstraint(topEdge)
                        }
                        
                        if rowIndex == keyRows.count - 1 {
                            let bottomEdge = NSLayoutConstraint(item: key, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0)
                            self.addConstraint(bottomEdge)
                        }
                        lastRowView = key
                    }
                    
                    if keyIndex == keyRow.count - 1 {
                        let rightEdge = NSLayoutConstraint(item: key, attribute: NSLayoutConstraint.Attribute.right, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.right, multiplier: 1.0, constant: 0.0)
                        self.addConstraint(rightEdge)
                    }
                    
                    lastKeyView = key
                }
            }
            layoutConstrained = true
        }
    }
    
    public func addKey(key: KeyboardKeyView, row: Int) {
        key.addTarget(self, action: #selector(keyPressed), for: .touchUpInside)
        if row >= keyRows.count {
            for _ in self.keyRows.count...row {
                keyRows.append(Array<KeyboardKeyView>())
            }
        }
                
        self.keyRows[row].append(key)
        self.addSubview(key)
    }
    
    public func removeKeys() {
        _ = [NSLayoutConstraint]()
        for row in keyRows {
            for key in row {
                if key.hasAmbiguousLayout {
                    print(" *** Ambiguous layout: \(key) \n")
                }
                key.removeConstraints(key.constraints)
                key.removeFromSuperview()
            }
        }
    }
    
    ///MARK: Public
    public func setShift(shift: Bool) {
        for row in keyRows {
            for key in row {
                if key.type == KeyboardKeyView.KeyType.Character {
                    key.shifted = shift
                }
            }
        }

    }
    
    public func toggleShift() {
        for row in keyRows {
            for key in row {
                if key.type == KeyboardKeyView.KeyType.Character {
                    key.shifted = !key.shifted
                }
            }
        }
    }
    
    ///MARK: Private Helper Methods
    @objc func keyPressed(sender: AnyObject!) {
        if let key: KeyboardKeyView = sender as? KeyboardKeyView {
            switch key.type {
                case .Character:
                    delegate?.keyPressed!(key: key)
                case .SpecialCharacter:
                    delegate?.specialKeyPressed!(key: key)
                case .Shift:
                    delegate?.shiftKeyPressed!(key: key)
                case .Backspace:
                    delegate?.backspaceKeyPressed!(key: key)
                case .ModeChange:
                    delegate?.modeChangeKeyPressed!(key: key)
                case .KeyboardChange:
                    delegate?.nextKeyboardKeyPressed!(key: key)
                case .Return:
                    delegate?.returnKeyPressed!(key: key)
                case .Space:
                    delegate?.spaceKeyPressed!(key: key)
                case .SwitchKey:
                    delegate?.switchKeyPressed?(key: key)
                default:
                    delegate?.keyPressed!(key: key)
                }
        }
    }
    
    private func constraintsForKey(key: KeyboardKeyView, lastKeyView: KeyboardKeyView, lastRowView: KeyboardKeyView) -> [NSLayoutConstraint] {
        let constraints: [NSLayoutConstraint] = []
        
        return constraints
    }
}
