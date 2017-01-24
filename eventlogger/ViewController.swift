//
//  ViewController.swift
//  eventlogger
//
//  Created by Dylan Rodriquez on 1/24/17.
//  Copyright © 2017 Dylan Rodriquez. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    var events : [NSManagedObject] = []
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // configuration of views once loaded
        title = "Event Log"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
    }
    override func viewDidAppear(_ animated: Bool) {
        // this allows us to fetch anything persistent
        super.viewWillAppear(animated)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Event")
        
        do{
            events = try managedContext.fetch(fetchRequest)
        } catch let error as NSError{
            print ("Danger, Danger Will Robinson! \(error). \(error.userInfo)")
        }
    }
    @IBAction func createEvent(_ sender: UIBarButtonItem) {
        //creating alert
        let alert = UIAlertController(title: "Event", message: "Add Event", preferredStyle: .alert)
        //creating save button
        let saveAc = UIAlertAction(title: "Save",
                                   style: .default) {
                                    [unowned self] action in
                                    
                                    guard let textField = alert.textFields?.first,
                                        let eventToSave = textField.text else {
                                            return
                                    }
                                    
                                    self.save(nameOfEvent: eventToSave)
                                    self.save(nameOfEvent: String(Date().timeIntervalSince1970))
                                    //self.events.append(String(Date().timeIntervalSince1970))
                                    self.tableView.reloadData()
        }
        
        //creating cancel button
        let cancel = UIAlertAction(title: "Cancel", style: .default)
        //adding buttons to alert
        
        alert.addTextField()
        alert.addAction(saveAc)
        alert.addAction(cancel)
        
        present(alert, animated: true)
    }
    
    func save (nameOfEvent: String){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        // first
        // create the NSManagedObjectContext, the "blank object in memory"
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        //second
        // put it in context
        let entity = NSEntityDescription.entity(forEntityName: "Event", in: managedContext)!
        
        let event = NSManagedObject(entity: entity, insertInto: managedContext)
        
        //third
        // key value coding
        event.setValue(nameOfEvent, forKeyPath: "nameOfEvent")
        
        //fourth
        // comit changes, and save
        do{
            try managedContext.save()
            events.append(event)
        }catch let error as NSError {
            print ("Danger, Danger Will Robinson! \(error). \(error.userInfo)")
        }
    }
}
extension ViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt path: IndexPath) -> UITableViewCell {
        let event = events[path.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",
                                                 for: path)
        // retrieving text from nameOfEvent attribute of Event
        // Key-Value
        cell.textLabel?.text = event.value(forKeyPath:"nameOfEvent") as? String
        return cell
    }
}


