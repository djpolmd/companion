//
//  ViewController.swift
//  din_nou_42
//
//  Created by Dobos Pavel on 25.05.2017.
//  Copyright © 2017 Dobos Pavel. All rights reserved.
//
import Foundation
import UIKit
import CoreData

class ViewController: UIViewController {
    
 
    private var tokenGot:Bool = false
    
    @IBOutlet weak var loginFild: UITextField!
    
    @IBAction func searchB(_ sender: Any) {
        if !self.tokenGot || (self.loginFild.text?.isEmpty)! {
            return
        }
        getUserId()
    }
    
    func getUserId(){
        let login = self.loginFild.text!
        let url = URL(string: "https://api.intra.42.fr/v2/users?range[login]=\(login),\(login)")
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.setValue("Bearer " + AppDelegate.access_token, forHTTPHeaderField: "Authorization")
        let task2 = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if nil != error {
                print("Error print\n",error!)
            }
            else if nil != data {
                do {
                    let dic2 = try JSONSerialization.jsonObject(with: data!, options: []) as! [NSDictionary]
                    if dic2.count > 0
                    {
                        AppDelegate.userId = String(describing: dic2[0]["id"]!)
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "showUserData", sender: self)
                        }
                    }
                    else
                    {
                        print("User does not exist!")
                    }
                }
                catch (let err)
                {
                    print(err)
                }
            }
        }
        task2.resume()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(AppDelegate.userId)
        print("prepare for segue:  ")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.update), userInfo: nil, repeats: true);
        // Do any additional setup after loading the view, typically from a nib.
        self.getToken()
    }
    
    var expToken = -1
    func update()
    {
        if expToken < 0
        {
            print("\n\nToken Expired, generating new...\n\n")
            self.getToken()
            expToken = 21
            return
        }
        expToken -= 1
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getToken()  {
        
        print("start getToken")
        let CUSTOMER_KEY    = AppDelegate.uid
        let CUSTOMER_SECRET = AppDelegate.secret
        let BEARER  = ((CUSTOMER_KEY + ":" + CUSTOMER_SECRET).data(using: String.Encoding.utf8))!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        let url     = URL(string: "https://api.intra.42.fr/oauth/token")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("Basic " + BEARER, forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = "grant_type=client_credentials".data(using: String.Encoding.utf8)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if nil != error {
                print(error!)
            }
            else if nil != data {
                do {
                    if let dic : Dictionary = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any]
                    {
                        AppDelegate.access_token = dic["access_token"] as! String
                        print(AppDelegate.access_token)
                        self.expToken = dic["expires_in"] as! Int
                        self.tokenGot = true
                    }
                }
                catch (let err) {
                    print(err)
                }
            }
        }
        task.resume()
    }
}

//    
//    func getUserId(){
//        let login = self.loginFild.text!
//        let url = URL(string: "https://api.intra.42.fr/v2/users?range[login]=\(login),\(login)")
//        var request = URLRequest(url: url!)
//        request.httpMethod = "GET"
//        request.setValue("Bearer " + AppDelegate.access_token, forHTTPHeaderField: "Authorization")
//        let task2 = URLSession.shared.dataTask(with: request) { (data, response, error) in
//            if nil != error {
//                print("Error print\n",error!)
//            }
//            else if nil != data {
//                do {
//                    let dic2 = try JSONSerialization.jsonObject(with: data!, options: []) as! [NSDictionary]
//                    if dic2.count > 0
//                    {
//                        AppDelegate.userId = String(describing: dic2[0]["id"]!)
//                        DispatchQueue.main.async {
//                            self.performSegue(withIdentifier: "showSecond", sender: self)
//                        }
//                    }
//                    else
//                    {
//                        print("User does not exist!")
//                    }
//                }
//                catch (let err)
//                {
//                    print(err)
//                }
//            }
//        }
//        task2.resume()
//    }
//    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        print(AppDelegate.userId)
//        print("prepare for segue:  ")
//        
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.update), userInfo: nil, repeats: true);
//        // Do any additional setup after loading the view, typically from a nib.
//        self.getToken()
//    }
//    
//    var expToken = -1
//    func update()
//    {
//        if expToken < 0
//        {
//            print("\n\nToken Expired, generating new...\n\n")
//            self.getToken()
//            expToken = 21
//            return
//        }
//        expToken -= 1
//    }
//    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
//    func getToken()  {
//        
//        print("start getToken")
//        let CUSTOMER_KEY    = AppDelegate.uid
//        let CUSTOMER_SECRET = AppDelegate.secret
//        let BEARER  = ((CUSTOMER_KEY + ":" + CUSTOMER_SECRET).data(using: String.Encoding.utf8))!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
//        let url     = URL(string: "https://api.intra.42.fr/oauth/token")
//        var request = URLRequest(url: url!)
//        request.httpMethod = "POST"
//        request.setValue("Basic " + BEARER, forHTTPHeaderField: "Authorization")
//        request.setValue("application/x-www-form-urlencoded;charset=UTF-8", forHTTPHeaderField: "Content-Type")
//        request.httpBody = "grant_type=client_credentials".data(using: String.Encoding.utf8)
//        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
//            if nil != error {
//                print(error!)
//            }
//            else if nil != data {
//                do {
//                    if let dic : Dictionary = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any]
//                    {
//                        AppDelegate.access_token = dic["access_token"] as! String
//                        print(AppDelegate.access_token)
//                        self.expToken = dic["expires_in"] as! Int
//                        self.tokenGot = true
//                    }
//                }
//                catch (let err) {
//                    print(err)
//                }
//            }
//        }
//        task.resume()
//    }
//}
