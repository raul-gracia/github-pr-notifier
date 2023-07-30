//
//  Github_PR_NotifierApp.swift
//  Github PR Notifier
//
//  Created by Raul Gracia on 27/07/2023.
//

import SwiftUI

@main
struct Github_PR_NotifierApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        Settings {
            Text("Settings View")
        }
    }
}


class AppDelegate: NSObject, NSApplicationDelegate {
    var popover = NSPopover.init()
    var statusBar: NSStatusItem?
    var prCount: Int = 0 {
        didSet {
            updateStatusBar()
        }
    }

    
    override init() {
        super.init()
        
        let contentView = ContentView()
        popover.contentSize = NSSize(width: 600, height: 400)
        popover.contentViewController = NSHostingController(rootView: contentView)
        
        statusBar = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let button = statusBar?.button {
            button.action = #selector(togglePopover(_:))
        }
        
        updateStatusBar()

        NotificationCenter.default.addObserver(self, selector: #selector(self.prsCountDidChange(_:)), name: .prsCountDidChange, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func updateStatusBar() {
        guard let button = statusBar?.button else { return }
        let statusItemView = NSHostingView(rootView: StatusItemView(count: prCount))
        statusItemView.frame = button.bounds
        button.addSubview(statusItemView)
    }
    
    @objc func prsCountDidChange(_ notification: Notification) {
        if let count = notification.userInfo?["count"] as? Int {
            prCount = count
        }
    }
    
    @objc func togglePopover(_ sender: AnyObject) {
        if popover.isShown {
            closePopover(sender)
        } else {
            showPopover(sender)
        }
    }
    
    func showPopover(_ sender: AnyObject) {
        if let button = statusBar?.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            popover.behavior = .transient
        }
    }
    
    func closePopover(_ sender: AnyObject) {
        popover.performClose(sender)
    }
}

