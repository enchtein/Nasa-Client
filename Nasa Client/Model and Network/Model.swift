//
//  Model.swift
//  Nasa Client
//
//  Created by Track Ensure on 2021-03-02.
//

import Foundation

struct NasaClient: Codable {
    var rovers: [Rovers]?
}

struct AllInfo: Codable {
    var photos: [Photos]
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
