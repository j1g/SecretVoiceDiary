//
//  InterfaceController.swift
//  SecretVoiceDiary WatchKit Extension
//
//  Created by SDT2 on 2015. 10. 29..
//  Copyright © 2015년 tacademy. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    @IBOutlet var tableView: WKInterfaceTable!

      var recordFiles : [String] = []
    // 목록: 배열 X 디렉토리 가져오기

    func refreshRecordingList() {
        recordFiles.removeAll(keepCapacity: false)
        
        let docPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0]
        
        let fs = NSFileManager.defaultManager()
        let files = try! fs.contentsOfDirectoryAtPath(docPath)
        
        for file in files {
            // 확장자
            if file.hasSuffix(".wav") {
                recordFiles.append(file)
            }
        }
    }

    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        let path = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0]
        var url = NSURL(fileURLWithPath: path)
        url = url.URLByAppendingPathComponent(recordFiles[rowIndex])
        self.presentMediaPlayerControllerWithURL(url,
            options: [WKMediaPlayerControllerOptionsAutoplayKey: true],
            completion: { (didPlayToEnd : Bool,
                endTime : NSTimeInterval,
                error : NSError?) -> Void in
                if let anErrorOccurred = error {
                    // Handle the error.
                }
                // Perform other tasks
        })
    }
    @IBAction func startRecording() {
        var url = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.com.tacademy.ios.SecretVoiceDiary")!
////        let path = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0]
//        var url = NSURL(fileURLWithPath: path)
        let formatter = NSDateFormatter()
        formatter.dateFormat = "YYYY.MM.dd.hh.mm.DD"
        let fileName = String(format: "%@.wav", formatter.stringFromDate(NSDate()))
        url = url.URLByAppendingPathComponent(fileName)

        self.presentAudioRecorderControllerWithOutputURL(url, preset: WKAudioRecorderPreset.NarrowBandSpeech, options: [WKAudioRecorderControllerOptionsMaximumDurationKey: NSNumber(integer: 30)]) { (didSave, error) -> Void in
            if let error = error {
                print("error: \(error)")
                return
            }
            
            if didSave {  
                print("saved!")
                self.recordFiles.append(fileName)
                self.loadTableData()
            }  
        }
    }
    
    func loadTableData() {
        // Set total row count. Remember our identifier was Cell
        refreshRecordingList()
        tableView.setNumberOfRows(recordFiles.count, withRowType: "Cell")
        
        var i = 0 // Used to count each item
        for item in recordFiles { // Loop over each item in tableData
            let row = tableView.rowControllerAtIndex(i) as! TableRowObject
            row.timeLabel.setText(item) // Set the row text to the corresponding item
            i++ // Move onto the next item
        }
        
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        loadTableData()
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
