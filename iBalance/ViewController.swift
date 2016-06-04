//
//  ViewController.swift
//  iBalance
//
//  Created by Vrund Patel on 1/20/16.
//  Copyright © 2016 VrundPatel. All rights reserved.
//

import UIKit
import CoreMotion
import MessageUI

class ViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    //Hides the status bar
    override func prefersStatusBarHidden() -> Bool { 
        return true;
    }
    
    //Label for the peak length
    @IBOutlet var peakLengthBox: UILabel!
    
    //Label for the peak length info.
    @IBOutlet var peakLengthInfo: UILabel!
    
    //Label for the path length info
    @IBOutlet var pathLengthInfo: UILabel!
    
    //Label for the countdown. Label text will change each second.
    @IBOutlet var countdownLabel: UILabel!
    
    //Total Path Length for the first ten seconds
    @IBOutlet var totalPathLengthFirstTenSeconds: UILabel!
    
    //Total path length will be displayed at the end of the timer.
    @IBOutlet var totalPathLength: UILabel!
    
    //Creating an instance of motion manager. Only ONE should be created.
    var motionManager: CMMotionManager!
    
    //Variables to store data of accelerometers: previous and current to calculate distance between them.
    var currentX:  Double = 0.0
    var currentY:  Double = 0.0
    var previousX: Double = 0.0
    var previousY: Double = 0.0
    var totalPath: Double = 0.0
    var totalPathFirstTenSecondsVal: Double = 0.0
   
    //Variable to store data
    var data: String = " "
    var dataFirst: String = " "
    
    //Variables for the X-Y graph plotting
    
    //First Quadrant Variables
    var highestXFirstQuad: Double = 0.0
    var highestYFirstQuad: Double = 0.0
    
    //Second Quadrant Variables
    var highestXSecondQuad: Double = 0.0
    var highestYSecondQuad: Double = 0.0
    
    //Third Quadrant Variables
    var highestXThirdQuad: Double = 0.0
    var highestYThirdQuad: Double = 0.0
    
    //Fourth Quadrant Variables
    var highestXFourthQuad: Double = 0.0
    var highestYFourthQuad: Double = 0.0
    
    //Variables to store the distance between quadrants.
    var maxLength1: Double = 0.0
    var maxLength2: Double = 0.0
    var maxLength3: Double = 0.0
    //The farthest distance from a point to a point in any other quadrant.
    var finalMaxLength: Double = 0.0
    
    //Variables for the timer
    var seconds = 20
    var timer = NSTimer()
    var counting = true;
    
    
    //View load method
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Creating instance of Motion Manager
        motionManager = CMMotionManager()
        
        //Setting interval for data update to 0.2 seconds.
        motionManager.accelerometerUpdateInterval = 0.2
    }
    
    //Method that is going to be executed when user clicks on the start button
    @IBAction func startTimer(sender: UIButton) {
        //Clearing out previous time.
        timer.invalidate()
        
        //Calling to reset values
        resetValues()
        
        //Start Recording Data
        motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue()!) {
            (accelerometerData: CMAccelerometerData?, NSError) -> Void in
            self.processData(accelerometerData!.acceleration)
            if(NSError != nil) { print("\(NSError)") }
        }
        
        //Repeating the method using the NSTimer.
        timer = NSTimer.scheduledTimerWithTimeInterval(
            1,
            target: self,
            selector: #selector(ViewController.countdown),
            //selector: Selector("countdown"),
            userInfo: nil,
            repeats: true)
        
        //Calling the countdown() method
        countdown()
      
    }
    
    //Method that is going to be executed to reset values in accelerometer and other custom variables
    func resetValues() {
        currentX = 0.0
        currentY = 0.0
        previousX = 0.0
        previousY = 0.0
        totalPath = 0.0
        totalPathFirstTenSecondsVal = 0.0
        seconds = 20;
        counting = true;
        data = ""
        dataFirst = ""
        self.totalPathLength.text = " "
        self.peakLengthBox.text = " "
    }
    
    
    //Countdwon function that handles the timer
    func countdown(){
        self.countdownLabel.text = "\(seconds--)"
        if(seconds < 0) {
            counting = false;
            self.countdownLabel.text = "0"
            self.totalPathLength.text = "\(totalPath)"
            self.totalPathLengthFirstTenSeconds.text = "\(totalPathFirstTenSecondsVal)"
            self.peakLengthBox.text = "\(finalMaxLength)"
            motionManager.stopAccelerometerUpdates()
        }
    }

    
    //Function that is going to process data from accelerometer.
    func processData (accelerometer: CMAcceleration) {
        
        if (counting){
            //Updating the variable to rounded number to 3 decimal places
            currentX = Double(round(accelerometer.x * 1000000)/1000)
            currentY = Double(round(accelerometer.y * 1000000)/1000)
            
            //Converting into a string to write to a file.
            let tempX = "\(currentX)"
            let tempY = "\(currentY)"
            
            //Adding elements to a string
            data += " " + tempX + " " + tempY + "\n"
            if(seconds >= 10){
                dataFirst += " " + tempX + " " + tempY + "\n"
                totalPathFirstTenSecondsVal += pointDistance(previousX, x2: currentX, y1: previousY, y2: currentY)
            }
           
            //Adding the x and y values according to their quadrants.
            if(currentX > 0 && currentY > 0){
                //1st quadrant
                if(currentX > highestXFirstQuad) {
                    highestXFirstQuad = currentX
                }
                if(currentY > highestYFirstQuad){
                    highestYFirstQuad = currentY
                }
            }else if (currentX < 0 && currentY > 0){
                //2nd quadrant
                if(currentX < highestXSecondQuad) {
                    highestXSecondQuad = currentX
                }
                if(currentY > highestYSecondQuad){
                    highestYSecondQuad = currentY
                }
            }else if(currentX < 0 && currentY < 0){
                //3rd quadrant
                if(currentX < highestXThirdQuad) {
                    highestXThirdQuad = currentX
                }
                if(currentY < highestYThirdQuad){
                    highestYThirdQuad = currentY
                }
            }else {
                //4th quadrant
                if(currentX > highestXFourthQuad) {
                    highestXFourthQuad = currentX
                }
                if(currentY < highestYFourthQuad){
                    highestYFourthQuad = currentY
                }
            }
            
            //Calculating the total path length
            //totalPath += Double(round(sqrt(pow(previousX - currentX, 2) + pow (previousY - currentY, 2)) * 100) / 100)
            totalPath += pointDistance(previousX, x2: currentX, y1: previousY, y2: currentY)
            
            //Calculating the distance between one point in a quadrant to other quadrants' highest point.
            maxLength1 = pointDistance(highestXFirstQuad, x2: highestXSecondQuad, y1: highestYFirstQuad, y2: highestYSecondQuad)
            maxLength2 = pointDistance(highestXFirstQuad, x2: highestXThirdQuad, y1: highestYFirstQuad, y2: highestYThirdQuad)
            maxLength3 = pointDistance(highestXFirstQuad, x2: highestXFourthQuad, y1: highestYThirdQuad, y2: highestYFourthQuad)
            
            //FinalMaxLength is the farthest distance from one quadrant to other three quadrants.
            finalMaxLength = max(max(maxLength1, maxLength2), maxLength3)

        }
        previousX = Double(round(accelerometer.x * 1000000)/1000)
        previousY = Double(round(accelerometer.y * 1000000)/1000)
    }
   
    //Function to calculate the distance between two points
    func pointDistance(x1:Double, x2:Double, y1:Double, y2:Double)->Double {
        let distance = Double(round(sqrt(pow(x1 - x2, 2) + pow (y1 - y2, 2)) * 100) / 100)
        return distance
    }
    
    //this is the file. we will write to and read from it
    let fileName = "data.txt"
    let firstFileName = "data10.txt"
    let directories = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
    
    //Function to create a test  that contains data from the accelerometer.
    func createTestFile(data: String) {
        
        //Variables for the location where the files are going to be saved.
        guard let directory = directories.first else { return }
        let fileSaveLocation = NSURL(fileURLWithPath: fileName , relativeToURL: directory)
        let fileSaveLocation1 = NSURL(fileURLWithPath: firstFileName , relativeToURL: directory)

        do {
            //writing the data to the different text files.
            try data.writeToURL(fileSaveLocation, atomically: true, encoding: NSUTF8StringEncoding)
            try dataFirst.writeToURL(fileSaveLocation1, atomically: true, encoding: NSUTF8StringEncoding)
        }catch {}
        //print("*** file saved to path: \(fileSaveLocation)")
        
    }

    //Method that is going to be executed when user clicks on the mail button
    @IBAction func sendMail(sender: UIButton) {
        let mailComposeViewController = configureMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.presentViewController(mailComposeViewController, animated:true, completion: nil)
        }
    }
    
    //Method that is going to be executed when user clicks on the graph button
    @IBAction func graphData(sender: AnyObject) {
    }
    
    //Setting up the email.
    func configureMailComposeViewController() -> MFMailComposeViewController{
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = self
        
        //Constants for the email.
        let receipient = "ibalancefsc@gmail.com"
        let subject = "Data file for  and  ";
        //let message = data + "\n\nTotal Path Length" + "\(totalPathLength)" + "\n\nTotal Path length first 10: " + "\(totalPathLengthFirstTenSeconds)" + "Peak Length: " + "\(finalMaxLength)"

        //Setting the constants in the email.
        mailComposer.setToRecipients([receipient])
        mailComposer.setSubject(subject)
        mailComposer.setMessageBody(data, isHTML: false)
      
        createTestFile(data)
        
        let directory = directories.first
        
        //File Location for the text file that contains data for the entire 20 seconds.
        let fileLocationForLoad = NSURL(fileURLWithPath: fileName, relativeToURL: directory)
        let urlString: String = fileLocationForLoad.path!
        
        //File location for the text file that contains data for the first 10 seconds.
        let fileLocationForLoad1 = NSURL(fileURLWithPath: firstFileName, relativeToURL: directory)
        let urlString1: String = fileLocationForLoad1.path!
        
        
        //Adding the attachment/data file to the email.
            if let fileData = NSData(contentsOfFile: urlString){
                mailComposer.addAttachmentData(fileData, mimeType: "text/plain", fileName: fileName)
            }
        
            if let fileData1 = NSData(contentsOfFile: urlString1){
                mailComposer.addAttachmentData(fileData1, mimeType: "text/plain", fileName: firstFileName)
            }
        
        //Priting variables for testing purposes
        print(highestXFirstQuad)
        print("\n\n\n")
        print(highestYFirstQuad)
        print("\n\n\n")
        print(highestXSecondQuad)
        print("\n\n\n")
        print(highestYSecondQuad)
        print("\n\n\n")
        print(highestXThirdQuad)
        print("\n\n\n")
        print(highestYThirdQuad)
        print("\n\n\n")
        print(highestXFourthQuad)
        print("\n\n\n")
        print(highestYFourthQuad)
        
        print("\n\n\n")
        print(maxLength1)
        print("\n\n\n")
        print(maxLength2)
        print("\n\n\n")
        print(maxLength3)
        print("\n\n\n")
        print(finalMaxLength)
        
        return mailComposer
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

