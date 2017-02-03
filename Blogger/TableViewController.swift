//
//  TableViewController.swift
//  Blogger
//
//  Created by Viraj Padte on 2/2/17.
//  Copyright © 2017 Bit2Labz. All rights reserved.
//

import UIKit
import CoreData

class TableViewController: UITableViewController{
    var selectedTitle = ""
    var selectedPostText = ""
    var key = ""

    
    @IBOutlet var table: UITableView!
    
    var titleNames = [String]()
    var posts = [String]()

    override func viewDidLoad() {
        
        //get key from config file
        
        let path = Bundle.main.path(forResource: "configuration", ofType: ".plist")
        key = (NSDictionary(contentsOfFile: path!)?["BloggerAPI"] as! NSDictionary)["APIKEY"] as! String
        
        super.viewDidLoad()
        retriveData()
    
     }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return titleNames.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
        cell.textLabel?.text = titleNames[indexPath.row]
        // Configure the cell...
        return cell
    }


    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedTitle = titleNames[indexPath.row]
        selectedPostText = posts[indexPath.row]
        performSegue(withIdentifier: "toPost", sender: nil)
    }
    
    
    func downloadData(){
        //empty array
        posts.removeAll()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let address = URL(string: "https://www.googleapis.com/blogger/v3/blogs/32069983/posts?key=\(key)")
        let request = URLRequest(url: address!)
        
        let task = URLSession.shared.dataTask(with: request){
            data,resposne,error in
            if error != nil{
                print(error)
            }
            else{
                if let data = data{
                    do{
                        let parsedData = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)  as! NSDictionary
                        let items  = parsedData["items"] as! NSArray
                        
                        for item in items{
                            if let post = item as? NSDictionary{
                                //get title
                                let title = post["title"] as! NSString
                                //get content
                                let content = post["content"] as! NSString
                                
                                //view
                                //print(title)
                                //print(content)
                                
                                self.titleNames.append(title as String)
                                self.posts.append(content as String)
                                
                                DispatchQueue.main.sync(execute: {
                                    self.table.reloadData()
                                })
                                //save data
                                let newPost = NSEntityDescription.insertNewObject(forEntityName: "Blog", into: context)
                                newPost.setValue(title, forKey: "titles")
                                newPost.setValue(content, forKey: "contents")
                                
                                do{
                                    try context.save()
                                    print("saved")
                                }
                                catch{
                                    print("didnt save")
                                }
                            }
                        }
                    }
                    catch{
                    
                    }
                }
            }
            
        }
        task.resume()
    }

    
    func retriveData(){
        print("here")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Blog")
        
        do{
            let results = try context.fetch(request)
            print("fetched data")
            print("Number of Entries \(results.count)")
            if results.count == 10{
                print("I have 10")
                for result in results as! [NSManagedObject]{
                    self.titleNames.append(result.value(forKey: "titles") as! String)
                    self.table.reloadData()
                    
                }
            }else if 1...9 ~= results.count{
                print("I have less than 10")
                //fetch and delete and then download new
                do{
                    let tempResults = try context.fetch(request)
                    for tempResult in tempResults as! [NSManagedObject]{
                        context.delete(tempResult)
                        
                        //save the the delete operation has occured
                        do {
                            try context.save()
                            print("permanently deleted")
                            
                        } catch  {
                            print("couldn't permanently delete")
                        }
                    }
                    //fetch and delete done now download again
                    downloadData()
                }
                catch{
                    print("couldnt referesh incomplete data!")
                }
            }
            else{
                //download again
                downloadData()
            }
        }
        catch{
            print("no data found")
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            
            let postTitle = table.cellForRow(at: indexPath)?.textLabel?.text
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Blog")
            request.predicate = NSPredicate(format: "titles == %@", postTitle!)
            do{
                let tempResults = try context.fetch(request)
                for tempResult in tempResults as! [NSManagedObject]{
                    
                    if let title = tempResult.value(forKey: "titles") as? String{
                        let findex = titleNames.index(of: title)
                        titleNames.remove(at: findex!)
                        //delete form permanent data:
                        context.delete(tempResult)
                        //save the the delete operation has occured
                        do {
                            try context.save()
                            } catch  {
                                print("couldn't permanently delete")
                            }
                        }
                    else{
                        print("cannot get the title string")
                    }
                    //save the the delete operation has occured
                    do {
                        try context.save()
                        print("permanently deleted")
                        //find in list
                        table.reloadData()
                    } catch  {
                        print("couldn't permanently delete")
                    }
                }
            }
            catch{
                print("couldnt fetch existing data")
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPost"{
            var destinationViewController = segue.destination as! ViewController
            destinationViewController.postTitle = selectedTitle
            destinationViewController.post = selectedPostText
        }
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    

}
