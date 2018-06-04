//
//  TeamDetailViewController.swift
//  ZeTeam
//
//  Created by Sarah Usher on 04/06/2018.
//  Copyright © 2018 Zuhlke. All rights reserved.
//

import UIKit

class TeamDetailViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let label = UILabel()
        label.text = "Team Page Description"
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        
        view.addSubview(label)
        
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
