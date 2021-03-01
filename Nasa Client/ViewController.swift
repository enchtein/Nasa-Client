//
//  ViewController.swift
//  Nasa Client
//
//  Created by enchtein on 17.02.2021.
//

import UIKit
import RealmSwift

class ViewController: UIViewController, StoryboardInitializable {
    let realm = try! Realm()
    var historyItems: Results<History>?
    var queryFromHistory: History?
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var labelStackView: UIStackView!
    
    @IBOutlet weak var roverButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var dataButton: UIButton!
    
    @IBOutlet weak var roverLabel: UILabel!
    @IBOutlet weak var cameraLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    var roversName = [String]()
    var camerasName = [String]()
    
    var temp = NasaClient()
    var repositoryDataSourse: NasaClient?
    var repositoryRovers: AllInfo?
    
    var roverPicker = UIPickerView()
    var cameraPicker = UIPickerView()
    var datePicker = UIDatePicker()
    var oneCell: NewTableViewCell?
    
    private var searchTimer: Timer?
    
    var barButton: UIBarButtonItem?
    
    var toolbar = UIToolbar()
    
    var dataTuple: (rover: String?, camera: String?, date: String?, page: Int?)
    
    fileprivate func toolbarProperties() {
        toolbar = UIToolbar(frame: CGRect(x: 0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 50))
        
        self.toolbar.backgroundColor = .none
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action:
                                            #selector(cancelButtonTapped))
        cancelButton.tintColor = UIColor.systemBlue
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action:
                                            #selector(saveDate))
        
        doneButton.tintColor = UIColor.systemBlue
        
        //add the items to the toolbar
        self.toolbar.items = [doneButton, flexSpace, cancelButton]
        
        self.toolbar.sizeToFit()
        self.toolbar.isHidden = true
        self.view.addSubview(self.toolbar)
    }
    @objc private func cancelButtonTapped() {
        self.roverPicker.isHidden = true
        self.cameraPicker.isHidden = true
        self.datePicker.isHidden = true
        self.toolbar.isHidden = true
    }
    
    @objc private func saveDate() {
        self.roverPicker.isHidden = true
        self.cameraPicker.isHidden = true
        self.datePicker.isHidden = true
        self.toolbar.isHidden = true
        
        self.dataTuple.page = 1
        
        self.dataTuple.rover = self.roverLabel.text != "All" ? self.roverLabel.text! : nil
        if self.cameraLabel.text != "All" {
            for rover in self.temp.rovers! {
                for camera in rover.cameras {
                    if camera.full_name == self.cameraLabel.text {
                        self.dataTuple.camera = camera.name
                    }
                }
            }
        } else {
            self.dataTuple.camera = nil
        }
        self.dataTuple.date = self.dateLabel.text != "All" ? self.dateLabel.text! : nil
        
        selectedItems()
    }
    
    fileprivate func pickerViewProperties(picker: UIPickerView, tag: Int) {
        picker.backgroundColor = UIColor.white
        picker.autoresizingMask = .flexibleWidth
        picker.frame = CGRect(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 300)
        
        picker.isHidden = true
        picker.dataSource = self
        picker.delegate = self
        picker.tag = tag
        self.view.addSubview(picker)
    }
    
