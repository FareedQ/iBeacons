import Foundation

struct ItemConstant {
  static let nameKey = "name"
  static let uuidKey = "uuid"
  static let majorKey = "major"
  static let minorKey = "minor"
}

class Item: NSObject, NSCoding {
  let name: String
  let uuid: UUID
  let majorValue: UInt16
  let minorValue: UInt16
  
  init(name: String, uuid: UUID, majorValue: UInt16, minorValue: UInt16) {
    self.name = name
    self.uuid = uuid
    self.majorValue = majorValue
    self.minorValue = minorValue
  }

  // MARK: NSCoding
  required init(coder aDecoder: NSCoder) {
    if let aName = aDecoder.decodeObject(forKey: ItemConstant.nameKey) as? String {
      name = aName
    }
    else {
      name = ""
    }
    if let aUUID = aDecoder.decodeObject(forKey: ItemConstant.uuidKey) as? UUID {
      uuid = aUUID
    }
    else {
      uuid = UUID()
    }
    majorValue = UInt16(aDecoder.decodeInteger(forKey: ItemConstant.majorKey))
    minorValue = UInt16(aDecoder.decodeInteger(forKey: ItemConstant.minorKey))
  }
  
  func encode(with aCoder: NSCoder) {
    aCoder.encode(name, forKey: ItemConstant.nameKey)
    aCoder.encode(uuid, forKey: ItemConstant.uuidKey)
    aCoder.encode(Int(majorValue), forKey: ItemConstant.majorKey)
    aCoder.encode(Int(minorValue), forKey: ItemConstant.minorKey)
  }
}
