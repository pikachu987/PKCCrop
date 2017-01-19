//
//  PKCCheck.swift
//  PKCCheck
//
//  Created by guanho on 2017. 1. 9..
//  Copyright © 2017년 guanho. All rights reserved.
//

//pikchu987
//https://github.com/pikachu987

import Foundation
import UIKit
import AVFoundation
import CoreAudio
import Photos


//pkccheck delegate
@objc public protocol PKCCheckDelegate: NSObjectProtocol {
    @objc optional func pkcCheckPlugIn()
    @objc optional func pkcCeckPlugOut()
    
    @objc optional func pkcCheckAudioPermissionDenied()
    @objc optional func pkcCheckAudioPermissionGranted()
    @objc optional func pkcCheckAudioPermissionUndetermined()
    
    @objc optional func pkcCheckCameraPermissionDenied()
    @objc optional func pkcCheckCameraPermissionGranted()
    @objc optional func pkcCheckCameraPermissionUndetermined()
    
    @objc optional func pkcCheckPhotoPermissionDenied()
    @objc optional func pkcCheckPhotoPermissionGranted()
    @objc optional func pkcCheckPhotoPermissionUndetermined()
    
    @objc optional func pkcCheckDecibelErr(_ error: Error)
    @objc optional func pkcCheckDecibel(_ level: CGFloat, average: CGFloat, degree: CGFloat, radian: CGFloat)
}



open class PKCCheck {
    // MARK: - properties
    open weak var delegate: PKCCheckDelegate?
    
    open var maxDecibelDegree: CGFloat = 360
    open var minDecibelDegree: CGFloat = 0
    
    fileprivate var secondPerDecibelCheck = 0
    fileprivate var recorder: AVAudioRecorder!
    fileprivate var levelTimer = Timer()
    fileprivate var lowPassResults: Double = 0.0
    fileprivate var decibelArray = [CGFloat]()
    
    public init() {
        
    }
    
    
    
    
    
    
    
    // MARK: - listener
    
    
    //plug in/out check
    dynamic fileprivate func audioRouteChangeListener(_ notification:Notification) {
        let audioRouteChangeReason = notification.userInfo![AVAudioSessionRouteChangeReasonKey] as! UInt
        
        switch audioRouteChangeReason {
        case AVAudioSessionRouteChangeReason.newDeviceAvailable.rawValue:
            self.delegate?.pkcCheckPlugIn?()
        case AVAudioSessionRouteChangeReason.oldDeviceUnavailable.rawValue:
            self.delegate?.pkcCeckPlugOut?()
        default:
            break
        }
    }
    
    
    
    //decibel check
    dynamic fileprivate func levelTimerListener() {
        recorder.updateMeters()
        var level : CGFloat!
        let minDecibels: CGFloat = -80
        let decibels = recorder.averagePower(forChannel: 0)
        if decibels < Float(minDecibels)
        {
            level = 0
        }
        else if decibels >= 0
        {
            level = 1
        }
        else
        {
            let root: Float = 2
            let minAmp = powf(10, 0.05 * Float(minDecibels))
            let inverseAmpRange: Float = 1 / (1 - minAmp)
            let amp = powf(10, 0.05 * decibels)
            let adjAmp: Float = (amp - minAmp) * inverseAmpRange
            level = CGFloat(powf(adjAmp, 1/root))
        }
        level = level * self.maxDecibelDegree + self.minDecibelDegree
        let degree: CGFloat = level/(self.maxDecibelDegree - self.minDecibelDegree)
        let radian: CGFloat = level*CGFloat(M_PI)/180
        
        if self.decibelArray.count >= self.secondPerDecibelCheck
        {
            _ = self.decibelArray.removeFirst()
        }
        self.decibelArray.append(level)
        
        self.delegate?.pkcCheckDecibel?(
            level,
            average: self.decibelArray.average,
            degree: degree, radian: radian
        )
    }
    
    
}






// MARK: - check
extension PKCCheck{
    
