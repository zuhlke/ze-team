//
//  TeamDetailViewController.swift
//  ZeTeam
//
//  Created by Sarah Usher on 04/06/2018.
//  Copyright © 2018 Zuhlke. All rights reserved.
//

import UIKit
import RxSwift
class TeamDetailViewController: UIViewController {
    
    var editableDescription: UITextView!
    var labelDescription: UILabel!
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        makeEditButton()
        makeDescription()
    }
    
    private func makeEditButton(){
        let button = UIBarButtonItem(barButtonSystemItem: .edit, target: nil, action: nil)
        navigationItem.rightBarButtonItem = button
        button.rx.tap.subscribe(onNext: { _ in
            self.editableDescription.isHidden = false
            self.labelDescription.isHidden = true
        }).disposed(by: bag)
    }
    
    private func makeDescription(){
        labelDescription = UILabel()
        
        labelDescription.sizeToFit()
        labelDescription.translatesAutoresizingMaskIntoConstraints = false
        labelDescription.numberOfLines = 0
        
        let fakeText = "Lorem ipsum dolor sit amet consectetur adipiscing elit vel dis enim elementum et, semper ornare duis felis urna magnis donec proin accumsan erat purus. Lobortis risus ac torquent litora hendrerit massa suspendisse ultricies, integer nunc velit penatibus orci at sollicitudin turpis, eleifend ut ultrices aliquam feugiat tempor congue. Nisl per himenaeos curae justo ligula varius montes tincidunt ridiculus venenatis, pretium porttitor odio sem eget cras lacus maecenas phasellus, senectus sociosqu eu vulputate nulla facilisi blandit bibendum conubia. Malesuada parturient leo est cum class ante morbi hac, consequat quis iaculis ad lacinia condimentum inceptos, tristique convallis nam platea etiam potenti sociis."
        
        labelDescription.text = fakeText
        //label.text = "Team Page Description"
        
        view.addSubview(labelDescription)
        
        labelDescription.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 50).isActive = true
        labelDescription.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
        labelDescription.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor).isActive = true
        
        editableDescription = UITextView()
        editableDescription.text = fakeText
        editableDescription.isHidden = true
        editableDescription.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(editableDescription)
        
        editableDescription.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 50).isActive = true
        editableDescription.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
        editableDescription.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor).isActive = true
        editableDescription.heightAnchor.constraint(equalTo: labelDescription.heightAnchor).isActive = true
        
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
