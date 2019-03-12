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
    
    func reloadCreditStatus(realm: Realm) -> Int {
        if sections.count == 0 {
            willCredit = subjects.sum(ofProperty: "credit")
            nowCredit = subjects.filter("done == true").sum(ofProperty: "credit")
            
            if willCredit > needCredit {
                if title == "専攻教育科目（選択必修）" {
                    let over = willCredit - needCredit
                    let sub = realm.objects(Section.self).filter("title == '専攻教育科目（選択）'")[0]
                    let subSubjects = sub.subjects.filter("title == %@", title)
                    if subSubjects.count != 0 {
                        subSubjects[0].credit = over
                        subSubjects[0].done = (nowCredit == willCredit)
                        sub.reloadCreditStatus(realm: realm)
                    }
                    else {
                        let subSubject = Subject()
                        subSubject.title = title
                        subSubject.credit = over
                        subSubject.done = (nowCredit == willCredit)
                        sub.subjects.append(subSubject)
                        sub.reloadCreditStatus(realm: realm)
                    }
                    return 2
                    
                } else if title == "専攻教育科目（選択）" {
                    let over = willCredit - needCredit
                    let sub = realm.objects(Section.self).filter("title == '専攻教育科目（学部内自由）'")[0]
                    let subSubjects = sub.subjects.filter("title == %@", title)
                    if subSubjects.count != 0 {
                        subSubjects[0].credit = over
                        subSubjects[0].done = (nowCredit == willCredit)
                        sub.reloadCreditStatus(realm: realm)
                    }
                    else {
                        let subSubject = Subject()
                        subSubject.title = title
                        subSubject.credit = over
                        subSubject.done = (nowCredit == willCredit)
                        sub.subjects.append(subSubject)
                        sub.reloadCreditStatus(realm: realm)
                    }
                    return 3
                    
                }
                else if title != "その他" {
                    let over = willCredit - needCredit
                    let other = realm.objects(Section.self).filter("title == 'その他'")[0]
                    let otherSubjects = other.subjects.filter("title == %@", title)
                    if otherSubjects.count != 0 {
                        otherSubjects[0].credit = over
                        otherSubjects[0].done = (nowCredit == willCredit)
                        other.reloadCreditStatus(realm: realm)
                    }
                    else {
                        let otherSubject = Subject()
                        otherSubject.title = title
                        otherSubject.section = "その他"
                        otherSubject.credit = over
                        otherSubject.done = (nowCredit == willCredit)
                        other.subjects.append(otherSubject)
                        other.reloadCreditStatus(realm: realm)
                    }
                    return 1
                }
                
            }
            else {
                if title == "専攻教育科目（選択必修）" {
                    let sub = realm.objects(Section.self).filter("title == '専攻教育科目（選択）'")[0]
                    let subSubjects = sub.subjects.filter("title == %@", title)
                    if subSubjects.count != 0 {
                        realm.delete(subSubjects[0])
                        sub.reloadCreditStatus(realm: realm)
                    }
                    return 2
                    
                } else if title == "専攻教育科目（選択）" {
                    let sub = realm.objects(Section.self).filter("title == '専攻教育科目（学部内自由）'")[0]
                    let subSubjects = sub.subjects.filter("title == %@", title)
                    if subSubjects.count != 0 {
                        realm.delete(subSubjects[0])
                        sub.reloadCreditStatus(realm: realm)
                    }
                    return 3
                    
                }
                else if title != "その他" {
                    let other = realm.objects(Section.self).filter("title == 'その他'")[0]
                    let otherSubjects = other.subjects.filter("title == %@", title)
                    if otherSubjects.count != 0 {
                        realm.delete(otherSubjects[0])
                        other.reloadCreditStatus(realm: realm)
                        return 1
                    }
                }
            }
        } else {
            var overWill: Float = 0
            var overNow: Float = 0
            if sections.filter("title == '専攻教育科目（選択）'").count != 0 {
                let overSection = sections.filter("title == '専攻教育科目（選択）'")[0]
                if overSection.subjects.filter("title == '専攻教育科目（選択必修）'").count != 0 {
                    let overSubject = overSection.subjects.filter("title == '専攻教育科目（選択必修）'")[0]
                    overWill = -overSubject.credit
                    overNow = overSubject.done ? overWill : 0
                }
            } else if title == "基幹教育科目" {
                let others = sections.filter("title == 'その他'")[0].subjects.filter("title == '専攻教育科目（学部内自由）'")
                if others.count != 0 {
                    overWill = others[0].credit
                    overNow = others[0].done ? overWill : 0
                }
            } else if title == "卒業要件" {
                let others = sections.filter("title == '基幹教育科目'")[0].sections.filter("title == 'その他'")[0].subjects.filter("title == '専攻教育科目（学部内自由）'")
                if others.count != 0 {
                    overWill = -others[0].credit
                    overNow = others[0].done ? overWill : 0
                }
            }
            willCredit = sections.filter("title != 'その他'").sum(ofProperty: "willCredit") + overWill
            nowCredit = sections.filter("title != 'その他'").sum(ofProperty: "nowCredit") + overNow
        }
        
        return 0
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
