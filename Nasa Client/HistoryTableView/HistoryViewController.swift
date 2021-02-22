//
//  HistoryViewController.swift
//  Nasa Client
//
//  Created by enchtein on 22.02.2021.
//

import UIKit
import RealmSwift

class HistoryViewController: UIViewController {
    let realm = try! Realm()
    var historyItems: Results<History>?
    private var barButton: UIBarButtonItem?
    
    @IBOutlet weak var historyTableView: UITableView!
    @objc func tapBarButton() {
        try! realm.write {
            realm.deleteAll()
        }
        DispatchQueue.main.async {
            self.historyTableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.barButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(tapBarButton))
        self.navigationItem.rightBarButtonItem = barButton
        
        // Do any additional setup after loading the view.
        self.historyItems = { self.realm.objects(History.self) }()
        
        //        HistoryCell
        self.historyTableView.register(UINib(nibName: "HistoryTableViewCell", bundle: nil), forCellReuseIdentifier: "HistoryCell")
        self.historyTableView.delegate = self
        self.historyTableView.dataSource = self
    }
    override func viewWillAppear(_ animated: Bool) {
        self.historyItems = { self.realm.objects(History.self) }()
        self.historyTableView.reloadData()
    }
}

extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.historyItems?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as? HistoryTableViewCell {
            guard let items = self.historyItems else { return UITableViewCell() }
            let item = items[indexPath.row]
            cell.roverLabel.text = "Rover:" + item.rover
            cell.cameraLabel.text = "Camera: " + item.camera
            cell.dateLabel.text = "Date: " + item.date
            cell.pageLabel.text = "Page: " + String(item.page)
            
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as? HistoryTableViewCell {
            let vc = storyboard?.instantiateViewController(identifier: "ViewController") as! ViewController
            vc.queryFromHistory = nil
//            print(indexPath.row)
            guard let items = self.historyItems else { return }
            let item = items[indexPath.row]
            vc.queryFromHistory = item
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
