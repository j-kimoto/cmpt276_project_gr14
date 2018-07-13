//
//  InfoViewController.swift
//  Mind-Full Meals
//
//  Created by Jason Kimoto on 7/12/18.
//  Copyright © 2018 CMPT 267. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func TeamWeb(_ sender: Any) {
        UIApplication.shared.open(URL(string:"https://sites.google.com/view/group-14-project/home")! as URL, options: [:], completionHandler: nil)
    }
    @IBAction func HungerLevel(_ sender: Any) {
        UIApplication.shared.open(URL(string:"https://medical.mit.edu/sites/default/files/hunger_scale.pdf")! as URL, options: [:], completionHandler: nil)
    }
    @IBAction func Portions(_ sender: Any) {
        UIApplication.shared.open(URL(string:"https://www.canada.ca/content/dam/hc-sc/migration/hc-sc/fn-an/alt_formats/hpfb-dgpsa/pdf/food-guide-aliment/view_eatwell_vue_bienmang-eng.pdf")! as URL, options: [:], completionHandler: nil)
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
