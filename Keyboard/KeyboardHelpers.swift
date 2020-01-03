//
//  utils.swift
//  Keyboard
//
//  Created by Zixuan on 1/3/20.
//  Copyright © 2020 Zixuan. All rights reserved.
//

import Foundation
import UIKit

public extension CGFloat {
    func adjusted() -> CGFloat {
        return self * (UIScreen.main.bounds.height / CGFloat(667.0))
    }
}
