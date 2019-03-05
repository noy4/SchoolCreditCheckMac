//
//  AppDelegate.swift
//  SchoolCreditCheckMac
//
//  Created by 桑村直弥 on 2019/01/11.
//  Copyright © 2019年 noy4. All rights reserved.
//

import Cocoa
import RealmSwift
import FirebaseCore

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {


    override init() {
        super.init()
        FirebaseApp.configure()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSApp.keyWindow?.contentMinSize = NSSize(width: 600, height: 300)
        
        let seedFilePath = Bundle.main.url(forResource: "seed", withExtension: "realm")
        let realmPath = seedFilePath?.deletingLastPathComponent().appendingPathComponent("1.realm")
        let copyPath = seedFilePath?.deletingLastPathComponent().appendingPathComponent("copy.realm")
        print(realmPath)
        
        do {
//            try FileManager.default.copyItem(at: seedFilePath!, to: realmPath!)
            let config = Realm.Configuration(fileURL: realmPath, schemaVersion: 4)
            let realm = try Realm(configuration: config)
//            try realm.writeCopy(toFile: copyPath!)
        } catch {
            print("Error initializing new realm, \(error)")
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

