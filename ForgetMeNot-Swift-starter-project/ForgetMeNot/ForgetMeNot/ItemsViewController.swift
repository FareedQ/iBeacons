import UIKit

struct ItemsViewControllerConstant {
  static let storedItemsKey = "storedItems"
}

class ItemsViewController: UIViewController {
  @IBOutlet weak var itemsTableView: UITableView!
  
  var items: [Item] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    loadItems()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func loadItems() {
    if let storedItems = NSUserDefaults.standardUserDefaults().arrayForKey(ItemsViewControllerConstant.storedItemsKey) {
      for itemData in storedItems {
        let item: Item = NSKeyedUnarchiver.unarchiveObjectWithData(itemData as! NSData) as! Item
        items.append(item)
      }
    }
  }
  
  func persistItems() {
    var itemsDataArray:[NSData] = []
    for item in items {
      let itemData = NSKeyedArchiver.archivedDataWithRootObject(item)
      itemsDataArray.append(itemData)
    }
    NSUserDefaults.standardUserDefaults().setObject(itemsDataArray, forKey: ItemsViewControllerConstant.storedItemsKey)
  }
  
  // MARK: Unwind Segue actions
  @IBAction func saveItem(segue: UIStoryboardSegue) {
    let addItemViewController = segue.sourceViewController as! AddItemViewController
    if let newItem = addItemViewController.newItem {
      items.append(newItem)
      itemsTableView.beginUpdates()
      let newIndexPath = NSIndexPath(forRow: items.count-1, inSection: 0)
      itemsTableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Automatic)
      itemsTableView.endUpdates()
      persistItems()
    }
  }
  
  @IBAction func cancelItem(segue: UIStoryboardSegue) {
    // Do nothing
  }
}

// MARK: UITableViewDataSource
extension ItemsViewController : UITableViewDataSource {
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Item", forIndexPath: indexPath) as! ItemCell
    let item = items[indexPath.row]
    cell.item = item
    return cell
  }
  
  func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
  }
  
  func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
      let itemToRemove = items[indexPath.row] as Item
      tableView.beginUpdates()
      items.removeAtIndex(indexPath.row)
      tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
      tableView.endUpdates()
      persistItems()
    }
  }
}

// MARK: UITableViewDelegate
extension ItemsViewController: UITableViewDelegate {
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    let item = items[indexPath.row] as Item
    let uuid = item.uuid.UUIDString
    let detailMessage = "UUID: \(uuid)\nMajor: \(item.majorValue)\nMinor: \(item.minorValue)"
    let detailAlert = UIAlertController(title: "Details", message: detailMessage, preferredStyle: .Alert)
    detailAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
    self.presentViewController(detailAlert, animated: true, completion: nil)
  }
}
