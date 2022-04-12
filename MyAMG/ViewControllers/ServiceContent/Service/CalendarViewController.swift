//
//  CalendarViewController.swift
//  MyAMG
//
//  Created by Сергей Никитин on 01/08/2019.
//  Copyright © 2019 Mercedes-Benz Russia SAO. All rights reserved.
//

import UIKit

class CalendarViewController: InnerViewController, FSCalendarDelegate, FSCalendarDataSource, UIPickerViewDelegate, UIPickerViewDataSource {

    var delegate: ServiceOrderViewController!
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var selectButton: AMGButton!
    
    var shedules: [AMGServiceShedule] = []
    
    var gregorianCalendar: Calendar!
    var dateFormatter: DateFormatter!
    
    var selectedTimeInterval = ""
    var selectedPickerRow = 0
    var avaliableTimeIntervals: [String] = []
    var datesWithEvent: [Date] = []
    
    var pickerView: UIPickerView!
    var toolbar: UIToolbar!
    var fadeView: UIView!
    var pickerType = PickerType.UnknownTypePicker
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bChangedFormData = true
        titleLabel.text = "Выберите дату"
        
        setSchedules(shedules: self.shedules)
        initCalendar()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        makePickerView()
    }
    
    override func backButtonAction(sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    func initCalendar() {
        self.gregorianCalendar = Calendar(identifier: .gregorian)
        
        dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        calendar.appearance.caseOptions = [.headerUsesUpperCase, .weekdayUsesUpperCase]
        calendar.appearance.headerDateFormat = "LLLL YYYY"
        calendar.locale = Locale(identifier: "ru_RU")
        avaliableTimeIntervals = []
        
        calendar.select(dateFormatter.date(from: "2016/12/05"))
        calendar.accessibilityIdentifier = "calendar"
    }
    
    func setSchedules(shedules: [AMGServiceShedule]) {
        datesWithEvent = []
        for shedule in shedules.filter({ $0.timeIntervals.count > 0}) {
            if shedule.numberOfFreeIntervals() > 0 {
                datesWithEvent.append(shedule.date)
            }
        }
        calendar.reloadData()
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        
        if datesWithEvent.contains(date) { return 1 }
        return 0
    }
    
    func minimumDate(for calendar: FSCalendar) -> Date {
        
        if shedules.count > 0 {
            if let date = shedules.sorted(by: { $0.date < $1.date }).first?.date {
                return date
            }
        }
        
        return Date()
    }
    
    func maximumDate(for calendar: FSCalendar) -> Date {
        
        if shedules.count > 0 {
            if let date = shedules.sorted(by: { $0.date > $1.date }).first?.date {
                return date
            }
        }
        
        return Date()
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        
        let shouldSelect = datesWithEvent.contains(date)
        if (!shouldSelect) {
            showAttention(message: "К сожалению, на эту дату уже всё занято. Пожалуйста, выберите другую дату.")
        } else {
            print("Попытка выбрать дату \(dateFormatter.string(from: date))")
        }
        return shouldSelect
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        if (monthPosition == FSCalendarMonthPosition.next || monthPosition == FSCalendarMonthPosition.previous) {
            calendar.setCurrentPage(date, animated: true)
        }
        
        avaliableTimeIntervals = []
        for s in shedules {
            if (s.date == date) {
                for interval in s.timeIntervals.filter({ $0.isFree == true }) {
                    avaliableTimeIntervals.append(interval.intervalAsString)
                }
                break
            }
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM"
        dateFormatter.locale = Locale(identifier: "ru_RU")
        selectButton.setTitle("Выбрать \(dateFormatter.string(from: date))", for: .normal)
        selectButton.isHidden = false
    }
    
    @IBAction func selectDateAction() {
        loadPicker()
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        
        self.view.layoutIfNeeded()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return avaliableTimeIntervals.count
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        
        return 36
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return avaliableTimeIntervals[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedPickerRow = row
    }
    
    @objc func donePickerAction() {
        
        for shedule in self.shedules {
            if shedule.date == calendar.selectedDate {
                for interval in shedule.timeIntervals {
                    selectedTimeInterval = avaliableTimeIntervals[selectedPickerRow]
                    if interval.intervalAsString == selectedTimeInterval {
                        
                        delegate.workDateCell.setValidated(validated: true)
                        
                        let formatter = DateFormatter()
                        formatter.dateFormat = "dd.MM.yyyy"
                        let dateAsString = formatter.string(from: calendar.selectedDate!)
                        delegate.workDateLabel.text = "\(dateAsString) \(selectedTimeInterval)"
                        delegate.workDateLabel.textColor = .black
                        formatter.dateFormat = "dd.MM.yyyy HH:mm"
                        delegate.selectedDate = calendar.selectedDate!
                        delegate.selectedInterval = interval
                        delegate.selectedTimeInterval = selectedTimeInterval
                        
                        if let manager = delegate.filteredManagersBySelectedDate().first {
                            delegate.managerCell.setValidated(validated: true)
                            delegate.selectedManager = manager
                            delegate.managerLabel.text = manager.name
                            delegate.managerLabel.textColor = .black
                        } else {
                            delegate.selectedManager = nil
                            delegate.managerLabel.text = "Выберите менеджера"
                            delegate.managerLabel.textColor = UIColor(white: 0, alpha: 0.3)
                        }
                        
                        delegate.tableView.reloadData()
                        cancelPickerAction()
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
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
