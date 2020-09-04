//
//  ViewController.swift
//  SpokestackTray
//
//  Created by Cory D. Wiles on 8/9/20.
//

import Foundation
import UIKit

public class ViewController: UIViewController {
    
    // MARK: Intenral (properties)
    
    weak var activeField: UITextField?
    
    // MARK: Initializers
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View Life Cycle
    
    public override func loadView() {
        
        self.view = UIView(frame: UIScreen.main.bounds)
        self.view.backgroundColor = .white
        
        let backButtonItem: UIBarButtonItem = UIBarButtonItem(title: "",
                                                              style: .done,
                                                              target: nil,
                                                              action: nil)
        
        self.navigationItem.backBarButtonItem = backButtonItem
        self.edgesForExtendedLayout = []
        self.overrideUserInterfaceStyle = .light
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}
