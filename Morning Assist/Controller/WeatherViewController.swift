//
//  ViewController.swift
//  Morning Assist
//
//  Created by Mascarenhas on 2019-01-28.
//  Copyright © 2019 Mascarenhas. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON
import GooglePlaces


class WeatherViewController: UIViewController,CLLocationManagerDelegate{
    
    var placesClient: GMSPlacesClient!
    var placeFields: GMSPlace!
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let API_ID = "d1a58756b8377c9af721ff5a03fdde46"
    
    let locationManager = CLLocationManager()
    let weatherModel = WeatherDataModel()
    
    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBAction func tempTypeLabel(_ sender: Any) {
        weatherModel.iconBool = !weatherModel.iconBool
        updateUI()
        if weatherModel.iconBool{
            (sender as! UIButton).setTitle("F", for: [])
        }
        else if !weatherModel.iconBool{
            (sender as! UIButton).setTitle("C", for: [])
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        placesClient = GMSPlacesClient.shared()
    }
    func getCurrentPlace()
    {
        var id: String = ""
        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
//            self.nameLabel.text = "No current place"
//            self.addressLabel.text = ""
            
            if let placeLikelihoodList = placeLikelihoodList {
                let place = placeLikelihoodList.likelihoods.first?.place
                if let place = place {
                    print("\n\n\n\n")
                    id = place.placeID
                    
                }
            }
        })
        
        // Specify the place data types to return (in this case, just photos).
        
//
//        placesClient?.fetchPlace(fromPlaceID: id,
//                                 placeFields: nil,
//                                 sessionToken: nil, callback: {
//                                    (place: GMSPlace?, error: Error?) in
//                                    if let error = error {
//                                        print("An error occurred: \(error.localizedDescription)")
//                                        return
//                                    }
//                                    if let place = place {
//                                        // Get the metadata for the first photo in the place photo metadata list.
//                                        let photoMetadata: GMSPlacePhotoMetadata = place.photos![0]
//
//                                        // Call loadPlacePhoto to display the bitmap and attribution.
//                                        self.placesClient?.loadPlacePhoto(photoMetadata, callback: { (photo, error) -> Void in
//                                            if let error = error {
//                                                // TODO: Handle the error.
//                                                print("Error loading photo metadata: \(error.localizedDescription)")
//                                                return
//                                            } else {
//                                                // Display the first image and its attributions.
//                                                self.imageView?.image = photo;
//                                                self.lblText?.attributedText = photoMetadata.attributions;
//                                            }
//                                        })
//                                    }
//        })
    }
    //MARK: - Networking
    func getWeatherData(url: String ,params:[String:String])
    {
        Alamofire.request(url, method: .get, parameters: params).responseJSON { response in
            if response.result.isSuccess
            {
                let weatherJSON: JSON = JSON(response.result.value!)
                self.updateWeatherData(weatherJSON: weatherJSON)
            }
            else
            {
                print("Error in getting weather data")
            
            }
        }
    }
    //MARK: - Location Manager Delegate Methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location = locations[locations.count-1]
        if location.horizontalAccuracy>0
        {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            let lat = String(location.coordinate.latitude)
            let lon = String(location.coordinate.longitude)
            let parameters: [String: String] = ["lat":lat,"lon":lon,"appid":API_ID]
            getCurrentPlace()
            getWeatherData(url: WEATHER_URL, params: parameters)
        }
        
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("\(error): Error in retriving location data.")
        errorMessage.text = "Location Unavaliable!"
    }
    
    //MARK: - JSON Parsing Methods
    func updateWeatherData(weatherJSON: JSON)
    {
        if let temp = weatherJSON["main"]["temp"].double
        {
            weatherModel.temperature = Int(temp-273)
            weatherModel.city = weatherJSON["name"].stringValue
            weatherModel.condition = weatherJSON["weather"][0]["id"].intValue
            weatherModel.weatherIcon = weatherModel.weatherIconImg(condition: weatherModel.condition)
            weatherModel.iconBool = false
            updateUI()
        }
        else
        {
            errorMessage.text = "Weather Unavaliable"
        }
    }
    
    //MARK: - UI Update Methods
    func updateUI()
    {
        tempLabel.text = String(getTemp()) + "°"
        cityLabel.text = weatherModel.city
        errorMessage.text = ""
        weatherIcon.image = UIImage(named: weatherModel.weatherIcon)
    }
    func getTemp()->Int
    {
        if (weatherModel.iconBool)
        {
            var F: Int = weatherModel.temperature
            F = (F + (9/5))+32
            return F
        }
        return weatherModel.temperature
        
    }
}

