//
//  Payment.swift
//  sharemoney
//
//  Created by oktay on 2.12.2024.
//

import Foundation
import RealmSwift

class Payment : Object {
    @objc dynamic var userPayment:String = ""
    @objc dynamic var desc: String = ""
    @objc dynamic var quantitiy: Int = -1
    var activities = LinkingObjects(fromType: Activity.self, property: "payments")
}
