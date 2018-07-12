//
//  TodayViewController.swift
//  JustDoIt Widget
//
//  Created by Виктория Бадисова on 12.07.2018.
//  Copyright © 2018 Виктория Бадисова. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    
    // MARK: - View methods
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        titleLabel.text = "Best title ever"
    }
    
}

// MARK: - NCWidgetProviding methods

extension TodayViewController: NCWidgetProviding {
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
}

extension TodayViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "WigdetTableViewCell")
        cell.textLabel?.text = "Line: \(indexPath.row)"
        return cell
    }
    
}
