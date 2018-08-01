//
//  SendMailViewController.swift
//  Mind-Full Meals
//
//  Created by mwa96 on 7/17/18.
//  Copyright © 2018 CMPT 267. All rights reserved.
//

/* Handles sending your meal data as an email */

import Foundation
import MessageUI

extension UIViewController: MFMailComposeViewControllerDelegate {
    // Sets up the fields for sending an email. Attaches the string you provide as a text file to the email
    func newMailComposeViewController(file: String) -> MFMailComposeViewController {
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = self
        
        // Set the fields
        mail.setToRecipients(["you@example.com"])
        mail.setSubject("My meals")
        mail.setMessageBody("Please see my meals in the attached file.", isHTML: false)
        
        let data = file.data(using: .utf8)
        mail.addAttachmentData(data!, mimeType: "text/csv", fileName: "myMeals.txt")
        return mail
    }
    
    // Shows the write mail screen with your settings if you can send mail. Else if there's an error it shows an alert
    func presentMailComposeView(mailComposeViewController: MFMailComposeViewController) {
        if MFMailComposeViewController.canSendMail() {
            present(mailComposeViewController, animated: true, completion: nil)
        }
        else {
            // Show alert with OK button that dismisses the alert
            let sendMailAlert = UIAlertController(title: "Error", message: "Couldn't send your email", preferredStyle: .alert)
            present(sendMailAlert, animated: true, completion: nil)
            sendMailAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        }
    }
    
    // If there was no error showing the write mail screen, dismiss the mail screen after sending the mail
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
