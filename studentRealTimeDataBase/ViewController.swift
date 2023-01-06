//
//  ViewController.swift
//  studentRealTimeDataBase
//
//  Created by CHRISTIAN BOURQUIN on 1/4/23.
//

import UIKit
import FirebaseCore
import FirebaseDatabase

class ViewController: UIViewController {

    @IBOutlet weak var textFieldOutlet: UITextField!
    
    @IBOutlet weak var textViewOutlet: UITextView!
    var ref: DatabaseReference!
    var names = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        //reading from database
        //automatically gets called at start and when child gets added
        ref.child("students").observe(.childAdded) { snapshot in
            
            var name = snapshot.value as! String
            
            self.names.append(name)
            
            self.textViewOutlet.text += name + "\n"
            
        }
        // Do any additional setup after loading the view.
    }

    
    @IBAction func buttonAction(_ sender: Any) {
        var name = textFieldOutlet.text!
        names.append(name)
        ref.child("students").childByAutoId().setValue(name)
    }
    
}

