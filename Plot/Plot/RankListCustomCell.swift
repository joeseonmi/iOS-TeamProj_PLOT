//
//  RankListCustomCell.swift
//  Plot
//
//  Created by joe on 2017. 8. 1..
//  Copyright © 2017년 joe. All rights reserved.
//

import UIKit
import Firebase

class RankListCustomCell: UITableViewCell {

    
    /*******************************************/
    // MARK: -  Outlet                         //
    /*******************************************/
    
    @IBOutlet weak var cellBgImageView: UIImageView!
    @IBOutlet weak var rankingTitleTextLabel: UILabel!
    
    
    
    /*******************************************/
    // MARK: -  LifeCycle                      //
    /*******************************************/
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
   

    
}
