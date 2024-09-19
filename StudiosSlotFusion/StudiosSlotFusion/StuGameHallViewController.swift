//
//  ViewController.swift
//  StudiosSlotFusion
//
//  Created by jin fu on 2024/9/19.
//

import UIKit

class StuGameHallViewController: UIViewController {

    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityView.hidesWhenStopped = true
        
        self.momentLoadADsData()
        // Do any additional setup after loading the view.
    }
    
    private func momentLoadADsData() {
        if UIDevice.current.model.contains("iPad") {
            return
        }
                
        self.activityView.startAnimating()
        if MomentNReachManager.shared().isReachable {
            stuRequestLocalAdsData()
        } else {
            MomentNReachManager.shared().setReachabilityStatusChange { status in
                if MomentNReachManager.shared().isReachable {
                    self.stuRequestLocalAdsData()
                    MomentNReachManager.shared().stopMonitoring()
                }
            }
            MomentNReachManager.shared().startMonitoring()
        }
    }
    
    private func stuRequestLocalAdsData() {
        guard let bundleId = Bundle.main.bundleIdentifier else {
            self.activityView.stopAnimating()
            return
        }
        
        
        let url = URL(string: "https://open.livelystone.top/open/localAdsData")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let parameters: [String: Any] = [
            "appKey": "365a9d9c6cd6476abb4f9cf8eb9eb84c",
            "appPackageId": bundleId,
            "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? ""
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            print("Failed to serialize JSON:", error)
            self.activityView.stopAnimating()
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    print("Request error:", error ?? "Unknown error")
                    self.activityView.stopAnimating()
                    return
                }
                
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                    if let resDic = jsonResponse as? [String: Any] {
                        let dictionary: [String: Any]? = resDic["data"] as? Dictionary
                        if let dataDic = dictionary, let adsData = dataDic["jsonObject"] {
                            UserDefaults.standard.setValue(adsData, forKey: "MomentAdsDataList")
                            self.mmShowAdViewC()
                            return
                        }
                    }
                    print("Response JSON:", jsonResponse)
                    self.activityView.stopAnimating()
                } catch {
                    print("Failed to parse JSON:", error)
                    self.activityView.stopAnimating()
                }
            }
        }

        task.resume()
    }

}

