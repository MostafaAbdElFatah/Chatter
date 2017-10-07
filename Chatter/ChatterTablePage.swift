

import UIKit
import CoreData

class ChatterTablePage: UITableViewController , UIImagePickerControllerDelegate ,UINavigationControllerDelegate {
    
    
    var signupbtn = UIAlertAction()
    var loginbtn = UIAlertAction()
    var loginUser:NSDictionary? = nil
    var isLogout = false
    var ChatterData:NSMutableArray = NSMutableArray()
    var flag = (text1:false , text2:false )
    
    // load data from chat data from database
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // make button in footer of table to do logout
        // make footer view in footer of table view
        let footerView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        self.tableView.tableFooterView = footerView
        // make button logout and put in footer view
        let logoutButton:UIButton = UIButton(type: UIButtonType.System) as UIButton
        logoutButton.frame = CGRect(x: footerView.frame.size.width - 60 , y: 10, width: 50, height: 20)
        logoutButton.setTitle("Logout", forState: UIControlState.Normal)
        logoutButton.addTarget(self, action: "logoutbtnClicked:", forControlEvents: UIControlEvents.TouchUpInside)
        footerView.addSubview(logoutButton)
        self.showAlterController(nil)
        
        self.loadDataFromDatabase()
    }
    
    func loadDataFromDatabase(){
        self.ChatterData.removeAllObjects()
        let appDeleg:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context:NSManagedObjectContext = appDeleg.managedObjectContext
        
        do{
            let request = NSFetchRequest(entityName: "Chat")
            let results = try context.executeFetchRequest(request)
            if results.count > 0 {
                for chat in results{
                    let username = chat.valueForKey("username")    as! NSString
                    let chattext = chat.valueForKey("chattext")  as! String
                    let chatdate = chat.valueForKey("chatdate")  as! NSDate
                    // fetch user name , user image
                    let appDeleg:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    let context:NSManagedObjectContext = appDeleg.managedObjectContext
                    let request = NSFetchRequest(entityName: "Users")
                    request.predicate = NSPredicate(format: "username == '\(username)'")
                    do{
                        let results = try context.executeFetchRequest(request)
                        if results.count > 0 {
                            let username  = results[0].valueForKey("username")  as? String
                            let userimage = results[0].valueForKey("userimage")  as? NSData
                            // save chat info into array
                            let chatinfo:NSDictionary = ["username":username!,"chatdate":chatdate
                                ,"userimage":userimage!,"chattext":chattext]
                            self.ChatterData.addObject(chatinfo)
                        }
                        
                    }catch{
                        print("error in fetching data")
                    }
                }
                let dateSort:NSSortDescriptor = NSSortDescriptor(key: "chatdate", ascending: true)
                let sortedArray:NSArray = self.ChatterData.sortedArrayUsingDescriptors([dateSort])
                self.ChatterData = NSMutableArray(array: sortedArray)
                self.tableView.reloadData()
            }
        }catch{
            print("error in fetching data")
        }

    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.ChatterData.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:RowTableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell")  as! RowTableViewCell
        let chatinfo:NSDictionary = self.ChatterData.objectAtIndex(indexPath.row) as! NSDictionary
        cell.userNameLabel.text = chatinfo.valueForKey("username") as? String
        cell.userChat.text      = chatinfo.valueForKey("chattext") as! String
        // set date
        let chatDate = chatinfo.valueForKey("chatdate") as! NSDate
        let dateFormatter:NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd 'at' HH:mm:ss"
        let dateString:String = dateFormatter.stringFromDate(chatDate)
        cell.userDateChat.text  = dateString
        // set image 
        let userimage:NSData = chatinfo.valueForKey("userimage") as! NSData
        let imageuser:UIImage = UIImage(data: userimage)!
        var imageFrameUser:CGRect = cell.userImage.frame
        imageFrameUser.size = CGSizeMake(50,50)
        cell.userImage.frame = imageFrameUser
        cell.userImage.image = imageuser
        return cell
    }
    
    func logoutbtnClicked(sender:UIButton){
        self.isLogout = true
        self.showAlterController(nil)
    }
    
    
    
    // show alert controller in table view Controller
    
    
    func showAlterController(Message:String?){
        
        if self.loginUser == nil || self.isLogout {
            self.isLogout = false
            // make alert controller to login and logout
            let alert = UIAlertController(title: "login / logout", message: Message ,   preferredStyle: UIAlertControllerStyle.Alert)
            
            signupbtn = UIAlertAction(title: "Sign up", style: UIAlertActionStyle.Default, handler: { action in
                let textfields:NSArray = alert.textFields! as NSArray
                let userNametextfield = textfields.objectAtIndex(0) as! UITextField
                let userPasstextfield = textfields.objectAtIndex(1) as! UITextField
                self.signup_btn(userNametextfield.text!, userpass: userPasstextfield.text!)
            })
            signupbtn.enabled = false
            loginbtn = UIAlertAction(title: "login", style: UIAlertActionStyle.Default, handler:{ actionbtn in
                let textfields:NSArray = alert.textFields! as NSArray
                let userNametextfield = textfields.objectAtIndex(0) as! UITextField
                let userPasstextfield = textfields.objectAtIndex(1) as! UITextField
                self.login_btn(userNametextfield.text!, userpass: userPasstextfield.text!)
                
            })
            loginbtn.enabled = false
        
            alert.addTextFieldWithConfigurationHandler({ textField in
                textField.placeholder = "User Name"
                textField.addTarget(self, action: "userTextChange:", forControlEvents: UIControlEvents.EditingChanged)
            })
            
            alert.addTextFieldWithConfigurationHandler({ textField in
                textField.placeholder = "User Password"
                textField.secureTextEntry = true
                textField.addTarget(self, action: "passTextChange:", forControlEvents:UIControlEvents.EditingChanged)
            })
            
            alert.addAction(signupbtn)
            alert.addAction(loginbtn)
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    //pick image function delegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let imageinfo:NSDictionary = info as NSDictionary
        let pickedImage:UIImage = imageinfo.objectForKey(UIImagePickerControllerOriginalImage) as! UIImage
        let imageData = UIImagePNGRepresentation(pickedImage)
        let name  = loginUser?.valueForKey("username") as! NSString
        let pass  = loginUser?.valueForKey("userpass") as! NSString
        let image = imageData!
        self.loginUser = ["username":name,"userpass":pass,"image":image]
        self.SaveUserInData()
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // ahow image picker Controller to pick user image
    func signup_btn(username:String , userpass:String) {
        
        if isUserExisting(username){
            self.showAlterController("UserName is Exist")
        }else{
         // set data in sign up new account
        self.loginUser = ["username":username , "userpass":userpass]
        // pick image to user
        let imagePicker:UIImagePickerController = UIImagePickerController()
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imagePicker.delegate = self
        self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    // Save new user account with username , userpass , userimage in database
    
    func SaveUserInData(){
        
        let appDeleg:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context:NSManagedObjectContext = appDeleg.managedObjectContext
        let newUser = NSEntityDescription.insertNewObjectForEntityForName("Users", inManagedObjectContext: context)
        let username = self.loginUser?.valueForKey("username") as! NSString
        let userpass = self.loginUser?.valueForKey("userpass") as! NSString
        let image = self.loginUser?.valueForKey("image") as! NSData
        newUser.setValue(username,forKey: "username")
        newUser.setValue(userpass, forKey: "userpass")
        newUser.setValue(image , forKey: "userimage")
        do{
            try context.save()
        }catch{
            print("error in saving data")
        }
    }
    
    // login into existing acount
    
    func login_btn(username:String , userpass:String) {
        
        
        let appDeleg:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context:NSManagedObjectContext = appDeleg.managedObjectContext
        let request = NSFetchRequest(entityName: "Users")
        request.predicate = NSPredicate(format: "username == '\(username)'")
        do{
            let results = try context.executeFetchRequest(request)
            if results.count > 0 {
                let correctpass  = results[0].valueForKey("userpass")  as? String
                if userpass == correctpass{
                    let username  = results[0].valueForKey("username")  as? String
                    let userimage = results[0].valueForKey("userimage") as? NSData
                    self.loginUser = ["username":username!,"userpass":userpass
                        ,"userimage":userimage!]
                }else{
                    self.showAlterController("Incorrect Password")
                }
            }else{
                self.showAlterController("User Name is not Existing")
            }
            
        }catch{
            print("error in fetching data")
        }
        
    }
    
    func isUserExisting(name:NSString) -> Bool{
        let appDeleg:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context:NSManagedObjectContext = appDeleg.managedObjectContext
        let request = NSFetchRequest(entityName: "Users")
        request.predicate = NSPredicate(format: "username == '\(name)'")
        do{
            let results = try context.executeFetchRequest(request)
            if results.count > 0 {
                return true
            }
            
        }catch{
            print("error in fetching data")
        }
        return false
    }
    
    // when textfield in alter controller change vallue
    
    func userTextChange(textfield:UITextField){
        
        
        if textfield.text == ""{
            flag.text1 = false
        }else{
            flag.text1 = true
        }
        
        if flag.text1 == true && flag.text2 == true {
            signupbtn.enabled  = true
            loginbtn.enabled = true
        }else{
            signupbtn.enabled  = false
            loginbtn.enabled = false
        }
    }
    
    func passTextChange(textfield:UITextField){
        
        if textfield.text == ""{
            flag.text2 = false
        }else{
            flag.text2 = true
        }
        if flag.text1 == true && flag.text2 == true{
            signupbtn.enabled  = true
            loginbtn.enabled = true
        }else{
            signupbtn.enabled  = false
            loginbtn.enabled = false
        }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "chatSegue"{
            let ChatVC:ChatTextVC = segue.destinationViewController as! ChatTextVC
            ChatVC.loginUser = self.loginUser
        }
    }

    
    
    /*
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        // usefull this code if textfield one
        /*let userEnterString:NSString  = textField.text! as NSString
        let newString =  userEnterString.stringByReplacingCharactersInRange(range, withString: string)
        if newString != "" {
            loginbtn.enabled = true
        }else{
            loginbtn.enabled  = false
        }
        return true*/
    }
    */
}
