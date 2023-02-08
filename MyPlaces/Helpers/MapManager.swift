//
//  MapManager.swift
//  MyPlaces
//
//  Created by Вадим Игнатенко on 1.12.22.
//

import UIKit
import MapKit



class MapManager {
    
    
    let locationManager = CLLocationManager()
    
    private let regionMeters = 1000.00
    private var directionsArray: [MKDirections] = []
    private var placeCoordinate: CLLocationCoordinate2D?


    
    
    // маркер заведения
    func setupPlacemark (place: Place, mapView: MKMapView) {
        guard let location = place.location else { return }
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { (placemarks, error) in
            if let error = error {
                print(error)
                return
            }
            guard let placemarks = placemarks else { return }
            
            let placemark = placemarks.first
            
            let annotation = MKPointAnnotation()
            annotation.title = place.name
            annotation.subtitle = place.type
            
            guard let placemarkLoacation = placemark?.location else { return }
            
            annotation.coordinate = placemarkLoacation.coordinate
            self.placeCoordinate = placemarkLoacation.coordinate
            
            mapView.showAnnotations([annotation], animated: true)
            mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    
    
    // проверка доступности сервисов геолокации
    func checkLocationServices(mapView: MKMapView, segueIdentifier: String, closure:() ->()) {
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            checkLocationAutorization(mapView: mapView, segueIdentifier: segueIdentifier)
            closure()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.alertRelize()
            }
        }
    }
    
    
    
    // проверка авторизации приложения для использования сервисов геолокации
    func checkLocationAutorization(mapView: MKMapView, segueIdentifier: String) {
        switch CLLocationManager.authorizationStatus() {
            
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            break
        case .denied:
            alertCancelView()
            break
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if segueIdentifier == "getAddress" { showUserLocation(mapView: mapView) }
            break
        }
    }
    
                                                                  
    // фокус карты на местоположении пользователя
    func showUserLocation(mapView: MKMapView) {
                                                                      
        if let location = locationManager.location?.coordinate {
        let region = MKCoordinateRegion(center: location,
                                        latitudinalMeters: regionMeters,
                                        longitudinalMeters: regionMeters)
                                                                          
        mapView.setRegion(region, animated: true)
        }
    }
                                                                  
                                                                  
    
    // строим маршрут от местоположения пользователя до заведения
    func getDirection(for mapView: MKMapView, previousLocation:(CLLocation) ->()) {
        
       guard let location = locationManager.location?.coordinate else {
           alertRelize()
           return
       }
        locationManager.startUpdatingLocation()
        previousLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))
        
        guard let request = createDirectionsRequest(from: location) else {
            alertRelize()
            return
        }
        let directions = MKDirections(request: request)
        resetMapView(withNew: directions, mapView: mapView)
        
        directions.calculate { response, error in
           
            if let error = error {
                print(error)
                return
            }
            guard let response = response else {
                self.alertRelize()
                return
            }
            for route in response.routes {
                mapView.addOverlay(route.polyline)
                mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                let distance = String(format: "%.1f", route.distance / 1000)
                let timeInterval = route.expectedTravelTime
                
                print("расстояние до места \(distance) км")
                print("время в пути составит \(timeInterval) сек")
            }
        }
    }
    
    
    
    // настройка запроса для расчета маршрута
    func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        
        guard let destinationCoordinate = placeCoordinate else { return nil }
        let startingLocation = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        
        return request
    }
    
    
    
    // меняем отображаемую зону области карты в соответствии с перемищением пользователя
    func startTrakingUserLocation(for mapView: MKMapView, and location: CLLocation?, closure: (_ currentLocation: CLLocation) ->()) {
        
        guard let previousLocation = location else { return }
        let center = getCenterLocation(for: mapView)
        guard center.distance(from: previousLocation) > 50 else { return }
        
        closure(center)
        }
    
    
    
    // сброс всех маршрутов перед построением нового
    func resetMapView(withNew directions: MKDirections, mapView: MKMapView) {
        
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map { $0.cancel() }
        directionsArray.removeAll()
    }
    
    
    
    // определение центра отображаемой области карты
    func getCenterLocation (for mapView: MKMapView) -> CLLocation {
        
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    
    
    // алерты
    private func alertCancelView() {
        
        let alert = UIAlertController(title: "Отследить место положение не возможно", message: "Для включения геолокации советую Вам выкинуть Ваш IPhone", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "ok"),
                                      style: .default,
                                      handler: {_ in
        let mapVC = MapViewController()
            mapVC.closeVC()
        }))
        
        let alertWindow  = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alert, animated: true, completion: nil)
        }
        
       
    private func alertRelize() {
        
        let alert = UIAlertController(title: "Отследить место положение не возможно", message: "Для включения геолокации советую Вам выкинуть Ваш IPhone", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "ok"), style: .cancel, handler: { _ in
        NSLog("The \"OK\" alert occured.")
        }))
        
        let alertWindow  = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
}
