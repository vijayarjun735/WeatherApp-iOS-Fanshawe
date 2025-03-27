//
//  CityViewController.swift
//  FanshaweWeather
//
//  Created by Arjun V on 2025-03-26.
//

import UIKit

class CitiesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var weatherDataArray: [WeatherData] = [] {
        didSet {
            print("weatherDataArray updated to \(weatherDataArray.count) items, instance: \(ObjectIdentifier(self))")
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }
    var isCelsius = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        view.backgroundColor = .systemGray5
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "WeatherCell")
        tableView.rowHeight = 60
        print("CitiesViewController loaded with \(weatherDataArray.count) items, instance: \(ObjectIdentifier(self))")
        
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("View will appear, current weatherDataArray count: \(weatherDataArray.count), instance: \(ObjectIdentifier(self))")
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = weatherDataArray.count
        print("Table view row count: \(count), instance: \(ObjectIdentifier(self))")
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherCell", for: indexPath)
        let weather = weatherDataArray[indexPath.row]
        
        cell.textLabel?.text = weather.city
        let tempC = Int(weather.tempC)
        let tempF = Int(weather.tempF)
        cell.viewWithTag(100)?.removeFromSuperview()
        let tempLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 40))
        tempLabel.tag = 100
        tempLabel.text = "\(weather.condition), \(tempC)°C / \(tempF)°F"
        tempLabel.textAlignment = .right
        tempLabel.textColor = .white
        tempLabel.font = .systemFont(ofSize: 14)
        tempLabel.numberOfLines = 2
        cell.contentView.addSubview(tempLabel)
        
        tempLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tempLabel.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -10),
            tempLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            tempLabel.widthAnchor.constraint(equalToConstant: 150),
            tempLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        cell.imageView?.image = getWeatherSymbol(for: weather.conditionCode)
        cell.textLabel?.textColor = .white
        cell.backgroundColor = .clear
        cell.imageView?.tintColor = .systemBlue
        
        print("Configured cell for \(weather.city) with condition and temp \(weather.condition), \(tempC)°C / \(tempF)°F, instance: \(ObjectIdentifier(self))")
        return cell
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
}
