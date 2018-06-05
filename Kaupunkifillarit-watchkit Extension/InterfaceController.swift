//
//  InterfaceController.swift
//  Kaupunkifillarit-watchkit Extension
//
//  Created by Lauri Piispanen on 31/05/2018.
//  Copyright © 2018 Lauri Piispanen. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    @IBOutlet weak var stationsTable: WKInterfaceTable!

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        if let ctx = context as? StationSelectorContext {
            let sortedStations = Array(ctx.stations.sorted(by: { s1, s2 in
                return ctx.location.distance(from: stationToLoc(s1)) <
                       ctx.location.distance(from: stationToLoc(s2))
            }).prefix(10))

            if self.stationsTable.numberOfRows != sortedStations.count {
                self.stationsTable.setNumberOfRows(sortedStations.count, withRowType: "StationRowType")
            }

            (0 ..< self.stationsTable.numberOfRows).forEach { rowNum in
                if let row = stationsTable.rowController(at: rowNum) as? StationRowType {
                    if rowNum < sortedStations.count {
                        let station = sortedStations[rowNum]
                        row.setStation(station)
                        row.setDistanceFromLocation(ctx.location)
                    }
                }
            }
        }
    }
    
    override func contextForSegue(withIdentifier segueIdentifier: String,
                                  in table: WKInterfaceTable,
                                  rowIndex: Int) -> Any? {
        if let row = table.rowController(at: rowIndex) as? StationRowType,
           let station = row.station,
           let distance = row.distance {
            return StationMapContext(station, distance: distance)
        } else {
            return nil
        }
    }

}

class StationRowType: NSObject {

    @IBOutlet weak var bikeStandNameLabel: WKInterfaceLabel!
    @IBOutlet weak var numberOfBikesLabel: WKInterfaceLabel!
    @IBOutlet weak var distanceLabel: WKInterfaceLabel!
    var bikeStandName: String = " " {
        didSet {
            if bikeStandName != oldValue {
                self.bikeStandNameLabel.setText(bikeStandName)
            }
        }
    }
    var numberOfBikes: String = " " {
        didSet {
            if numberOfBikes != oldValue {
                self.numberOfBikesLabel.setText(numberOfBikes)
            }
        }
    }
    var numberOfBikesColor: UIColor? {
        didSet {
            if numberOfBikesColor != oldValue && numberOfBikesColor != nil {
                self.numberOfBikesLabel.setTextColor(numberOfBikesColor)
            }
        }
    }
    var distance: Int? {
        didSet {
            if distance != oldValue && distance != nil {
                self.distanceLabel.setText(String(distance!) + "m")
            }
        }
    }
    var station: Station?

    func setStation(_ station: Station) {
        self.station = station
        self.bikeStandName = station.name
        self.numberOfBikes = String(station.bikesAvailable)
        self.numberOfBikesColor = (
            station.bikesAvailable == 0
                ? UIColor.black
                : Colors.BRANDYELLOW
        )
    }

    func setDistanceFromLocation(_ location: CLLocation?) {
        if let loc = location,
           let st = station {
            let dist = Int(loc.distance(from: stationToLoc(st)))
            self.distance = dist
        } else {
            self.distance = nil
        }
    }

}

struct StationSelectorContext {
    var location: CLLocation
    var stations: [Station] = []
}


fileprivate func stationToLoc(_ s: Station) -> CLLocation {
    return CLLocation(latitude: s.lat, longitude: s.lon)
}
