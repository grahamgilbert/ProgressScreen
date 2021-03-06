//
//  AppDelegate.swift
//  ProgressScreen
//
//  The MIT License (MIT)
//
//Copyright (c) 2015 Jason Tratta
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//SOFTWARE.
//


import Cocoa
import WebKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet var webView: WebView!
    @IBOutlet var feedbackLabel: NSTextField!
    @IBOutlet var progressBar: NSProgressIndicator!
    @IBOutlet weak var theWindow: NSWindow!
    @IBOutlet weak var quitButton: NSButton!
    var theTimer = NSTimer()
    
    var quarter = false
    var half = false
    var threeQuarter = false
    var end = false
    var numberOfPolices = 0
    dynamic var ready = NSNumber(bool: false)
    
    
    var configurations = NSMutableArray()
    
    
    // ************************************************************************************************************************
    // ************************************************************************************************************************
    // Cutomization Variables
    
    var useWayPointMessages = false
    var estimatedCompletionTime = NSTimeInterval(1800)   //Change 1800 to a time in seconds your installation process averages.
    
    // Determine which installer packages should happen in what order in your installation
    //This will update the progres bar for a more accurate time estimate.
    var quarterProgress = "defaultPackageName"
    var halfProgress = "defaultPackageName"
    var threeQuartersProgress = "defaultPackageName"
    var lastPackage = "defaultPackageName"
    
    // ************************************************************************************************************************
    // ************************************************************************************************************************




    
    

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        theWindow.backgroundColor = NSColor.whiteColor()
        theWindow.collectionBehavior = NSWindowCollectionBehavior.FullScreenPrimary
        theWindow.toggleFullScreen(self)
        
        let app = NSApplication.sharedApplication() as! PSApplication
        configurations = app.configurations
    
        
        self.addObserver(self, forKeyPath: "configurations", options:.New, context: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"changeBuildTime:", name:PSBuildTimeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"changeHTMLURL:", name:PSURLChange, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"changeCurrentTime:", name:PSCurrentTimeChange, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"adjustFullScreen:", name:PSFullScreen, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"hideQuitButton:", name:PSHideQuit, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"enableWayPointMethod:", name:PSHWayPointMethod, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"setWaypointOne:", name:PSHWayPointOne, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"setWaypointTwo:", name:PSHWayPointTwo, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"setWaypointThree:", name:PSHWayPointThree, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"setWaypointFour:", name:PSHWayPointFour, object: nil)
        
        progressBar.hidden = false
        progressBar.minValue = 0
        progressBar.maxValue = estimatedCompletionTime
        progressBar.startAnimation(self)
        
        
        loadWebPage()
        progress()
        
        
    }


    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        
        debugPrint(keyPath)
        
        return super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        
    }
    
    //MARK: Scripting Methods
    
    
    func changeBuildTime(note: NSNotification) {
        
        
        let object = note.object as! ConfigurationSettings
    
        estimatedCompletionTime = NSTimeInterval(object.buildTime)
        progressBar.maxValue = estimatedCompletionTime
        
    }
    
    
    func changeHTMLURL(note: NSNotification)  {
        debugPrint("Changing HTML")
        let object = note.object as! ConfigurationSettings
         let newURL = NSURL(string: object.htmlLocation)
          webView.mainFrame.loadRequest(NSURLRequest(URL: newURL!))
        
    }
    
    func changeCurrentTime(note: NSNotification) {
        
        let object = note.object as! ConfigurationSettings
        progressBar.doubleValue = object.currentTime.doubleValue
        
    }

    func adjustFullScreen(note: NSNotification) {
     
        let object = note.object as! ConfigurationSettings
        let screenBool = object.fullscreen
        

        
        if screenBool == true {
            
            if inFullScreenMode() == false {
                theWindow.toggleFullScreen(self) }
            
        } else {
            
            if inFullScreenMode() == true {
                theWindow.toggleFullScreen(self) }

            
        }
        
        
    }
    
    
    func inFullScreenMode() -> Bool {
        
        
     let options = NSApplication.sharedApplication().presentationOptions
    
        if options == NSApplicationPresentationOptions.FullScreen {
            
         return true
            
        }
        
        return false
    }
    
    
    
    
    func hideQuitButton(note: NSNotification) {
        
        let object = note.object as! ConfigurationSettings
        let quitBool = object.hideQuitButton
        
        if quitBool == true {
            
           quitButton.hidden = true
            
        }
        
        else if quitBool == false {
           
            quitButton.hidden = false
            
        }
        
        
    }
    
    //Set the WayPoints from Scripting 
    func enableWayPointMethod(note: NSNotification) {
        
        let object = note.object as! ConfigurationSettings
        useWayPointMessages = object.useWayPointMethod
        
    }
    
    
    func setWaypointOne(note: NSNotification) {
        
        let object = note.object as! ConfigurationSettings
        quarterProgress = object.wayPointOne
        
    }
    
    func setWaypointTwo(note: NSNotification) {
        
        let object = note.object as! ConfigurationSettings
        halfProgress = object.wayPointTwo
        
    }
    
    func setWaypointThree(note: NSNotification) {
        
        let object = note.object as! ConfigurationSettings
        threeQuartersProgress = object.wayPointThree
        
    }
    
    func setWaypointFour(note: NSNotification) {
        
        let object = note.object as! ConfigurationSettings
        lastPackage = object.wayPointFour
        
    }
    
    //MARK: PG Methods
    
    func loadWebPage() {
        
        // Uncomment the line below to use a URL instead of embeded HTML
        // You must then comment out the other var thePath
        //let thePath = NSURL(string: "http://yourURLhere.com")
        
        let thePath = NSBundle.mainBundle().URLForResource("index", withExtension: "html")
        webView.mainFrame.loadRequest(NSURLRequest(URL: thePath!))
        
        
    }
    
 

    
    func progress() {
        
        let timerInterval = NSTimeInterval(0.05)
        theTimer = NSTimer.scheduledTimerWithTimeInterval(timerInterval, target: self, selector: "refreshData", userInfo: nil, repeats: true)
        theTimer.fire()
        
    }
    
    
    
    
    
    func refreshData() {
       
     
       //debugPrint(buildTime)
        //refresh the feedback label
        feedbackLabel.stringValue = logFileLastRecord()
        
        
        //setup the progressbar logic
        progressBar.controlTint = NSControlTint.BlueControlTint
        progressBar.incrementBy(0.05)
        
        
        if useWayPointMessages {
            
            updateWaypointMethod()
            
        }
        
    }
    
    

    
    func updateWaypointMethod() {
        
        let logString = logFileLastRecord()
        
        if (logString.rangeOfString("Successfully installed " + quarterProgress) != nil) {
            
            
            if quarter == false  {
                
                quarter = true
                progressBar.doubleValue = estimatedCompletionTime / 4 }
            
        }
        
        if (logString.rangeOfString("Successfully installed " + halfProgress) != nil) {
            
            
            if half == false  {
                
                half = true
                progressBar.doubleValue = estimatedCompletionTime / 2 }
            
        }
        
        
        if (logString.rangeOfString("Successfully installed " + threeQuartersProgress) != nil) {
            
            
            if threeQuarter == false  {
                
                threeQuarter = true
                progressBar.doubleValue = estimatedCompletionTime / 1.33 }
            
        }
        
        
        
        if (logString.rangeOfString("Successfully installed " + lastPackage) != nil) {
            
            
            if end == false  {
                
                //When the last package is installed, quit this application.
                end = true
                NSApplication.sharedApplication().terminate(self)
                
            }

        }
        
    }
    
    
    
    
    
    @IBAction func quitButton(sender: AnyObject) {
        
        NSApplication.sharedApplication().terminate(self)

    }
    
    
    
    func  logFileLastRecord() -> String {
        
        //This method reads the jamf.log and returns the last line edited into a easy to read format for the user feedback.
        
        if let log = NSData(contentsOfFile: "/private/var/log/jamf.log") {
            
            
            let logString =  NSString(data: log, encoding: NSUTF8StringEncoding)
     
            
            let theRange = logString?.rangeOfString("]:", options: NSStringCompareOptions.BackwardsSearch)
            let scanner = NSScanner(string: logString as! String)
            scanner.scanLocation = (theRange?.location)!
            
            let lineReturn = NSMutableCharacterSet.newlineCharacterSet()
            
            var logLine = NSString?()
            while scanner.scanUpToCharactersFromSet(lineReturn, intoString: &logLine),
                let logLine = logLine
                
            {
                //debugPrint("Log Line: \(logLine)")
                
            }
            
            
            let trimTimeStamp = logLine!.stringByReplacingOccurrencesOfString("]:", withString: "")
            let removedSlash =  trimTimeStamp.stringByReplacingOccurrencesOfString("\"", withString: "")
            let trimedWhiteSpace = removedSlash.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            
            //debugPrint("Trimmed")
            //debugPrint(trimedWhiteSpace)
            
            
            return trimedWhiteSpace
            
        } else {
            
            return "No jamf.log found." }
        
    }
    
    // End of Class

    override func indicesOfObjectsByEvaluatingObjectSpecifier(specifier: NSScriptObjectSpecifier) -> [NSNumber]? {
        
        
        debugPrint(specifier)
        
        return super.indicesOfObjectsByEvaluatingObjectSpecifier(specifier)
        
    }
    
    

    
    
    

}

