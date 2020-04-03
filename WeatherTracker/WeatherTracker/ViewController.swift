//
//  ViewController.swift
//  WeatherTracker
//
//  Created by Dinesh Danda on 4/1/20.
//  Copyright © 2020 Dinesh Danda. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class ViewController: UIViewController {
    
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLocationServices()
    }
    
    func configureLocationServices() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestLocation()
    }
    
     func getWeatherUsingAlamofire(lat: String, long: String) {
        
        guard let url = URL(string: APIClient.shared.getWeatherDataURL(lat: lat, long: long)) else {
            print("Could not form URL")
            return
        }
        
        let headers: HTTPHeaders = ["Accept": "application/json"]
        let parameters: Parameters = [:]
    
        AF.request(url, method: HTTPMethod.get, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseJSON { [weak self] (response)  in
              guard let strongSelf = self else { return }
            
            // FIXME: Use switch case for success/Failure if you get error no member of value this may happen becuse of old version of Cocoapods for Alamofire
              if let jsonData = response.result.value as? [String:Any] {
              DispatchQueue.main.async {
                strongSelf.parseJSONWithSwifty(data: jsonData)
            }
          }
        }
        
//        AF.request(url).responseJSON { [weak self] (response) in
//            guard let strongSelf = self else { return }
//            if let jsonData = response.result.self as? [String:Any]{
//                DispatchQueue.main.async {
//                strongSelf.parseJSONWithSwifty(data: jsonData)
//                }
//                print(jsonData)
//            }
//        }
        
    }
    
    func parseJSONWithSwifty(data: [String: Any]) {
        let jsonData = JSON(data)
        if let humidity = jsonData["main"]["humidity"].int {
            humidityLabel.text = "\(humidity)"
        }
        
        if let temp = jsonData["main"]["temp"].double {
            temperatureLabel.text = "\(temp)"
        }
        if let windSpeed = jsonData["wind"]["speed"].double {
            windSpeedLabel.text = "\(windSpeed)"
        }
        if let name = jsonData["name"].string {
                  cityNameLabel.text = "\(name)"
              }
    }
    
    func getWeahterwithURLSession(lat: String, long: String) {
     
        //MARK:- Method 1 using URLSession
        
        let apiKey = APIClient.shared.apiKey
        if var urlComponents = URLComponents(string: APIClient.shared.baseURL) {
            urlComponents.query = "lat=\(lat)&lon=\(long)&APPID=\(apiKey)"
            guard let url = urlComponents.url else { return }
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            let task = session.dataTask(with: request) {(data, response, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                guard let data = data else { return }
                
                do {
                    guard let weatherData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                        print("There was an error while converting the data into JSON")
                        return
                    }
                    print(weatherData)
                } catch {
                    print("Error while converting data into JSON")
                }
            }
            task.resume()
        }
        
        //MARK:- Method 2 using URLSession
      /*  guard let weatherURL = URL(string: APIClient.shared.getWeatherDataURL(lat: lat, long: long)) else { return }

        URLSession.shared.dataTask(with: weatherURL) {(data, response, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }

            guard let data = data else { return }

            do {
                guard let weatherData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                    print("There was an error while converting the data into JSON")
                    return
                }
                print(weatherData)
            } catch {
                print("Error while converting data into JSON")
            }
        }.resume() */
    }
}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            print(latitude)
            print(longitude)
            getWeatherUsingAlamofire(lat: latitude, long: longitude)
           // getWeahterwithURLSession(lat: latitude, long: longitude)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
        case .denied, .restricted:
            let alertController = UIAlertController.init(title: "Location Disabled", message: "Please turn on your location to track the Climate", preferredStyle: .alert)
            let cancelAction = UIAlertAction.init(title: "Cancel", style: .cancel) {(action) in
                alertController.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(cancelAction)
            
            let openAction = UIAlertAction.init(title: "Open", style: .default) {(action) in
                
                if let url = NSURL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
                }
            }
            alertController.addAction(openAction)
            present(alertController, animated: true, completion: nil)
            break
        }
    }
}

