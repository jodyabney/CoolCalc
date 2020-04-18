//
//  CircularButton.swift
//  CoolCalc
//
//  Created by Jody Abney on 4/17/20.
//  Copyright © 2020 AbneyAnalytics. All rights reserved.
//

import UIKit

@IBDesignable
class CircularButton: UIButton {
    
    override func prepareForInterfaceBuilder() {
        customizeView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        customizeView()
    }
    
    func customizeView() {

        layer.frame.size.height = 80.0
        layer.frame.size.width = 80.0
        
        layer.cornerRadius = frame.size.width / 2.0
        clipsToBounds = true
        layer.masksToBounds = true
    }
    
}
