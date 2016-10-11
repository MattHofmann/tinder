//
//  BorderTextField.swift
//  Tinder
//
//  Created by Matthias Hofmann on 07.10.16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class BorderTextField: UITextField {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    
    // round textfield
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.borderColor = UIColor(red: SHADOW_GRAY, green: SHADOW_GRAY, blue: SHADOW_GRAY, alpha: 0.2).cgColor
        layer.borderWidth = 1.0
        // rounded edges
        layer.cornerRadius = self.frame.height / 2
        
    }

}
