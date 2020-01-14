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
import Swifter
import SwiftyJSON
import CoreML
import RSScrollingLabel

class WeatherViewController: UIViewController,CLLocationManagerDelegate{
class WeatherViewController: UIViewController{
    
    let locationManager = CLLocationManager()
    let weatherModel = WeatherDataModel()
    let sentimentClassifer = TweetSentimentClassifier()
    let tweetCount = 100

    let companies: [String] = ["@Apple"]

    let swifter = Swifter(consumerKey: "_____", consumerSecret: "_____")
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let API_ID = "_____"
    
    @IBOutlet weak var sentimentLabel: UILabel!
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
        fetchData()
    }
    
    //MARK: -Make Prediction
    func makePrediction(with tweets: [TweetSentimentClassifierInput])
    {
        do {
            let predictions = try sentimentClassifer.predictions(inputs: tweets)

            var sentimentScore = 0

            for pred in predictions {
                let sentiment = pred.label

                if sentiment == "Pos" {
                    sentimentScore += 1
                } else if sentiment == "Neg" {
                    sentimentScore -= 1
                }
            }
            self.updateTwitterClassifierData(with: sentimentScore)

        } catch {
            print("There was an error with making a prediction, \(error)")
        }
    }
    
    //MARK: - Networking
    func getWeatherData(url: String ,params:[String:String])
    {
        Alamofire.request(url, method: .get, parameters: params).responseJSON { response in
            if response.result.isSuccess
            {

                let weatherJSON: SwiftyJSON.JSON = SwiftyJSON.JSON (response.result.value!)
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
            getWeatherData(url: WEATHER_URL, params: parameters)
        }

    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("\(error): Error in retriving location data.")
        errorMessage.text = "Location Unavaliable!"
    }

    //MARK: - JSON Parsing Methods
    func updateWeatherData(weatherJSON: SwiftyJSON.JSON)
    {
        if let temp = weatherJSON["main"]["temp"].double
        {
            weatherModel.temperature = Int(temp-273)
            weatherModel.city = weatherJSON["name"].stringValue
            weatherModel.condition = weatherJSON["weather"][0]["id"].intValue
            weatherModel.weatherIcon = weatherModel.weatherIconImg(condition: weatherModel.condition)
            weatherModel.iconBool = false
//            updateUI()
        }
        else
        {
            errorMessage.text = "Weather Unavaliable"
        }
    }
    func fetchData()
    {
        for company in companies
        {
            swifter.searchTweet(using: company, lang:"en", count: tweetCount, tweetMode: .extended, success: { (results, metadata) in
                var tweets = [TweetSentimentClassifierInput]()
                
                for i in 0..<self.tweetCount {
                    if let tweet = results[i]["full_text"].string {
                        let tweetForClassification = TweetSentimentClassifierInput(text: tweet)
                        tweets.append(tweetForClassification)
                    }
                }
                self.makePrediction(with: tweets)
                
            }) { (error) in
                print("\(error): Error in Twitter API Request")
            }
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
    func updateTwitterClassifierData(with sentimentScore: Int)
    {

        if sentimentScore > 20 {
            self.sentimentLabel.text = "😍"
        } else if sentimentScore > 10 {
            self.sentimentLabel.text = "😀"
        } else if sentimentScore > 0 {
            self.sentimentLabel.text = "🙂"
        } else if sentimentScore == 0 {
            self.sentimentLabel.text = "😐"
        } else if sentimentScore > -10 {
            self.sentimentLabel.text = "😕"
        } else if sentimentScore > -20 {
            self.sentimentLabel.text = "😡"
        } else {
            self.sentimentLabel.text = "🤮"
        }
        //self.sentimentLabel.animate(to: "Scroll Down", direction: .down)

    }
}

