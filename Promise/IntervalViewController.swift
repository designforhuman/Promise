//
//  IntervalViewController.swift
//  Promise
//
//  Created by LeeDavid on 10/19/16.
//  Copyright © 2016 Daylight. All rights reserved.
//

import UIKit


protocol IntervalViewControllerDelegate: class {
    func intervalViewController(_ controller: IntervalViewController,
                                didFinishEditing interval: [Bool], days: String)
}

 

class IntervalViewController: UITableViewController, UINavigationControllerDelegate {
    
    weak var delegate: IntervalViewControllerDelegate?
    let daysShort = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    var days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    var intervals: [Bool]!
    var intervalToDisplay: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
//        tableView.tableFooterView?.backgroundColor = UIColor.groupTableViewBackground

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        delegate?.intervalViewController(self, didFinishEditing: intervals, days: intervalToDisplay)
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return days.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IntervalItem", for: indexPath)
        
        // Set data and visual
        let label = cell.contentView.subviews[0] as! UILabel
        label.text = days[indexPath.row]

        if intervals[indexPath.row] == true {
            label.textColor = UIColor.black
            if #available(iOS 8.2, *) {
                label.font = UIFont.systemFont(ofSize: 22, weight: UIFontWeightMedium)
            } else {
                // Fallback on earlier versions
            }
        } else {
            label.textColor = UIColor.lightGray
            if #available(iOS 8.2, *) {
                label.font = UIFont.systemFont(ofSize: 22, weight: UIFontWeightRegular)
            } else {
                // Fallback on earlier versions
            }
        }

        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Change data and visual
        if let cell = tableView.cellForRow(at: indexPath) {
            let label = cell.contentView.subviews[0] as! UILabel
            
            intervals[indexPath.row] = !intervals[indexPath.row]
            
//            let label = cell.viewWithTag(1001) as! UILabel
//            print("LABEL: \(label.text!)")
//            intervalToDisplay = ""
            var intervalCount = 0
            var index = 0
            var intervalToDisplayTemp = ""
            for bool in intervals {
                if bool {
                    intervalToDisplayTemp += "\(daysShort[index]) "
                    intervalCount += 1
                }
                index += 1
            }
            if intervalCount == 7 {
                intervalToDisplay = "Everyday"
            } else {
                intervalToDisplay = intervalToDisplayTemp
            }
            
            
            label.textColor = (label.textColor == UIColor.black) ? UIColor.lightGray : UIColor.black
            if #available(iOS 8.2, *) {
                label.font = (label.font == UIFont.systemFont(ofSize: 22, weight: UIFontWeightMedium)) ? UIFont.systemFont(ofSize: 22, weight: UIFontWeightRegular) : UIFont.systemFont(ofSize: 22, weight: UIFontWeightMedium)
            } else {
                // Fallback on earlier versions
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
 
    

}