    fileprivate func datePickerProperties() {
        self.datePicker.preferredDatePickerStyle = .wheels
        datePicker.backgroundColor = UIColor.white
        
        datePicker.autoresizingMask = .flexibleWidth
        datePicker.datePickerMode = .date
        
        datePicker.addTarget(self, action: #selector(getDateFromPicker), for: .valueChanged)
        datePicker.frame = CGRect(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 300)
        datePicker.isHidden = true
        self.view.addSubview(datePicker)
    }
    @objc func tapBarButton() {
//        if let vc = storyboard?.instantiateViewController(identifier: "HistoryViewController") as? HistoryViewController {
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
        ApplicationCoordinator.shared.push(.history)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.queryFromHistory = { self.realm.objects(History.self) }().last
        
        pickerViewProperties(picker: self.roverPicker, tag: 0)
        pickerViewProperties(picker: self.cameraPicker, tag: 1)
        datePickerProperties()
        toolbarProperties()
        
        self.barButton = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(tapBarButton))
        self.navigationItem.rightBarButtonItem = barButton
        
        [self.stackView, self.labelStackView].forEach { stackView in
            stackView?.spacing = 10
            stackView?.backgroundColor = .none
        }
        
        [self.roverButton, self.cameraButton, self.dataButton].forEach { button in
            button?.setTitleColor(UIColor.black, for: .normal)
            button?.layer.cornerRadius = 8
            button?.layer.borderWidth = 3
            button?.layer.borderColor = UIColor.red.cgColor
            button?.semanticContentAttribute = .forceRightToLeft
            
            // настроить вид кнопок!
        }
        self.tableView.register(UINib(nibName: "NewTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .singleLine
        self.tableView.separatorColor = .red
        
        self.getAllData()
        self.selectedItems()
    }
    override func viewWillAppear(_ animated: Bool) {
        guard let data = self.queryFromHistory else { return }
        if data.camera != "" {
            self.dataTuple.camera = data.camera
        } else {
            self.dataTuple.camera = nil
        }
        if data.date != "" {
            self.dataTuple.date = data.date
        } else {
            self.dataTuple.date = nil
        }
        if data.rover != "" {
            self.dataTuple.rover = data.rover
        } else {
            self.dataTuple.rover = nil
        }
        self.dataTuple.page = data.page
        self.queryFromHistory = nil
        self.fetchQuery(task: self.dataTuple)
    }
    
    private func getAllData() {
        NasaClient.performRequest(with: .getAll) { [weak self] (isSuccess, response) in
            guard let self = self else {return}
            if isSuccess {
                self.repositoryDataSourse = response.0
                self.temp = response.0
                self.dataTuple.page = 1
                self.selectedItems()
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.roverPicker.reloadAllComponents()
                }
            }
        }
    }
    func fetchQuery(task: (String?, String?, String?, Int?)) {
        self.queryFromHistory = nil
        self.searchTimer?.invalidate()
        self.searchTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { [weak self] (_) in
            NasaClient.performRequest(with: .task(searchTask: self!.dataTuple)) { [weak self] (isSuccess, response) in
                guard let self = self else { return }
                if isSuccess {
                    
                    
                    var tempRepository: AllInfo?
                    if self.dataTuple.page != nil && self.dataTuple.page! > 1 {
                        tempRepository = response.1
                        if tempRepository?.photos != nil && (tempRepository?.photos?.count)! > 0 {
                            self.repositoryRovers?.photos?.append(contentsOf: (tempRepository?.photos)!)
                        } else {
                            return
                        }
                    } else {
                        self.repositoryRovers = response.1
                    }
                    
                    DispatchQueue.main.async {
                        try! self.realm.write {
                            let history = History()
                            history.rover = self.dataTuple.rover ?? ""
                            history.date = self.dataTuple.date ?? ""
                            history.camera = self.dataTuple.camera ?? ""
                            history.page = self.dataTuple.page ?? 0
                            self.realm.add(history)
                        }
                        self.tableView.reloadData()
                    }
                }
            }
        })
    }
    
    @IBAction func buttonClick(_ sender: UIButton) {
        if sender.tag == 0 {
            self.roverPicker.isHidden = false
        }
        if sender.tag == 1 {
            self.cameraPicker.isHidden = false
        }
        if sender.tag == 2 {
            self.datePicker.isHidden = false
        }
        self.toolbar.isHidden = false
    }
    @objc func getDateFromPicker() {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "yyyy-MM-dd"
        self.dateLabel.text = dateFormater.string(from: self.datePicker.date)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.repositoryRovers?.photos != nil {
            return (self.repositoryRovers?.photos!.count)!
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? NewTableViewCell {
            cell.avatarImageView.layer.cornerRadius = 8
            
            guard let data = self.repositoryRovers?.photos else { self.tableView.isHidden = true; return UITableViewCell() }
            self.tableView.isHidden = false
            cell.roverLabel.text = "Rover: " + data[indexPath.row].rover.name
            cell.cameraLabel.text = "Camera: " + data[indexPath.row].camera.full_name
            cell.dateLabel.text = "Date: " + data[indexPath.row].earth_date
            cell.setImageView(strUrl: data[indexPath.row].img_src)
            
            return cell
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastRow = indexPath.row
        if lastRow == (self.repositoryRovers?.photos!.count)! - 1 {
            self.dataTuple.page! += 1
            self.fetchQuery(task: self.dataTuple)
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? NewTableViewCell {
            self.oneCell = cell
        }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? NewTableViewCell else { return }
        ApplicationCoordinator.shared.push(.image(cell: cell))
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToScrollView" {
            if let vc = segue.destination as? ScrollViewController {
                vc.delegate = self.oneCell
            }
        }
    }
}

extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0 {
            return self.roversName.count
        } else if pickerView.tag == 1 {
            return self.camerasName.count
        } else {
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 0 {
            return self.roversName[row]
        } else if pickerView.tag == 1 {
            return self.camerasName[row]
        } else {
            return ""
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 0 {
            self.roverLabel.text = self.roversName[row]
        } else if pickerView.tag == 1 {
            self.cameraLabel.text = self.camerasName[row]
        }
    }
}
