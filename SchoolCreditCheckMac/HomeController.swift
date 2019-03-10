//
//  ViewController.swift
//  SchoolCreditCheckMac
//
//  Created by 桑村直弥 on 2019/01/11.
//  Copyright © 2019年 noy4. All rights reserved.
//

import Cocoa
import RealmSwift

class HomeController: NSViewController {
    
    @IBOutlet weak var creditComboBox: NSComboBox!
    @IBOutlet weak var parentPopUp: NSPopUpButton!
    @IBOutlet weak var textField: NSTextField!
    @IBOutlet weak var outlineView: NSOutlineView!
    
    var data: Results<Section>?
    
    var realm: Realm!
    let creditArray = ["1.0", "1.5", "2.0", "2.5", "3.0", "3.5", "4.0"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let realmPath = Bundle.main.url(forResource: "seed", withExtension: "realm")?.deletingLastPathComponent().appendingPathComponent("1.realm")
        let config = Realm.Configuration(fileURL: realmPath, schemaVersion: 4)
        realm = try! Realm(configuration: config)
        
        data = realm.objects(Section.self).sorted(byKeyPath: "date")
        outlineView.reloadData()
        outlineView.expandItem(nil, expandChildren: true)
        
        creditComboBox.removeAllItems()
        creditComboBox.addItems(withObjectValues: creditArray)
        parentPopUp.removeAllItems()
        parentPopUp.addItems(withTitles: parentTitles())
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func buttonPressed(_ sender: NSButton) {
//        let newSection = Section()
//        newSection.title = textField.stringValue
//        newSection.needCredit = creditComboBox.floatValue
//
//        do {
//            try realm.write {
//                if let data = data {
//                    data[parentPopUp.indexOfSelectedItem].sections.append(newSection)
//                }
//            }
//        } catch {
//            print("ERROR 1")
//        }
//
//        parentPopUp.removeAllItems()
//        parentPopUp.addItems(withTitles: parentTitles())
        
        outlineView.reloadData()
        outlineView.expandItem(nil, expandChildren: true)
        for i in (0...outlineView.numberOfRows - 1).reversed() {
            outlineView.reloadData(forRowIndexes: IndexSet(integer: i), columnIndexes: IndexSet(integer: 0))
        }
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        let listVC = segue.destinationController as! ListController
        listVC.outlineView = outlineView
    }
    
    func parentTitles() -> [String] {
        var titles = [String]()
        if let data = data {
            for d in data {
                titles.append(d.title)
            }
        }
        return titles
    }
    
    override func keyDown(with event: NSEvent) {
        interpretKeyEvents([event])
    }
    
    override func deleteBackward(_ sender: Any?) {
        
        let selectedRows = outlineView.selectedRowIndexes.sorted(by: >)
        var sectionRows: [Int] = []
        var subjectRows: [Int] = []
        for j in 0..<selectedRows.count {
            let selectedRow = selectedRows[j]
            var item = outlineView.item(atRow: selectedRow)
            if let subject = item as? Subject {
                if subject.parentSection[0].title != "その他" && subject.title != "専攻教育科目（選択必修）" {
                    print(subject.section)
                    subjectRows.append(selectedRow)
                    do {
                        try realm.write {
                            realm.delete(subject)
                        }
                    } catch {
                        print("Error deleting")
                    }
                    
                    var i = 0
                    while true {
                        item = outlineView.parent(forItem: item)
                        if item == nil {
                            break
                        }
                        i = outlineView.row(forItem: item)
                        sectionRows.append(i)
                    }
                    
                    if j == selectedRows.count - 1 {
                        var flag1 = false
                        var flag2 = false
                        let orderedI = NSOrderedSet(array: sectionRows)
                        let orderedIArray = (orderedI.array as! [Int]).sorted(by: >)
                        for k in orderedIArray {
                            if let section = outlineView.item(atRow: k) as? Section {
                                do {
                                    try realm.write {
                                        let flag = section.reloadCreditStatus(realm: realm)
                                        print(flag)
                                        switch flag {
                                        case 1:
                                            flag1 = true
                                        case 2:
                                            flag2 = true
                                        default:
                                            break
                                        }
                                    }
                                } catch {
                                    print("Error reload credit in delete")
                                }
                                outlineView.reloadData(forRowIndexes: IndexSet(integer: k), columnIndexes: IndexSet(integer: 0))
                                
                            }
                        }
                        subjectRows.sort(by: >)
                        for l in subjectRows {
                            item = outlineView.item(atRow: l)
                            let parentItem = outlineView.parent(forItem: item)
                            let index = outlineView.childIndex(forItem: item)
                            outlineView.removeItems(at: IndexSet(integer: index), inParent: parentItem, withAnimation: .slideRight)
                            
                        }
                        
                        if flag1 {
                            reloadOther()
                        }
                        if flag2 {
                            reloadSub()
                        }
                        
                        
                    }
                }
            }
            
        }
        
    }
    
    @IBAction func checkBoxClicked(_ sender: NSButton) {
        let row = outlineView.row(for: sender.superview!)
        var item = outlineView.item(atRow: row)
        guard let subject = item as? Subject else {fatalError()}
        do {
            try realm.write {
                subject.done = !subject.done
            }
        } catch {
            print("Error change done status")
        }
        
        var i = row
        outlineView.reloadData(forRowIndexes: IndexSet(integer: i), columnIndexes: IndexSet(integer: 0))
        item = outlineView.parent(forItem: item)
        i = outlineView.row(forItem: item)
        
        var section = subject.parentSection[0]
        var flag1 = false
        var flag2 = false
        while true {
            do {
                try realm.write {
                    let flag = section.reloadCreditStatus(realm: realm)
                    switch flag {
                    case 1:
                        flag1 = true
                    case 2:
                        flag2 = true
                    default:
                        break
                    }
                }
            } catch {
                print("Error reload credit in checkbox")
            }
            outlineView.reloadData(forRowIndexes: IndexSet(integer: i), columnIndexes: IndexSet(integer: 0))
            if section.parentSection.count == 0 {
                break
            }
            section = section.parentSection[0]
            item = outlineView.parent(forItem: item)
            i = outlineView.row(forItem: item)
        }
        section = subject.parentSection[0]
        
        if flag1 {
            reloadOther()
        }
        if flag2 {
            reloadSub()
        }
        
    }
    
    func reloadOther() {
        for j in 0..<outlineView.numberOfRows {
            let item = outlineView.item(atRow: j)
            if let anItem = item as? Section {
                if anItem.title == "その他" {
                    outlineView.reloadItem(item, reloadChildren: true)
                    outlineView.reloadData(forRowIndexes: IndexSet(integer: j), columnIndexes: IndexSet(integer: 0))
                }
            }
        }
    }
    
    func reloadSub() {
        for j in 0..<outlineView.numberOfRows {
            let item = outlineView.item(atRow: j)
            if let anItem = item as? Section {
                if anItem.title == "専攻教育科目（選択）" {
                    outlineView.reloadItem(item, reloadChildren: true)
                    outlineView.reloadData(forRowIndexes: IndexSet(integer: j), columnIndexes: IndexSet(integer: 0))
                }
            }
        }
    }
    
    
}

