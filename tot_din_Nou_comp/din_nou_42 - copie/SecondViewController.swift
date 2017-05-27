//
//  SecondViewController.swift
//  din_nou_42
//
//  Created by Dobos Pavel on 25.05.2017.
//  Copyright © 2017 Dobos Pavel. All rights reserved.
//
import Foundation
import UIKit
import CoreData

struct skills {
    let name:String
    let level:String
    
    init(name:String, level:String) {
        self.name = name
        self.level = level
    }
}

class SecondViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
    @IBOutlet weak var nameUser:    UILabel!
    @IBOutlet weak var correctUser: UILabel!
    @IBOutlet weak var loginUser:   UILabel!
    @IBOutlet weak var walletUser:  UILabel!
    @IBOutlet weak var phoneUser:   UILabel!
    @IBOutlet weak var email:       UILabel!
    @IBOutlet weak var izStaff:     UILabel!
    
    @IBOutlet weak var uImage:      UIImageView!
    @IBOutlet weak var progress:    UIProgressView!
    @IBOutlet weak var level:       UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var allSkills   = [skills]()
    var allProjects = [skills]()
    var userData    = [skills]()
    
    
    private var levelWidthProcent:CGFloat?
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            print("\n\nlandscape\n\n")
        }
        else {
            print("\n\nportrait\n\n")
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return ""
        }
        else if section == 1 {
            return "-Skills-"
        }
        else {
            return "-Projects-"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.userData.count
        }
        else if section == 1 {
            return self.allSkills.count
        }
        else {
            return self.allProjects.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "skillCell", for: indexPath) as! TableViewCell
        
        if indexPath.section     == 0 {
            cell.name.text  = self.userData[indexPath.row].name
            cell.level.text = "\(self.userData[indexPath.row].level)  "
        }
        else if indexPath.section == 1 {
            cell.name.text   = allSkills[indexPath.row].name
            cell.level.text  = "\(allSkills[indexPath.row].level)  "
        }
        else {
            cell.name.text  = self.allProjects[indexPath.row].name
            cell.level.text = "\(self.allProjects[indexPath.row].level)  "
        }
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        self.izStaff.isHidden  = true
        progress.transform = progress.transform.scaledBy(x: 1, y: 15)
        self.automaticallyAdjustsScrollViewInsets = false
        self.uImage.layer.borderWidth   = 1
        self.uImage.layer.masksToBounds = false
        self.uImage.layer.borderColor   = UIColor.white.cgColor
        self.uImage.layer.cornerRadius  = uImage.frame.size.width/2
        self.uImage.clipsToBounds = true;
  //      self.levelBarBg.layer.cornerRadius = 5
  //      self.levelBarBg.layer.borderColor  = UIColor.black.cgColor
  //      self.levelBarBg.layer.borderWidth  = 1
  //      self.levelBarBg.clipsToBounds = true
        getUserData()
    }
    
    func getUserData(){
        let url = URL(string: "https://api.intra.42.fr/v2/users/\(AppDelegate.userId)")
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.setValue("Bearer " + AppDelegate.access_token, forHTTPHeaderField: "Authorization")
       // self.imageActivityIndicator.startAnimating()
        let task2 = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if nil != error {
                print("Error print\n",error!)
            }
            else if nil != data {
                do {
                    let dic2 = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
                    if dic2.count > 0
                    {
//                        print(dic2)
                        DispatchQueue.main.async {
                            
                            let userName = dic2["displayname"] as? String
                            let isStaff  = String(describing: dic2["staff?"]!)
                            self.nameUser.text   = userName?.uppercased()
                            self.loginUser.text  = dic2["login"] as? String
                            self.correctUser.text  = "Correction: " + String(describing: dic2["correction_point"]!)
                            self.walletUser.text = "Wallet: " + String(describing: dic2["wallet"]!)
                            
                            let proj = dic2["projects_users"] as! [NSDictionary]
                            
                            if isStaff == "1" {
                                self.izStaff.isHidden = false
                            }
                            for p in proj
                            {
                                var finalMark = ""
                                if String(describing: p.value(forKey: "final_mark")!) != "<null>"
                                {
                                    finalMark = String(describing: p.value(forKey: "final_mark")!)
                                }
                                else
                                {
                                    finalMark = String(describing: p.value(forKey: "status")!)
                                }
                                let projName = p.value(forKey: "project") as! NSDictionary
                                //                                print(projName)
                                //                                print("\n")
                                let str = String(describing: projName.value(forKey: "slug")!)
                                if str.range(of:"piscine-c") != nil || str.range(of:"day-") != nil || str.range(of:"-rush") != nil{
                                    continue
                                }
                                let prname = String(describing: projName.value(forKey: "slug")!)
                                self.allProjects.append(skills(name: prname, level: finalMark))
                            }
                            
                            let cursus = dic2["cursus_users"] as! [NSDictionary]
                            var isIn = false
                            for curs in cursus
                            {
                                if String(describing: curs.value(forKey: "cursus_id")!) == "1" &&  isStaff != "1"
                                {
                                    let level = String(describing: curs.value(forKey: "level")!)
                                    let lev = level.components(separatedBy: ".")
                                    if lev.isEmpty {
                                        return
                                    }
                                    self.level.text = "Level: \(lev[0]) - \(lev[1])%"
                                    let fl = Float(lev[1])!
                                    self.progress.progress = Float(fl / 100)
                                    
                                    let sk = curs["skills"] as! [NSDictionary]
                                    for skill in sk {
                                        self.allSkills.append(skills(name: String(describing: skill.value(forKey: "name")!), level: String(describing: skill.value(forKey: "level")!)))
                                    }
                                    
                                    self.tableView.reloadData()
                                    isIn = true
                                }
                            }
                            if !isIn {
                                self.level.text = "Level: 0 - 0%"
                                self.progress.progress = Float(0)
                            }
                        }
                        let url = URL(string: (dic2["image_url"] as? String)!)
                        let download = URLSession.shared.dataTask(with: url!) {(data, response, error) in
                          //  self.imageActivityIndicator.stopAnimating()
                            if error != nil {
                                print("Error downloading the image")
                            }
                            else {
                                DispatchQueue.main.async {
                                   // self.imageActivityIndicator.stopAnimating()
                                    self.uImage.image = UIImage(data: data!)
                                }
                            }
                        }
                        download.resume()
                    }
                    else {
                        print("User does not exist")
                    }
                }
                catch (let err) {
                    print(err)
                }
            }
        }
        task2.resume()
    }
}
