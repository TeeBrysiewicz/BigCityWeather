//
//  ViewController.swift
//  BigCityWeather
//
//  Created by Tobias Robert Brysiewicz on 8/21/16.
//  Copyright © 2016 Tobias Robert Brysiewicz. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import SwiftyJSON
import SwiftOpenWeatherMapAPI

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var currentTableView: UITableView!
    
    // Config WeatherAPI
    var apiKey = "d07aeb6d66d63043cdb0eff35eabb506"
    let weatherAPI = WAPIManager(apiKey: "d07aeb6d66d63043cdb0eff35eabb506", temperatureFormat: .Fahrenheit, lang: .English)
    // Config Cities
    let staticCities: [String] = ["Chicago", "New York", "Houston", "San Francisco", "Austin", "Denver", "Detroit", "Los Angeles", "Seattle", "Nashville"]
    // Core Data
    var cities = [NSManagedObject]()
    // Data To Pass
    var forecastToPass = JSON([])
    // Connectivity
    var offlineFlag = Bool()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    
    override func viewWillAppear(animated: Bool) {
        
        print("Created By: Tobias Brysiewicz")
        checkConnectivity()
        
//            deleteAllCoreData()

        self.fetch { (result) in
            if result {
                self.currentTableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        dispatch_async(dispatch_get_main_queue()) {
            if self.cities.count == 0 {
                // Initialize
                for city in self.staticCities {
                    self.get(city, new: true)
                }
            } else {
                // Update
                for city in self.cities {
                    self.get(city.valueForKey("name") as! String, new: false)
                }
            }
        }  
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func connectivityAlert(title: String, message: String) {
        
        // Create Controller
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.view.tintColor = UIColor.redColor()
        
        // Create Actions
        let okAction = UIAlertAction(title: "Okay", style: .Default, handler: { (action) -> Void in
            
            print("User selected okay.")
            
        })
        
        // Add Actions To Alert
        alert.addAction(okAction)
        
        // Present Alert
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    // GET WEATHER
    func get(name: String, new: Bool) {
        self.activityStart(self)
        weatherAPI.currentWeatherByCityNameAsJson(name) { (result) -> Void in
            switch result {
            case .Success(let json):
                let cityWeather = json
                
//                print("Weather Found: \(cityWeather)")
                
                print("Getting \(cityWeather["name"])'s weather...")
                let name = cityWeather["name"].stringValue
                print("= ID: \(cityWeather["id"])")
                let id = cityWeather["id"].stringValue
                print("= Temp: \(cityWeather["main"]["temp"])")
                let temp = cityWeather["main"]["temp"].stringValue
                print("= Desc: \(cityWeather["weather"][0]["description"])")
                let desc = cityWeather["weather"][0]["description"].stringValue
                
                if new {
                    self.save(name, id: id, temp: temp, desc: desc)
                } else {
                    self.update(name, newTemp: temp, newDesc: desc)
                }
                
                self.activityStop(self)
                break
                
            case .Error(let errorMessage):
                print("Error: \(errorMessage)")
                
                self.activityStop(self)
                break
                
            }
        }
    }
    // SAVE
    func save(name: String, id: String, temp: String, desc: String) {
        // Setup
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        // Set Get
        let entity = NSEntityDescription.entityForName("City", inManagedObjectContext: managedContext)
        let city = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        // Set Values
        city.setValue(name, forKey: "name")
        city.setValue(id, forKey: "id")
        city.setValue(temp, forKey: "temp")
        city.setValue(desc, forKey: "desc")
        // Save
        do {
            try managedContext.save()
            cities.append(city)
            self.currentTableView.reloadData()
            print("==> Saved \(name)! <==")
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    // UPDATE
    func update(name: String, newTemp: String, newDesc: String) {
        // Setup
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        // Config
        let fetchRequest = NSFetchRequest(entityName: "City")
        fetchRequest.predicate = NSPredicate(format: "name = %@", name)
        // Fetch
        
        // Success
        do {
            let results =
                try managedContext.executeFetchRequest(fetchRequest)
            // Check
            if results.count != 0 {
                print("\(results.count) Result(s) Found")
                // Edit
                var managedObject = results[0]
                managedObject.setValue(newTemp, forKey: "temp")
                managedObject.setValue(newDesc, forKey: "desc")
                // Save
                try managedContext.save()
                print("Updated \(results[0].valueForKey("name") as! String)'s temperature to \(newTemp) and description to \(newDesc).")
                
                self.fetch({ (result) in
                    if result {
                        self.currentTableView.reloadData()
                    }
                })
                
            } else {
                print("Fetch Results Not Found")
            }
        // Failure
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    func fetch(completion: (result: Bool)->()) {
        // Setup
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        // Config
        let fetchRequest = NSFetchRequest(entityName: "City")
        // Fetch
        do {
            let results =
                try managedContext.executeFetchRequest(fetchRequest)
            // Reassignment
            cities = results as! [NSManagedObject]
            print("Fetch Complete!")
            completion(result: true)
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
            completion(result: false)
        }
    }
    // DELETE
    func deleteAllCoreData() {
        // Setup
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        // Config
        let fetchRequest = NSFetchRequest(entityName: "City")
        // Delete
        do {
            let results =
                try managedContext.executeFetchRequest(fetchRequest)
            for object in results {
                managedContext.deleteObject(object as! NSManagedObject)
            }
        } catch let error as NSError {
            print("Error: \(error), \(error.userInfo).")
        }
        // SAVE
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Error: \(error), \(error.userInfo).")
        }
    }
    // GET 5 DAY
    func getFiveDay(city: NSManagedObject, completion: (result: Bool)->()) {
        print(" ----- Getting 5 Day Forecast for \(city.valueForKey("name") as! String) -----")
        
        let id = city.valueForKey("id") as! String
        
        let url = "http://api.openweathermap.org/data/2.5/forecast?id="+id+"&APPID="+apiKey
        Alamofire.request(.GET, url).responseJSON{ request, response, result in
            switch result{
            case .Success(let json):
//                print("Success with JSON: \(JSON)")
                self.forecastToPass = JSON(json)
                completion(result: true)

            case .Failure(let data, let error):
                print("Request failed with error: \(error)")
                if let data = data {
                    print("Response data: \(NSString(data:data, encoding: NSUTF8StringEncoding))")
                }
                completion(result: false)
                
            }
        }
    }
    
    
    func makeAttributedString(city: String, desc: String) -> NSAttributedString {
        
        let cityAttributes = [NSFontAttributeName: UIFont.systemFontOfSize(30), NSForegroundColorAttributeName: UIColor.blackColor()]
        let descAttributes = [NSFontAttributeName: UIFont.systemFontOfSize(14), NSForegroundColorAttributeName: UIColor.blackColor()]
        
        let cityString = NSMutableAttributedString(string: "\(city)\n", attributes: cityAttributes)
        let descString = NSMutableAttributedString(string: "\(desc)", attributes: descAttributes)
        
        cityString.appendAttributedString(descString)
        
        return cityString
    }


    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return cities.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    
        return 100
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! LandingTableViewCell
     
        let city = cities[indexPath.row]
        let cityName = city.valueForKey("name") as? String
        let description = city.valueForKey("desc")?.capitalizedString
        
        let temp = city.valueForKey("temp") as! String
        let fahrenheit = Double(temp)
        let roundTemp = round(fahrenheit!)
        let temperature = Int(roundTemp)
        
        // Assign Values
        cell.cityNameLabel.attributedText = makeAttributedString(cityName!, desc: description!)
        cell.tempLabel.text = String(temperature) + " \u{00B0}F"
        
        
        return cell
     }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.getFiveDay(cities[indexPath.row]) { (result) in
            if result {
                self.performSegueWithIdentifier("detail", sender: self)
            }
        }
    }
    
    
     // MARK: - Navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "detail") {
            let detailTableViewController : DetailTableViewController = segue.destinationViewController as! DetailTableViewController
            detailTableViewController.forecast = forecastToPass
        }
    }
    
    
    // MARK: - Connectivity 
    func checkConnectivity() {
        
        // CONNECTIVITY CONTROL
        let reachability: Reachability
        do {
            reachability = try Reachability.reachabilityForInternetConnection()
            self.offlineFlag = false
            print("Device can be Reached. Offline = \(self.offlineFlag)")
            
        } catch {
            self.offlineFlag = true
            print("Device can not be Reached. Offline = \(self.offlineFlag)")
            
            return
        }
        
        reachability.whenReachable = { reachability in
            dispatch_async(dispatch_get_main_queue()) {
                if reachability.isReachableViaWiFi() {
                    print("Reachable via WiFi")
                } else {
                    print("Reachable via Cellular")
                }
            }
        }
        
        reachability.whenUnreachable = { reachability in
            dispatch_async(dispatch_get_main_queue()) {
                
                self.connectivityAlert("Whoops!", message: "Failed to connect to internet. Please check your internet connection.")

                self.offlineFlag = true
                print("Device can not be Reached. Offline = \(self.offlineFlag)")
                
                print("No internet connection.")
            }
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
//     Start Activity
        func activityStart(view: UIViewController) {
    
            activityIndicator.hidden = false
            activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 100, 100))
            activityIndicator.center.y = view.view.center.y
            activityIndicator.center.x = view.view.center.x
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
            activityIndicator.startAnimating()
            activityIndicator.backgroundColor = UIColor(white: 0.0, alpha: 0.9)
            activityIndicator.layer.cornerRadius = 8.0
            activityIndicator.clipsToBounds = true
            activityIndicator.tag = 901
    
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
    
            view.view.addSubview(activityIndicator)
    
        }
    
    
//     Stop Activity
        func activityStop(view: UIViewController) {
    
            self.activityIndicator.stopAnimating()
    
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
    
            if let viewWithTag = view.view.viewWithTag(901) {
                viewWithTag.removeFromSuperview()
            }
        }
}

