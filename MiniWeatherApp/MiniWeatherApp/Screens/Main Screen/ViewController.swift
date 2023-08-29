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
        guard let location = locations.last else { return }
        locationManager.stopUpdatingLocation()
        
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        print("latitude: \(latitude)")
        print("longitude: \(longitude)")
        
        reverseGeocodeLocation(location)
        
        WeatherService.shared.fetchWeatherData(latitude: latitude, longitude: longitude) { result in
            switch result {
            case .success(let weatherData):
                DispatchQueue.main.async {
                    print("Temp: \(weatherData.current.temp)")
                    if let weatherMain = weatherData.current.weather.first?.main {
                        print("Icon: \(weatherMain)")
                    }
                    if let dailyMin = weatherData.daily.first?.temp.min {
                        print("Daily min: \(dailyMin)")
                    }
                    if let dailyMax = weatherData.daily.first?.temp.max {
                        print("Daily max: \(dailyMax)")
                    }
                }
            case .failure(let error):
                print("Error fetching weather data: \(error)")
            }
        }
    }

    func reverseGeocodeLocation(_ location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let placemark = placemarks?.first {
                if let city = placemark.locality {
                    print("Your city: \(city)")
                }
            }
        }
    }

        
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error: \(error)")
    }

}

