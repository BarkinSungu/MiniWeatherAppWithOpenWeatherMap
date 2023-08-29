//
//  ViewController.swift
//  MiniWeatherApp
//
//  Created by Barkın Süngü on 29.08.2023.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            
            print("latitude: \(latitude)")
            print("longitude: \(longitude)")
            
            WeatherService.shared.fetchWeatherData(latitude: latitude, longitude: longitude) { result in
                switch result {
                case .success(let weatherData):
                    DispatchQueue.main.async {
                        print("Temp: \(weatherData.current.temp)")
                        print("Icon: \(weatherData.current.weather.first?.main)")
                        print("Daily min: \(weatherData.daily.first?.temp.min)")
                        print("Daily min: \(weatherData.daily.first?.temp.max)")
                        
                        
                    }
                case .failure(let error):
                    print("Error fetching weather data: \(error)")
                }
            }
        }
    }
        
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error: \(error)")
    }

}

