/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    The `TextCharacteristicCell` represents text-input characteristics.
*/

import UIKit
import HomeKit

extension Data {
    var hexDescription: String {
        return reduce("") {$0 + String(format: "%02x", $1)}
    }
}

extension String {
    
    /// Create `Data` from hexadecimal string representation
    ///
    /// This takes a hexadecimal representation and creates a `Data` object. Note, if the string has any spaces or non-hex characters (e.g. starts with '<' and with a '>'), those are ignored and only hex characters are processed.
    ///
    /// - returns: Data represented by this hexadecimal string.
    
    func hexadecimal() -> Data? {
        var data = Data(capacity: characters.count / 2)
        
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, range: NSMakeRange(0, utf16.count)) { match, flags, stop in
            let byteString = (self as NSString).substring(with: match!.range)
            var num = UInt8(byteString, radix: 16)!
            data.append(&num, count: 1)
        }
        
        guard data.count > 0 else { return nil }
        
        return data
    }
    
}

/**
    A `CharacteristicCell` subclass that contains a text field.
    Used for text-input characteristics.
*/
class DataCharacteristicCell: CharacteristicCell, UITextFieldDelegate {
    // MARK: Properties
    
    @IBOutlet weak var textField: UITextField!
    
    
    
    override var characteristic: HMCharacteristic! {
        didSet {
            textField.alpha = enabled ? 1.0 : CharacteristicCell.DisabledAlpha
            textField.isUserInteractionEnabled = enabled
        }
    }
    
    /// If notify is false, sets the text field's text from the value.
    override func setValue(_ newValue: CellValueType?, notify: Bool) {
        super.setValue(newValue, notify: notify)
        if !notify {
            if let newStringValue = newValue as? String {
                textField.text = newStringValue
            }
            else{
                if let newStringValue = newValue as? Data {
                    textField.text = textField.text! + " ; " + newStringValue.hexDescription;
                }
            }
        }
    }
    
    /// Dismiss the keyboard when "Go" is clicked
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    /// Sets the value of the characteristic when editing is complete.
    func textFieldDidEndEditing(_ textField: UITextField) {
        setValue((textField.text?.hexadecimal())! as CellValueType, notify: true)
    }
}
