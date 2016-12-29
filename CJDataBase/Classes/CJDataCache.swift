import Foundation
import CoreData

open class CJDataCache: NSObject {
    public init(identity: String) {
        super.init()
        _initializeCoreData(with: identity)
    }
    
    private let _innerBeanEntity = "CJInnerBean"
    private var _context: NSManagedObjectContext?
    
    public func data(for key:String) -> NSObject? {
        guard let _mo = _getManagedObject(for: key) else {
            return nil
        }
        let _data: Data = _mo.value(forKey: "data") as! Data
        let _unarchiver = NSKeyedUnarchiver(forReadingWith: _data)
        return _unarchiver.decodeObject() as! NSObject?
    }
    
    public func setData(_ data:NSCoding?, for key:String) -> Void {
        if data == nil {
            // delete
            guard let _mo = _getManagedObject(for: key) else {
                return
            }
            _context?.delete(_mo)
            _save()
        } else {
            guard let _mo = _getManagedObject(for: key) else {
                // insert
                let _bean = NSEntityDescription.insertNewObject(forEntityName: _innerBeanEntity, into: _context!)
                let _dataToBeSaved = NSMutableData()
                let _archiver = NSKeyedArchiver(forWritingWith: _dataToBeSaved)
                _archiver.encodeRootObject(data!)
                _archiver.finishEncoding()
                _bean.setValue(_dataToBeSaved, forKey: "data")
                _bean.setValue(key, forKey: "key")
                _save()
                return
            }
            
            // modify
            let _dataToBeSaved = NSMutableData()
            let _archiver = NSKeyedArchiver(forWritingWith: _dataToBeSaved)
            _archiver.encodeRootObject(data!)
            _archiver.finishEncoding()
            _mo.setValue(_dataToBeSaved, forKey: "data")
            _save()
        }
    }
    
    private func _getManagedObject(for key:String) -> NSManagedObject? {
        let _request = NSFetchRequest<NSFetchRequestResult>(entityName: _innerBeanEntity)
        _request.predicate = NSPredicate(format: "key == %@", key)
        do {
            guard let _beans = try _context?.fetch(_request) else {
                return nil
            }
            if _beans.count == 0 {
                return nil
            }
            return _beans[0] as? NSManagedObject
        } catch {
            NSLog("CJDataBase fetch object ERROR: %@", error.localizedDescription)
            return nil
        }
    }
    
    private func _save() {
        do {
            try _context?.save()
        } catch {
            NSLog("CJDataBase save ERROR: %@", error.localizedDescription)
        }
    }
    
    private func _initializeCoreData(with identity: String) {
        let _bundle: Bundle = Bundle(for: CJDataCache.self)
        guard let _modelURL = _bundle.url(forResource: "CJDataModel", withExtension: "momd") else {
            return
        }
        
        guard let _model = NSManagedObjectModel(contentsOf: _modelURL) else {
            return
        }
        
        let _psc = NSPersistentStoreCoordinator(managedObjectModel: _model)
        let _moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        _moc.persistentStoreCoordinator = _psc
        _context = _moc
        
        let _fileManager = FileManager.default
        let _documentsURL = _fileManager.urls(for: .documentDirectory, in: .userDomainMask).last
        let _storeURL = _documentsURL?.appendingPathComponent(identity + ".sqlite")
        let __psc = self._context?.persistentStoreCoordinator
        do {
            try __psc?.addPersistentStore(ofType: NSSQLiteStoreType,
                                          configurationName: nil,
                                          at: _storeURL,
                                          options: nil)
            NSLog("Init data manager.")
        } catch {
            fatalError("Error migrating store: \(error)")
        }
    }
}
