//
//  WeatherService.swift
//  MiniWeatherApp
//
//  Created by Barkın Süngü on 29.08.2023.
//

import Foundation

class WeatherService {
    static let shared = WeatherService()

    private let apiKey = "YOUR API KEY"

    private init() {}

    func fetchWeatherData(latitude: Double, longitude: Double, completion: @escaping (Result<WeatherData, Error>) -> Void) {
        let urlString = "https://api.openweathermap.org/data/3.0/onecall?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)"
        
        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let data = data else {
                    completion(.failure(NetworkError.noData))
                    return
                }

                do {
                    let weatherData = try JSONDecoder().decode(WeatherData.self, from: data)
                    completion(.success(weatherData))
                } catch {
                    completion(.failure(error))
                }
            }.resume()
        }
    }
    
    struct WeatherData: Codable {
        let lat: Double
        let lon: Double
        let current: Current
        let daily: [Daily]
    // Diğer alanları da ekleyebilirsiniz
    }
    struct Current: Codable {
        let temp: Double                                //anlık sıcaklık
        let feels_like: Double
        let pressure: Int
        let humidity: Int
        let weather: [Weather]
        // Diğer alanları da ekleyebilirsiniz
    }
    struct Weather: Codable{
        let main: String                               //hava durumu ikonu
    }
    struct Daily: Codable{
        let temp: Temp
    }
    struct Temp: Codable{
        let min: Double                                 //Daily min
        let max: Double                                 //Daily max
    }

}

enum NetworkError: Error {
    case noData
}

