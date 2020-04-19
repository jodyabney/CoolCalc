//
//  CircularButton.swift
//  CoolCalc
//
//  Created by Jody Abney on 4/17/20.
//  Copyright © 2020 AbneyAnalytics. All rights reserved.
//

import UIKit

@IBDesignable // make displayable in Interface Builder
class RoundedButton: UIButton {
    
    override func prepareForInterfaceBuilder() {
        customizeView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        customizeView()
    }
    
    func customizeView() {

        // set 1:1 aspect ratio and size
        layer.frame.size.height = 40.0
        layer.frame.size.width = 40.0
        
        // round the corners and clip
        layer.cornerRadius = frame.size.width / 2.0
        clipsToBounds = true

    }
    
}
