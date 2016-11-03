//
//  Device.swift
//  Pods
//
//  Created by Adrian Apodaca on 24/10/16.
//
//

import Foundation
import Alamofire

public struct Device {
    
    static var id: Int?
    var uid: String
    var name: String?
    var os: String
    var osVersion: String
    var device: String
    var manufacturer: String
    var model: String
    var appVersion: String?
    var appVersionCode: String?
    var createdAt: Date?
    var updatedAt: Date?
    var active: Bool
    var lastConnectionStart: Date?
    var lastConnectionEnd: Date?
    var pushId: String?
    var badge: Int
    var languageCode: String?
    var countyCode: String?
    var regionCode: String?
    var currencyCode: String?
    
    // MARK: - init
    
    //
    // Init device. If stored get static data from Defaults, else get uid
    //
    public init() {
        let data: Data? = UserDefaults.standard.data(forKey: "deviceJsonData")
        let stored: Dictionary? = ConManager.json(data)
        print("stored: \(stored)")
        
        if let id = stored?["id"] as? Int {
            Device.id = id
        }
        
        if let uid = stored?["uid"] as? String {
            self.uid = uid
        } else {
            if let uuid = UIDevice.current.identifierForVendor?.uuidString {
                self.uid = uuid
            } else {
                self.uid = UUID().uuidString
            }
        }
        
        if let active = stored?["active"] as? Int {
            self.active = active == 1
        } else {
            self.active = true
        }
        
        if let badge = stored?["badge"] as? Int {
            self.badge = badge
        } else {
            self.badge = 0
        }
        
        if let pushId = stored?["pushId"] as? String {
            self.pushId = pushId
        }
        
        var formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        if let createdAt = stored?["createdAt"] as? String {
            self.createdAt = formatter.date(from: createdAt)
        }
        
        if let updatedAt = stored?["updatedAt"] as? String {
            self.updatedAt = formatter.date(from: updatedAt)
        }
        
        if let lastConnectionStart = stored?["lastConnectionStart"] as? String {
            self.lastConnectionStart = formatter.date(from: lastConnectionStart)
        }
        
        if let lastConnectionEnd = stored?["lastConnectionEnd"] as? String {
            self.lastConnectionEnd = formatter.date(from: lastConnectionEnd)
        }
        
        if let data: Data = UserDefaults.standard.data(forKey: "deviceJsonData"), let stored:Dictionary? = ConManager.json(data) {
            print("stored: \(stored)")
        }
        
        name = UIDevice.current.name
        os = "iOS"
        osVersion = UIDevice.current.systemVersion
        device = UIDevice.current.model
        manufacturer = "Apple"
        model = UIDevice.current.localizedModel
        appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        appVersionCode = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        languageCode = Locale.current.languageCode
        countyCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String
        regionCode = Locale.current.regionCode
        currencyCode = Locale.current.currencyCode
    }
    
    // MARK: - private
    
    //
    // create or update in server
    //
    private func storeInServer() {
        let params: Params = self.parameters()
        var path: String
        var method: HTTPMethod
        if let deviceId = Device.id {
            method = .put
            path = "\(url_devices())/\(deviceId)"
        } else {
            method = .post
            path = url_devices()
        }
        
        ConManager.connection(path,
                              params: params,
                              method: method,
                              encoding: JSONEncoding.default,
                              success: { (responseData) in
                                if let data: Data = responseData {
                                    self.store(data)
                                }
        })
    }
    
    //
    // convert Device to Parameters
    //
    private func parameters() -> Parameters {
        var response: Parameters = Parameters()
        if let name = self.name {
            response["name"] = name
        }
        response["uid"] = uid
        response["active"] = active
        
        if let pushId = self.pushId {
            response["pushId"] = pushId
        }
        response["badge"] = badge
        response["os"] = os
        response["osVersion"] = osVersion
        response["device"] = device
        response["manufacturer"] = manufacturer
        response["model"] = model
        
        if let appVersion = self.appVersion {
            response["appVersion"] = appVersion
        }
        if let appVersionCode = self.appVersionCode {
            response["appVersionCode"] = appVersionCode
        }
        if let languageCode = self.languageCode {
            response["languageCode"] = languageCode
        }
        if let countyCode = self.countyCode {
            response["countyCode"] = countyCode
        }
        if let regionCode = self.regionCode {
            response["regionCode"] = regionCode
        }
        if let currencyCode = self.currencyCode {
            response["currencyCode"] = currencyCode
        }
        return response
    }
    
    private func store(_ data: Data?) {
        print("JSON: \(ConManager.json(data))")
        if let id = ConManager.json(data)["id"] as? Int {
            let defs = UserDefaults.standard
            defs.set(data, forKey: "deviceJsonData")
            defs.synchronize()
        } else {
            print("Error storing device Json")
        }
    }
    
    // MARK: - public static
    
    public static func setDeviceActive(_ active: Bool) {
        var device = Device()
        device.active = active
        device.badge = 0
        device.storeInServer()
    }
    
    public static func setPushId(_ pushId: String) {
        var device = Device()
        device.pushId = pushId
        device.storeInServer()
    }
}
