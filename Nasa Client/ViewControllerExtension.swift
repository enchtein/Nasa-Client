//
//  ViewControllerExtension.swift
//  Nasa Client
//
//  Created by enchtein on 22.02.2021.
//

import Foundation

extension ViewController {
    func selectedItems() {
        guard let startMassive = self.temp.rovers else { return }
        self.roversName = [String]()
        self.roversName.append("All")
        if self.dataTuple.camera != nil {
            for mass in startMassive {
                if mass.cameras.contains(where: {$0.full_name == self.dataTuple.camera}) {
                    self.roversName.append(mass.name)
                }
            }
        } else if self.dataTuple.date != nil {
            for mass in startMassive {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let launchDate = dateFormatter.date(from: mass.launch_date)
                let maxDate = dateFormatter.date(from: mass.max_date)
                
                let currentDate = dateFormatter.date(from: self.dataTuple.date!)
                if currentDate! >= launchDate! && currentDate! <= maxDate! {
                    self.roversName.append(mass.name)
                }
            }
        } else {
            startMassive.forEach({ mass in
                self.roversName.append(mass.name)
            })
        }
        
        self.camerasName = [String]()
        self.camerasName.append("All")
        if self.dataTuple.rover != nil {
            let res = startMassive.filter{$0.name == self.dataTuple.rover}.map{$0}.first
            guard let result = res else { return }
            result.cameras.forEach { camera in
                if self.camerasName.contains(camera.full_name) == false {
                    self.camerasName.append(camera.full_name)
                }
            }
        } else if self.dataTuple.date != nil {
            for mass in startMassive {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let launchDate = dateFormatter.date(from: mass.launch_date)
                let maxDate = dateFormatter.date(from: mass.max_date)
                
                let currentDate = dateFormatter.date(from: self.dataTuple.date!)
                if currentDate! >= launchDate! && currentDate! <= maxDate! {
                    mass.cameras.forEach { camera in
                        if self.camerasName.contains(camera.full_name) == false {
                            self.camerasName.append(camera.full_name)
                        }
                    }
                }
            }
        } else {
            startMassive.forEach({ mass in
                mass.cameras.forEach { camera in
                    if self.camerasName.contains(camera.full_name) == false {
                        self.camerasName.append(camera.full_name)
                    }
                }
            })
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if self.dataTuple.rover != nil {
            let res = self.temp.rovers?.filter({$0.name == self.roverLabel.text}).first
            guard let result = res else { return }
            
            let minDate = result.launch_date
            let maxDate = result.max_date
            
            self.datePicker.minimumDate = dateFormatter.date(from: minDate)
            self.datePicker.maximumDate = dateFormatter.date(from: maxDate)
            self.temp.rovers = self.repositoryDataSourse?.rovers?.filter({$0.id == res?.id}).map({$0})
        } else if self.dataTuple.camera != nil {
            var tempMinDate = [Date]()
            var tempMaxDate = [Date]()
            for mass in startMassive {
                if mass.cameras.contains(where: { cameras -> Bool in
                    cameras.full_name == self.dataTuple.camera
                }) {
                    let tempLanchDate = mass.launch_date
                    let tempMax_Date = mass.max_date
                    let minDate = dateFormatter.date(from: tempLanchDate)
                    let maxDate = dateFormatter.date(from: tempMax_Date)
                    guard let minDateResult = minDate else { return }
                    tempMinDate.append(minDateResult)
                    guard let maxDateResult = maxDate else { return }
                    tempMaxDate.append(maxDateResult)
                }
            }
            DispatchQueue.main.async {
                self.datePicker.minimumDate = tempMinDate.min()
                self.datePicker.maximumDate = tempMaxDate.max()
            }
        } else {
            var tempMinDate = [Date]()
            var tempMaxDate = [Date]()
            for mass in startMassive {
                let tempLanchDate = mass.launch_date
                let tempMax_Date = mass.max_date
                let minDate = dateFormatter.date(from: tempLanchDate)
                let maxDate = dateFormatter.date(from: tempMax_Date)
                guard let minDateResult = minDate else { return }
                tempMinDate.append(minDateResult)
                guard let maxDateResult = maxDate else { return }
                tempMaxDate.append(maxDateResult)
            }
            DispatchQueue.main.async {
                self.datePicker.minimumDate = tempMinDate.min()
                self.datePicker.maximumDate = tempMaxDate.max()
            }
        }
        DispatchQueue.main.async {
            self.roverPicker.reloadAllComponents()
            self.cameraPicker.reloadAllComponents()
            
            self.datePicker.reloadInputViews()
            self.fetchQuery(task: self.dataTuple)
        }
    }
}
