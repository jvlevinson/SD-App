//
//  SDNDataConnector.swift
//  Smart Drinks & Nutrition
//
//  Created by Phanidhar Mothukuri on 9/24/17.
//  Copyright © 2017 TechSoft,Inc. All rights reserved.
//

import Foundation

class SDNGlobal: NSObject {
    
    @objc static let sdnInstance = SDNGlobal()
    private let urlHash = "299af7d18e3d7eb92d74d9e2c233ef62"
    private let baseURL = "https://api.navixy.com"
    @objc var deviceId = 0
    @objc var devicesJson = [String:Any]()
    @objc var trackingJson = [String:Any]()
    @objc var apiCalls = [String:String]()
    
    @objc var coordinates = [[String:Any]]()
    
    private override init() {
        super.init()
    }
    
    
    //https://api.navixy.com/v2/tracker/list/?hash=f4bb7c3f4c730540b4d90b2cf2499ed9
    //https://api.navixy.com/v2/tracker/get_states/?trackers=[228592]&hash=f4bb7c3f4c730540b4d90b2cf2499ed9
    
    
    @objc func populateURLs(){
        self.apiCalls = ["DeviceId": "/v2/tracker/list/?hash=",
            "Tracking": "/v2/tracker/get_states/?"]
    }
    
    @objc func updateDeviceIdURL(withURLHash:String){
        apiCalls["DeviceId"] = "/v2/tracker/list/?hash=\(withURLHash)"
    }
    @objc func updateTrackingURL(withTrackers:String,withURLHash:String){
        apiCalls["Tracking"] = "/v2/tracker/get_states/?trackers=[\(withTrackers)]&hash=\(withURLHash)"
    }
    
    func getDevices(completionHandler:@escaping(Bool?, NSError?) -> Void){
        self.updateDeviceIdURL(withURLHash: self.urlHash)
        self.getPayload(apiString:"DeviceId"){(apiSuccess,error) -> Void in completionHandler(apiSuccess,error)}
        
        }
    

    func getLocation(withTrackers:String, completionHandler:@escaping(Bool?, NSError?) -> Void){
        self.updateTrackingURL(withTrackers:withTrackers,withURLHash:self.urlHash)
        self.getPayload(apiString:"Tracking"){(apiSuccess,error) -> Void in completionHandler(apiSuccess,error)}
        
    }
    
    
    func getPayload(apiString:String,completionHandler: @escaping(Bool?,NSError?) -> Void){
        let uri = apiCalls[apiString]
        let url = URL(string: baseURL+uri!)
        var request = URLRequest(url:url!)
        request.httpMethod = "GET"
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request, completionHandler: {(data,response,error) in
            if let tempData = data{
                do{
                    if apiString == "DeviceId"{
                        self.devicesJson = try JSONSerialization.jsonObject(with: tempData, options: .allowFragments) as! [String:Any]
                    } else if apiString == "Tracking"{
                        self.trackingJson = try JSONSerialization.jsonObject(with: tempData, options: .allowFragments) as! [String:Any]
                    }
                    completionHandler(true,nil)
                }
                catch let e as NSError{
                    completionHandler(false, e)
                }
            }
        })
        task.resume()
        
    }
}
