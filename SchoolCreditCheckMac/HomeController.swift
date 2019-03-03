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
        let config = Realm.Configuration(fileURL: realmPath, schemaVersion: 2)
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
        for selectedRow in selectedRows {
            
            outlineView.beginUpdates()
            if let item = outlineView.item(atRow: selectedRow) {
                if let item = item as? Subject {
                    do {
                        try realm.write {
                            realm.delete(item)
                        }
                    } catch {
                        print("Error deleting")
                    }
                    
                    let parentItem = outlineView.parent(forItem: item)
                    let index = outlineView.childIndex(forItem: item)
                    outlineView.removeItems(at: IndexSet(integer: index), inParent: parentItem, withAnimation: .slideRight)
                    
                }
            }
            outlineView.endUpdates()
        }
        
    }
    
    @IBAction func outlineViewClicked(_ sender: NSOutlineView) {
//        let item = outlineView.item(atRow: sender.clickedRow)
//        let parentItem = sender.parent(forItem: item)
//        if let subject = item as? Subject {
//            do {
//                try realm.write {
//                    subject.done = !subject.done
//                }
//            } catch {
//                print("Error change done status")
//            }
//        }
////        outlineView.reloadData(forRowIndexes: IndexSet(integer: sender.clickedRow), columnIndexes: IndexSet(integer: 0))
//        sender.reloadItem(parentItem, reloadChildren: true)
    }
    
    @IBAction func checkBoxClicked(_ sender: NSButton) {
        let row = outlineView.row(for: sender.superview!)
        let item = outlineView.item(atRow: row)
        let parentItem = outlineView.parent(forItem: item)
        if let subject = item as? Subject {
            do {
                try realm.write {
                    subject.done = !subject.done
                }
            } catch {
                print("Error change done status")
            }
            
            
            
        }
        
        let childIndex = IndexSet(integer: outlineView.childIndex(forItem: item))
        let parentIndex = IndexSet(integer: outlineView.childIndex(forItem: parentItem))
        let parent2Item = outlineView.parent(forItem: parentItem)
//        outlineView.removeItems(at: childIndex, inParent: parentItem, withAnimation: .effectFade)
//        outlineView.insertItems(at: childIndex, inParent: parentItem, withAnimation: .effectFade)
//        outlineView.expandItem(parent2Item, expandChildren: true)
        
//        outlineView.reloadItem(parent2Item, reloadChildren: true)
//        for i in 0...5 {
//            outlineView.reloadData()
//        }
//        outlineView.expandItem(parent2Item, expandChildren: true)
//        outlineView.reloadData()
//        outlineView.expandItem(nil, expandChildren: true)
        
        for i in (0...row).reversed() {
            outlineView.reloadData(forRowIndexes: IndexSet(integer: i), columnIndexes: IndexSet(integer: 0))
        }
        
    }
    
    
    
}