    //device app setting
    open func permissionsChange(_ bundleIdentifier: String? = Bundle.main.bundleIdentifier){
        guard bundleIdentifier != nil else {
            return
        }
        let url = NSURL(string: "\(UIApplicationOpenSettingsURLString)\(bundleIdentifier!)")
        if url == nil{
            return
        }
        
        if #available(iOS 8.0, *) {
            UIApplication.shared.openURL(url as! URL)
        }else{
            UIApplication.shared.open(url as! URL, options: [:], completionHandler: nil)
        }
    }
    
    
    //audio access check
    open func audioAccessCheck(){
        if AVAudioSession.sharedInstance().recordPermission() == .denied
        {
            self.delegate?.pkcCheckAudioPermissionDenied?()
        }
        else if AVAudioSession.sharedInstance().recordPermission() == .granted
        {
            self.delegate?.pkcCheckAudioPermissionGranted?()
        }
        else if AVAudioSession.sharedInstance().recordPermission() == .undetermined
        {
            self.delegate?.pkcCheckAudioPermissionUndetermined?()
            
            AVAudioSession.sharedInstance().requestRecordPermission({
                (permission) in
                if permission
                {
                    self.delegate?.pkcCheckAudioPermissionGranted?()
                }
                else
                {
                    self.delegate?.pkcCheckAudioPermissionDenied?()
                }
            })
        }
    }
    
    
    
    //camera access check
    open func cameraAccessCheck(){
        if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) == .authorized
        {
            self.delegate?.pkcCheckCameraPermissionGranted?()
        }
        else if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) == .denied
        {
            self.delegate?.pkcCheckCameraPermissionDenied?()
        }
        else
        {
            self.delegate?.pkcCheckCameraPermissionUndetermined?()
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo){
                (isAccess) in
                if isAccess
                {
                    self.delegate?.pkcCheckCameraPermissionGranted?()
                }
                else
                {
                    self.delegate?.pkcCheckCameraPermissionDenied?()
                }
            }
        }
    }
    
    //photo access check
    open func photoAccessCheck(){
        if PHPhotoLibrary.authorizationStatus() == .authorized
        {
            self.delegate?.pkcCheckPhotoPermissionGranted?()
        }
        else if PHPhotoLibrary.authorizationStatus() == .denied
        {
            self.delegate?.pkcCheckPhotoPermissionDenied?()
        }
        else
        {
            self.delegate?.pkcCheckPhotoPermissionUndetermined?()
            PHPhotoLibrary.requestAuthorization() {
                (status) in
                switch status {
                case .authorized:
                    self.delegate?.pkcCheckPhotoPermissionGranted?()
                    break
                default:
                    self.delegate?.pkcCheckPhotoPermissionDenied?()
                }
            }
        }
    }
    
    
    //plug in/out check
    open func plugAccessCheck(){
        let currentRoute = AVAudioSession.sharedInstance().currentRoute
        if currentRoute.outputs.count != 0 {
            for description in currentRoute.outputs {
                if description.portType == AVAudioSessionPortHeadphones
                {
                    self.delegate?.pkcCheckPlugIn?()
                }
                else
                {
                    self.delegate?.pkcCeckPlugOut?()
                }
            }
        }
        
        NotificationCenter.default.removeObserver(
            self,
            name: NSNotification.Name.AVAudioSessionRouteChange,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.audioRouteChangeListener(_:)),
            name: NSNotification.Name.AVAudioSessionRouteChange,
            object: nil
        )
    }
}



// MARK: - decibel
extension PKCCheck{
    
    //decibel start
    open func decibelStart(_ secondPerDecibelCheck: Int = 50, _ cafPath: String = "recordTest.caf"){
        if self.levelTimer.isValid
        {
            return
        }
        
        self.secondPerDecibelCheck = secondPerDecibelCheck
        
        do{
            let audioSession:AVAudioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioSession.setActive(true)
            let documents: AnyObject = NSSearchPathForDirectoriesInDomains(
                FileManager.SearchPathDirectory.documentDirectory,
                FileManager.SearchPathDomainMask.userDomainMask,
                true
                )[0] as AnyObject
            
            let str : String =  documents.appendingPathComponent(cafPath)
            let url = NSURL.fileURL(withPath: str)
            
            let recordSettings: [NSObject : AnyObject] =
                [
                    AVFormatIDKey as NSObject:kAudioFormatAppleIMA4 as AnyObject,
                    AVSampleRateKey as NSObject:44100 as AnyObject,
                    AVNumberOfChannelsKey as NSObject:1 as AnyObject,
                    AVLinearPCMBitDepthKey as NSObject:16 as AnyObject,
                    AVLinearPCMIsBigEndianKey as NSObject:false as AnyObject,
                    AVLinearPCMIsFloatKey as NSObject:false as AnyObject
            ]
            
            self.recorder = try AVAudioRecorder(url:url, settings: recordSettings as! [String : AnyObject])
            self.recorder.prepareToRecord()
            self.recorder.isMeteringEnabled = true
            self.recorder.record()
            
            self.levelTimer = Timer.scheduledTimer(
                timeInterval: Double(1/secondPerDecibelCheck),
                target: self,
                selector: #selector(self.levelTimerListener),
                userInfo: nil,
                repeats: true
                
            )
        }catch let err{
            self.delegate?.pkcCheckDecibelErr?(err)
        }
    }
    
    
    
    
    
    
    //decibel stop
    open func decibelStop(){
        self.levelTimer.invalidate()
    }
}






extension Array where Element: FloatingPoint {
    fileprivate var total: Element {
        return reduce(0, +)
    }
    fileprivate var average: Element {
        return isEmpty ? 0 : total / Element(count)
    }
}
