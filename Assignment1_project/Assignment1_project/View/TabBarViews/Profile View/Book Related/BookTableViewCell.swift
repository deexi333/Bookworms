//
//  BookTableViewCell.swift
//  Assignment1_project
//
//  Created by ME on 16/5/19.
//  Copyright © 2019 Monash University. All rights reserved.
//

import UIKit

class BookTableViewCell: UITableViewCell {
    
    // MARK: - Variables
    @IBOutlet weak var bookNameLabel: UILabel!
    
    
    // MARK: - Functions
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
