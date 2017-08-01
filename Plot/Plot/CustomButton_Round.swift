//
//  CustomButton_Round.swift
//  Plot
//
//  Created by joe on 2017. 7. 31..
//  Copyright © 2017년 joe. All rights reserved.
//

import UIKit

class CustomButton_Round: UIButton {
    
    
    
    /*******************************************/
    // MARK: -  Life Cycle                     //
    /*******************************************/
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if self.tag == 1 {
            self.layer.cornerRadius = self.frame.size.height / 2
            self.layer.borderColor = UIColor.init(red: 31/255, green: 208/255, blue: 255/255, alpha: 1).cgColor
            self.layer.borderWidth = 1
        }
        
        self.layer.cornerRadius = self.frame.size.height / 2
        
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
