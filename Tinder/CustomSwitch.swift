//
//  CustomSwitch.swift
//  Tinder
//
//  Created by Matthias Hofmann on 06.10.16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

class CustomSwitch: UISwitch {

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
    

    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = 16.0
        clipsToBounds = true
    }

}
