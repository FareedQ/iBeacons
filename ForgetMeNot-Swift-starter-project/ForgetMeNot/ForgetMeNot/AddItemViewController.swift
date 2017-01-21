import UIKit

class AddItemViewController: UITableViewController {
  @IBOutlet weak var saveBarButtonItem: UIBarButtonItem!
  @IBOutlet weak var nameTextField: UITextField!
  @IBOutlet weak var uuidTextField: UITextField!
  @IBOutlet weak var majorIdTextField: UITextField!
  @IBOutlet weak var minorIdTextField: UITextField!
  
  var nameFieldValid = false
  var UUIDFieldValid = false
  var newItem: Item?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    saveBarButtonItem.isEnabled = false
    
    nameTextField.addTarget(self, action: #selector(AddItemViewController.nameTextFieldChanged(_:)), for: .editingChanged)
    uuidTextField.addTarget(self, action: #selector(AddItemViewController.uuidTextFieldChanged(_:)), for: .editingChanged)
  }
  
  func nameTextFieldChanged(_ textField: UITextField) {
    nameFieldValid = (textField.text!.characters.count > 0)
    saveBarButtonItem.isEnabled = (UUIDFieldValid && nameFieldValid)
  }
  
  func uuidTextFieldChanged(_ textField: UITextField) {
    let numberOfMatches = numberOfMatchesInString(textField.text!)
    UUIDFieldValid = (numberOfMatches > 0)
    
    saveBarButtonItem.isEnabled = (UUIDFieldValid && nameFieldValid)
  }
    
    func numberOfMatchesInString(_ string:String) -> Int {
        do {
            let pattern = "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$"
            let regex = try NSRegularExpression(pattern: pattern)
            let nsString = string as NSString
            let results = regex.numberOfMatches(in: string, range: NSRange(location: 0, length: nsString.length))
            return results
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return -1
        }
    }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "SaveItemSegue" {
      let uuid = UUID(uuidString: uuidTextField.text!)
      let major = UInt16(Int(majorIdTextField.text!)!)
      let minor = UInt16(Int(minorIdTextField.text!)!)
      
      newItem = Item(name: nameTextField.text!, uuid: uuid!, majorValue: major, minorValue: minor)
    }
  }
}
