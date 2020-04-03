//
//  APIClient.swift
//  WeatherTracker
//
//  Created by Dinesh Danda on 4/2/20.
//  Copyright © 2020 Dinesh Danda. All rights reserved.
//

import Foundation


class APIClient {
    
    static let shared: APIClient = APIClient()
    
    let baseURL: String = "https://api.openweathermap.org/data/2.5/weather"
    let apiKey = "" // Hiding the APIKey for Privacy //
    
    func getWeatherDataURL(lat: String, long: String) -> String {
        return "\(baseURL)?lat=\(lat)&lon=\(long)&APPID=\(apiKey)"
    }
}
