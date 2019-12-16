//
//  UserWebService.swift
//  SimpleNotes
//
//  Created by João Palma on 16/12/2019.
//  Copyright © 2019 João Palma. All rights reserved.
//

import Foundation

protocol UserWebService {
    func getUser(userId: Int16, completion: @escaping (_ user: UserObject?) -> Void) -> String
}