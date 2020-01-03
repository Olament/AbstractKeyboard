//
//  KeyboardSelectionViewCell.swift
//  Keyboard
//
//  Created by Zixuan on 1/2/20.
//  Copyright © 2020 Zixuan. All rights reserved.
//

import Foundation
import UIKit

public class KeyboardSelectionViewCell: UICollectionViewCell {
    public var label = UILabel()
    
    private var isWidthCalculated: Bool = false
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        //contentView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        
        label.font = .systemFont(ofSize: 20.0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
