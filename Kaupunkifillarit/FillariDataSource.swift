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
    
    let API = NSURL(string: "http://kaupunkifillarit.fi/api/stations")
    var delegate: FillariDataSourceDelegate?
    var stations = Array<Station>()
    
    @objc func loadData() {
        print("Reloading station data...")
        let task = NSURLSession.sharedSession().dataTaskWithURL(API!) {
            (data, response, error) -> Void in
            do {
                let obj = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as! NSDictionary
                let stations = obj["bikeRentalStations"]
                if stations is NSArray {
                    self.stations = (stations as! NSArray).map { Station.parse($0) }.filter { $0 != nil }.map { $0! }
                    self.delegate?.updatedStationData(self.stations)
                }
            } catch let err {
                print(err)
            }
            
        }
        
        task.resume()
    }
    
    func startRefresh() {
        NSTimer.scheduledTimerWithTimeInterval(60.0, target: self, selector: #selector(loadData), userInfo: nil, repeats: true).fire()
    }
    
    func nearestStation(location: CLLocation, borrowing: Bool) -> Station? {
        let distanceTo = distance(location)
        
        return stations.filter { borrowing ? $0.bikesAvailable > 0 : $0.spacesAvailable > 0 }.sort({ (station1, station2) -> Bool in
            distanceTo(station1) < distanceTo(station2)
        }).first
    }
    
}

func distance(location: CLLocation) -> (Station) -> Double {
    return {(station: Station) -> Double in
        return location.distanceFromLocation(CLLocation(latitude: station.lat, longitude: station.lon))
    }
}

protocol FillariDataSourceDelegate {
    
    func updatedStationData(stations: [Station])
    
}

struct Station {
    let spacesAvailable: Int
    let bikesAvailable: Int
    let id: String
    let lat: Double
    let lon: Double
    let name: String
    
    static func parse(obj: AnyObject) -> Station? {
        if obj is Dictionary<String, AnyObject> {
            if let spacesAvailable = obj["spacesAvailable"] as? Int,
                let bikesAvailable = obj["bikesAvailable"] as? Int,
                let id = obj["id"] as? String,
                let lat = obj["lat"] as? Double,
                let lon = obj["lon"] as? Double,
                let name = obj["name"] as? String {
                return Station(spacesAvailable: spacesAvailable, bikesAvailable: bikesAvailable, id: id, lat: lat, lon: lon, name: name)
            }
        }
        return nil
    }
}
