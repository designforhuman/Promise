//
//  EmailSignInViewController.swift
//  Promise
//
//  Created by LeeDavid on 10/28/16.
//  Copyright © 2016 Daylight. All rights reserved.
//

import UIKit
import FirebaseAuth



class EmailSignInViewController: UIViewController {
    
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
//
//    
//    
//    @IBAction func didTapSignIn(_ sender: AnyObject) {
//        // Sign In with credentials.
//        guard let email = emailField.text, let password = passwordField.text else { return }
//        FIRAuth.auth()?.signIn(withEmail: email, password: password) { (user, error) in
//            if let error = error {
//                print(error.localizedDescription)
//                return
//            }
//            self.signedIn(user!)
//        }
//    }
//    
//    @IBAction func didTapSignUp(_ sender: AnyObject) {
//        guard let email = emailField.text, let password = passwordField.text else { return }
//        FIRAuth.auth()?.createUser(withEmail: email, password: password) { (user, error) in
//            if let error = error {
//                print(error.localizedDescription)
//                return
//            }
//            self.setDisplayName(user!)
//        }
//    }
    
    @IBAction func didRequestPasswordReset(_ sender: AnyObject) {
        let prompt = UIAlertController.init(title: nil, message: "Email:", preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "OK", style: .default) { (action) in
            let userInput = prompt.textFields![0].text
            if (userInput!.isEmpty) {
                return
            }
            FIRAuth.auth()?.sendPasswordReset(withEmail: userInput!) { (error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
            }
        }
        prompt.addTextField(configurationHandler: nil)
        prompt.addAction(okAction)
        present(prompt, animated: true, completion: nil);
    }
    
    
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func done(_ sender: Any) {
        
    }
    
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
