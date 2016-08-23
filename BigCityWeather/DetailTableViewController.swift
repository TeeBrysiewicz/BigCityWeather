//
//  DetailTableViewController.swift
//  BigCityWeather
//
//  Created by Tobias Robert Brysiewicz on 8/21/16.
//  Copyright © 2016 Tobias Robert Brysiewicz. All rights reserved.
//

import UIKit
import SwiftyJSON


class DetailTableViewController: UITableViewController {

    var forecast = JSON([])
    var forecastList = [JSON]([])
    
    var forecastDates = [String]()
    var forecastDays = [JSON]([])
    
    
    override func viewWillAppear(animated: Bool) {
        
//        print("Passed Data: \(forecast)")
//        print("We have \(forecastList.count) forecasts.")
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getForecastDays()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getForecastDays() {
        forecastList = forecast["list"].arrayValue
        forecastDays = forecastList.filter({
            if ($0) != nil {
                
                let forecastDate = convertStringToDate($0["dt_txt"].stringValue)
                
                if !forecastDates.contains(forecastDate) {
                    forecastDates.append(forecastDate)
                    return true
                } else {
                    return false
                }
            } else {
                return false
            }
        })
 
        print("ForecastDates: \(forecastDates)")
        print("ForecastDays: \(forecastDays)")
    }
    
    func convertStringToDate(date: String) -> String {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        guard let date = dateFormatter.dateFromString(date) else { return "" }
        
        dateFormatter.dateFormat = "MM-dd-yy"
        let timeStamp = dateFormatter.stringFromDate(date)
        
        return timeStamp
    }
    
    
    func convertStringToNiceDate(date: String) -> String {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        guard let date = dateFormatter.dateFromString(date) else { return "" }

        dateFormatter.dateFormat = "MMM dd, "+"20"+"yy"
        let timeStamp = dateFormatter.stringFromDate(date)

        return timeStamp
    }
    func getDayOfWeek(day:String)->String? {
        
        let dateFormatter  = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd-yy"
        
        guard let date = dateFormatter.dateFromString(day) else { return nil }
        
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let components = calendar.components(.Weekday, fromDate: date)
        
        let weekDays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        
        return weekDays[components.weekday - 1]
    }
    func makeAttributedString(day: String, date: String) -> NSAttributedString {
        
        let dayAttributes = [NSFontAttributeName: UIFont.systemFontOfSize(24), NSForegroundColorAttributeName: UIColor.blackColor()]
        let dateAttributes = [NSFontAttributeName: UIFont.systemFontOfSize(18), NSForegroundColorAttributeName: UIColor.blackColor()]
        
        let dayString = NSMutableAttributedString(string: "\(day)\n", attributes: dayAttributes)
        let dateString = NSMutableAttributedString(string: "\(date)", attributes: dateAttributes)
        
        dayString.appendAttributedString(dateString)
        
        return dayString
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 6
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let mainScreenSize : CGSize = UIScreen.mainScreen().bounds.size
        let mainAdjustment = mainScreenSize.height - 84
        
        let rowHeight = (mainAdjustment / 5)
        
        if indexPath.row == 0 {
            return 24
        } else {
            return rowHeight
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row != 0 {
            
        let trueIndex = indexPath.row - 1
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! DetailTableViewCell
        
        // Date
        let dateString = forecastDays[trueIndex]["dt_txt"].stringValue
        let dateNice = convertStringToNiceDate(dateString)
        let date = convertStringToDate(dateString)
        let weekDay = getDayOfWeek(date)! as String
        // Desc
        let description = forecastDays[trueIndex]["weather"][0]["description"].stringValue.capitalizedString
        // Temp
        let kelvinTemp = forecastDays[trueIndex]["main"]["temp"].doubleValue
        let fahrenheitTemp = (kelvinTemp * (9/5)) - 459.67
        let roundTemp = round(fahrenheitTemp)
        let temperature = Int(roundTemp)

        
        cell.dayLabel.attributedText = makeAttributedString(weekDay, date: dateNice)
        cell.descLabel.text = description
        cell.tempLabel.text = String(temperature) + " \u{00B0}F"
        

        return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("headerCell", forIndexPath: indexPath)

            return cell
        }
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
