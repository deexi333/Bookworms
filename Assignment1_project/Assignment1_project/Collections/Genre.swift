//
//  Genre.swift
//  Assignment1_project
//
//  Created by ME on 6/5/19.
//  Copyright © 2019 Monash University. All rights reserved.
//

import UIKit
import Firebase

class Genre: NSObject {
    var genreID: String?
    var genreType: String?
    
    init(genreID: String, genreType: String) {
        self.genreType = genreType
        self.genreID = genreID
    }
}
