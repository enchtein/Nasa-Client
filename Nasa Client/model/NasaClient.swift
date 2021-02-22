//
//  NasaClient.swift
//  Nasa Client
//
//  Created by enchtein on 18.02.2021.
//

import Foundation
import RealmSwift

struct NasaClient: Codable {
    var rovers: [Rovers]?
    
    static func performRequest(with requestType: RequestType, completion: @escaping (_ isSuccess: Bool, _ response: (NasaClient, AllInfo)) -> ()) {
        var repStringURL = ""
        switch requestType {
        case .getAll:
            repStringURL = "https://api.nasa.gov/mars-photos/api/v1/rovers?api_key=Tzsl1O7tW2nGfOxfwipsJJSVUhFDrTabwxaFHomH"
        case .task(let tuple):
            let date = Date()
            let calendar = Calendar(identifier: .gregorian)
            let previousDay = calendar.date(byAdding: .day, value: -2, to: date)
            
            guard let dateUrl = previousDay else { return }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            switch tuple {
            case (nil, nil, _, tuple.page):
                repStringURL = "https://api.nasa.gov/mars-photos/api/v1/rovers/curiosity/photos?earth_date=\(tuple.date ?? dateFormatter.string(from: dateUrl))&page=\(tuple.page ?? 1)&api_key=Tzsl1O7tW2nGfOxfwipsJJSVUhFDrTabwxaFHomH"
            case (nil, tuple.camera, _, tuple.page) where tuple.camera != nil:
                repStringURL = "https://api.nasa.gov/mars-photos/api/v1/rovers/curiosity/photos?earth_date=\(tuple.date ?? dateFormatter.string(from: dateUrl))&camera=\(tuple.camera!.lowercased())&page=\(tuple.page ?? 1)&api_key=Tzsl1O7tW2nGfOxfwipsJJSVUhFDrTabwxaFHomH"
            case (tuple.rover, nil, _, tuple.page) where tuple.rover != nil:
                repStringURL = "https://api.nasa.gov/mars-photos/api/v1/rovers/\(tuple.rover!.lowercased())/photos?earth_date=\(tuple.date ?? dateFormatter.string(from: dateUrl))&page=\(tuple.page ?? 1)&api_key=Tzsl1O7tW2nGfOxfwipsJJSVUhFDrTabwxaFHomH"
            case (tuple.rover, tuple.camera, _, tuple.page) where tuple.rover != nil && tuple.camera != nil:
                repStringURL = "https://api.nasa.gov/mars-photos/api/v1/rovers/\(tuple.rover!.lowercased())/photos?earth_date=\(tuple.date ?? dateFormatter.string(from: dateUrl))&camera=\(tuple.camera!.lowercased())&page=\(tuple.page ?? 1)&api_key=Tzsl1O7tW2nGfOxfwipsJJSVUhFDrTabwxaFHomH"
            default:
                print("wrong query!")
            }
        }
        
        guard let repURL = URL(string: repStringURL) else {return}
        
        URLSession.shared.dataTask(with: repURL) { (data, response, error) in
            var result = NasaClient()
            var rover = AllInfo()
            guard data != nil else {
                print("NO DATA")
                completion(false, (result, rover))
                return
            }
            
            guard error == nil else {
                print(error!.localizedDescription)
                completion(false, (result, rover))
                return
            }
            
            do {
                dump(data)
                switch requestType {
                case .getAll: result = try JSONDecoder().decode(NasaClient.self, from: data!)
                case .task(_): rover = try JSONDecoder().decode(AllInfo.self, from: data!)
                }
                completion(true, (result, rover))
            } catch {
                print(error.localizedDescription)
                completion(false, (result, rover))
            }
        }.resume()
    }
}

struct AllInfo: Codable {
    var photos: [Photos]?
}
struct Rovers: Codable {
    var id: Int
    var name: String
    var launch_date: String
    var max_date: String
    var total_photos: Int
    var cameras: [Cameras]
}
struct Cameras: Codable {
    var name: String
    var full_name: String
}
struct Photos: Codable {
    var id: Int
    var camera: Cameras
    var img_src: String
    var earth_date: String
    var rover: Rover
}
struct Rover: Codable {
    var id: Int
    var name: String
}

enum RequestType {
    case getAll
    case task(searchTask: (rover: String?, camera: String?, date: String?, page: Int?))
}
