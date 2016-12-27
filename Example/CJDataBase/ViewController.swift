//
//  ViewController.swift
//  CJDataBase
//
//  Created by fminor on 12/26/2016.
//  Copyright (c) 2016 fminor. All rights reserved.
//

import UIKit
import CJDataBase

class ViewController: UIViewController {

    let kFirstGenerateIdent = "kFirstGenerateIdent"
    
    @IBOutlet weak var _label: UILabel!
    
    private let _dataManager = CJDataBase(identity: "CJDataBaseExample")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if _dataManager.data(for: kFirstGenerateIdent) == nil {
            let _ident = arc4random()
            let _identStr = _ident.description
            _dataManager.setData(_identStr as NSString, for: kFirstGenerateIdent)
            _label.text = _identStr
        } else {
            if let _ident = _dataManager.data(for: kFirstGenerateIdent) as? String {
                NSLog("%@", _ident)
                _label.text = _ident
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
