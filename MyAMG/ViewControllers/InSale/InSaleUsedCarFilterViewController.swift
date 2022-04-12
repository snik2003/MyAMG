//
//  InSaleUsedCarFilterViewController.swift
//  MyAMG
//
//  Created by Сергей Никитин on 22/08/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import UIKit

class InSaleUsedCarFilterViewController: InnerViewController, UITableViewDelegate, UITableViewDataSource {

    var delegate: InSaleCarListViewController!
    var selectedClass: AMGObject!
    var filter: AMGUsedFilter!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet var certifiedCell: AMGTableViewCell!
    @IBOutlet var cityCell: AMGTableViewCell!
    @IBOutlet var dealerCell: AMGTableViewCell!
    @IBOutlet var modelCell: AMGTableViewCell!
    @IBOutlet var engineTypeCell: AMGTableViewCell!
    @IBOutlet var driveCell: AMGTableViewCell!
    @IBOutlet var yearCell: AMGTableViewCell!
    @IBOutlet var runCell: AMGTableViewCell!
    @IBOutlet var engineVolumeCell: AMGTableViewCell!
    @IBOutlet var priceCell: AMGTableViewCell!
    @IBOutlet var sortCell: AMGTableViewCell!
    @IBOutlet var doneCell: AMGTableViewCell!
    @IBOutlet var bodyColorCell: AMGTableViewCell!
    
    @IBOutlet weak var certifiedSwitch: UISwitch!
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var dealerLabel: UILabel!
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var engineTypeLabel: UILabel!
    @IBOutlet weak var driveLabel: UILabel!
    @IBOutlet weak var sortLabel: UILabel!
    
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var runLabel: UILabel!
    @IBOutlet weak var engineLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var yearSlider: MMRangeSlider!
    @IBOutlet weak var runSlider: MMRangeSlider!
    @IBOutlet weak var engineSlider: MMRangeSlider!
    @IBOutlet weak var priceSlider: MMRangeSlider!
    
    @IBOutlet weak var bodyColorCollectionView: UICollectionView!
    
    @IBOutlet weak var buttonASC: UIButton!
    @IBOutlet weak var buttonDesc: UIButton!
    
    let numFormatter = NumberFormatter()
    
    var pickerView: UIPickerView!
    var toolbar: UIToolbar!
    var fadeView: UIView!
    var pickerType = PickerType.UnknownTypePicker
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bChangedFormData = true
        titleLabel.text = "Фильтр"
        
        numFormatter.numberStyle = .decimal
        numFormatter.groupingSeparator = " "
        numFormatter.maximumFractionDigits = 0
        
        bodyColorCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        bodyColorCollectionView.allowsMultipleSelection = true
        
