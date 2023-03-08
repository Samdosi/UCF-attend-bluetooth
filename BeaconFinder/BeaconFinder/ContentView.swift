//
//  ContentView.swift
//  BeaconFinder
//
//  Created by Sam Dosi on 3/5/23.
//

import Combine
import CoreLocation
import SwiftUI

class BeaconDetector: NSObject, ObservableObject, CLLocationManagerDelegate{
    
    //var didChange = PassthroughSubject<Void, Never>()
    let objectWillChange = ObservableObjectPublisher()
    var locationManager: CLLocationManager?
    var lastDistance = CLProximity.unknown
    
    override init() {
        super.init()
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self){
                if CLLocationManager.isRangingAvailable(){
                    startScanning()
                    
                }
            }
        }
    }
    
    func startScanning(){
        let uuid = UUID(uuidString: "AF80D50E-9905-4562-B154-AB5C82B635ED")!
        let constraint = CLBeaconIdentityConstraint(uuid: uuid, major: 1, minor: 1)
        let beaconRegion = CLBeaconRegion(beaconIdentityConstraint: constraint, identifier: "Flexible iOS Beacon")
        
        locationManager?.startMonitoring(for: beaconRegion)
        locationManager?.startRangingBeacons(satisfying: constraint)
        
    }

    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        if let beacon = beacons.first {
        
            update(distance: beacon.proximity)
        }else {
            update(distance: .unknown)
        }
    }
    func update(distance: CLProximity){
        
   
        lastDistance = distance
        //didChange.send()
        self.objectWillChange.send()
    }
   
}
struct BigText: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(Font.system(size: 72, design: .rounded))
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
    }
}
struct ContentView: View {
    
    @ObservedObject var detector = BeaconDetector()
  
    var body: some View {
       
        if detector.lastDistance == .immediate{
            return Text("next to Beacon, you are marked present :)")
                .modifier(BigText())
                .background(Color.green)
                .edgesIgnoringSafeArea(.all)
              
            
        } else if detector.lastDistance == .near {
            return Text("close to Beacon, you are marked present :)")
                .modifier(BigText())
                .background(Color.yellow)
                .edgesIgnoringSafeArea(.all)
              
            
        } else if detector.lastDistance == .far {
            return Text("far from the Beacon, you are marked present :)")
                .modifier(BigText())
                .background(Color.blue)
                .edgesIgnoringSafeArea(.all)
              
            
        }else{
            return Text("Can not find Beacon, You are marked absent :|")
                    .modifier(BigText())
                    .background(Color.red)
                    .edgesIgnoringSafeArea(.all)
             
              
        }
          
      

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
