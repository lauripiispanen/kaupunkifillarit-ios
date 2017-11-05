//
//  FillariDataSource.swift
//  Kaupunkifillarit
//
//  Created by Lauri Piispanen on 06/05/16.
//  Copyright © 2016 Lauri Piispanen. All rights reserved.
//

import Foundation
import MapKit

class FillariDataSource {
    
    let API = URL(string: "https://kaupunkifillarit.fi/api/stations")
    var delegate: FillariDataSourceDelegate?
    var stations = Array<Station>()
    var timer:Timer?
    
    @objc func loadData() {
        print("Reloading station data...")
        let task = URLSession.shared.dataTask(with: API!, completionHandler: {
            (data, response, error) -> Void in
            if data == nil {
                return
            }
            do {
                let obj = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSDictionary
                let stations = obj["bikeRentalStations"]
                if stations is NSArray {
                    self.stations = (stations as! NSArray).map { Station.parse($0 as AnyObject) }.filter { $0 != nil }.map { $0! }
                    self.delegate?.updatedStationData(self.stations)
                }
            } catch let err {
                print(err)
            }
            
        }) 
        
        task.resume()
    }
    
    func startRefresh() {
        print("starting station data refresh job")
        timer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(loadData), userInfo: nil, repeats: true)
        timer?.fire()
    }

    func stopRefresh() {
        print("stopped station data refresh job")
        timer?.invalidate()
    }
    
}

protocol FillariDataSourceDelegate {
    
    func updatedStationData(_ stations: [Station])
    
}

struct Station {
    let bikesAvailable: Int
    let id: String
    let lat: Double
    let lon: Double
    let name: String
    
    static func parse(_ obj: AnyObject) -> Station? {
        if obj is Dictionary<String, AnyObject> {
            if let bikesAvailable = obj["bikesAvailable"] as? Int,
                let id = obj["id"] as? String,
                let lat = obj["lat"] as? Double,
                let lon = obj["lon"] as? Double,
                let name = obj["name"] as? String {
                return Station(bikesAvailable: bikesAvailable, id: id, lat: lat, lon: lon, name: name)
            }
        }
        return nil
    }
}
