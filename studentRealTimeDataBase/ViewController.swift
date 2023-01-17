//
//  ViewController.swift
//  studentRealTimeDataBase
//
//  Created by CHRISTIAN BOURQUIN on 1/4/23.
//

class student{
    var name: String
    var age: Int
    var ref = Database.database().reference()
    var key = ""
    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
    init(dict: [String: Any]) {
        if let n = dict["name"] as? String{
            name = n
        }
        else{
            name = ""
        }
        if let a = dict["age"] as? Int{
            age = a
        }
        else {
            age = 0
        }
    }
    func saveToFireBase(){
        var dict = ["name":name,"age":age] as [String: Any]
        key = ref.child("students2").childByAutoId().key ?? ""
        ref.child("students2").child(key).setValue(dict)
        
    }
    func deleteFromFirebase (){
        ref.child("students2").child(key).removeValue()
    }
    func updateFirebase(){
        let dict = ["name": name,"age": age] as! [String: Any]
        ref.child("students").child(key).updateChildValues(dict)
        
    }
}







import UIKit
import FirebaseCore
import FirebaseDatabase

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    

    @IBOutlet weak var ageTextFieldOutlet: UITextField!
    @IBOutlet weak var textFieldOutlet: UITextField!
    
    @IBOutlet weak var tableViewOutlet: UITableView!
    //  @IBOutlet weak var textViewOutlet: UITextView!
    var ref: DatabaseReference!
    var names = [String]()
    var students = [student]()
    var selectedIndex = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //need these two lines to connect
        tableViewOutlet.delegate = self
        tableViewOutlet.dataSource = self
        // names.append("brian")
        ref = Database.database().reference()
        //reading from database
        //automatically gets called at start and when child gets added
        ref.child("students").observe(.childAdded) { snapshot in
            
            var name = snapshot.value as! String
            
            // student.key = snapshot.key
            //stopped at child removeed
            self.names.append(name)
            self.tableViewOutlet.reloadData()
            
            
            // self.textViewOutlet.text += name + "\n"
            
        }
        
        ref.child("students2").observe(.childAdded) { snapshot in
            
            var dict = snapshot.value as! [String: Any]
            var stews = student(dict: dict)
            stews.key = snapshot.key
            self.students.append(stews)
            self.tableViewOutlet.reloadData()
            
            
            // self.textViewOutlet.text += name + "\n"
            
        }
        
        //remove observer
        ref.child("students2").observe(.childRemoved) { snapshot in
            
            var dict = snapshot.value as! [String: Any]
            for i in 0 ..< self.students.count{
                if self.students[i].key == snapshot.key{
                    self.students.remove(at: i)
                    self.tableViewOutlet.reloadData()
                    break
                }
            }
        }
            
            
            ref.child("students2").observe(.childChanged) { snapshot in
                
                var dict = snapshot.value as! [String: Any]
                
                for i in 0 ..< self.students.count{
                    if self.students[i].key == snapshot.key{
                        self.students[i].name = dict["name"] as! String
                        self.students[i].age = dict["age"] as! Int
                        self.tableViewOutlet.reloadData()
                        break
                    }
                }
                self.tableViewOutlet.reloadData()
            }
            
          /*  ref.child("students2").observe(.childAdded) { snapshot in
                
                var dict = snapshot.value as! [String: Any]
                var stews = student(dict: dict)
                stews.key = snapshot.key
                //stopped at child removeed
                self.students.append(stews)
                self.tableViewOutlet.reloadData()
                
                
                // self.textViewOutlet.text += name + "\n"
                
            */
            // Do any additional setup after loading the view.
        
    }
    @IBAction func nameAndAgeSave(_ sender: Any) {
        let name = textFieldOutlet.text!
        let age = Int(ageTextFieldOutlet.text!)!
        var stew = student(name: name, age: age)
        stew.saveToFireBase()
        //students.append(stew)
       // tableViewOutlet.reloadData()
    }
    
    @IBAction func buttonAction(_ sender: Any) {
        var name = textFieldOutlet.text!
       
        ref.child("students").childByAutoId().setValue(name)
    }
    
    
    @IBAction func EditAction(_ sender: Any) {
        students[selectedIndex].name = textFieldOutlet.text!
        students[selectedIndex].age = Int(ageTextFieldOutlet.text!)!
        tableViewOutlet.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewOutlet.dequeueReusableCell(withIdentifier: "myCell")!
        cell.textLabel?.text = students[indexPath.row].name
        cell.detailTextLabel?.text = String(students[indexPath.row].age)
        return cell
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            students[indexPath.row].deleteFromFirebase()
            students.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
   
    
}

