import UIKit
import CoreLocation

struct ItemsViewControllerConstant {
  static let storedItemsKey = "storedItems"
}

class ItemsViewController: UIViewController {
  @IBOutlet weak var itemsTableView: UITableView!
  
  let locationManager = CLLocationManager()
  var items: [Item] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    locationManager.requestAlwaysAuthorization()
    locationManager.delegate = self
    
    loadItems()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func loadItems() {
    if let storedItems = UserDefaults.standard.array(forKey: ItemsViewControllerConstant.storedItemsKey) {
      for itemData in storedItems {
        let item: Item = NSKeyedUnarchiver.unarchiveObject(with: itemData as! Data) as! Item
        startMonitoringItem(item)
        items.append(item)
      }
    }
  }
  
  func persistItems() {
    var itemsDataArray:[Data] = []
    for item in items {
      let itemData = NSKeyedArchiver.archivedData(withRootObject: item)
      itemsDataArray.append(itemData)
    }
    UserDefaults.standard.set(itemsDataArray, forKey: ItemsViewControllerConstant.storedItemsKey)
  }
    
    func beaconRegionWithItem(_ item:Item) -> CLBeaconRegion {
        let beaconRegion = CLBeaconRegion(proximityUUID: item.uuid,
                                          major: item.majorValue,
                                          minor: item.minorValue,
                                          identifier: item.name)
        return beaconRegion
    }
    
    func startMonitoringItem(_ item: Item) {
        let beaconRegion = beaconRegionWithItem(item)
        locationManager.startMonitoring(for: beaconRegion)
        locationManager.startRangingBeacons(in: beaconRegion)
    }
    
    func stopMonitoringItem(_ item: Item) {
        let beaconRegion = beaconRegionWithItem(item)
        locationManager.stopMonitoring(for: beaconRegion)
        locationManager.stopRangingBeacons(in: beaconRegion)
    }
  
  // MARK: Unwind Segue actions
  @IBAction func saveItem(_ segue: UIStoryboardSegue) {
    let addItemViewController = segue.source as! AddItemViewController
    if let newItem = addItemViewController.newItem {
      items.append(newItem)
      itemsTableView.beginUpdates()
      let newIndexPath = IndexPath(row: items.count-1, section: 0)
      itemsTableView.insertRows(at: [newIndexPath], with: .automatic)
      itemsTableView.endUpdates()
      startMonitoringItem(newItem)
      persistItems()
    }
  }
  
  @IBAction func cancelItem(_ segue: UIStoryboardSegue) {
    // Do nothing
  }
}

// MARK: UITableViewDataSource
extension ItemsViewController : UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Item", for: indexPath) as! ItemCell
    let item = items[indexPath.row]
    cell.item = item
    return cell
  }
  
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      let itemToRemove = items[indexPath.row] as Item
      stopMonitoringItem(itemToRemove)
      tableView.beginUpdates()
      items.remove(at: indexPath.row)
      tableView.deleteRows(at: [indexPath], with: .automatic)
      tableView.endUpdates()
      persistItems()
    }
  }
}

// MARK: UITableViewDelegate
extension ItemsViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let item = items[indexPath.row] as Item
    let uuid = item.uuid.uuidString
    let detailMessage = "UUID: \(uuid)\nMajor: \(item.majorValue)\nMinor: \(item.minorValue)"
    let detailAlert = UIAlertController(title: "Details", message: detailMessage, preferredStyle: .alert)
    detailAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    self.present(detailAlert, animated: true, completion: nil)
  }
}

// MARK: - CLLocationManagerDelegate
extension ItemsViewController: CLLocationManagerDelegate {
}
