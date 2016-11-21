//
//  DurationViewController.swift
//  Promise
//
//  Created by LeeDavid on 10/19/16.
//  Copyright © 2016 Daylight. All rights reserved.
//

import UIKit



protocol DurationViewControllerDelegate: class {
    func durationViewController(_ controller: DurationViewController,
                                didFinishSelect duration: Int, durationToDisplay: String)
}



class DurationViewController: UITableViewController {
    
    weak var delegate: DurationViewControllerDelegate?
    let weeks = ["1 Week", "2 Weeks", "3 Weeks", "4 Weeks"]
    var selectedWeek: Int!
    var durationToDisplay: String!
    var durationSuffix = "s"
    
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func done(_ sender: Any) {
        delegate?.durationViewController(self, didFinishSelect: selectedWeek, durationToDisplay: "")
        dismiss(animated: true, completion: nil)
    }
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)

    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(true)
//        
//        delegate?.durationViewController(self, didFinishSelect: selectedWeek, durationToDisplay: "")
//    }

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
        return weeks.count
    }
    
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        selectedWeek = indexPath.row + 1
        tableView.reloadData()
//        navigationController?.popViewController(animated: true)
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DurationItem", for: indexPath)
        cell.selectionStyle = .none

        let label = cell.contentView.subviews[0] as! UILabel
        label.text = weeks[indexPath.row]
        
        if selectedWeek == indexPath.row + 1 {
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
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
