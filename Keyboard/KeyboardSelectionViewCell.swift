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
    public var label: UILabel = {
        let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        
        return lb
    }()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(label)
        label.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
