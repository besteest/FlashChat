//
//  LoginViewController.swift
//  FlashChat
//
//  Created by Beste on 19.12.2023.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    

    @IBAction func loginPressed(_ sender: UIButton) {
        
        if let email = emailTextfield.text, let password = passwordTextfield.text {
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if error != nil {
                    self.showAlert(title: "E-mail/Password?", message: error?.localizedDescription ?? "Error")
                } else {
                    //navigation to chatVC
                    self.performSegue(withIdentifier: K.loginSegue, sender: self)
                }
            }
        }
        
    }
    
    func showAlert(title: String, message: String) {
        // UIAlertController
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // UIAlertAction
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
        
    }

}
