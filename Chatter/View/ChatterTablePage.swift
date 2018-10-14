

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
    override func viewDidLoad() {
        // make footer view in footer of table view
        let footerView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        self.tableView.tableFooterView = footerView
        // make button logout and put in footer view
        let logoutButton:UIButton = UIButton(type: UIButtonType.system) as UIButton
        logoutButton.frame = CGRect(x: footerView.frame.size.width - 60 , y: 10, width: 50, height: 20)
        logoutButton.setTitle("Logout", for: UIControlState.normal)
        logoutButton.addTarget(self, action: #selector(ChatterTablePage.logoutbtnClicked(_:)), for: UIControlEvents.touchUpInside)
        footerView.addSubview(logoutButton)
        self.showAlterController(Message: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // make button in footer of table to do logout
        self.loadDataFromDatabase()
    }
    
    func loadDataFromDatabase(){
        self.ChatterData.removeAllObjects()
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context:NSManagedObjectContext = appDelegate.managedObjectContext
        // core data
        do{
            var request = NSFetchRequest<NSFetchRequestResult>(entityName: "Chat")
            let results = try context.fetch(request)
            if results.count > 0 {
                for chat in results as! [NSManagedObject]{
                    let username = chat.value(forKey: "username" ) as! String
                    let chattext = chat.value(forKey: "chattext")  as! String
                    let chatdate = chat.value(forKey: "chatdate")  as! NSDate
                    // fetch user name , user image
                    request = NSFetchRequest<NSFetchRequestResult>(entityName: "Users")
                    request.predicate = NSPredicate(format: "username == '\(username)'")
                    do{
                        let results = try context.fetch(request) as! [NSManagedObject]
                        if results.count > 0 {
                            let username  = results[0].value(forKey: "username")  as? String
                            let userimage = results[0].value(forKey: "userimage")  as? NSData
                            // save chat info into array
                            let chatinfo:NSDictionary = ["username":username!,"chatdate":chatdate
                                ,"userimage":userimage!,"chattext":chattext]
                            self.ChatterData.add(chatinfo)
                        }
                        
                    }catch{
                        print("error in fetching data")
                    }
                }
                let dateSort:NSSortDescriptor = NSSortDescriptor(key: "chatdate", ascending: true)
                let sortedArray:NSArray = self.ChatterData.sortedArray(using: [dateSort]) as NSArray
                self.ChatterData = NSMutableArray(array: sortedArray)
                self.tableView.reloadData()
            }
        }catch{
            print("error in fetching data")
        }

    }
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.ChatterData.count
    }
    
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell:RowTableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell")  as! RowTableViewCell
    
        let chatinfo:NSDictionary = self.ChatterData.object(at: indexPath.row) as! NSDictionary
        cell.userNameLabel.text  = chatinfo.value(forKey: "username") as? String
        cell.userChat.text      = chatinfo.value(forKey: "chattext") as! String
        // set date
        let chatDate = chatinfo.value(forKey: "chatdate") as! NSDate
        let dateFormatter:DateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd 'at' HH:mm:ss"
        let dateString:String = dateFormatter.string(from: chatDate as Date)
        cell.userDateChat.text  = dateString
        // set image
        let userimage:NSData = chatinfo.value(forKey: "userimage") as! NSData
        let imageuser:UIImage = UIImage(data: userimage as Data)!
        var imageFrameUser:CGRect = cell.userImage.frame
        imageFrameUser.size = CGSize(width: 50, height: 50)
        cell.userImage.frame = imageFrameUser
        cell.userImage.image = imageuser
        return cell
    }
    
    @objc func logoutbtnClicked(_ sender:UIButton){
        self.isLogout = true
        self.showAlterController(Message: nil)
    }
    
    
    
    // show alert controller in table view Controller
    
    
    func showAlterController(Message:String?){
        
        if self.loginUser == nil || self.isLogout {
            self.isLogout = false
            // make alert controller to login and logout
            let alert = UIAlertController(title: "login / logout", message: Message ,   preferredStyle: UIAlertControllerStyle.alert)
            
            signupbtn = UIAlertAction(title: "Sign up", style: UIAlertActionStyle.default, handler: { action in
                let textfields:NSArray = alert.textFields! as NSArray
                let userNametextfield = textfields.object(at: 0) as! UITextField
                let userPasstextfield = textfields.object(at: 1) as! UITextField
                self.signup_btn(username: userNametextfield.text!, userpass: userPasstextfield.text!)
            })
            signupbtn.isEnabled = false
            loginbtn = UIAlertAction(title: "login", style: UIAlertActionStyle.default, handler:{ actionbtn in
                let textfields:NSArray = alert.textFields! as NSArray
                let userNametextfield = textfields.object(at: 0) as! UITextField
                let userPasstextfield = textfields.object(at: 1) as! UITextField
                self.login_btn(username: userNametextfield.text!, userpass: userPasstextfield.text!)
                
            })
            loginbtn.isEnabled = false
        
            alert.addTextField(configurationHandler: { textField in
                textField.placeholder = "User Name"
                textField.addTarget(self, action: #selector(ChatterTablePage.userTextChange(_:)), for: UIControlEvents.editingChanged)
            })
            
            alert.addTextField(configurationHandler: { textField in
                textField.placeholder = "User Password"
                textField.isSecureTextEntry = true
                textField.addTarget(self, action: #selector(ChatterTablePage.passTextChange(_:)), for:UIControlEvents.editingChanged)
            })
            
            alert.addAction(signupbtn)
            alert.addAction(loginbtn)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // when textfield in alter controller change vallue
    @objc func userTextChange(_ textfield:UITextField){
        
        if textfield.text == "" {
            flag.text1 = false
        }else{
            flag.text1 = true
        }
        
        if flag.text1 == true && flag.text2 == true {
            signupbtn.isEnabled  = true
            loginbtn.isEnabled = true
        }else{
            signupbtn.isEnabled  = false
            loginbtn.isEnabled = false
        }
    }
    
    @objc func passTextChange(_ textfield:UITextField){
        
        if textfield.text == ""{
            flag.text2 = false
        }else{
            flag.text2 = true
        }
        if flag.text1 == true && flag.text2 == true{
            signupbtn.isEnabled  = true
            loginbtn.isEnabled = true
        }else{
            signupbtn.isEnabled  = false
            loginbtn.isEnabled = false
        }
    }
    
    
    //pick image function delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let imageinfo:NSDictionary = info as NSDictionary
        let pickedImage:UIImage = imageinfo.object(forKey: UIImagePickerControllerOriginalImage) as! UIImage
        let imageData = UIImagePNGRepresentation(pickedImage)
        let name  = loginUser?.value(forKey: "username") as! String
        let pass  = loginUser?.value(forKey: "userpass") as! String
        let image = imageData!
        self.loginUser = ["username":name,"userpass":pass,"image":image]
        self.SaveUserInData()
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    // ahow image picker Controller to pick user image
    func signup_btn(username:String , userpass:String) {
        
        if isUserExisting(name: username as NSString){
            self.showAlterController(Message: "UserName is Exist")
        }else{
            // set data in sign up new account
            self.loginUser = ["username":username , "userpass":userpass]
            // pick image to user
            let imagePicker:UIImagePickerController = UIImagePickerController()
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    // Save new user account with username , userpass , userimage in database
    
    func SaveUserInData(){
        
        let appDeleg:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context:NSManagedObjectContext = appDeleg.managedObjectContext
        let entity = NSEntityDescription.entity(forEntityName: "Users", in: context)
        let newUser = NSManagedObject(entity: entity!, insertInto: context)
        let username = self.loginUser?.value(forKey: "username") as! String
        let userpass = self.loginUser?.value(forKey: "userpass") as! String
        let image = self.loginUser?.value(forKey: "image") as! NSData
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
        
        let appDeleg:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context:NSManagedObjectContext = appDeleg.managedObjectContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Users")
        request.predicate = NSPredicate(format: "username == '\(username)'")
        do{
            let results = try context.fetch(request) as! [NSManagedObject]
            if results.count > 0 {
                let correctpass  = results[0].value(forKey: "userpass")  as? String
                if userpass == correctpass{
                    let username  = results[0].value(forKey: "username")  as? String
                    let userimage = results[0].value(forKey: "userimage") as? NSData
                    self.loginUser = ["username":username!,"userpass":userpass
                        ,"userimage":userimage!]
                }else{
                    self.showAlterController(Message: "Incorrect Password")
                }
            }else{
                self.showAlterController(Message: "User Name is not Existing")
            }
            
        }catch{
            print("error in fetching data")
        }
        
    }
    
    func isUserExisting(name:NSString) -> Bool{
        let appDeleg:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context:NSManagedObjectContext = appDeleg.managedObjectContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Users")
        request.predicate = NSPredicate(format: "username == '\(name)'")
        do{
            let results = try context.fetch(request)
            if results.count > 0 {
                return true
            }
        }catch{
            print("error in fetching data")
        }
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "chatSegue"{
            let ChatVC:ChatTextVC = segue.destination as! ChatTextVC
            ChatVC.loginUser = self.loginUser
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        // usefull this code if textfield one
        let userEnterString:NSString  = textField.text! as NSString
        let newString =  userEnterString.replacingCharacters(in: range, with: string)
        if newString != "" {
            loginbtn.isEnabled = true
        }else{
            loginbtn.isEnabled  = false
        }
        return true
    }
    
}






