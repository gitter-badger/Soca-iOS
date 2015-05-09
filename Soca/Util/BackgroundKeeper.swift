//
//  BackgroundKeeper.swift
//  soca
//
//  Created by Zhuhao Wang on 3/2/15.
//  Copyright (c) 2015 Zhuhao Wang. All rights reserved.
//

import Foundation
import AVFoundation
import SocaCore

class BackgroundKeeper {
    unowned let application :UIApplication
    var backgroundTask :UIBackgroundTaskIdentifier?
    let blankAudioData :NSData
    let player :AVAudioPlayer
    
    init(application: UIApplication) {
        self.application = application
        let path = NSBundle.mainBundle().pathForResource("blank", ofType: "mp3")!
        blankAudioData = NSData(contentsOfFile: path)!
        let audioSession = AVAudioSession.sharedInstance()
        audioSession.setCategory(AVAudioSessionCategoryPlayback, withOptions: AVAudioSessionCategoryOptions.MixWithOthers, error: nil)
        player = AVAudioPlayer(data: blankAudioData, fileTypeHint: AVFileTypeMPEGLayer3, error: nil)
    }
    
    func keepRunning() {
        // begin background task
        backgroundTask = application.beginBackgroundTaskWithExpirationHandler(){}
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            [unowned self] in
            var remainingTime :NSTimeInterval = 0
            while true {
                remainingTime = self.application.backgroundTimeRemaining
                if remainingTime < 30 {
                    self.player.play()
                }
                NSThread.sleepForTimeInterval(7)
            }
        }
    }
}