//
//  FriendTableViewCell.swift
//  Assignment1_project
//
//  Created by ME on 27/5/19.
//  Copyright © 2019 Monash University. All rights reserved.
//

import UIKit

class FriendTableViewCell: UITableViewCell {
    
    @IBOutlet weak var friendUserName: UILabel!
    @IBOutlet weak var friendProfileImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
