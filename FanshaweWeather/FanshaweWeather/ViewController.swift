//
//  ViewController.swift
//  FanshaweWeather
//
//  Created by Arjun V on 2025-03-26.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var tempToggle: UISegmentedControl!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var citiesButton: UIButton!
    
    let locationManager = CLLocationManager()
    var weatherDataArray: [WeatherData] = []
    var isCelsius = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        searchTextField.delegate = self
        locationManager.requestLocation()
        print("View loaded successfully, ViewController instance: \(ObjectIdentifier(self))")
    }
    
    func setupUI() {
        view.backgroundColor = .systemGray6
        searchTextField.layer.cornerRadius = 10
        searchButton.layer.cornerRadius = 10
        locationButton.layer.cornerRadius = 30
        locationButton.backgroundColor = .systemBlue
        locationButton.setImage(UIImage(systemName: "arrow.up", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .bold))?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        locationButton.clipsToBounds = true
        citiesButton.layer.cornerRadius = 12
        tempToggle.layer.cornerRadius = 8
        updateTemperatureDisplay()
        print("UI setup completed")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
           print("Location error: \(error.localizedDescription)")
       }
    
    @IBAction func searchTapped(_ sender: UIButton) {
        print("Search button tapped")
        if let city = searchTextField.text?.trimmingCharacters(in: .whitespaces), !city.isEmpty {
            print("Searching for: \(city)")
            fetchWeather(for: city)
        } else {
            print("Search field is empty or invalid")
        }
    }
    
    @IBAction func locationTapped(_ sender: UIButton) {
        print("Location button tapped")
        locationManager.requestLocation()
    }
    
    @IBAction func toggleChanged(_ sender: UISegmentedControl) {
        print("Toggle changed to: \(sender.selectedSegmentIndex == 0 ? "°C" : "°F")")
        isCelsius = sender.selectedSegmentIndex == 0
        updateTemperatureDisplay()
    }
    
    func fetchWeather(for city: String) {
        
        if weatherDataArray.contains(where: { $0.city.lowercased() == city.lowercased() }) {
                print("City \(city) already exists in the weather data array")
                return
            }
        
        let apiKey = "74acd0f7535a42ac99f171105252503"
        let urlString = "https://api.weatherapi.com/v1/current.json?key=\(apiKey)&q=\(city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? city)"
    
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return
        }
        
        print("Fetching weather for \(city) from: \(urlString)")
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("API request failed: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received from API")
                return
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw JSON response: \(jsonString)")
            }
            
            do {
                let weather = try JSONDecoder().decode(WeatherResponse.self, from: data)
                let weatherData = WeatherData(
                    city: weather.location.name,
                    tempC: weather.current.temp_c,
                    tempF: weather.current.temp_f,
                    condition: weather.current.condition.text,
                    conditionCode: weather.current.condition.code
                )
                
                DispatchQueue.main.async {
                    self?.weatherDataArray.append(weatherData)
                    print("Weather data added: \(weatherData.city), \(weatherData.tempC)°C, \(weatherData.tempF)°F")
                    self?.updateUI(with: weatherData)
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Failed JSON: \(jsonString)")
                }
            }
        }.resume()
    }
    
    func updateUI(with weather: WeatherData) {
        locationLabel.text = weather.city
        conditionLabel.text = weather.condition
        updateTemperatureDisplay()
        weatherImage.image = getWeatherSymbol(for: weather.conditionCode)
        print("UI updated with: \(weather.city), \(weather.condition), \(isCelsius ? weather.tempC : weather.tempF)\(isCelsius ? "°C" : "°F")")
    }
    
    func updateTemperatureDisplay() {
        if let currentWeather = weatherDataArray.last {
            let temp = isCelsius ? currentWeather.tempC : currentWeather.tempF
            let unit = isCelsius ? "°C" : "°F"
            tempLabel.text = "\(Int(temp))\(unit)"
            print("Temperature updated to: \(Int(temp))\(unit)")
        } else {
            tempLabel.text = isCelsius ? "0°C" : "0°F"
            print("No weather data, showing default: \(tempLabel.text ?? "N/A")")
        }
    }
    
    func getWeatherSymbol(for code: Int) -> UIImage? {
        let config = UIImage.SymbolConfiguration(paletteColors: [.systemYellow, .systemBlue])
        switch code {
        case 1000: return UIImage(systemName: "sun.max.fill")?.withConfiguration(config)
        case 1003: return UIImage(systemName: "cloud.sun.fill")?.withConfiguration(config)
        case 1006, 1009: return UIImage(systemName: "cloud.fill")?.withConfiguration(config)
        case 1063, 1180, 1183, 1186, 1189: return UIImage(systemName: "cloud.rain.fill")?.withConfiguration(config)
        case 1066, 1210, 1213, 1216, 1219: return UIImage(systemName: "cloud.snow.fill")?.withConfiguration(config)
        case 1030, 1135: return UIImage(systemName: "cloud.fog.fill")?.withConfiguration(config)
        case 1087, 1273, 1276: return UIImage(systemName: "cloud.bolt.fill")?.withConfiguration(config)
        default: return UIImage(systemName: "cloud.fill")?.withConfiguration(config)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCities",
           let navigationController = segue.destination as? UINavigationController,
           let destination = navigationController.topViewController as? CitiesViewController {
            destination.weatherDataArray = weatherDataArray
            destination.isCelsius = isCelsius
            print("Passing data to CitiesViewController: \(weatherDataArray.count) items, isCelsius: \(isCelsius), destination instance: \(ObjectIdentifier(destination))")
        }
    }
}

extension ViewController: CLLocationManagerDelegate, UITextFieldDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Location updated with \(locations.count) locations")
        if let location = locations.last {
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
                if let city = placemarks?.first?.locality {
                    print("Geocoded city: \(city)")
                    if !(self?.weatherDataArray.contains(where: { $0.city.lowercased() == city.lowercased() }) ?? false) {
                        self?.fetchWeather(for: city)
                    }
                    else {
                        print("Geocoding failed: \(error?.localizedDescription ?? "Unknown error")")
                    }
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            print("Location permission granted, requesting location")
            locationManager.requestLocation()
        } else {
            print("Location permission denied: \(status.rawValue)")
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchTapped(searchButton)
        return true
    }
}

struct WeatherResponse: Codable {
    let location: Location
    let current: Current
    
    struct Location: Codable {
        let name: String
    }
    
    struct Current: Codable {
        let temp_c: Double
        let temp_f: Double
        let condition: Condition
        
        struct Condition: Codable {
            let text: String
            let code: Int
        }
    }
}
