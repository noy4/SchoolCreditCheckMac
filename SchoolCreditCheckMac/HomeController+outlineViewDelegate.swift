//
//  HomeController+outlineViewDelegate.swift
//  SchoolCreditCheckMac
//
//  Created by 桑村直弥 on 2019/02/28.
//  Copyright © 2019年 noy4. All rights reserved.
//

import Cocoa

extension HomeController: NSOutlineViewDelegate {
    
    func outlineView(_ outlineView: NSOutlineView, shouldExpandItem item: Any) -> Bool {
        return true
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldCollapseItem item: Any) -> Bool {
        return true
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        
        var title = ""
        var credit: Float = 0
        var checkHidden = true
        var done = false
        var needCredit: Float = 0
        var willCredit: Float = 0
        var nowCredit: Float = 0
        var creditStatusHidden = true
        
        if let item = item as? Section {
            
            switch item.title{
            case "理系ディシプリン科目（必修①）":
                title = "必修科目①"
            case "理系ディシプリン科目（選択必修）":
                fallthrough
            case "専攻教育科目（選択必修）":
                title = "選択必修科目"
            case "理系ディシプリン科目（必修②）":
                title = "必修科目②"
            case "総合科目（フロンティア）":
                title = "フロンティア科目"
            case "総合科目（オープン）":
                title = "オープン科目"
            case "専攻教育科目（必修）":
                title = "必修科目"
            case "専攻教育科目（選択）":
                title = "選択科目"
            case "専攻教育科目（学部内自由）":
                title = "学部内自由科目"
            default:
                title = item.title
            }
            
            needCredit = item.needCredit
            if item.subjects.count == 0 {
                willCredit = item.sections.sum(ofProperty: "willCredit")
                nowCredit = item.sections.sum(ofProperty: "nowCredit")
            } else {
                willCredit = item.subjects.sum(ofProperty: "credit")
                nowCredit = item.subjects.filter("done == true").sum(ofProperty: "credit")
            }
            
            do {
                try realm.write {
                    item.willCredit = willCredit
                    item.nowCredit = nowCredit
                }
            } catch {
                print("Error saving credit status")
            }
            
            creditStatusHidden = false
            
            
        } else if let item = item as? Subject {
            title = item.title
            credit = item.credit
            checkHidden = false
            done = item.done
        } else {
            return nil
        }
        
        let cell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("outlineColumnItem"), owner: self) as! CustomTableCellView
        cell.textField!.stringValue = "  \(title)"
        cell.textField?.textColor = done ? .controlBackgroundColor : .controlTextColor
        cell.checkBox.title = String(credit)
        cell.checkBox.isHidden = checkHidden
        cell.checkBox.state = done ? .on : .off
//        cell.checkBox.contentTintColor = done ? .controlBackgroundColor : .controlTextColor
        
        cell.creditStatusLabel.stringValue = "\(nowCredit) / \(willCredit) / \(needCredit)"
        cell.creditStatusLabel.isHidden = creditStatusHidden
        cell.box.fillColor = done ? .systemGray : .controlBackgroundColor
        cell.box.borderColor = done ? .systemRed : .controlBackgroundColor
        
        return cell

    }
    
//    func outlineView(_ outlineView: NSOutlineView, didAdd rowView: NSTableRowView, forRow row: Int) {
//
//        var bgColor = NSColor.controlBackgroundColor
//
//        let item = outlineView.item(atRow: row)
//        if let subject = item as? Subject {
//            if subject.done {
//                bgColor = NSColor.systemOrange
//            }
//        }
//        rowView.backgroundColor = bgColor
//    }
    
//    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
//        return true
//    }
    
}
