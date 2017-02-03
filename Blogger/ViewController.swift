//
//  ViewController.swift
//  Blogger
//
//  Created by Viraj Padte on 2/2/17.
//  Copyright © 2017 Bit2Labz. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    let address = ""
    @IBOutlet weak var web: UIWebView!
    var post = ""
    var postTitle = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //print(postTitle)
        //print(post)
        self.navigationItem.title = postTitle
        retriveData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    func retriveData(){
        print("here")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Blog")
        
        do{
            let results = try context.fetch(request)
            print("fetched data")
            print("Number of Entries \(results.count)")
            for result in results as! [NSManagedObject]{
                let post = result.value(forKey: "contents")
                contents.append(post as! String)
            }
            print(contents)
            
            web.loadHTMLString(content, baseURL: nil)
        }
        catch{
            print("no data found")
        }
    }
 */
    func retriveData(){
        web.loadHTMLString(post, baseURL: nil)
        web.scalesPageToFit = true
    }



}

