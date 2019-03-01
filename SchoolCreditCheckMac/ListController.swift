//
//  ListController.swift
//  SchoolCreditCheckMac
//
//  Created by 桑村直弥 on 2019/02/27.
//  Copyright © 2019年 noy4. All rights reserved.
//

import Cocoa
import RealmSwift
import FirebaseDatabase

class ListController: NSViewController {
    
    @IBOutlet weak var creditConboBox: NSComboBox!
    @IBOutlet weak var parentPopUp: NSPopUpButton!
    @IBOutlet weak var textField: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    
    var realm: Realm!
    var realmItems: Results<Section>?
    var sectionItems: Results<Section>?
    var fireItems: [Subject] = []
    let creditArray = ["1.0", "1.5", "2.0", "2.5", "3.0", "3.5", "4.0"]
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        loadSubjects()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let realmPath = Bundle.main.url(forResource: "seed", withExtension: "realm")?.deletingLastPathComponent().appendingPathComponent("1.realm")
        let config = Realm.Configuration(fileURL: realmPath, schemaVersion: 1)
        realm = try! Realm(configuration: config)
        
        realmItems = realm.objects(Section.self).sorted(byKeyPath: "date")
        
        parentPopUp.removeAllItems()
        parentPopUp.addItems(withTitles: parentTitles())
        creditConboBox.removeAllItems()
        creditConboBox.addItems(withObjectValues: creditArray)
    }

    @IBAction func buttonPressed(_ sender: NSButton) {
//        let newSubject = Database.database().reference().child("subjects").childByAutoId()
//        let subjectDic = ["title": textField.stringValue, "credit": creditConboBox.floatValue, "section": parentPopUp.titleOfSelectedItem] as [String : Any]
//
//        newSubject.setValue(subjectDic){
//            (error, reference) in
//
//            if error != nil {
//                print(error!)
//            } else {
//                print("Subject saved")
//            }
//        }
        tableView.reloadData()
        
    }
    
    func parentTitles() -> [String] {
        var titles = [String]()
        if let realmItems = realmItems {
            for r in realmItems {
                if r.sections.count == 0 {
                    titles.append(r.title)
                }
            }
        }
        return titles
    }
    
    func loadSubjects(){
        
        let subjectDB = Database.database().reference().child("subjects")
        
        subjectDB.observe(.childAdded) { (snapshot) in
            
            let snapshotValue = snapshot.value as! Dictionary<String, Any>
            
            let title = snapshotValue["title"]!
            let section = snapshotValue["section"]!
            let credit = snapshotValue["credit"]!
            
            let subject = Subject()
            
            subject.title = title as! String
            subject.section = section as! String
            subject.credit = credit as! Float
            
            self.fireItems.append(subject)
            
            self.tableView.reloadData()
        }
        
    }
    
    
}

extension ListController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return fireItems.count 
    }
}

extension ListController: NSTableViewDelegate {
    
    fileprivate enum CellIdentifiers {
        static let TitleCell = "TitleCellID"
        static let CreditCell = "CreditCellID"
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var text: String = ""
        var cellIdentifier: String = ""
        
        // 1
//        guard let item = fireItems?[row] else {
//            return nil
//        }
        let item = fireItems[row]
        
        // 2
        if tableColumn == tableView.tableColumns[0] {
            text = item.title
            cellIdentifier = CellIdentifiers.TitleCell
        } else if tableColumn == tableView.tableColumns[1] {
            text = String(item.credit)
            cellIdentifier = CellIdentifiers.CreditCell
        }
        
        // 3
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
    
}
