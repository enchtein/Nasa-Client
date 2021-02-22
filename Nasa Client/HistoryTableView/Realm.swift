//
//  Realm.swift
//  Nasa Client
//
//  Created by enchtein on 22.02.2021.
//

import Foundation
import RealmSwift

class History: Object {
    @objc dynamic var rover = ""
    @objc dynamic var camera = ""
    @objc dynamic var date = ""
    @objc dynamic var page = 1
//    (rover: String?, camera: String?, date: String?, page: Int?)
}
enum DataError: Error {
    case duplicateFailure
    case nonExistent
    case incomplete
}
