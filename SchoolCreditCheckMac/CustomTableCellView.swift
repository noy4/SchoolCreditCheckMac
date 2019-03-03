//
//  CustomTableCellView.swift
//  SchoolCreditCheckMac
//
//  Created by 桑村直弥 on 2019/03/03.
//  Copyright © 2019年 noy4. All rights reserved.
//

import Cocoa

class CustomTableCellView: NSTableCellView {

    @IBOutlet weak var box: NSBox!
    @IBOutlet weak var creditStatusLabel: NSTextField!
    @IBOutlet weak var checkBox: NSButton!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
