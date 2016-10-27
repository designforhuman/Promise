//
//  CheckInViewController.swift
//  Promise
//
//  Created by LeeDavid on 10/27/16.
//  Copyright © 2016 Daylight. All rights reserved.
//

import UIKit



protocol CheckInViewControllerDelegate: class {
    func checkInViewController(_ controller: CheckInViewController, didSelect emoji: String)
}




class CheckInViewController: UIViewController {
    
    
    var delegate: CheckInViewControllerDelegate?
    
    
    @IBOutlet weak var camera: UIView!
    @IBOutlet weak var emoji_sunglasses: UIButton!
    
    
    
    @IBAction func emoji_v(_ sender: Any) {
        delegateWithEmoji("emoji_v")
    }
    @IBAction func emoji_sunglasses(_ sender: Any) {
        delegateWithEmoji("emoji_sunglasses")
    }
    @IBAction func emoji_hm(_ sender: Any) {
        delegateWithEmoji("emoji_hm")
    }
    @IBAction func emoji_phew(_ sender: Any) {
        delegateWithEmoji("emoji_phew")
    }
    @IBAction func emoji_sick(_ sender: Any) {
        delegateWithEmoji("emoji_sick")
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        camera.layer.cornerRadius = 50

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func delegateWithEmoji(_ emoji: String) {
        delegate?.checkInViewController(self, didSelect: emoji)
        dismiss(animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    

    
    
//    func backgroundBlur() {
//        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
//        let blurEffectView = UIVisualEffectView(effect: blurEffect)
//        blurEffectView.frame = view.bounds
//        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
//        view.addSubview(blurEffectView)
//    }

}
