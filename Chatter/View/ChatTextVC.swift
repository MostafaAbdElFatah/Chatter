

import UIKit
import CoreData

class ChatTextVC: UIViewController , UITextViewDelegate {
    
    var numLetter = 140
    var loginUser:NSDictionary? = nil
    @IBOutlet weak var letternumLabel: UILabel!
    @IBOutlet weak var ChatText: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        numLetter = 140
        ChatText.delegate = self
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n"{
            self.ChatText.resignFirstResponder()
            self.SaveDatatoDatabase()
            return false
        }
        if text != ""{
            if self .numLetter > 0  {
                self.numLetter = self.numLetter - 1
                self.letternumLabel.text =  String(format: "%i", self.numLetter)
            }else{
                return false
            }
        }else{
            if self .numLetter < 140  {
                self.numLetter = self.numLetter + 1
                self.letternumLabel.text =  String(format: "%i", self.numLetter)
            }
        }
        return true
    }
    
    
    

    @IBAction func done_btnClicked(_ sender: UIBarButtonItem) {
        self.SaveDatatoDatabase()
    }
    
    func SaveDatatoDatabase(){
        
        let username = self.loginUser?.value(forKey: "username") as! NSString
        /// core data
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context:NSManagedObjectContext = appDelegate.managedObjectContext        
        let entity = NSEntityDescription.entity(forEntityName: "Chat", in: context)
        let newChat = NSManagedObject(entity: entity!, insertInto: context)
        newChat.setValue(username ,forKey: "username")
        newChat.setValue(self.ChatText.text , forKey: "chattext")
        newChat.setValue(NSDate() , forKey: "chatdate")
        do{
            try context.save()
        }catch{
            print("error in saving data")
        }
        self.navigationController?.popViewController(animated: true)
    }
    
}









