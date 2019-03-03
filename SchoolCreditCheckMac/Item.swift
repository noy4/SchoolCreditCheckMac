//
//  Item.swift
//  SchoolCreditCheckMac
//
//  Created by 桑村直弥 on 2019/02/28.
//  Copyright © 2019年 noy4. All rights reserved.
//

import Foundation
import RealmSwift

class Section: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var needCredit: Float = 0
    @objc dynamic var willCredit: Float = 0
    @objc dynamic var nowCredit: Float = 0
    @objc dynamic var date = Date()
    
    let sections = List<Section>()
    let subjects = List<Subject>()
    var parentSection = LinkingObjects(fromType: Section.self, property: "sections")
}

class Subject: Object {
    @objc dynamic var title: String = ""
    var section: String = ""
    @objc dynamic var credit: Float = 0
    @objc dynamic var done: Bool = false 
    @objc dynamic var date = Date()

    var parentSection = LinkingObjects(fromType: Section.self, property: "subjects")
}
