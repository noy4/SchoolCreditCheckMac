//
//  HomeController+outlineViewDataSource.swift
//  SchoolCreditCheckMac
//
//  Created by 桑村直弥 on 2019/02/28.
//  Copyright © 2019年 noy4. All rights reserved.
//

import Cocoa

extension HomeController: NSOutlineViewDataSource {
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        
        if item == nil { // root
            return 1
        }
        
        if let item = item as? Section {
            return item.sections.count
        }
        
        return 0 // anything else
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil { // root
            if let data = data {
                return data[index]
            }
        }
        
        if let item = item as? Section {
            return item.sections[index]
        }
        
        return "UNKNOWN" // if this returns, check your code!
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
//        let item = item as! Item
//        return item.isExpandable
        
        return true
    }
    
    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        if let column = tableColumn, column.identifier.rawValue == "outlineColumn", let item = item as? Section {
            return item.title
        }
        return nil
    }
}
