//
//  Activity.swift
//  sharemoney
//
//  Created by oktay on 28.11.2024.
//

import Foundation
import RealmSwift

class Activity : Object {
    @objc dynamic var Name:String = ""
    @objc dynamic var isFinish : Bool = false
    let payments = List<Payment>()
}
