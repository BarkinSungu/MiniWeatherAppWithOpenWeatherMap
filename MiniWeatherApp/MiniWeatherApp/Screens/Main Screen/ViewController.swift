//
//  ViewController.swift
//  MiniWeatherApp
//
//  Created by Barkın Süngü on 29.08.2023.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        WeatherService.shared.fetchWeatherData(latitude: 41.0082, longitude: 28.9784) { result in
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

