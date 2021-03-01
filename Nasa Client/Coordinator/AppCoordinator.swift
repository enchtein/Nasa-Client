//
//  AppCoordinator.swift
//  Nasa Client
//
//  Created by Track Ensure on 2021-03-01.
//

import Foundation
import UIKit

class ApplicationCoordinator: NSObject {
    static let shared = ApplicationCoordinator()
    private var currentNavigator: UINavigationController?
    
    func start(with window: UIWindow) {
//        let startVC = self.instantiate(.main)
        let startVC = self.instantiate(.main(queryFromHistory: nil))
      currentNavigator = UINavigationController(rootViewController: startVC)
      window.rootViewController = currentNavigator
      window.makeKeyAndVisible()
    }
    
    func push(_ controller: RoutesViewController, animated: Bool = true) {
      let vc = instantiate(controller)
      currentNavigator?.pushViewController(vc, animated: animated)
    }
    
    private func instantiate(_ controller: RoutesViewController) -> UIViewController {
      switch controller {
      case .main(let queryFromHistory):
        let vc = ViewController.createFromStoryboard()
        vc.queryFromHistory = nil
        vc.queryFromHistory = queryFromHistory
        return vc
//        return ViewController.createFromStoryboard()
      case .image(let cell):
        let vc = ScrollViewController.createFromStoryboard()
        vc.delegate = cell
        return vc
      case .history:
        return HistoryViewController.createFromStoryboard()
      }
    }
    
  }
