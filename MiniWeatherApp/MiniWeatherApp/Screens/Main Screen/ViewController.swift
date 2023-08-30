//
//  ViewController.swift
//  MiniWeatherApp
//
//  Created by Barkın Süngü on 29.08.2023.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    let cityLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .black
        return label
    }()
    
    let weatherIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .black
        return imageView
    }()
    
    let temperatureLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 24)
        label.textColor = .black
        return label
    }()
    
    let minMaxTemperatureLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    let locationManager = CLLocationManager()
    
    var cityName = ""
    var temperature: Double = 0.0
    var weatherIconName: String = ""
    var dailyMinTemp: Double = 0.0
    var dailyMaxTemp: Double = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        setupUI()
    }
    
    func setupUI() {
        view.addSubview(cityLabel)
        view.addSubview(weatherIconImageView)
        view.addSubview(temperatureLabel)
        view.addSubview(minMaxTemperatureLabel)
        
        NSLayoutConstraint.activate([
            cityLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            cityLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cityLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            weatherIconImageView.topAnchor.constraint(equalTo: cityLabel.bottomAnchor, constant: 20),
            weatherIconImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            weatherIconImageView.widthAnchor.constraint(equalToConstant: 100),
            weatherIconImageView.heightAnchor.constraint(equalToConstant: 100),
            
            temperatureLabel.topAnchor.constraint(equalTo: weatherIconImageView.bottomAnchor, constant: 20),
            temperatureLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            temperatureLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            minMaxTemperatureLabel.topAnchor.constraint(equalTo: temperatureLabel.bottomAnchor, constant: 10),
            minMaxTemperatureLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            minMaxTemperatureLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func updateWeatherData() {
        let min = Int(dailyMinTemp-273.15)
        let max = Int(dailyMaxTemp-273.15)
        let temp = Int(temperature-273.15)
        cityLabel.text = cityName
        temperatureLabel.text = "\(temp)°C"
        minMaxTemperatureLabel.text = "Max:\(max)°C Min:\(min)°C"
        weatherIconImageView.image = getWeatherIconImage(iconName: weatherIconName)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        locationManager.stopUpdatingLocation()
        
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        print("latitude: \(latitude)")
        print("longitude: \(longitude)")
        
        reverseGeocodeLocation(location) { city in
            if let city = city {
                self.cityName = city
                print("City: \(city)")
            } else {
                print("City not found.")
            }
        }
        
        WeatherService.shared.fetchWeatherData(latitude: latitude, longitude: longitude) { result in
            switch result {
            case .success(let weatherData):
                DispatchQueue.main.async {
                    self.temperature = weatherData.current.temp
                    print("Temp: \(self.temperature)")
                    if let weatherMain = weatherData.current.weather.first?.icon {
                        self.weatherIconName = weatherMain
                        print("Icon: \(self.weatherIconName)")
                    }
                    if let dailyMin = weatherData.daily.first?.temp.min {
                        self.dailyMinTemp = dailyMin
                        print("Daily min: \(self.dailyMinTemp)")
                    }
                    if let dailyMax = weatherData.daily.first?.temp.max {
                        self.dailyMaxTemp = dailyMax
                        print("Daily max: \(self.dailyMaxTemp)")
                    }
                    
                    self.updateWeatherData()
                    
                }
            case .failure(let error):
                print("Error fetching weather data: \(error)")
            }
        }
    }
    
    func reverseGeocodeLocation(_ location: CLLocation, completion: @escaping (String?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let placemark = placemarks?.first {
                if let city = placemark.locality {
                    completion(city)
                } else {
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error: \(error)")
    }
    
    func getWeatherIconImage(iconName: String) -> UIImage? {
        switch iconName {
        case "01d": return UIImage(systemName: "sun.max")
            case "01n": return UIImage(systemName: "moon")
            case "02d": return UIImage(systemName: "cloud.sun")
            case "02n": return UIImage(systemName: "cloud.moon")
            case "03d", "03n", "04d", "04n": return UIImage(systemName: "cloud")
            case "09d", "09n": return UIImage(systemName: "cloud.rain")
            case "10d", "10n": return UIImage(systemName: "cloud.sun.rain")
            case "11d", "11n": return UIImage(systemName: "cloud.bolt.rain")
            case "13d", "13n": return UIImage(systemName: "snow")
            case "50d", "50n": return UIImage(systemName: "cloud.fog")
            default: return nil
        }
    }

}

