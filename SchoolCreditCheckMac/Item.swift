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
    
    func reloadCreditStatus(realm: Realm){
        do {
            try realm.write {
                if sections.count == 0 {
                    willCredit = subjects.sum(ofProperty: "credit")
                    nowCredit = subjects.filter("done == true").sum(ofProperty: "credit")
                    
                    if willCredit > needCredit {
                        let over = willCredit - needCredit
                        let other = realm.objects(Section.self).filter("title == 'その他'")[0]
                        let otherSubjects = other.subjects.filter("title == %@", title)
                        if otherSubjects.count != 0 {
                        otherSubjects[0].credit = over
                        otherSubjects[0].done = (nowCredit == willCredit)
                        }
                        else if title != "その他" {
                            let otherSubject = Subject()
                            otherSubject.title = title
                            otherSubject.section = "その他"
                            otherSubject.credit = over
                            otherSubject.done = (nowCredit == willCredit)
                            other.subjects.append(otherSubject)
                        }
                        
                    }
                    else {
                        let otherSubjects = realm.objects(Section.self).filter("title == 'その他'")[0].subjects.filter("title == %@", title)
                        if otherSubjects.count != 0 {
                            realm.delete(otherSubjects[0])
                        }
                    }
                } else {
                    willCredit = sections.filter("title != 'その他'").sum(ofProperty: "willCredit")
                    nowCredit = sections.filter("title != 'その他'").sum(ofProperty: "nowCredit")
                }

                

            }
        } catch {
            print("Error reloading all credit status")
        }
    }
}

class Subject: Object {
    @objc dynamic var title: String = ""
    var section: String = ""
    @objc dynamic var credit: Float = 0
    @objc dynamic var done: Bool = false 
    @objc dynamic var date = Date()

    var parentSection = LinkingObjects(fromType: Section.self, property: "subjects")
}
