//
//  FriendTableViewCell.swift
//  Assignment1_project
//
//  Created by ME on 27/5/19.
//  Copyright © 2019 Monash University. All rights reserved.
//

import UIKit

class FriendTableViewCell: UITableViewCell {
    
    // MARK: - Variables
    // Elements from the storyboard
    @IBOutlet weak var friendUserName: UILabel!
    @IBOutlet weak var friendProfileImage: UIImageView!
    
    
    // MARK: - Functions
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
