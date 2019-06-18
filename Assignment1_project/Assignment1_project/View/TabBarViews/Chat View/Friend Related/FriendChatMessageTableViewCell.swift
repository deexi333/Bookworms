//
//  FriendChatMessageTableViewCell.swift
//  Assignment1_project

//  Created by ME on 27/5/19.
//  Copyright © 2019 Monash University. All rights reserved.
//

import UIKit

class FriendChatMessageTableViewCell: UITableViewCell {

    // MARK: - Variables
    // Element from the storyboard
    @IBOutlet weak var friendNameLabel: UILabel!
    @IBOutlet weak var friendMessageLabel: UILabel!
    
    
    // MARK: - Functions
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
