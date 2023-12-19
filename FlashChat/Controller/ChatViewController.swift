//
//  ChatViewController.swift
//  FlashChat
//
//  Created by Beste on 19.12.2023.
//

import UIKit
import Firebase

class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    let db = Firestore.firestore()
    
    var messages : [Message] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        
        //ChatVC sol üstteki back butonunu kaldırdık
        navigationItem.hidesBackButton = true
        
        //message cell xib file register
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        
        loadMessages()
        
        // IQKeyboardManager -> package dependicies -> kodu app delegate' a yazdık.
        // Yazı yazarken klavye textfield'ı gizliyor. Artık klavye açılınca textfield otomatik olarak yukarı kalkıcak

    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        //Firestore Database add data
        if let messageBody = messageTextfield.text, let messageSender = Auth.auth().currentUser?.email {
            self.db.collection(K.FStore.collectionName).addDocument(data: [
                K.FStore.senderField : messageSender,
                K.FStore.bodyField : messageBody,
                K.FStore.dateField : Date().timeIntervalSince1970
            ]) { error in
                if error != nil {
                    self.showAlert(title: "Saving Error!", message: error?.localizedDescription ?? "Data saving is failed!")
                } else {
                    //Save data success
                    DispatchQueue.main.async {
                        self.messageTextfield.text = ""
                    }
                }
            }
        }
    }
    
    //Firestore Database get data
    func loadMessages() {
        
        db.collection(K.FStore.collectionName)
            .order(by: K.FStore.dateField)
            .addSnapshotListener { querySnapshot, error in
            
            self.messages = []
            
            if error != nil {
                self.showAlert(title: "Error!", message: error?.localizedDescription ?? "Retrieving data error")
            } else {
                if let snapshotDocuments = querySnapshot?.documents {
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        
                        if let sender = data[K.FStore.senderField] as? String, let body = data[K.FStore.bodyField] as? String {
                            
                            let newMessage = Message(sender: sender, body: body)
                            self.messages.append(newMessage)
                            
                            DispatchQueue.main.async {
                                //verilerin table view'da gözükmesi için
                                self.tableView.reloadData()
                                //giriş yapıldığında en baştaki değil en sondaki mesajı görmek için
                                let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                                //row = en sondaki mesajın index'i | 1 adet section var ve index'i 0'a eşit
                                self.tableView.scrollToRow(at: indexPath, at: .top, animated: false) // animated: true kötü gözüktü
                            }
                        }
                        
                    }
                    
                }
            }
        }

    }
    
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        
        do {
            try Auth.auth().signOut()
            //navigate to welcomeVC
            navigationController?.popToRootViewController(animated: true)
            
        } catch let signOutError as NSError {
            showAlert(title: "Sign Out Error!", message: signOutError.localizedDescription)
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

//MARK: - UITableViewDataSource

extension ChatViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = messages[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell
        
        cell.messageLabel.text = message.body
        
        // firestore'da mesajı gönderen == giris yapılan hesap
        if message.sender == Auth.auth().currentUser?.email {
            cell.rightImageView.isHidden = true
            cell.leftImageView.isHidden = false
            
            cell.messageBubble.backgroundColor = .brandPurple
            cell.messageLabel.textColor = .brandLightPurple
            
            cell.messageLabel.textAlignment = .left
            
        } else {
            cell.rightImageView.isHidden = false
            cell.leftImageView.isHidden = true
            
            cell.messageBubble.backgroundColor = .brandLightPurple
            cell.messageLabel.textColor = .brandPurple
            
            cell.messageLabel.textAlignment = .right
        }
        

        return cell
    }
    
}

