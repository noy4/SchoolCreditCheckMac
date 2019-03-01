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
        
//        guard let item = item as? Section else {
//            return nil
//        }
        var title = ""
        if let item = item as? Section {
            
            switch title{
                //                    case "基幹教育セミナー":
            //                        let i = 0
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
            case "その他":
                let i = 0
            default:
                title = item.title
            }
        } else if let item = item as? Subject {
            title = item.title
        } else {
            return nil
        }
        
        let cell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("outlineColumnItem"), owner: self) as! NSTableCellView
        cell.textField!.stringValue = title
        
        return cell

    }
    
//    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
//        return true
//    }
    
}
