//
//  ViewController.swift
//  CJDataBase
//
//  Created by fminor on 12/26/2016.
//  Copyright (c) 2016 fminor. All rights reserved.
//

import UIKit
import CJDataBase

class CJBaseBean: NSObject, NSCoding {
    
    public var name: String? = ""
    public var beanId: Int = 0
    
    override init() {
        name = ""
        beanId = 0
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(beanId, forKey: "beanId")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        self.beanId = aDecoder.decodeInteger(forKey: "id")
        self.name = aDecoder.decodeObject(forKey: "name") as? String
    }
}

class ViewController: UIViewController {

    let kFirstGenerateIdent = "kFirstGenerateIdent"
    let kFirstGenerateModel = "kFirstGenerateModel"
    
    @IBOutlet weak var _label: UILabel!
    
    fileprivate let _dataManager = CJDataCache(identity: "CJDataBaseExample")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if _dataManager.data(for: kFirstGenerateIdent) == nil {
            let _ident = arc4random()
            let _identStr = _ident.description
            _dataManager.setData(_identStr as NSString, for: kFirstGenerateIdent)
            _label.text = _identStr
            
            let _bean = CJBaseBean()
            _bean.beanId = Int(_ident)
            _bean.name = _identStr
            _dataManager.setData(_bean, for: kFirstGenerateModel)
            
        } else {
            if let _ident = _dataManager.data(for: kFirstGenerateIdent) as? String {
                NSLog("%@", _ident)
                _label.text = _ident
            }
            
            if let _bean = _dataManager.data(for: kFirstGenerateModel) as? CJBaseBean {
                NSLog("%@", _bean)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
