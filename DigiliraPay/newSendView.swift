//
//  newSendView.swift
//  DigiliraPay
//
//  Created by Hayrettin İletmiş on 18.10.2020.
//  Copyright © 2020 Ilao. All rights reserved.
//

import Foundation
import UIKit


class newSendView: UIView, UIPickerViewDelegate, UIPickerViewDataSource {
    var selectedCountry: String?
    
    weak var delegate: NewCoinSendDelegate?
    
    var pickerData: [String] = [String]()
    let thePicker = UIPickerView()

    @IBOutlet weak var coinView: UIView!
    @IBOutlet weak var coinLbl: UILabel!
    @IBOutlet weak var coinTextField: UITextField!
    @IBOutlet weak var textAmount: UITextField!
    @IBOutlet weak var coinSwitch: UISegmentedControl!
    @IBOutlet weak var totalBalanceLabel: UILabel!
    @IBOutlet weak var commissionLabel: UILabel!
    @IBOutlet weak var fetchQR: UIImageView!
    @IBOutlet weak var recipientText: UITextField!
    var transaction: SendTrx?
    
    @IBAction func sendMoneyButton(_ sender: Any) {
        delegate?.sendCoinNew(params: transaction!)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        coinTextField.text = pickerData[0]
        return 1 // number of session
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count // number of dropdown items
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row] // dropdown item
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCountry = pickerData[row] // selected item
        coinTextField.text = selectedCountry
    }
    
    @IBAction func btnCancel(_ sender: Any) {
        delegate?.dismissNewSend()
    }
    

    override func awakeFromNib()
    {
        pickerData = ["Bitcoin", "Ethereum", "Waves", "Charity"]
        createPickerView()
        dismissPickerView()
        recipientText?.addDoneCancelToolbar()
        textAmount?.addDoneCancelToolbar()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(getQR))
        fetchQR.isUserInteractionEnabled = true
        fetchQR.addGestureRecognizer(tap)

    }
    
    @objc func getQR () {
        delegate?.readAddressQR()
    }
    
    
    
    func createPickerView() {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        coinTextField.inputView = pickerView
    }
    func dismissPickerView() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let button = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(action1))
        toolBar.setItems([button], animated: true)
        toolBar.isUserInteractionEnabled = true
        coinTextField.inputAccessoryView = toolBar
    }
    
    @objc func action1() {
          self.endEditing(true)
    }
    
}
 
 
