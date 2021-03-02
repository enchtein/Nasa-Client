//
//  ApiProvider.swift
//  Nasa Client
//
//  Created by Track Ensure on 2021-03-02.
//

import Foundation
import PromiseKit
import Moya


struct Provider {
    static private let provider = MoyaProvider<RequestType>()
    
    static func performReguest(rover: String, camera: String, date: String, page: Int) -> Promise<AllInfo> {
        return Promise { seal in
            provider.request(.task(rover: rover, camera: camera, date: date, page: page)) { result in
                switch result {
                case let .success(moyaResponse):
                    do {
                        let resp = try JSONDecoder().decode(AllInfo.self, from: moyaResponse.data)
                        seal.fulfill(resp)
                    } catch let error {
                        print(error)
                        seal.reject(error)
                    }
                // you can also have some logic and call reject() here
                case let .failure(error):
                    seal.reject(error)
                }
            }
        }
    }
    
    static func performRequestAll() -> Promise<NasaClient> {
        return Promise { seal in
            provider.request(.getAll) { result in
                switch result {
                case let .success(moyaResponse):
                    do {
                        let resp = try JSONDecoder().decode(NasaClient.self, from: moyaResponse.data)
                        seal.fulfill(resp)
                    } catch let error {
                        print(error)
                        seal.reject(error)
                    }
                // you can also have some logic and call reject() here
                case let .failure(error):
                    seal.reject(error)
                }
            }
            
        }
    }
}
