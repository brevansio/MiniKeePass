/*
 * Copyright 2016 Jason Rush and John Flanagan. All rights reserved.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import UIKit
import AudioToolbox
import LocalAuthentication

class SettingsViewController: UITableViewController, PinViewControllerDelegate {
    @IBOutlet weak var pinEnabledLabel: UILabel!
    @IBOutlet weak var pinEnabledSwitch: UISwitch!
    @IBOutlet weak var pinLockTimeoutCell: UITableViewCell!


    @IBOutlet weak var biometricsEnabledCell: UITableViewCell!
    @IBOutlet weak var biometricsEnabledLabel: UILabel!
    @IBOutlet weak var biometricsEnabledSwitch: UISwitch!
    
    @IBOutlet weak var deleteDataLabel: UILabel!
    @IBOutlet weak var deleteAllDataEnabledCell: UITableViewCell!
    @IBOutlet weak var deleteAllDataEnabledSwitch: UISwitch!
    @IBOutlet weak var deleteAllDataAttemptsCell: UITableViewCell!
    
    @IBOutlet weak var closeDatabaseEnabledSwitch: UISwitch!
    @IBOutlet weak var closeDatabaseLabel: UILabel!
    @IBOutlet weak var closeDatabaseTimeoutCell: UITableViewCell!

    @IBOutlet weak var rememberLastOpenedDatabaseLabel: UILabel!
    @IBOutlet weak var rememberLastOpenedDatabaseEnabledSwitch: UISwitch!

    @IBOutlet weak var rememberPasswordLabel: UILabel!
    @IBOutlet weak var rememberDatabasePasswordsEnabledSwitch: UISwitch!
    
    @IBOutlet weak var hidePasswordsLabel: UILabel!
    @IBOutlet weak var hidePasswordsEnabledSwitch: UISwitch!

    @IBOutlet weak var sortingEnabledLabel: UILabel!
    @IBOutlet weak var sortingEnabledSwitch: UISwitch!

    @IBOutlet weak var searchTitleOnlyLabel: UILabel!
    @IBOutlet weak var searchTitleOnlySwitch: UISwitch!
    
    @IBOutlet weak var passwordEncodingCell: UITableViewCell!
    
    @IBOutlet weak var clearClipboardEnabledSwitch: UISwitch!
    @IBOutlet weak var clearClipboardLabel: UILabel!
    @IBOutlet weak var clearClipboardTimeoutCell: UITableViewCell!

    @IBOutlet weak var integratedWebBrowserLabel: UILabel!
    @IBOutlet weak var integratedWebBrowserEnabledSwitch: UISwitch!

    @IBOutlet weak var coffeeIAPCell: UITableViewCell!
    @IBOutlet weak var lunchIAPCell: UITableViewCell!
    
    @IBOutlet weak var versionTitleLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    
    fileprivate let pinLockTimeouts = [NSLocalizedString("Immediately", comment: ""),
                                   NSLocalizedString("30 Seconds", comment: ""),
                                   NSLocalizedString("1 Minute", comment: ""),
                                   NSLocalizedString("2 Minutes", comment: ""),
                                   NSLocalizedString("5 Minutes", comment: "")]
    
    fileprivate let deleteAllDataAttempts = ["3", "5", "10", "15"]
    
    fileprivate let closeDatabaseTimeouts = [NSLocalizedString("Immediately", comment: ""),
                                         NSLocalizedString("30 Seconds", comment: ""),
                                         NSLocalizedString("1 Minute", comment: ""),
                                         NSLocalizedString("2 Minutes", comment: ""),
                                         NSLocalizedString("5 Minutes", comment: "")]
    
    fileprivate let passwordEncodings = [NSLocalizedString("UTF-8", comment: ""),
                                     NSLocalizedString("UTF-16 Big Endian", comment: ""),
                                     NSLocalizedString("UTF-16 Little Endian", comment: ""),
                                     NSLocalizedString("Latin 1 (ISO/IEC 8859-1)", comment: ""),
                                     NSLocalizedString("Latin 2 (ISO/IEC 8859-2)", comment: ""),
                                     NSLocalizedString("7-Bit ASCII", comment: ""),
                                     NSLocalizedString("Japanese EUC", comment: ""),
                                     NSLocalizedString("ISO-2022-JP", comment: "")]

    fileprivate let clearClipboardTimeouts = [NSLocalizedString("30 Seconds", comment: ""),
                                          NSLocalizedString("1 Minute", comment: ""),
                                          NSLocalizedString("2 Minutes", comment: ""),
                                          NSLocalizedString("3 Minutes", comment: "")]
    
    fileprivate var appSettings = AppSettings.sharedInstance()
    fileprivate var biometricsSupported = false
    fileprivate var tempPin: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = NSLocalizedString("Settings", comment: "")
        
        // Get the version number
        versionLabel.text = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String

        // Check if TouchID/FaceID is supported
        let laContext = LAContext()
        biometricsSupported = laContext.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: nil)
        tableView.delegate = self

        // Localization
        tableView.headerView(forSection: 0)?.textLabel?.text = NSLocalizedString("PIN Protection", comment: "")
        pinEnabledLabel.text = NSLocalizedString("PIN Enabled", comment: "")
        pinLockTimeoutCell.textLabel?.text = NSLocalizedString("Lock Timeout", comment: "")
        biometricsEnabledLabel.text = NSLocalizedString("Use Touch ID / Face ID", comment: "")
        deleteDataLabel.text = NSLocalizedString("Delete Data on Failure", comment: "")
        deleteAllDataAttemptsCell.textLabel?.text = NSLocalizedString("Attempts Until Deletion", comment: "")
        tableView.footerView(forSection: 0)?.textLabel?.text = NSLocalizedString("Prevent unauthorized access to Kagi with a PIN.", comment: "")

        tableView.headerView(forSection: 1)?.textLabel?.text = NSLocalizedString("Database Password Settings", comment: "")
        rememberPasswordLabel.text = NSLocalizedString("Remember Database Passwords", comment: "")
        clearClipboardLabel.text = NSLocalizedString("Clear Clipboard on Timeout", comment: "")
        clearClipboardTimeoutCell.textLabel?.text = NSLocalizedString("Clipboard Timeout", comment: "")
        closeDatabaseLabel.text = NSLocalizedString("Close Database on Timeout", comment: "")
        closeDatabaseTimeoutCell.textLabel?.text = NSLocalizedString("Close Timeout", comment: "")

        tableView.headerView(forSection: 2)?.textLabel?.text = NSLocalizedString("Database Display Settings", comment: "")
        hidePasswordsLabel.text = NSLocalizedString("Hide Passwords", comment: "")
        passwordEncodingCell.textLabel?.text = NSLocalizedString("Password Encoding", comment: "")
        sortingEnabledLabel.text = NSLocalizedString("Sort Alphabetically", comment: "")
        searchTitleOnlyLabel.text = NSLocalizedString("Search Title Only", comment: "")
        integratedWebBrowserLabel.text = NSLocalizedString("Use Integrated Web Browser", comment: "")

        tableView.headerView(forSection: 3)?.textLabel?.text = NSLocalizedString("About Kagi", comment: "")
        versionTitleLabel.text = NSLocalizedString("Kagi Version", comment: "")
        coffeeIAPCell.textLabel?.text = NSLocalizedString("(Tip Jar) Pay for a Cup of Coffee", comment: "")
        lunchIAPCell.textLabel?.text = NSLocalizedString("(Tip Jar) Pay for Lunch", comment: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Delete the temp pin
        tempPin = nil
        
        if let appSettings = appSettings {
            // Initialize all the controls with their settings
            pinEnabledSwitch.isOn = appSettings.pinEnabled()
            pinLockTimeoutCell.detailTextLabel!.text = pinLockTimeouts[appSettings.pinLockTimeoutIndex()]
            
            biometricsEnabledSwitch.isOn = biometricsSupported && appSettings.biometricsEnabled()
            
            deleteAllDataEnabledSwitch.isOn = appSettings.deleteOnFailureEnabled()
            deleteAllDataAttemptsCell.detailTextLabel!.text = deleteAllDataAttempts[appSettings.deleteOnFailureAttemptsIndex()]
            
            closeDatabaseEnabledSwitch.isOn = appSettings.closeEnabled()
            closeDatabaseTimeoutCell.detailTextLabel!.text = closeDatabaseTimeouts[appSettings.closeTimeoutIndex()]

            rememberLastOpenedDatabaseEnabledSwitch.isOn = appSettings.rememberLastOpenedDatabase()
            rememberDatabasePasswordsEnabledSwitch.isOn = appSettings.rememberPasswordsEnabled()
            
            hidePasswordsEnabledSwitch.isOn = appSettings.hidePasswords()
            
            sortingEnabledSwitch.isOn = appSettings.sortAlphabetically()

            searchTitleOnlySwitch.isOn = appSettings.searchTitleOnly()
            
            passwordEncodingCell.detailTextLabel!.text = passwordEncodings[appSettings.passwordEncodingIndex()]
            
            clearClipboardEnabledSwitch.isOn = appSettings.clearClipboardEnabled()
            clearClipboardTimeoutCell.detailTextLabel!.text = clearClipboardTimeouts[appSettings.clearClipboardTimeoutIndex()]

            integratedWebBrowserEnabledSwitch.isOn = appSettings.webBrowserIntegrated()
        }
        
        // Update which controls are enabled
        updateEnabledControls()

        IAPManager.shared.transactionCallback = transactionCallback
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        IAPManager.shared.transactionCallback = nil
    }
    
    fileprivate func updateEnabledControls() {
        guard let appSettings = appSettings else {
            return
        }
        
        let pinEnabled = appSettings.pinEnabled()
        let deleteOnFailureEnabled = appSettings.deleteOnFailureEnabled()
        let closeEnabled = appSettings.closeEnabled()
        let clearClipboardEnabled = appSettings.clearClipboardEnabled()
        
         // Enable/disable the components dependant on settings
        setCellEnabled(pinLockTimeoutCell, enabled: pinEnabled)
        setCellEnabled(biometricsEnabledCell, enabled: pinEnabled && biometricsSupported)
        biometricsEnabledSwitch.isEnabled = pinEnabled && biometricsSupported
        setCellEnabled(deleteAllDataEnabledCell, enabled: pinEnabled)
        setCellEnabled(deleteAllDataAttemptsCell, enabled: pinEnabled && deleteOnFailureEnabled)
        setCellEnabled(closeDatabaseTimeoutCell, enabled: closeEnabled)
        setCellEnabled(clearClipboardTimeoutCell, enabled: clearClipboardEnabled)

        let iapEnabled = IAPManager.shared.enableIAP()
        let productIds = IAPManager.shared.products.map { $0.productIdentifier }
        setCellEnabled(coffeeIAPCell, enabled: iapEnabled && productIds.contains(PurchaseID.coffee.rawValue))
        if let coffeeProduct = IAPManager.shared.products.filter({ $0.productIdentifier == PurchaseID.coffee.rawValue }).first {
            coffeeIAPCell.textLabel?.text = coffeeProduct.localizedTitle
            let numberFormatter = NumberFormatter()
            numberFormatter.formatterBehavior = .behavior10_4
            numberFormatter.numberStyle = .currency
            numberFormatter.locale = coffeeProduct.priceLocale
            coffeeIAPCell.detailTextLabel?.text = numberFormatter.string(from: coffeeProduct.price)
        }
        setCellEnabled(lunchIAPCell, enabled: iapEnabled && productIds.contains(PurchaseID.lunch.rawValue))
        if let lunchProduct = IAPManager.shared.products.filter({ $0.productIdentifier == PurchaseID.lunch.rawValue }).first {
            lunchIAPCell.textLabel?.text = lunchProduct.localizedTitle
            let numberFormatter = NumberFormatter()
            numberFormatter.formatterBehavior = .behavior10_4
            numberFormatter.numberStyle = .currency
            numberFormatter.locale = lunchProduct.priceLocale
            lunchIAPCell.detailTextLabel?.text = numberFormatter.string(from: lunchProduct.price)
        }
    }
    
    fileprivate func setCellEnabled(_ cell: UITableViewCell, enabled: Bool) {
        cell.isUserInteractionEnabled = enabled
        cell.selectionStyle = enabled ? .blue : .none
        cell.textLabel!.isEnabled = enabled
        cell.detailTextLabel?.isEnabled = enabled
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        // Only allow these segues if the setting is enabled
        if (identifier == "PIN Lock Timeout") {
            return pinEnabledSwitch.isOn
        } else if (identifier == "Delete All Data Attempts") {
            return deleteAllDataEnabledSwitch.isOn
        } else if (identifier == "Close Database Timeout") {
            return closeDatabaseEnabledSwitch.isOn
        } else if (identifier == "Clear Clipboard Timeout") {
            return clearClipboardEnabledSwitch.isOn
        }
        
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let selectionViewController = segue.destination as! SelectionViewController
        if (segue.identifier == "PIN Lock Timeout") {
            selectionViewController.items = pinLockTimeouts
            selectionViewController.selectedIndex = (appSettings?.pinLockTimeoutIndex())!
            selectionViewController.itemSelected = { (selectedIndex) in
                self.appSettings?.setPinLockTimeoutIndex(selectedIndex)
                self.navigationController?.popViewController(animated: true)
            }
        } else if (segue.identifier == "Delete All Data Attempts") {
            selectionViewController.items = deleteAllDataAttempts
            selectionViewController.selectedIndex = (appSettings?.deleteOnFailureAttemptsIndex())!
            selectionViewController.itemSelected = { (selectedIndex) in
                self.appSettings?.setDeleteOnFailureAttemptsIndex(selectedIndex)
                self.navigationController?.popViewController(animated: true)
            }
        } else if (segue.identifier == "Close Database Timeout") {
            selectionViewController.items = closeDatabaseTimeouts
            selectionViewController.selectedIndex = (appSettings?.closeTimeoutIndex())!
            selectionViewController.itemSelected = { (selectedIndex) in
                self.appSettings?.setCloseTimeoutIndex(selectedIndex)
                self.navigationController?.popViewController(animated: true)
            }
        } else if (segue.identifier == "Password Encoding") {
            selectionViewController.items = passwordEncodings
            selectionViewController.selectedIndex = (appSettings?.passwordEncodingIndex())!
            selectionViewController.itemSelected = { (selectedIndex) in
                self.appSettings?.setPasswordEncoding(selectedIndex)
                self.navigationController?.popViewController(animated: true)
            }
        } else if (segue.identifier == "Clear Clipboard Timeout") {
            selectionViewController.items = clearClipboardTimeouts
            selectionViewController.selectedIndex = (appSettings?.clearClipboardTimeoutIndex())!
            selectionViewController.itemSelected = { (selectedIndex) in
                self.appSettings?.setClearClipboardTimeoutIndex(selectedIndex)
                self.navigationController?.popViewController(animated: true)
            }
        } else {
            assertionFailure("Unknown segue")
        }
    }
    
    // MARK: - Actions
    
    @IBAction func donePressedAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pinEnabledChanged(_ sender: UISwitch) {
        if (pinEnabledSwitch.isOn) {
            let pinViewController = PinViewController()
            pinViewController.titleLabel.text = NSLocalizedString("Set PIN", comment: "")
            pinViewController.delegate = self
            
            // Background is clear for lock screen blur, set to white to set the pin.
            pinViewController.view.backgroundColor = UIColor.systemBackground
            
            present(pinViewController, animated: true, completion: nil)
        } else {
            self.appSettings?.setPinEnabled(false)
            
            // Delete the PIN from the keychain
            KeychainUtils.deleteData(forKey: "PIN", andServiceName: KEYCHAIN_PIN_SERVICE)
            
            // Update which controls are enabled
            updateEnabledControls()
        }
    }
    
    @IBAction func biometricsEnabledChanged(_ sender: UISwitch) {
        self.appSettings?.setBiometricsEnabled(sender.isOn)
    }
    
    @IBAction func deleteAllDataEnabledChanged(_ sender: UISwitch) {
        self.appSettings?.setDeleteOnFailureEnabled(deleteAllDataEnabledSwitch.isOn)
        
        // Update which controls are enabled
        updateEnabledControls()
    }
    
    @IBAction func closeDatabaseEnabledChanged(_ sender: UISwitch) {
        self.appSettings?.setCloseEnabled(closeDatabaseEnabledSwitch.isOn)

        // Update which controls are enabled
        updateEnabledControls()
    }

    @IBAction func rememberLastOpenedDatabaseEnabledChanged(_ sender: UISwitch) {
        self.appSettings?.setRememberLastOpenedDatabase(rememberLastOpenedDatabaseEnabledSwitch.isOn)

        KeychainUtils.deleteAll(forServiceName: KEYCHAIN_LAST_DATABASE_SERVICE)
    }
    
    @IBAction func rememberDatabasePasswordsEnabledChanged(_ sender: UISwitch) {
        self.appSettings?.setRememberPasswordsEnabled(rememberDatabasePasswordsEnabledSwitch.isOn)
        
        KeychainUtils.deleteAll(forServiceName: KEYCHAIN_PASSWORDS_SERVICE)
        KeychainUtils.deleteAll(forServiceName: KEYCHAIN_KEYFILES_SERVICE)
    }
    
    @IBAction func hidePasswordsEnabledChanged(_ sender: UISwitch) {
        self.appSettings?.setHidePasswords(hidePasswordsEnabledSwitch.isOn)
    }
    
    @IBAction func sortingEnabledChanged(_ sender: UISwitch) {
        self.appSettings?.setSortAlphabetically(sortingEnabledSwitch.isOn)
    }

    @IBAction func searchTitleOnlyChanged(_ sender: UISwitch) {
        self.appSettings?.setSearchTitleOnly(searchTitleOnlySwitch.isOn)
    }

    @IBAction func clearClipboardEnabledChanged(_ sender: UISwitch) {
        self.appSettings?.setClearClipboardEnabled(clearClipboardEnabledSwitch.isOn)
        
        // Update which controls are enabled
        updateEnabledControls()
    }
    
    @IBAction func integratedWebBrowserEnabledChanged(_ sender: UISwitch) {
        self.appSettings?.setWebBrowserIntegrated(integratedWebBrowserEnabledSwitch.isOn)
    }
    
    // MARK: - Pin view delegate
    func pinViewController(_ pinViewController: PinViewController!, pinEntered: String!) {
        if (tempPin == nil) {
            tempPin = pinEntered
            
            pinViewController.titleLabel.text = NSLocalizedString("Confirm PIN", comment: "")
            
            // Clear the PIN entry for confirmation
            pinViewController.clearPin()
        } else if (tempPin == pinEntered) {
            tempPin = nil
            
            // Hash the pin
            let pinHash = PasswordUtils.hashPassword(pinEntered)
            
            // Set the PIN and enable the PIN enabled setting
            appSettings?.setPin(pinHash)
            appSettings?.setPinEnabled(true)
            
            // Update which controls are enabled
            updateEnabledControls()
            
            // Remove the PIN view
            dismiss(animated: true, completion: nil)
        } else {
            tempPin = nil
            
            // Notify the user the PINs they entered did not match
            pinViewController.titleLabel.text = NSLocalizedString("PINs did not match. Try again", comment: "")
            
            // Vibrate the phone
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            
            // Clear the PIN entry to let them try again
            pinViewController.clearPin()
        }
    }
}

extension SettingsViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        if cell == coffeeIAPCell {
            guard let coffeeProduct = IAPManager.shared.products.first(where: { $0.productIdentifier == PurchaseID.coffee.rawValue }) else {
                return
            }
            MBProgressHUD.showAdded(to: view.superview!, animated: true)
            IAPManager.shared.buy(product: coffeeProduct)
        } else if cell == lunchIAPCell {
            guard let lunchProduct = IAPManager.shared.products.first(where: { $0.productIdentifier == PurchaseID.lunch.rawValue }) else {
                return
            }
            MBProgressHUD.showAdded(to: view.superview!, animated: true)
            IAPManager.shared.buy(product: lunchProduct)
        }
    }

    func transactionCallback(purchaseId: PurchaseID?, success: Bool) {
        MBProgressHUD.hide(for: view.superview!, animated: true)
        guard success else {
            let errorAlert = UIAlertController(title: NSLocalizedString("Unable to complete purchase", comment: ""),
                                               message: nil,
                                               preferredStyle: .alert)
            errorAlert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""),
                                               style: .cancel,
                                               handler: nil))
            present(errorAlert, animated: true, completion: nil)
            return
        }

        let thankYouMessage: String
        switch purchaseId {
        case .some(let purchaseId):
            thankYouMessage = purchaseId.thankYouString
        case .none:
            thankYouMessage = "Thank you very much!"
        }
        let thankYouAlert = UIAlertController(title: thankYouMessage,
                                              message: nil,
                                              preferredStyle: .alert)
        thankYouAlert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""),
                                              style: .default,
                                              handler: nil))
        present(thankYouAlert, animated: true, completion: nil)
    }
}
