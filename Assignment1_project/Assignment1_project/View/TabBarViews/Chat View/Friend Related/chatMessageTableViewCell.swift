//
//  chatMessageTableViewCell.swift
//  Assignment1_project
//
//  Created by ME on 27/5/19.
//  Copyright © 2019 Monash University. All rights reserved.
//

import UIKit

class chatMessageTableViewCell: UITableViewCell {

    @IBOutlet weak var messageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
