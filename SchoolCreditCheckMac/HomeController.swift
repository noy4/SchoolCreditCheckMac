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
        let config = Realm.Configuration(fileURL: realmPath, schemaVersion: 1)
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
        
        outlineView.beginUpdates()
        if let item = outlineView.item(atRow: outlineView.selectedRow) {
            if let item = item as? Subject {
                
                let parentItem = outlineView.parent(forItem: item)
                let index = outlineView.childIndex(forItem: item)
                outlineView.removeItems(at: IndexSet(integer: index), inParent: parentItem, withAnimation: .slideRight)
                
            }
        }
        outlineView.endUpdates()
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
    
}

