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
    var fireItems: [Subject]?
    let creditArray = ["1.0", "1.5", "2.0", "2.5", "3.0", "3.5", "4.0"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let realmPath = Bundle.main.url(forResource: "seed", withExtension: "realm")?.deletingLastPathComponent().appendingPathComponent("1.realm")
        let config = Realm.Configuration(fileURL: realmPath, schemaVersion: 1)
        realm = try! Realm(configuration: config)
        
        realmItems = realm.objects(Section.self).sorted(byKeyPath: "date")
        tableView.reloadData()
        
        parentPopUp.removeAllItems()
        parentPopUp.addItems(withTitles: parentTitles())
        creditConboBox.removeAllItems()
        creditConboBox.addItems(withObjectValues: creditArray)
    }

    @IBAction func buttonPressed(_ sender: NSButton) {
    }
    
    func parentTitles() -> [String] {
        var titles = [String]()
        if let realmItems = realmItems {
            for r in realmItems {
                if r.sections.count == 0 {
                    switch r.title {
//                    case "基幹教育セミナー":
//                        let i = 0
                    case "必修科目①":
                        titles.append("理系ディシプリン科目（必修①）")
                    case "選択必修科目":
                        if r.needCredit == 4.5 {
                            titles.append("理系ディシプリン科目（選択）")
                        } else {
                            titles.append("専攻教育科目（選択必修）")
                        }
                    case "必修科目②":
                        titles.append("理系ディシプリン科目（必修②）")
                    case "フロンティア科目":
                        titles.append("総合科目（フロンティア）")
                    case "オープン科目":
                        titles.append("総合科目（オープン）")
                    case "必修科目":
                        titles.append("専攻教育科目（必修）")
                    case "選択科目":
                        titles.append("専攻教育科目（選択）")
                    case "その他":
                        let i = 0
                    default:
                        titles.append(r.title)
                    }
                }
            }
        }
        return titles
    }
    
}

extension ListController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return realmItems?.count ?? 0
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
        guard let item = realmItems?[row] else {
            return nil
        }
        
        // 2
        if tableColumn == tableView.tableColumns[0] {
            text = item.title
            cellIdentifier = CellIdentifiers.TitleCell
        } else if tableColumn == tableView.tableColumns[1] {
            text = String(item.needCredit)
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
