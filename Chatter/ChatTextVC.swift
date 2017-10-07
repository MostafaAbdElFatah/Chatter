

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
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
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
    
    @IBAction func Done_btnClicked(sender: UIBarButtonItem) {
        self.SaveDatatoDatabase()
    }
    
    func SaveDatatoDatabase(){
        
        let appDeleg:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context:NSManagedObjectContext = appDeleg.managedObjectContext
        let newChat = NSEntityDescription.insertNewObjectForEntityForName("Chat", inManagedObjectContext: context)
        let username = self.loginUser?.valueForKey("username") as! NSString
        
        newChat.setValue(username ,forKey: "username")
        newChat.setValue(self.ChatText.text , forKey: "chattext")
        newChat.setValue(NSDate() , forKey: "chatdate")
        do{
            try context.save()
        }catch{
            print("error in saving data")
        }
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}
