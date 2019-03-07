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
    var subjectItems: Results<Subject>?
    var fireItems: [Subject] = []
    let creditArray = ["1.0", "1.5", "2.0", "2.5", "3.0", "3.5", "4.0"]
    
    var outlineView: NSOutlineView?
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        loadSubjectItems()
        loadSubjects()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let realmPath = Bundle.main.url(forResource: "seed", withExtension: "realm")?.deletingLastPathComponent().appendingPathComponent("1.realm")
        let config = Realm.Configuration(fileURL: realmPath, schemaVersion: 4)
        realm = try! Realm(configuration: config)
        
        realmItems = realm.objects(Section.self).sorted(byKeyPath: "date")
        
        parentPopUp.removeAllItems()
        parentPopUp.addItems(withTitles: parentTitles())
        creditConboBox.removeAllItems()
        creditConboBox.addItems(withObjectValues: creditArray)
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        
        outlineView?.reloadData()
        outlineView?.expandItem(nil, expandChildren: true)
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
        
//        tableView.beginUpdates()
//        tableView.reloadData(forRowIndexes: tableView.selectedRowIndexes, columnIndexes: tableView.selectedColumnIndexes)
////        tableView.deselectAll(<#T##sender: Any?##Any?#>)
//        tableView.endUpdates()
        
    }
    
    func parentTitles() -> [String] {
        var titles = [String]()
        if let realmItems = realmItems {
            for r in realmItems {
                if r.sections.count == 0 {
                    switch r.title {
                    case "基幹教育セミナー":
                        print()
                    case "課題協学科目":
                        print()
                    case "その他":
                        print()
                    default:
                        titles.append(r.title)
                    }
                    
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
    
    func loadSubjectItems(){
        subjectItems = realm.objects(Subject.self).sorted(byKeyPath: "date")
    }
    
    @IBAction func tableViewClicked(_ sender: NSTableView) {
        if sender.clickedRow == -1 {
            return
        }
        let subject = fireItems[sender.clickedRow]
        if var section = realmItems?.filter("title == %@", subject.section)[0] {
            if section.subjects.filter("title == %@", subject.title).count == 0 {
                do {
                    try realm.write {
                        section.subjects.append(subject)
                        sender.reloadData(forRowIndexes: IndexSet(integer: sender.clickedRow), columnIndexes: IndexSet(integersIn: 0...1))
                        while true {
                            section.reloadCreditStatus(realm: realm)
                            if section.parentSection.count == 0 {
                                break
                            }
                            section = section.parentSection[0]
                        }
                    }
                } catch {
                    print("ERROR fire to realm")
                }
                
            }
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
        let bgColor1 = NSColor.systemBlue
        let bgColor2 = NSColor.controlBackgroundColor
        let textColor1 = NSColor.alternateSelectedControlTextColor
        let textColor2 = NSColor.controlTextColor
        
        let item = fireItems[row]
        let rowView = tableView.rowView(atRow: row, makeIfNecessary: false)
        
        if tableColumn == tableView.tableColumns[0] {
            text = item.title
            cellIdentifier = CellIdentifiers.TitleCell
        } else if tableColumn == tableView.tableColumns[1] {
            text = String(item.credit)
            cellIdentifier = CellIdentifiers.CreditCell
        }
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            if subjectItems?.filter("title == %@", item.title).count != 0 {
                rowView?.backgroundColor = bgColor1
                cell.textField?.textColor = textColor1
            } else {
                rowView?.backgroundColor = bgColor2
                cell.textField?.textColor = textColor2
            }
            return cell
        }
        return nil
    }
    
//    func tableViewSelectionDidChange(_ notification: Notification) {
//        let subject = fireItems[tableView.selectedRow]
//        if let section = realmItems?.filter("title == %@", subject.section)[0] {
//            if section.subjects.filter("title == %@", subject.title).count == 0 {
//                do {
//                    try realm.write {
//                        section.subjects.append(subject)
//                    }
//                } catch {
//                    print("ERROR fire to realm")
//                }
//            }
//        }
//
//        loadSubjectItems()
//        tableView.reloadData()
//    }
    
    
    
}
