//
//  LaunchVC.swift
//  ChatGPT Ultivic
//
//  Created by SHIVAM GAIND on 02/05/23.
//

import UIKit

class LaunchVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let vc =  self.storyboard?.instantiateViewController(withIdentifier: "WelcomeVC") as! WelcomeVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
