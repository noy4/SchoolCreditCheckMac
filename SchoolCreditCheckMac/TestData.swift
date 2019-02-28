//
//  TestData.swift
//  SchoolCreditCheckMac
//
//  Created by 桑村直弥 on 2019/02/28.
//  Copyright © 2019年 noy4. All rights reserved.
//

import Foundation

struct TestData {
    
    var items: [Item]
    
    init() {
        
        items = []
        for g in 1...3 {
            let group = Item("Group \(g)", .Group)
            for f in 1...3 {
                let item = Item("Folder \(g).\(f)", .Container)
                for n in 1...4 {
                    let node = Item("Node \(g).\(f).\(n)", .Container)
                    item.children.append(node)
                }
                group.children.append(item)
            }
            items.append(group)
        }
    }
}