        fillFormWithCurrentFilter()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        makePickerView()
    }
    
    override func backButtonAction(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func fillFormWithCurrentFilter() {
        
        certifiedSwitch.isOn = filter.onlyCertified
        
        cityLabel.text = "Выберите город"
        cityLabel.alpha = 0.3
        
        if filter.selectedCityId > 0 {
            if let city = filter.cities.filter({ $0.id == filter.selectedCityId }).first {
                cityLabel.text = city.name
                cityLabel.alpha = 1.0
            }
        }
        
        
        dealerLabel.text = "Выберите дилера"
        dealerLabel.alpha = 0.3
        
        if filter.selectedDealerId > 0 {
            if let dealer = filter.dealers.filter({ $0.id == filter.selectedDealerId }).first {
                dealerLabel.text = dealer.name
                dealerLabel.alpha = 1.0
            }
        }
        
        
        modelLabel.text = "Выберите модель"
        modelLabel.alpha = 0.3
        
        if filter.selectedModelId > 0 {
            if let model = filter.models.filter({ $0.id == filter.selectedModelId }).first {
                modelLabel.text = model.name
                modelLabel.alpha = 1.0
            }
        }
        
        
        engineTypeLabel.text = "Выберите двигатель"
        engineTypeLabel.alpha = 0.3
        
        if filter.selectedEngineType > 0 {
            if let engine = filter.engineTypes.filter({ $0.id == filter.selectedEngineType }).first {
                engineTypeLabel.text = engine.name
                engineTypeLabel.alpha = 1.0
            }
        }
        
        
        driveLabel.text = "Выберите тип привода"
        driveLabel.alpha = 0.3
        
        if filter.selectedDrive > 0 {
            if let drive = filter.drives.filter({ $0.id == filter.selectedDrive }).first {
                driveLabel.text = drive.name
                driveLabel.alpha = 1.0
            }
        }
        
        
        sortLabel.text = "Без сортировки"
        sortLabel.alpha = 0.3
        
        if filter.sortField != "" {
            sortLabel.text = filter.sortField
            sortLabel.alpha = 1.0
        }
        
        
        yearSlider.minimumValue = CGFloat(filter.minimalYear)
        yearSlider.maximumValue = CGFloat(filter.maximumYear)
        yearSlider.minimumRange = CGFloat(filter.scaleYear)
        
        yearSlider.selectedMinimumValue = filter.selectedMinimalYear > 0 ? CGFloat(filter.selectedMinimalYear) : yearSlider.minimumValue
        yearSlider.selectedMaximumValue = filter.selectedMaximumYear > 0 ? CGFloat(filter.selectedMaximumYear) : yearSlider.maximumValue
        rangeSliderChangeAction(sender: yearSlider)
        yearSlider.layoutSubviews()
        
        
        runSlider.minimumValue = CGFloat(filter.minimalRun)
        runSlider.maximumValue = CGFloat(filter.maximumRun)
        runSlider.minimumRange = CGFloat(filter.scaleRun)
        
        runSlider.selectedMinimumValue = filter.selectedMinimalRun > 0 ? CGFloat(filter.selectedMinimalRun) : runSlider.minimumValue
        runSlider.selectedMaximumValue = filter.selectedMaximumRun > 0 ? CGFloat(filter.selectedMaximumRun) : runSlider.maximumValue
        rangeSliderChangeAction(sender: runSlider)
        runSlider.layoutSubviews()
        
        
        engineSlider.minimumValue = CGFloat(filter.minimalEngineVolume)
        engineSlider.maximumValue = CGFloat(filter.maximumEngineVolume)
        engineSlider.minimumRange = CGFloat(filter.scaleEngineVolume)
        
        engineSlider.selectedMinimumValue = filter.selectedMinimalEngineVolume > 0 ? CGFloat(filter.selectedMinimalEngineVolume) : engineSlider.minimumValue
        engineSlider.selectedMaximumValue = filter.selectedMaximumEngineVolume > 0 ? CGFloat(filter.selectedMaximumEngineVolume) : engineSlider.maximumValue
        rangeSliderChangeAction(sender: engineSlider)
        engineSlider.layoutSubviews()
        
        
        priceSlider.minimumValue = CGFloat(filter.minimalPrice)
        priceSlider.maximumValue = CGFloat(filter.maximumPrice)
        priceSlider.minimumRange = CGFloat(filter.scalePrice)
        
        priceSlider.selectedMinimumValue = filter.selectedMinimalPrice > 0 ? CGFloat(filter.selectedMinimalPrice) : priceSlider.minimumValue
        priceSlider.selectedMaximumValue = filter.selectedMaximumPrice > 0 ? CGFloat(filter.selectedMaximumPrice) : priceSlider.maximumValue
        rangeSliderChangeAction(sender: priceSlider)
        priceSlider.layoutSubviews()
        
        if filter.sortOrder == 0 {
            sortOrderAction(sender: buttonASC)
        } else {
            sortOrderAction(sender: buttonDesc)
        }
    }
    
    @IBAction func doneButtonAction() {
        
        showHUD()
        AMGDataManager().getUsedCarsWithFilter(filter: filter, success: { cars in
            OperationQueue.main.addOperation {
                self.hideHUD()
                
                if cars.count == 0 {
                    self.showAttention(message: "По Вашим критериям автомобилей не найдено. Попробуйте расширить рамки поиска.")
                    return
                }
                
                self.delegate.usedFilter = self.filter
                self.delegate.cars = cars
                self.delegate.cacheImages.removeAll()
                self.delegate.tableView.reloadData()
                self.delegate.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                self.dismiss(animated: true, completion: nil)
            }
        }, failure: {
            OperationQueue.main.addOperation {
                self.hideHUD()
                self.showServerError()
            }
        })
    }
    
    @IBAction func resetFilterAction() {
        filter.reset()
        fillFormWithCurrentFilter()
        bodyColorCollectionView.reloadData()
        tableView.reloadData()
        doneButtonAction()
    }
    
    @IBAction func switchValueChanged() {
        filter.onlyCertified = certifiedSwitch.isOn
    }
    
    @IBAction func rangeSliderChangeAction(sender: MMRangeSlider) {
        if sender == yearSlider {
            filter.selectedMinimalYear = Int(sender.selectedMinimumValue)
            filter.selectedMaximumYear = Int(sender.selectedMaximumValue)
            
            yearLabel.text = "c \(filter.selectedMinimalYear) по \(filter.selectedMaximumYear)"
        }
        
        if sender == runSlider {
            filter.selectedMinimalRun = Double(sender.selectedMinimumValue)
            filter.selectedMaximumRun = Double(sender.selectedMaximumValue)
            
            runLabel.text = "от \(numFormatter.string(from: NSNumber(value: filter.selectedMinimalRun)) ?? "0") до \(numFormatter.string(from: NSNumber(value: filter.selectedMaximumRun)) ?? "0") км."
        }
        
        if sender == engineSlider {
            filter.selectedMinimalEngineVolume = Double(sender.selectedMinimumValue)
            filter.selectedMaximumEngineVolume = Double(sender.selectedMaximumValue)
            
            engineLabel.text = "от \(numFormatter.string(from: NSNumber(value: filter.selectedMinimalEngineVolume)) ?? "0") до \(numFormatter.string(from: NSNumber(value: filter.selectedMaximumEngineVolume)) ?? "0") куб.см."
        }
        
        if sender == priceSlider {
            filter.selectedMinimalPrice = Double(sender.selectedMinimumValue)
            filter.selectedMaximumPrice = Double(sender.selectedMaximumValue)
            
            priceLabel.text = "от \(numFormatter.string(from: NSNumber(value: filter.selectedMinimalPrice)) ?? "0") до \(numFormatter.string(from: NSNumber(value: filter.selectedMaximumPrice)) ?? "0") ₽"
        }
    }
    
    @IBAction func sortOrderAction(sender: UIButton) {
        if sender == buttonASC {
            buttonASC.tag = 1
            buttonASC.setImage(UIImage(named: "checked"), for: .normal)
            buttonDesc.tag = 0
            buttonDesc.setImage(UIImage(named: "unchecked"), for: .normal)
            filter.sortOrder = 0
        }
        
        if sender == buttonDesc {
            buttonASC.tag = 0
            buttonASC.setImage(UIImage(named: "unchecked"), for: .normal)
            buttonDesc.tag = 1
            buttonDesc.setImage(UIImage(named: "checked"), for: .normal)
            filter.sortOrder = 1
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 13
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 68
        case 1:
            return 48
        case 2:
            return 48
        case 3:
            return 48
        case 4:
            return 48
        case 5:
            return 48
        case 6:
            return 96
        case 7:
            return 96
        case 8:
            return 96
        case 9:
            return 96
        case 10:
            return 135
        case 11:
            if filter.sortField != "" { return 96 }
            return 48
        case 12:
            return 150
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            return certifiedCell
        case 1:
            return cityCell
        case 2:
            return dealerCell
        case 3:
            return modelCell
        case 4:
            return engineTypeCell
        case 5:
            return driveCell
        case 6:
            return yearCell
        case 7:
            return runCell
        case 8:
            return engineVolumeCell
        case 9:
            return priceCell
        case 10:
            return bodyColorCell
        case 11:
            return sortCell
        case 12:
            return doneCell
        default:
            return UITableViewCell()
        }
    }
}

extension InSaleUsedCarFilterViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filter.bodyColors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if filter.selectedBodyColors.filter({ $0.self == filter.bodyColors[indexPath.item].id }).count > 0 {
            cell.layer.borderWidth = 6
        } else {
            cell.layer.borderWidth = 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = filter.bodyColors[indexPath.item].color
        addImageOverlayToCell(cell)
        cell.layer.borderColor = UIColor(red: 217/255, green: 37/255, blue: 43/255, alpha: 1).cgColor
        cell.layer.borderWidth = 0
        cell.layer.cornerRadius = 36
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if filter.selectedBodyColors.filter({ $0.self == filter.bodyColors[indexPath.item].id }).count > 0 {
            filter.selectedBodyColors = filter.selectedBodyColors.filter({ $0.self != filter.bodyColors[indexPath.item].id })
        } else {
            filter.selectedBodyColors.append(filter.bodyColors[indexPath.item].id)
        }
        
        collectionView.reloadItems(at: [indexPath])
    }
    
    func addImageOverlayToCell(_ cell: UICollectionViewCell) {
        for subview in cell.subviews {
            if subview is UIImageView { return }
        }
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 72, height: 72))
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "blink.png")
        imageView.layer.cornerRadius = 36
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        cell.addSubview(imageView)
    }
}

extension InSaleUsedCarFilterViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBAction func cityButtonAction() {
        pickerType = .CityTypePicker
        loadPicker()
    }
    
    @IBAction func dealerButtonAction() {
        
        if filter.dealers.count == 0 {
            showAttention(message: "Пожалуйста, выберите сначала город")
            return
        }
        
        pickerType = .DealerTypePicker
        loadPicker()
    }
    
    @IBAction func modelButtonAction() {
        pickerType = .ModelTypePicker
        loadPicker()
    }
    
    @IBAction func engineButtonAction() {
        pickerType = .EngineTypePicker
        loadPicker()
    }
    
    @IBAction func driveButtonAction() {
        pickerType = .DrivePicker
        loadPicker()
    }
    
    @IBAction func sortButtonAction() {
        pickerType = .SortPicker
        loadPicker()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        switch pickerType {
        case .CityTypePicker:
            return filter.cities.count + 1
        case .DealerTypePicker:
            return filter.dealers.count + 1
        case .ModelTypePicker:
            return filter.models.count + 1
        case .EngineTypePicker:
            return filter.engineTypes.count + 1
        case .DrivePicker:
            return filter.drives.count + 1
        case .SortPicker:
            return filter.sortingFields.count - 1
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        
        return 36
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        var index = row
        
        if index == 0 {
            switch pickerType {
            case .CityTypePicker:
                return "Любой город"
            case .DealerTypePicker:
                return "Любой дилер"
            case .ModelTypePicker:
                return "Любая модель"
            case .EngineTypePicker:
                return "Любой двигатель"
            case .DrivePicker:
                return "Любой тип привода"
            case .SortPicker:
                return "Без сортировки"
            default:
                return ""
            }
        }
        
        index -= 1
        
        switch pickerType {
        case .CityTypePicker:
            return filter.cities[index].name
        case .DealerTypePicker:
            return filter.dealers[index].name
        case .ModelTypePicker:
            return filter.models[index].name
        case .EngineTypePicker:
            return filter.engineTypes[index].name
        case .DrivePicker:
            return filter.drives[index].name
        case .SortPicker:
            return filter.sortingFields[index + 2]
        default:
            return ""
        }
    }
    
    @objc func donePickerAction() {
        
        bChangedFormData = true
        var index = pickerView.selectedRow(inComponent: 0)
        
        if index == 0 {
            switch pickerType {
            case .CityTypePicker:
                filter.selectedCityId = 0
                cityLabel.text = "Выберите город"
                cityLabel.alpha = 0.3
                
                filter.selectedDealerId = 0
                dealerLabel.text = "Выберите дилера"
                dealerLabel.alpha = 0.3
                filter.setSelectedCityId(cityId: filter.selectedCityId)
                
                break
            case .DealerTypePicker:
                filter.selectedDealerId = 0
                dealerLabel.text = "Выберите дилера"
                dealerLabel.alpha = 0.3
                break
            case .ModelTypePicker:
                filter.selectedModelId = 0
                modelLabel.text = "Выберите модель"
                modelLabel.alpha = 0.3
                break
            case .EngineTypePicker:
                filter.selectedEngineType = 0
                engineTypeLabel.text = "Выберите двигатель"
                engineTypeLabel.alpha = 0.3
                break
            case .DrivePicker:
                filter.selectedDrive = 0
                driveLabel.text = "Выберите тип привода"
                driveLabel.alpha = 0.3
                break
            case .SortPicker:
                filter.sortField = ""
                sortLabel.text = "Без сортировки"
                sortLabel.alpha = 0.3
                tableView.reloadData()
                break
            default:
                break
            }
            
            cancelPickerAction()
            return
        }
        
        index -= 1
        
        switch pickerType {
        case .CityTypePicker:
            filter.selectedCityId = filter.cities[index].id
            cityLabel.text = filter.cities[index].name
            cityLabel.alpha = 1
            
            filter.selectedDealerId = 0
            dealerLabel.text = "Выберите дилера"
            dealerLabel.alpha = 0.3
            filter.setSelectedCityId(cityId: filter.selectedCityId)
            
            break
        case .DealerTypePicker:
            filter.selectedDealerId = filter.dealers[index].id
            dealerLabel.text = filter.dealers[index].name
            dealerLabel.alpha = 1
            break
        case .ModelTypePicker:
            filter.selectedModelId = filter.models[index].id
            modelLabel.text = filter.models[index].name
            modelLabel.alpha = 1
            break
        case .EngineTypePicker:
            filter.selectedEngineType = filter.engineTypes[index].id
            engineTypeLabel.text = filter.engineTypes[index].name
            engineTypeLabel.alpha = 1
            break
        case .DrivePicker:
            filter.selectedDrive = filter.drives[index].id
            driveLabel.text = filter.drives[index].name
            driveLabel.alpha = 1
            break
        case .SortPicker:
            filter.sortField = filter.sortingFields[index + 2]
            sortLabel.text = filter.sortingFields[index + 2]
            sortLabel.alpha = 1
            tableView.reloadData()
            break
        default:
            break
        }
        
        cancelPickerAction()
    }
    
    func loadPicker() {
        self.view.endEditing(true)
        pickerView.reloadAllComponents()
        pickerView.selectRow(0, inComponent: 0, animated: false)
        pickerView.isHidden = false
        toolbar.isHidden = false
        fadeView.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            let bounds = self.view.bounds
            self.pickerView.frame = CGRect(x: 0, y: bounds.height - 206, width: bounds.width, height: 206)
            self.toolbar.frame = CGRect(x: 0, y: bounds.height - 250, width: bounds.width, height: 44)
        })
    }
    
    @objc func cancelPickerAction() {
        UIView.animate(withDuration: 0.3, animations: {
            self.fadeView.isHidden = true
            let bounds = self.view.bounds
            self.pickerView.frame = CGRect(x: 0, y: bounds.height, width: bounds.width, height: 206)
            self.toolbar.frame = CGRect(x: 0, y: bounds.height, width: bounds.width, height: 44)
        }, completion: { finished in
            self.toolbar.isHidden = true
            self.pickerView.isHidden = true
        })
    }
    
    func makePickerView() {
        let bounds = view.bounds
        
        pickerView = UIPickerView(frame: CGRect(x: 0, y: bounds.height, width: bounds.width, height: 206))
        pickerView.backgroundColor = .lightGray
        pickerView.showsSelectionIndicator = true
        pickerView.dataSource = self
        pickerView.delegate = self
        
        let doneButton = UIBarButtonItem(title: "Готово", style: .done, target: self, action: #selector(donePickerAction))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Отмена", style: .plain, target: self, action: #selector(cancelPickerAction))
        
        toolbar = UIToolbar(frame: CGRect(x: 0, y: bounds.height, width: bounds.width, height: 44))
        toolbar.tintColor = .red
        toolbar.barTintColor = .darkText
        toolbar.sizeToFit()
        toolbar.items = [cancelButton, spaceButton, doneButton]
        
        fadeView = UIView(frame: bounds)
        fadeView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.45)
        
        pickerView.isHidden = true
        toolbar.isHidden = true
        fadeView.isHidden = true
        
        view.addSubview(fadeView)
        view.addSubview(toolbar)
        view.addSubview(pickerView)
    }
}

