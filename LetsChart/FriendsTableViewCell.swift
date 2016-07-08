//
//  FriendsTableViewCell.swift
//  LetsChart
//
//  Created by JiangYe on 7/8/16.
//  Copyright © 2016 JiangYe. All rights reserved.
//

import UIKit

class FriendsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var nameLable: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    func bindData(user: BackendlessUser)
    {
        
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width/2
        avatarImageView.layer.masksToBounds = true
        
        self.avatarImageView.image = UIImage(named: "avatarPlaceholder")
        
        if let avatarUrl = user.getProperty("Avatar") {
            
            getImageFromURL(avatarUrl as! String, result: { (image) in
                
                self.avatarImageView.image = image
            })
        }
        
        nameLable.text = user.getProperty("name") as? String
    }
}
