//
//  AddUserDelegate.swift
//  Assignment1_project
//
//  Created by Deexita Sai Koti Goli on 13/5/19.
//  Copyright © 2019 Monash University. All rights reserved.
//

import Foundation

protocol AddUserDelegate: AnyObject {
    func addUser(newUser: User) -> Bool
}
