

import UIKit
import SVGKit
import SVProgressHUD
import SystemConfiguration
import Kingfisher
import FBSDKLoginKit
import AVFoundation
import Foundation
import AssetsLibrary
import SwiftMessages
import CallKit

typealias trueFalseBlock = (_ successFail : Bool) ->Void
typealias DicBlock = (_ dicData : NSMutableDictionary?) ->Void
typealias ImageDownloaderBlock = (_ img : UIImage? ,_ identifier : String?) ->Void
typealias TrueFalseBlock = (_ successFail : Bool? ,_ strData : String?) ->Void
typealias SignedURLBlock = (_ successFail : Bool? ,_ signedUrl : String? , _ originalUrl : String?) ->Void
let appDele = UIApplication.shared.delegate as! AppDelegate

class Util: NSObject  {

    static let applicationName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
    static let Default = UserDefaults.standard
    
    static var updateCount = 0
    
    static var trueFalseCompletion : trueFalseBlock = { successFail in }
    static var ImageDownloaderCompletion : ImageDownloaderBlock = { img , identifier in }
    
    //MARK: Kingfisher Image doanload
    static func setImageToImageview(imageToSet: UIImageView, withImageURL: String, withPlaceHolder:UIImage) {
        
        imageToSet.image = withPlaceHolder
        let url = URL(string: withImageURL)        
        
        imageToSet.kf.setImage(with: url, placeholder: withPlaceHolder, options: [.transition(.fade(0.0))], progressBlock: nil, completionHandler: { (img, err, type, url) in
            
            if err != nil || img == nil {
                imageToSet.kf.indicatorType = .none
                imageToSet.image = withPlaceHolder
                print("Problem in caching image")
            }
        })        
    }
    
    //MARK:- UI Functions.
    
    static func gotoRecordScreen(_ fromViewController: UIViewController) {
        let gotoCameraVC = fromViewController.storyboard?.instantiateViewController(withIdentifier: Constant.basePageVCIdentifierName) as! BasePageVC
        let nav : UINavigationController = UINavigationController()
        nav.viewControllers  = [gotoCameraVC]
        fromViewController.navigationController?.present(nav, animated: true, completion: nil)
    }
    
    static func gotoNotification(_ fromViewController : UIViewController)
    {
        let notificationVC = fromViewController.storyboard?.instantiateViewController(withIdentifier: Constant.notificationVCIdentifierName) as! NotificationVC
        notificationVC.isFromPresent = true
        let nav : UINavigationController = UINavigationController()
        nav.viewControllers  = [notificationVC]
        fromViewController.navigationController?.present(nav, animated: true, completion: nil)
    }
    
    static func getDistance(lat1 : Float , lat2 : Float, long1 : Float , long2 : Float) -> Float
    {
        let harvesine = Haversine(lat1: lat1, lon1: long1, lat2: lat2, lon2: long2)
        var km = harvesine?.toKilometers()
        var dobKm = Double(km!)
        var finalValue = Double(round(100*dobKm)/100)
        
//        var strKm = String(km!)
//        if strKm.contains(".")
//        {
//            var arrKm = strKm.components(separatedBy: ".")
//            if arrKm.count > 1
//            {
//
//            }
//        }
        km = Float(finalValue)
        return km!
    }
    
    static func getLatLongFormat(latLongValue : String) -> String
    {
        var arr = latLongValue.components(separatedBy: ".")
        
        let index = arr[1].index(arr[1].startIndex, offsetBy: 6)
        let strLatLong = arr[1].substring(to: index)
        
        //var strLatLong = arr[1].characters.suffix(6)
        
        let strResponse = "\(arr[0]).\(strLatLong)"
        return strResponse
    }
    
    static func getLocationAddress(latitude : String , longitude : String , resBlock:  @escaping DicBlock)
    {
        let dicResponse : NSMutableDictionary = NSMutableDictionary()
        //let latitude :CLLocationDegrees = 23.011657
        //let longitude :CLLocationDegrees = 72.522935
        
//        let lat = self.getLatLongFormat(latLongValue: String(latitude))
//        let long = self.getLatLongFormat(latLongValue: String(longitude))
        
        let latitude = CLLocationDegrees(Double(latitude)!)
        let longitude = CLLocationDegrees(Double(longitude)!)
        
        let location = CLLocation(latitude: latitude, longitude: longitude) //changed!!!
        //print("location : \(location)")
        
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            //print(location)
            
            if error != nil {
                resBlock(nil)
//                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                return
            }
            
            if (placemarks?.count)! > 0 {
                let pm = placemarks?.last
                
                //let address = NSString.init(format: "%@",pm!.addressDictionary!)
                
//                let dicData = pm?.addressDictionary as! NSMutableDictionary
                let dicData = pm?.addressDictionary! as! NSDictionary
                //print("dicData : \(dicData)")
                
                var city : String = String()
                var address : String = String()
                
                if let subLocality = dicData["SubLocality"] as? String
                {
                    address = subLocality
                }
                else if let subC = dicData["SubAdministrativeArea"] as? String
                {
                    address = subC
                }
                
                if let c = dicData["City"] as? String
                {
                    city = c
                }
                else if let subC = dicData["SubAdministrativeArea"] as? String
                {
                    city = subC
                }
                
//                Util.Default.setValue(city, forKey: Constant.KEY_CURRENT_LOCATION_CITY)
//                Util.Default.setValue(address, forKey: Constant.KEY_CURRENT_LOCATION_ADDRESS)
                
                dicResponse["city"] = city
                dicResponse["address"] = address
                
                resBlock(dicResponse)
            }
            else {
//                print("Problem with the data received from geocoder")
                resBlock(nil)
            }
        })
        
    }
    
    
    static func hideSystemAlert()
    {
        SwiftMessages.hide()
    }
 
    static func setBarButtonItemColorAsDefault()
    {
        let cancelButtonAttributes: NSDictionary = [NSForegroundColorAttributeName: Constant.COLOR_BLUE_BARBUTTON]
        UIBarButtonItem.appearance().setTitleTextAttributes(cancelButtonAttributes as? [String : AnyObject], for: UIControlState.normal)
    }
    
    static func showSystemStatusAlert(type : String , title : String , msg : String)
    {
        var view = SwiftMessages.defaultConfig
        view.presentationContext = .automatic
        
        let view1  : MessageView = MessageView.viewFromNib(layout: .MessageView)        
        
        
    }
    
    static func showSystemAlert(type : String , title : String , msg : String, positiveBlock:   SystemAlertAction? , negativeBlock :  SystemAlertAction?)
    {
        
        let customView: SystemAlert = try! SwiftMessages.viewFromNib()
//        let customView: SystemAlert = try! MessageView.viewFromNib(layout: .MessageView)
        customView.configureDropShadow()
//        customView.backgroundColor = UIColor.yellow
        if self.targetOfProject() == Constant.TARGET_RED
        {
            customView.backgroundView.backgroundColor = Constant.COLOR_WHITE
            customView.lblTitle.text = title
            customView.lblMsg.text = msg
        }
        else
        {
            customView.backgroundView.backgroundColor = Constant.COLOR_BG_SYS_ALERT
            lblTitleSty1WhBo18(customView.lblTitle, title)
            lblDescSty1WhRe15(customView.lblMsg, msg)
            
            if type == Constant.SYSTEM_ALERT_TYPE_MEDIA_REQUEST
            {
                customView.imgIcon.image = UIImage(named : "typeMediaRequest")
            }
            else if type == Constant.SYSTEM_ALERT_TYPE_TRANSACTION
            {
                customView.imgIcon.image = UIImage(named : "typeMediaSold")
            }
            else
            {
                customView.imgIcon.image = UIImage(named : "notificationsWhite")
            }
//            Util.btnSty1ClWhRe13(customView.btnView, "")
//            Util.btnSty1ClWhRe13(customView.btnCancel, "")
            Util.setButtonUI(btnName: customView.btnView, btnText: "BTN_SUBMIT_PRRFILE")
            Util.setButtonUI(btnName: customView.btnCancel, btnText: "BTN_SUBMIT_PRRFILE")
        }
        
        if type == Constant.SYSTEM_ALERT_TYPE_SEEN
        {
            customView.btnView.setTitle("OK", for: .normal)
        }
        else
        {
            customView.btnView.setTitle("View", for: .normal)
        }
        customView.btnCancel.setTitle("Cancel", for: .normal)
        
        var config = SwiftMessages.defaultConfig
        config.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
        config.presentationStyle = .top
        config.dimMode = .gray(interactive: true)
        
        if type == Constant.SYSTEM_ALERT_TYPE_TOAST
        {
            config.duration = .seconds(seconds: TimeInterval(2.0))
        }
        else
        {
            config.duration = .forever
        }
        
        if positiveBlock == nil && negativeBlock == nil
        {
            customView.viewBtn.isHidden = true
            customView.consBtnViewsHeight.constant = 0
        }
        else
        {
            if negativeBlock == nil
            {
                customView.btnCancel.isHidden = true
            }
            else
            {
                customView.negativeAction = negativeBlock!
            }
            
            if positiveBlock == nil
            {
                customView.btnView.isHidden = true
            }
            else
            {
                customView.postiveAction = positiveBlock!
            }
        }
        
        SwiftMessages.show(config: config, view: customView)
    }
    
    
    static func setNavigationBarUI( navBarText : String , navBar : UINavigationBar)
    {
        if targetOfProject() == Constant.TARGET_RED
        {
            navBar.topItem?.title = Util.localizedString(value: navBarText)
            navBar.titleTextAttributes = [NSForegroundColorAttributeName : Constant.COLOR_BLACK , NSFontAttributeName : Constant.LBL_FONT_REGULAR_17]
            navBar.barTintColor = Constant.COLOR_WHITE_NAVIGATION_BAR
            navBar.isTranslucent = false
            self.statusBarColor(color: Constant.COLOR_WHITE_NAVIGATION_BAR)
            UIApplication.shared.setStatusBarStyle(.default, animated: false)
        }
        else
        {
            navBar.topItem?.title = Util.localizedString(value: navBarText)
            navBar.titleTextAttributes = [NSForegroundColorAttributeName : Constant.COLOR_WHITE , NSFontAttributeName : Constant.LBL_FONT_REGULAR_17]
            navBar.barTintColor = Constant.COLOR_BLACK_NAVIGATION_BAR
            navBar.isTranslucent = false
            self.statusBarColor(color: Constant.COLOR_STATUS_BAR_LIGHT_GREEN)
            UIApplication.shared.setStatusBarStyle(.lightContent, animated: false)
            navBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            navBar.shadowImage = UIImage()
            navBar.isTranslucent = true
        }
    }
    
    static func setNavigationBarUI(navBar : UINavigationBar , navBarText : String , navBarBackgroundColor : UIColor)
    {
        if targetOfProject() == Constant.TARGET_RED
        {
            navBar.topItem?.title = Util.localizedString(value: navBarText)
            navBar.titleTextAttributes = [NSForegroundColorAttributeName : Constant.COLOR_WHITE , NSFontAttributeName : Constant.LBL_TBLVIEW_FONT_BOLD_17]
            navBar.barTintColor = navBarBackgroundColor
            navBar.isTranslucent = false
            self.statusBarColor(color: navBarBackgroundColor)
            UIApplication.shared.setStatusBarStyle(.lightContent, animated: false)
        }
        else
        {
            navBar.topItem?.title = Util.localizedString(value: navBarText)
            navBar.titleTextAttributes = [NSForegroundColorAttributeName : Constant.COLOR_WHITE , NSFontAttributeName : Constant.LBL_TBLVIEW_FONT_BOLD_17]
            navBar.barTintColor = navBarBackgroundColor
            navBar.isTranslucent = false            
            self.statusBarColor(color: Constant.COLOR_STATUS_BAR_LIGHT_GREEN)
            UIApplication.shared.setStatusBarStyle(.lightContent, animated: false)
            navBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            navBar.shadowImage = UIImage()
            navBar.isTranslucent = true
        }
    }
    
    static func getDigitsAfterDot(value : Double) -> String
    {
        var arrValue = String(value).components(separatedBy: ".")
        return "\(arrValue[0]).\(arrValue[1].prefix(2))"
    }
    
    static func statusBarColor(color : UIColor)
    {
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        if statusBar.responds(to:#selector(setter: UIView.backgroundColor)) {
            statusBar.backgroundColor = color
        }
    }

    static func localizedString(value: String) -> String {
//        let result  = NSLocalizedString(value, comment: value)
        if targetOfProject() == Constant.TARGET_RED
        {
            let result = Bundle.main.localizedString(forKey: value, value: nil, table: "Localizable")
//            print("Red KEY : \(value) | Value: \(result)")
            return result
        }
        else
        {
            var result = Bundle.main.localizedString(forKey: value, value: nil, table: "LocalizableBlack")
            if result != ""
            {
                result = result.capitalizeFirst()
            }
//            print("Black KEY : \(value) | Value: \(result)")
            return result
        }        
    }
    
    // INFO : TitleSty1 : FONT : BOLD_15 || COLOR : WHITE
    static func lblInfoTitleSty1WhBo15(_ lbl : UILabel,_ lblText : String)
    {
        lbl.text = self.localizedString(value: lblText)
        lbl.font = Constant.FONT_LBL_BOLD_15
        lbl.textColor = Constant.COLOR_LBL_WH
    }
    
    // INFO : TitleSty2 : FONT : BOLD_17 || COLOR : WHITE
    static func lblInfoTitleSty2WhBo17(_ lbl : UILabel,_ lblText : String)
    {
        lbl.text = self.localizedString(value: lblText)
        lbl.font = Constant.FONT_LBL_BOLD_17
        lbl.textColor = Constant.COLOR_LBL_WH
    }
    
    // INFO : TitleSty3 : FONT : BOLD_15 || COLOR : BLACK
    static func lblInfoTitleSty3BKBo15(_ lbl : UILabel,_ lblText : String)
    {
        lbl.text = self.localizedString(value: lblText)
        lbl.font = Constant.FONT_LBL_BOLD_15
        lbl.textColor = Constant.COLOR_LBL_BK
    }
    
    
    // TitleSty1 : FONT : BOLD_18 || COLOR : WHITE
    static func lblTitleSty1WhBo18(_ lbl : UILabel,_ lblText : String)
    {
        lbl.text = lblText
        lbl.font = Constant.FONT_LBL_BOLD_18
        lbl.textColor = Constant.COLOR_LBL_WH
    }
    
    // TitleSty2 : FONT : BOLD_15 || COLOR : WHITE
    static func lblTitleSty2WhBo15(_ lbl : UILabel,_ lblText : String)
    {
        lbl.text = lblText
        lbl.font = Constant.FONT_LBL_BOLD_15
        lbl.textColor = Constant.COLOR_LBL_WH
    }
    
    // TitleSty3 : FONT : BOLD_20 || COLOR : WHITE
    static func lblTitleSty3WhBo20(_ lbl : UILabel,_ lblText : String)
    {
        lbl.text = lblText
        lbl.font = Constant.FONT_LBL_BOLD_20
        lbl.textColor = Constant.COLOR_LBL_WH
    }
    
    // TitleSty4 : FONT : BOLD_17 || COLOR : WHITE
    static func lblTitleSty4WhBo17(_ lbl : UILabel,_ lblText : String)
    {
        lbl.text = lblText
        lbl.font = Constant.FONT_LBL_BOLD_17
        lbl.textColor = Constant.COLOR_LBL_WH
    }
    
    // TitleSty5 : FONT : BOLD_14 || COLOR : WHITE
    static func lblTitleSty5WhBo14(_ lbl : UILabel,_ lblText : String)
    {
        lbl.text = lblText
        lbl.font = Constant.FONT_LBL_BOLD_14
        lbl.textColor = Constant.COLOR_LBL_WH
    }
    
    // TitleSty6 : FONT : BOLD_13 || COLOR : WHITE
    static func lblTitleSty6WhBo13(_ lbl : UILabel,_ lblText : String)
    {
        lbl.text = lblText
        lbl.font = Constant.FONT_LBL_BOLD_13
        lbl.textColor = Constant.COLOR_LBL_WH
    }
    
    // TitleSty7 : FONT : BOLD_15 || COLOR : BLACK
    static func lblTitleSty7BkBo15(_ lbl : UILabel,_ lblText : String)
    {
        lbl.text = lblText
        lbl.font = Constant.FONT_LBL_BOLD_15
        lbl.textColor = Constant.COLOR_LBL_BK
    }
    
    // TitleSty8 : FONT : BOLD_12 || COLOR : WHITE
    static func lblTitleSty8WhBo12(_ lbl : UILabel,_ lblText : String)
    {
        lbl.text = lblText
        lbl.font = Constant.FONT_LBL_BOLD_12
        lbl.textColor = Constant.COLOR_LBL_WH
    }
    
    // INFO DescSty1 : FONT : REG_13 || COLOR : WHITE
    static func lblInfoDescSty1WhRe13(_ lbl : UILabel,_ lblText : String)
    {
        lbl.text = self.localizedString(value: lblText)
        lbl.font = Constant.FONT_LBL_REGU_13
        lbl.textColor = Constant.COLOR_LBL_WH
    }
    
    // INFO DescSty2 : FONT : REG_15 || COLOR : WHITE
    static func lblInfoDescSty2WhRe15(_ lbl : UILabel,_ lblText : String)
    {
        lbl.text = self.localizedString(value: lblText)
        lbl.font = Constant.FONT_LBL_REGU_13
        lbl.textColor = Constant.COLOR_LBL_WH
    }
    
    // INFO DescSty3 : FONT : BO_15 || COLOR : WHITE
    static func lblInfoDescSty3WhBo15(_ lbl : UILabel,_ lblText : String)
    {
        lbl.text = self.localizedString(value: lblText)
        lbl.font = Constant.FONT_LBL_BOLD_15
        lbl.textColor = Constant.COLOR_LBL_WH
    }
    
    // DescSty1 : FONT : REG_15 || COLOR : WHITE
    static func lblDescSty1WhRe15(_ lbl : UILabel,_ lblText : String)
    {
        lbl.text = lblText
        lbl.font = Constant.FONT_LBL_REGU_15
        lbl.textColor = Constant.COLOR_LBL_WH
    }
    
    // DescSty2 : FONT : REG_13 || COLOR : WHITE
    static func lblDescSty2WhRe13(_ lbl : UILabel,_ lblText : String)
    {
        lbl.text = lblText
        lbl.font = Constant.FONT_LBL_REGU_13
        lbl.textColor = Constant.COLOR_LBL_WH
    }
    
    // DescSty3 : FONT : REG_11 || COLOR : WHITE
    static func lblDescSty3WhRe11(_ lbl : UILabel,_ lblText : String)
    {
        lbl.text = lblText
        lbl.font = Constant.FONT_LBL_REGU_11
        lbl.textColor = Constant.COLOR_LBL_WH
    }
    
    // DescSty9 : FONT : REG_08 || COLOR : WHITE
    static func lblDescSty9WhRe08(_ lbl : UILabel,_ lblText : String)
    {
        lbl.text = lblText
        lbl.font = Constant.FONT_LBL_REGU_08
        lbl.textColor = Constant.COLOR_LBL_WH
    }
    
    // DescSty4 : FONT : REG_12 || COLOR : WHITE
    static func lblDescSty4WhRe12(_ lbl : UILabel,_ lblText : String)
    {
        lbl.text = lblText
        lbl.font = Constant.FONT_LBL_REGU_12
        lbl.textColor = Constant.COLOR_LBL_WH
    }
    
    // DescSty5 : FONT : BOLD_15 || COLOR : WHITE
    static func lblDescSty5WhBo15(_ lbl : UILabel,_ lblText : String)
    {
        lbl.text = lblText
        lbl.font = Constant.FONT_LBL_BOLD_15
        lbl.textColor = Constant.COLOR_LBL_WH
    }
    
    // DescSty6 : FONT : BOLD_11 || COLOR : WHITE
    static func lblDescSty6WhBo11(_ lbl : UILabel,_ lblText : String)
    {
        lbl.text = lblText
        lbl.font = Constant.FONT_LBL_BOLD_11
        lbl.textColor = Constant.COLOR_LBL_WH
    }
    
    // DescSty7 : FONT : REG_10 || COLOR : WHITE
    static func lblDescSty7WhRe10(_ lbl : UILabel,_ lblText : String)
    {
        lbl.text = lblText
        lbl.font = Constant.FONT_LBL_REGU_10
        lbl.textColor = Constant.COLOR_LBL_WH
    }
    
    // DescSty7 : FONT : BOLD_14 || COLOR : WHITE
    static func lblDescSty7WhBo14(_ lbl : UILabel,_ lblText : String)
    {
        lbl.text = lblText
        lbl.font = Constant.FONT_LBL_BOLD_14
        lbl.textColor = Constant.COLOR_LBL_WH
    }
    
    // DescSty8 : FONT : BOLD_10 || COLOR : WHITE
    static func lblDescSty8WhBo10(_ lbl : UILabel,_ lblText : String)
    {
        lbl.text = lblText
        lbl.font = Constant.FONT_LBL_BOLD_10
        lbl.textColor = Constant.COLOR_LBL_WH
    }
    
    static func setLblDataUI(lblName : UILabel , lblText  : String , lblFont : UIFont , lblColor : UIColor)
    {
        lblName.text = lblText
        lblName.font = lblFont
        lblName.textColor = lblColor
    }
    
    static func setLblUI(lblName : UILabel , lblText  : String , lblFont : UIFont , lblColor : UIColor)
    {
        lblName.text = Util.localizedString(value: lblText)
        lblName.font = lblFont
        lblName.textColor = lblColor
    }
    
    static func setLabelUI(lblName : UILabel , lblText : String)
    {
        lblName.text = Util.localizedString(value: lblText)
//        lblName.font = lblName.font.withSize(16)
        lblName.font = Constant.LBL_FONT_REGULAR_17
    }
    
    static func setLabelSmallUI(lblName : UILabel , lblText : String)
    {
        lblName.text = lblText
        //        lblName.font = lblName.font.withSize(16)
        lblName.font = Constant.LBL_FONT_REGULAR_13
    }
    
    static func setLabelAdjustFont(lblName : UILabel) //This function can be use only after setting font if it its dynamic programmatically.
    {
        lblName.adjustsFontSizeToFitWidth = true
        lblName.minimumScaleFactor =  8 / lblName.font.pointSize
    }
    
    static func setLabalUITblView(lblName : UILabel , lblText : String)
    {
        lblName.text = lblText
        lblName.font = Constant.LBL_TBLVIEW_FONT_BOLD_17
        lblName.textColor = Constant.COLOR_BLACK
    }
    
    static func setLabelBoldBigUITblView(lblName : UILabel , lblText : String)
    {
        lblName.text = lblText
        lblName.font = Constant.LBL_TBLVIEW_FONT_BOLD_20
        lblName.textColor = Constant.COLOR_BLACK
    }
    
    static func setLabelUITblViewRED(lblName : UILabel , lblText : String)
    {
        lblName.text = lblText
        lblName.font = Constant.LBL_TBLVIEW_FONT_BOLD_17
        lblName.textColor = Constant.THEME_COLOR_RED
    }
    
    static func setLabelMediumBoldBlackUITblView(lblName : UILabel , lblText : String)
    {
        lblName.text = lblText
        lblName.font = Constant.LBL_TBLVIEW_FONT_BOLD_15
        lblName.textColor = Constant.COLOR_BLACK
    }
    
    static func setLabelMediumBlackUITblView(lblName : UILabel , lblText : String)
    {
        lblName.text = lblText
        lblName.font = Constant.LBL_SMALL_TBLVIEW_FONT_REGULAR_15
        lblName.textColor = Constant.COLOR_BLACK
    }
    
    static func setLabelSmallUITblView(lblName : UILabel , lblText : String)
    {
        lblName.text = lblText
        lblName.font = Constant.LBL_SMALL_TBLVIEW_FONT_REGULAR_13
        lblName.textColor = Constant.COLOR_BLACK
    }

    static func setLabelSmallUITblViewWhite(lblName : UILabel , lblText : String)
    {
        lblName.text = lblText
        lblName.font = Constant.LBL_SMALL_TBLVIEW_FONT_REGULAR_13
        lblName.textColor = Constant.COLOR_WHITE
    }
    
    
    static func setButtonUI(btnName : UIButton , btnText : String)
    {
        if self.targetOfProject() == Constant.TARGET_RED
        {
            btnName.setTitle(Util.localizedString(value: btnText), for: .normal)
            btnName.titleLabel?.font = Constant.FONT_BTN_TEXT
            btnName.backgroundColor = Constant.COLOUR_BTN_BACKGROUND
            btnName.setTitleColor(Constant.COLOUR_BTN_TEXT, for: .normal)
        }
        else
        {
            btnName.setTitle(Util.localizedString(value: btnText), for: .normal)
            btnName.titleLabel?.font = Constant.FONT_BTN_TEXT
            btnName.backgroundColor = Constant.COLOUR_BTN_BACKGROUND
            btnName.setTitleColor(Constant.COLOUR_BTN_TEXT, for: .normal)
            btnName.layer.masksToBounds = false
            btnName.clipsToBounds = true
            btnName.layer.cornerRadius = (btnName.frame.height)/2.0
            
        }
    }
    
    static func setButtonUI(btnName : UIButton , btnText : String , textSize : UIFont , textColor : UIColor)
    {
        btnName.setTitle(Util.localizedString(value: btnText), for: .normal)
        btnName.titleLabel?.font = textSize
        btnName.setTitleColor(textColor, for: .normal)
    }
    
    static func setButtonSpecialUI(btnName : UIButton , btnText : String)
    {
        if self.targetOfProject() == Constant.TARGET_RED
        {
            btnName.setTitle(Util.localizedString(value: btnText), for: .normal)
            btnName.titleLabel?.font = Constant.FONT_BTN_SPECIAL_TEXT
            btnName.backgroundColor = Constant.COLOUR_BTN_SPECI_BACKGROUND
            btnName.setTitleColor(Constant.COLOUR_BTN_SPECI_TEXT, for: .normal)
        }
        else
        {
            btnName.setTitle(Util.localizedString(value: btnText), for: .normal)
            btnName.titleLabel?.font = Constant.FONT_BTN_SPECIAL_TEXT
            btnName.backgroundColor = UIColor.clear
            btnName.setTitleColor(Constant.COLOUR_BTN_SPECI_TEXT, for: .normal)
        }
    }
    
    //MARK :- BTN Sty1 : Background = clear : textColor = White : Font = re13
    static func btnSty1ClWhRe13(_ btnName : UIButton ,_ btnText : String)
    {
        btnName.setTitle(Util.localizedString(value: btnText), for: .normal)
        btnName.titleLabel?.font = Constant.FONT_BTN_REGU_12
        btnName.titleLabel?.textAlignment = .center
        btnName.backgroundColor = UIColor.clear
        btnName.layer.borderWidth = 1
        btnName.layer.borderColor = Constant.COLOR_BTN_WH.cgColor
        btnName.setTitleColor(Constant.COLOR_BTN_WH, for: .normal)
        btnName.clipsToBounds = true
        btnName.layer.cornerRadius = 3
    }
    
    //MARK :- BTN Sty2 : Background = clear : textColor = black : Font = re15
    static func btnSty2WhBkRe15(_ btnName : UIButton ,_ btnText : String)
    {
        btnName.setTitle(Util.localizedString(value: btnText), for: .normal)
        btnName.titleLabel?.font = Constant.FONT_BTN_REGU_15
        btnName.backgroundColor = Constant.COLOR_BTN_WH
        btnName.setTitleColor(Constant.COLOR_BTN_BK, for: .normal)
    }
    
    //MARK :- BTN Sty3 : Background =  clear : textColor = White : Font = re15
    static func btnSty3ClWhRe15(_ btnName : UIButton ,_ btnText : String)
    {
        btnName.setTitle(Util.localizedString(value: btnText), for: .normal)
        btnName.titleLabel?.font = Constant.FONT_BTN_REGU_15
        btnName.backgroundColor = UIColor.clear
        btnName.setTitleColor(Constant.COLOR_BTN_WH, for: .normal)
    }
    
    //MARK :- BTN Sty4 : Background =  special : textColor = White : Font = re15
    static func btnSty4SpWhRe15(_ btnName : UIButton ,_ btnText : String)
    {
        btnName.setTitle(Util.localizedString(value: btnText), for: .normal)
        btnName.titleLabel?.font = Constant.FONT_BTN_REGU_15
        btnName.backgroundColor = Constant.COLOUR_TXT_SPECIAL_BACKGROUND
        btnName.setTitleColor(Constant.COLOR_BTN_WH, for: .normal)
    }
    
    //MARK :- BTN Sty5 : Background =  cell : textColor = White : Font = re15
    static func btnSty5CeWhRe15(_ btnName : UIButton ,_ btnText : String)
    {
        btnName.setTitle(Util.localizedString(value: btnText), for: .normal)
        btnName.titleLabel?.font = Constant.FONT_BTN_REGU_15
        btnName.backgroundColor = Constant.COLOR_CELL_BACKGROUND
        btnName.setTitleColor(Constant.COLOR_BTN_WH, for: .normal)
    }
    
    //MARK :- BTN Sty6 : Background = black  cell : textColor = White : Font = re15
    static func btnSty6CeBkRe15(_ btnName : UIButton ,_ btnText : String)
    {
        btnName.setTitle(Util.localizedString(value: btnText), for: .normal)
        btnName.titleLabel?.font = Constant.FONT_BTN_REGU_15
        btnName.backgroundColor = Constant.COLOR_BTN_BK
        btnName.setTitleColor(Constant.COLOR_BTN_WH, for: .normal)
    }
    
    
    
    static func setButtonUIBorderRed(btnName : UIButton , btnText : String)
    {
        btnName.setTitle(Util.localizedString(value: btnText), for: .normal)
        btnName.titleLabel?.font = Constant.BTN_FONT_SMALL_13
        btnName.backgroundColor = Constant.COLOR_WHITE
        btnName.layer.borderWidth = 1
        btnName.layer.borderColor = Constant.THEME_COLOR_RED.cgColor
        btnName.setTitleColor(Constant.THEME_COLOR_RED, for: .normal)
    }
    
    static func setBtnUI(btnName : UIButton , btnText : String , textFont : UIFont , backgroundColor : UIColor , textColor : UIColor)
    {
        btnName.setTitle(Util.localizedString(value: btnText), for: .normal)
        btnName.titleLabel?.font = textFont
        btnName.backgroundColor = backgroundColor
        btnName.setTitleColor(textColor, for: .normal)
    }
    
    static func setTextFieldPadding(txtFieldName : UITextField)
    {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: txtFieldName.frame.height))
        txtFieldName.leftView = paddingView
        txtFieldName.leftViewMode = UITextFieldViewMode.always
    }
    
    static func setTextFieldUI(txtFieldName : UITextField)
    {
        txtFieldName.borderStyle = UITextBorderStyle.bezel
    }
    
    static func setTextFieldLeftView(txtField : UITextField , imageName : String)
    {
        txtField.leftViewMode = .always
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 20))
        let image = UIImage(named: imageName)
        imageView.contentMode = .center
        imageView.image = image
        txtField.leftView = imageView
    }
    
    static func setTextFieldUIWithPlaceholder(txtFieldName : UITextField, placeHolder : String)
    {
        if self.targetOfProject() == Constant.TARGET_RED
        {
            txtFieldName.borderStyle = UITextBorderStyle.none
            txtFieldName.placeholder = Util.localizedString(value: placeHolder)
            txtFieldName.backgroundColor = UIColor.clear
            txtFieldName.font = Constant.FONT_TXT_FIELD
            txtFieldName.textColor = Constant.COLOUR_TXT_FIELD_TEXT_COLOR
        }
        else
        {
            txtFieldName.borderStyle = UITextBorderStyle.none
            txtFieldName.backgroundColor = UIColor.clear
            txtFieldName.font = Constant.FONT_TXT_FIELD
            txtFieldName.textColor = Constant.COLOUR_TXT_FIELD_TEXT_COLOR
            txtFieldName.attributedPlaceholder = NSAttributedString(string: Util.localizedString(value: placeHolder), attributes: [NSForegroundColorAttributeName : Constant.COLOUR_TXT_FIELD_PLACEHOLDER_COLOR])
        }
    }
    
    static func setBackgroundIMGforTxtField(imgName : UIView)
    {
        if self.targetOfProject() == Constant.TARGET_RED
        {
            imgName.backgroundColor = Constant.COLOR_TXT_BACKGROUND
            imgName.layer.borderColor = Constant.COLOR_TXT_BORDER.cgColor
            imgName.layer.borderWidth = 1
            imgName.layer.masksToBounds = false
            imgName.layer.cornerRadius = 5.0;
        }
        else
        {
            imgName.backgroundColor = Constant.COLOR_TXT_FIELD_BACKGROUND
            imgName.layer.masksToBounds = false
            imgName.clipsToBounds = true
            imgName.layer.cornerRadius = (imgName.frame.height)/2
        }
    }
    
    static func resignAndbecomeFirstResponder(resignTextField : UITextField , becomeTextField : UITextField)
    {
        resignTextField.resignFirstResponder()
        becomeTextField.becomeFirstResponder()
    }
    
    static func isValidEmail(emailID:String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: emailID)
    }
    
    static func setImage(imgView : UIImageView,imgName : String)
    {
        if targetOfProject() == Constant.TARGET_RED
        {
            imgView.image = UIImage(named : imgName)
        }
        else
        {
            imgView.image = UIImage(named : imgName)
        }
    }
    
    static func imageRound(image : UIImageView)
    {
        image.layer.cornerRadius = image.frame.size.width / 2
        image.clipsToBounds = true
        image.layer.borderColor = Constant.COLOR_WHITE.cgColor
        image.layer.borderWidth = 1.5
    }
    
    static func setLableWidthAcoordingToText(label: UILabel , font : UIFont) -> CGFloat {
        
        let constraint = CGSize(width: CGFloat.greatestFiniteMagnitude, height:  label.frame.size.height)
        var size: CGSize
        let context = NSStringDrawingContext()
        
        let boundingBox: CGSize? = label.text?.boundingRect(with: constraint, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName : font], context: context).size
        size = CGSize(width: ceil((boundingBox?.width)!), height: ceil((boundingBox?.height)!))
        
        var newFrame = label.frame
        var xxx = size.width
        return xxx
//        newFrame.size.width = size.width
//        label.frame = newFrame
    }
    
    static func setBtnShadow(button : UIButton)
    {
        button.layer.shadowColor = Constant.COLOR_BLACK.cgColor
        button.layer.shadowRadius = 3.0
        button.layer.shadowOpacity = 0.5
        button.layer.masksToBounds = false
        button.layer.cornerRadius = 5.0
    }
    
    static func setShadow(view : UIView)
    {
        view.layer.shadowColor = Constant.COLOR_BLACK.cgColor
        view.layer.shadowRadius = 3.0
        view.layer.shadowOpacity = 0.5
        view.layer.masksToBounds = false
        view.layer.cornerRadius = 5.0
    }
    
    static func buttonRound1(button : UIButton)
    {
        button.layer.cornerRadius = 32.5
        button.clipsToBounds = true
    }
    
    static func setSVGImage(imageName : String , imgView : UIImageView)
    {
//        let svgImage = SVGKImage(named: imageName)
//        svgImage?.size = imgView.frame.size
//        imgView.image = svgImage?.uiImage
        
        imgView.image = UIImage(named: imageName)
    }
    static func setSVGImageOnBarButtonItem(imageName : String , imgView : UIBarButtonItem)
    {
//        let svgImage = SVGKImage(named: imageName)
//        imgView.image = svgImage?.uiImage
        imgView.image = UIImage(named: imageName)
    }
    
    static func setSVGOnBtn(imageName : String , btnName : UIButton)
    {
//        let svgImage = SVGKImage(named: imageName)
//        svgImage?.size = btnName.frame.size
//        btnName.setBackgroundImage(svgImage?.uiImage, for: .normal)        
        btnName.setBackgroundImage(UIImage(named: imageName), for: .normal)
        
    }

    static func setNoRecordFoundView(tblView : UITableView , lbl : UILabel , imgView : UIImageView)
    {
        tblView.isHidden = true
        if targetOfProject() == Constant.TARGET_RED
        {
            Util.setLblUI(lblName: lbl, lblText: "LBL_NO_RECORD_FOUND", lblFont: Constant.LBL_SMALL_TBLVIEW_FONT_REGULAR_15!, lblColor: Constant.COLOR_BLACK)
        }
        else
        {
            lblInfoTitleSty1WhBo15(lbl, "LBL_NO_RECORD_FOUND")
        }
        
        Util.setSVGImage(imageName: "noRecord", imgView: imgView)
    }
    
    static func setFloatingBtnUI(btnFloat : UIButton  , tblView : UITableView)
    {
        if let constraint = (btnFloat.constraints.filter{$0.firstAttribute == .height}.first) {
            constraint.constant = 65.0
        }
        
        if let constraint = (btnFloat.constraints.filter{$0.firstAttribute == .width}.first) {
            constraint.constant = 65.0
        }
        Util.buttonRound1(button: btnFloat)
        if targetOfProject() == Constant.TARGET_RED
        {
            btnFloat.backgroundColor = Constant.THEME_COLOR_RED
            btnFloat.setImage(UIImage(named: "floatingBtn"), for: .normal)
            btnFloat.tintColor = UIColor.white
        }
        else
        {
            btnFloat.backgroundColor = Constant.COLOR_WHITE
            btnFloat.setBackgroundImage(UIImage(named: "floatingBtn"), for: .normal)
//            btnFloat.setImage(UIImage(named: "floatingBtn"), for: .normal)
//            btnFloat.tintColor = UIColor.black
        }
        
        btnFloat.contentMode = .center
        btnFloat.imageView?.contentMode = .scaleAspectFit
        tblView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 90, right: 0)
    }
    
    static func showLoading()
    {
        SVProgressHUD.show()
        SVProgressHUD.setDefaultMaskType(.black)
        //appDele.window?.isUserInteractionEnabled = false
    }
    
    static func showLoadingWithMsg(msg : String)
    {
        SVProgressHUD.show(withStatus: Util.localizedString(value: msg))
        SVProgressHUD.setDefaultMaskType(.black)
        //appDele.window?.isUserInteractionEnabled = false
    }
    
    
    static func hideLoading()
    {
        //appDele.window?.isUserInteractionEnabled = true        
        SVProgressHUD.dismiss()
    }
    
    static func getImageFromURL(strUrl : String) -> UIImage
    {
//        var data = NSData(contentsOfFile: strUrl)
        var imgResponse : UIImage!
//        if let urlData = NSURL(string: strUrl) {
//            if let data = NSData(contentsOf: urlData as URL) {
//        print("getImageFromURL : strUrl : \(strUrl)")
        var arrURL = strUrl.components(separatedBy: "file://")
//        print("Url to load image strUrl :\(strUrl) ")
//        print("Url to load image arrURL[1] :\(arrURL[1]) ")
            if let data = NSData(contentsOfFile: arrURL[1]) {
                imgResponse = UIImage(data: data as Data)!
            }
            else
            {
                print("Image fail /*-/*- getImageFromURL : \(strUrl)")
                imgResponse = UIImage(named : "DefaultReachout")
        }
//        }
        return imgResponse
    }
    
    static func getCurrentLocationCity() -> String
    {
        var city = ""
        if Util.Default.value(forKey: Constant.KEY_CURRENT_LOCATION_CITY) == nil
        {
            city = ""
        }
        else
        {
            city = Util.Default.value(forKey: Constant.KEY_CURRENT_LOCATION_CITY) as! String
        }
        return city
    }
    
    static func getCurrentLocationAddress() -> String
    {
        var address = ""
        if Util.Default.value(forKey: Constant.KEY_CURRENT_LOCATION_ADDRESS) == nil
        {
            address = ""
        }
        else
        {
            address = Util.Default.value(forKey: Constant.KEY_CURRENT_LOCATION_ADDRESS) as! String
        }
        return address
    }
    
    func getLatLongFormat(latLongValue : String) -> String
    {
        var arr = latLongValue.components(separatedBy: ".")
        
        let index = arr[1].index(arr[1].startIndex, offsetBy: 6)
        let strLatLong = arr[1].substring(to: index)
        
        //var strLatLong = arr[1].characters.suffix(6)
        
        let strResponse = "\(arr[0]).\(strLatLong)"
        return strResponse
    }
    
    static var exportSession : AVAssetExportSession?
    
    static func convertVideoIntoLowQuality(_ videoURL: URL ,_ resBlock : @escaping TrueFalseBlock)
    {
        let avAsset = AVURLAsset(url: videoURL, options: nil)
        let startDate = Foundation.Date()
        
        //Create Export session
        exportSession = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetMediumQuality)
        
        // exportSession = AVAssetExportSession(asset: composition, presetName: mp4Quality)
        //Creating temp path to save the converted video
        
        let recordingPath = Util.getDirectoryPath(directoryName: Constant.DIR_RECORDINGS)
        let recordingURL = URL(string : recordingPath)
        let convertedVideoUrl = recordingURL?.appendingPathComponent("\(Util.getTimeStamp())\(Constant.MEDIA_SAMPLE_NAME_EXTEND)\(Constant.VIDEO_EXTENSION)")
        
//        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
//        let myDocumentPath = URL(fileURLWithPath: documentsDirectory).appendingPathComponent("temp.mp4").absoluteString
//        let url = URL(fileURLWithPath: myDocumentPath)
//        let documentsDirectory2 = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
//        let filePath = documentsDirectory2.appendingPathComponent("rendered-Video2.mp4")
        
//        exportSession!.outputURL = filePath
        exportSession!.outputURL = convertedVideoUrl!
        exportSession!.outputFileType = AVFileTypeMPEG4
        exportSession!.shouldOptimizeForNetworkUse = true
        let start = CMTimeMakeWithSeconds(0.0, 0)
        let range = CMTimeRangeMake(start, avAsset.duration)
        exportSession!.timeRange = range
        
        exportSession!.exportAsynchronously(completionHandler: {() -> Void in
            switch self.exportSession!.status {
            case .failed:
                print("%@",self.exportSession?.error)
                resBlock(false, nil)
            case .cancelled:
                print("Export canceled")
                resBlock(false, nil)
            case .completed:
                //Video conversion finished
                let endDate = Foundation.Date()
                let time = endDate.timeIntervalSince(startDate)
                print("Successful!")
                print(self.exportSession!.outputURL!)
                resBlock(true, String(describing: self.exportSession!.outputURL!))
            default:
                break
            }            
        })
    }
    
    static func getCurrentLocationLatitude() -> String
    {
//        let manager = CLLocationManager()
//        if manager.location?.coordinate != nil
//        {
//            var locValue : CLLocationCoordinate2D = CLLocationCoordinate2D()
//            locValue = (manager.location?.coordinate)!
//
//            let latitude = String(locValue.latitude)
//            //        var latitude = self.getLatLongFormat(latLongValue: String(locValue.latitude))
//
//            if Util.isLocationDenied() == true
//            {
//                return "0.0"
//            }
//            else
//            {
//                return latitude
//            }
//        }
//        else
//        {
//            return "0.0"
//        }
        
        var strLat = ""
        if Util.Default.value(forKey: Constant.KEY_LATITUDE) == nil
        {
            strLat = "0.0"
        }
        else
        {
            strLat = String(describing: Util.Default.value(forKey: Constant.KEY_LATITUDE)!)
        }
        return strLat
    }
    
    static func isDateExpired(strDate : String) -> Bool
    {
        var result : Bool = Bool()
        let currentDate = "\(Util.getCurrentUTCDateTime())"
        
        let objDateFormate = DateFormatter()
        objDateFormate.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let objDate : Date = objDateFormate.date(from: strDate)!
//        print("Date is: \(objDate)")
        let objCurrentDate : Date = objDateFormate.date(from: currentDate)!
//        print("current Date is: \(objCurrentDate)")
        
        if objDate.compare(objCurrentDate) == .orderedAscending
        {
            result = true
        }
        else
        {
            result = false
        }
        return result
    }
    
    static func getCurrentLocationLongitude() -> String
    {
//        let manager = CLLocationManager()
//        if manager.location?.coordinate != nil
//        {
//            var locValue : CLLocationCoordinate2D  = CLLocationCoordinate2D()
//            locValue = (manager.location?.coordinate)!
//
//            let longitude = String(locValue.longitude)
//            //        var longitude = self.getLatLongFormat(latLongValue: String(locValue.longitude))
//
//            if Util.isLocationDenied() == true
//            {
//                return "0.0"
//            }
//            else
//            {
//                return longitude
//            }
//        }
//        else
//        {
//            return "0.0"
//        }
        
        var strLong = ""
        if Util.Default.value(forKey: Constant.KEY_LONGITUDE) == nil
        {
            strLong = "0.0"
        }
        else
        {
            strLong = String(describing:Util.Default.value(forKey: Constant.KEY_LONGITUDE)!)
        }
        return strLong
    }
    
    static func getDeviceCountrySymbol() -> String? {
        let countryCode = String(describing: Locale.current.regionCode!)
        var strSymbol : String?
        let localeIds = Locale.availableIdentifiers
        var countryCurrency = [String: String]()
        for localeId in localeIds {
            let locale = Locale(identifier: localeId)
            
            if let country = locale.regionCode, country.characters.count == 2 {
                if let currency = locale.currencySymbol {
                    countryCurrency[country] = currency
                }
            }
        }
        let sorted = countryCurrency.keys.sorted()
        for country in sorted {
            let currency = countryCurrency[country]!
            
            if country == countryCode
            {
                strSymbol = currency
                break
            }
            //            print("country: \(country), currency: \(currency)")
        }
        return strSymbol
    }
 
    
    static func getIndianRupeeSybmbol() -> String
    {
        return "₹"
    }
    
    static func getCurrentTime() -> String
    {
        let date = NSDate()
        let styler = DateFormatter()
        styler.dateFormat = "dd MMM, yyyy"
        let currentDate = styler.string(from: date as Date)
//        styler.dateStyle = .medium
        let todayDate = styler.string(from: date as Date)
        let dt = Date()
        let calendar = Calendar.current
        styler.timeStyle = .medium
        let hour = calendar.component(.hour, from: dt)
        styler.dateFormat = "HH"
        let minutes = calendar.component(.minute, from: dt)
        let second = calendar.component(.second, from: dt)
        
        let time = self.getConvertedTime(time: "\(hour):\(minutes):\(second)")
        print("timeeee : \(time)")
        let todayDateTime = "\(todayDate)"
        
        return todayDateTime
    }
    
    static func getDateFromTimeStamp(timeStamp : Double) -> String
    {
        let dateTime = TimeInterval(timeStamp) / 1000
        let date = Date(timeIntervalSince1970: dateTime)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constant.dateFormat
//        dateFormatter.timeZone = TimeZone.current
        dateFormatter.timeZone = NSTimeZone.init(abbreviation: "UTC") as TimeZone!
        let localDate = dateFormatter.string(from: date as Date)
    
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = Constant.timeFormat
//        timeFormatter.timeZone = TimeZone.current
        timeFormatter.timeZone = NSTimeZone.init(abbreviation: "UTC") as TimeZone!
        let localDate1 = timeFormatter.string(from: date as Date)
        
//        print("Returns \(localDate) \(localDate1)")
        return "\(localDate) \(localDate1)"
        
    }
    
    static func getTimeStampFromDate(date : String) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone.init(abbreviation: "UTC") as TimeZone!
        dateFormatter.dateFormat = "\(Constant.dateFormat) \(Constant.timeFormat)"
        let utcDate = dateFormatter.date(from: date)
        let unixTime =   utcDate?.timeIntervalSince1970
        let unixTimeStamp = Double(unixTime!) * 1000
        var arrUnix = String(unixTimeStamp).components(separatedBy: ".")
        var strUnix = ""
        if arrUnix.count == 0
        {
            strUnix = String(unixTimeStamp)
        }
        else
        {
            strUnix = arrUnix[0]
        }
//        print("strUnix 56789 : \(strUnix)")
        return strUnix
    }
    
    static func getTimeStampFromDate1(date : String) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone.init(abbreviation: "UTC") as TimeZone!
        dateFormatter.dateFormat = "\(Constant.dateFormat) \(Constant.timeFormat)"
        let utcDate = dateFormatter.date(from: date)
        let unixTime =   utcDate?.timeIntervalSince1970
        let unixTimeStamp = Double(unixTime!)
        var arrUnix = String(unixTimeStamp).components(separatedBy: ".")
        var strUnix = ""
        if arrUnix.count == 0
        {
            strUnix = String(unixTimeStamp)
        }
        else
        {
            strUnix = arrUnix[0]
        }
        //        print("strUnix 56789 : \(strUnix)")
        return strUnix
    }
    
    static func getTimeStampInCurrentFromCurrentDate(date : String) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "\(Constant.dateFormat) \(Constant.timeFormat)"
        let utcDate = dateFormatter.date(from: date)
        let unixTime =   utcDate?.timeIntervalSince1970
        let unixTimeStamp = Double(unixTime!)
        var arrUnix = String(unixTimeStamp).components(separatedBy: ".")
        var strUnix = ""
        if arrUnix.count == 0
        {
            strUnix = String(unixTimeStamp)
        }
        else
        {
            strUnix = arrUnix[0]
        }
        //        print("strUnix 56789 : \(strUnix)")
        return strUnix
    }
    
//    static func isValueNull(value : Any) -> Bool
//    {
//        if value is NSNull
//        {
//            return true
//        }
//        else
//        {
//            return false
//        }
//    }
//
    
    
    static func getTimeStampForAccessTokenValidity(seconds : Double) -> Double
    {
//        print("Get current time stamp UTC : \(Util.getCurrentUTCDateTime())")
//        print("Convert time stamp from date : \(Util.getTimeStampFromDate1(date: Util.getCurrentUTCDateTime()))")
        var secondsToAdd = (seconds * 20.0) / 100.0
        secondsToAdd = seconds - secondsToAdd
        var addedTime = Double(Util.getTimeStampFromDate1(date: Util.getCurrentUTCDateTime()))! + secondsToAdd
//        print("Add 500 seconds into current UTC : \(addedTime)")
        return addedTime
    }
    
    static func isReadyToGenerateToken() -> Bool
    {
        if Util.Default.value(forKey: Constant.KEY_ACCESS_TOKEN_DUE_TIME_TO_EXPIRE) != nil
        {
            let destinationTime = Util.Default.value(forKey: Constant.KEY_ACCESS_TOKEN_DUE_TIME_TO_EXPIRE) as! Double
            let currentTime = Double(Util.getTimeStampInCurrentFromCurrentDate(date: "\(Util.getDeviceDateOnly()) \(Util.getDeviceTimeOnly())"))!
            if destinationTime < currentTime
            {
                return true
            }
            else
            {
                return false
            }
        }
        else
        {
            return false
        }
    }
    
    static func getTimeStamp() -> String {        
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "yyyy_MM_dd_hh_mm_ss"
        let date = dateFormatter1.string(from: Date())

        return date
    }
    
    static func getDeviceDateOnly() -> String
    {
        let dateFormatter1 = DateFormatter()
//        dateFormatter1.dateStyle = .medium        
        dateFormatter1.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter1.string(from: Date())
//        print("date : \(date)")
        return date
    }
    
    static func getCurrentUTCDateTime() -> String
    {
        let dateFormatter1 = DateFormatter()
        //        dateFormatter1.dateStyle = .medium
        dateFormatter1.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter1.timeZone = TimeZone(abbreviation: "UTC")
        let date = dateFormatter1.string(from: Date())
//        print("date : \(date)")
        return date
    }
    
    static func getDeviceTimeOnly() -> String
    {
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let second = calendar.component(.second, from: date)
//        print("Hour : \(hour)")
//        print("minutes : \(minutes)")
//        print("second : \(second)")
        
        let time = "\(hour):\(minutes):\(second)"
//        print("time : \(time)")
        return time
    }
    
    static func convertSecondToMinutes(seconds : Int) -> (hours : Int,minutes : Int, seconds : Int)
    {
        var hour = Int(self.getStringFrom(seconds: seconds / 3600))!
        var minute = Int(self.getStringFrom(seconds: (seconds % 3600) / 60))!
        var second = Int(self.getStringFrom(seconds: (seconds % 3600) % 60))!
        
        return(hour ,minute, second)
    }
    
    static func hmsFrom(seconds: Int, completion: @escaping (_ hours: Int, _ minutes: Int, _ seconds: Int)->()) {
        
        completion(seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
        
    }
    
    static func getStringFrom(seconds: Int) -> String {
        
        return seconds < 10 ? "0\(seconds)" : "\(seconds)"
    }
    
    static func getTimeInHourMinute(timeInMinutes : Int) -> String
    {
        var strTime = ""
        let totalSeconds = timeInMinutes * 60
        
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        var seconds = (totalSeconds % 3600) % 60
        
        if hours == 0 && minutes != 0
        {
            strTime = "\(self.getStringFrom(seconds: Int(minutes)))m"
        }
        else if minutes == 0 && hours != 0
        {
            strTime = "\(self.getStringFrom(seconds: Int(hours)))h"
        }
        else if minutes != 0 && hours != 0
        {
            strTime = "\(self.getStringFrom(seconds: Int(hours)))h \(self.getStringFrom(seconds: Int(minutes)))m"
        }
//        print("final OP : \(strTime)")
        return strTime
    }
    
    static func convertDateFromUtcTocurrent(utcDate : String) -> String
    {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        inputFormatter.timeZone = NSTimeZone.init(abbreviation: "UTC") as TimeZone!
        //            inputFormatter.timeZone = TimeZone.current
        
        if let date = inputFormatter.date(from: utcDate) {
            
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            outputFormatter.timeZone = TimeZone.current
            //            print("User device time zone : \(TimeZone.current)")
            return outputFormatter.string(from: date)
        }
        else
        {
            return ""
        }
    }
    
    static func getConvertedDate(dateString: String) -> String? {
        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = Constant.dateFormat
        inputFormatter.timeZone = NSTimeZone.init(abbreviation: "UTC") as TimeZone!
//        inputFormatter.timeZone = TimeZone.current
        
        if let date = inputFormatter.date(from: dateString) {
            
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "dd MMM, yyyy"
            //outputFormatter.timeZone = TimeZone.current
//            print("User device time zone : \(TimeZone.current)")
            return outputFormatter.string(from: date)
        }
        return nil
    }
    
    static func getConvertedTime(time : String) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constant.timeFormat
        dateFormatter.timeZone = NSTimeZone.init(abbreviation: "UTC") as TimeZone!
//        dateFormatter.timeZone = TimeZone.current
        
        let date = dateFormatter.date(from: time)
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.timeZone = TimeZone.current
        
        let time = dateFormatter.string(from: date!)
        
        return time
    }
    
    static func timeAgoSinceDate(date:NSDate, numericDates:Bool) -> String {
        let calendar = NSCalendar.current
        let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
        let now = NSDate()
        let earliest = now.earlierDate(date as Date)
        let latest = (earliest == now as Date) ? date : now
        let components = calendar.dateComponents(unitFlags, from: earliest as Date,  to: latest as Date)
        
        if (components.year! >= 2) {
            return "\(components.year!)yrs"
        } else if (components.year! >= 1){
            if (numericDates){
                return "1yrs"
            } else {
                return "Last yr"
            }
        } else if (components.month! >= 2) {
            return "\(components.month!)mo"
        } else if (components.month! >= 1){
            if (numericDates){
                return "1mo"
            } else {
                return "Last mo"
            }
        } else if (components.weekOfYear! >= 2) {
            return "\(components.weekOfYear!)wks"
        } else if (components.weekOfYear! >= 1){
            if (numericDates){
                return "1wk"
            } else {
                return "Last wk"
            }
        } else if (components.day! >= 2) {
            return "\(components.day!)dys"
        } else if (components.day! >= 1){
            if (numericDates){
                return "1dy"
            } else {
                return "Yesterday"
            }
        } else if (components.hour! >= 2) {
            return "\(components.hour!)hrs"
        } else if (components.hour! >= 1){
            if (numericDates){
                return "1hr"
            } else {
                return "An hr"
            }
        } else if (components.minute! >= 2) {
            return "\(components.minute!)mins"
        } else if (components.minute! >= 1){
            if (numericDates){
                return "1min"
            } else {
                return "A min"
            }
        } else if (components.second! >= 3) {
            return "\(components.second!)secs"
        } else {
            return "Now"
        }
    }
    
    static func setMediaTypeIconBlack(pathType : String , img : UIImageView)
    {
        if pathType.caseInsensitiveCompare(Constant.MEDIA_TYPE_PHOTO) == ComparisonResult.orderedSame
        {
            Util.setSVGImage(imageName: "camerablack", imgView: img)
        }
        else if pathType.caseInsensitiveCompare(Constant.MEDIA_TYPE_VIDEO) == ComparisonResult.orderedSame
        {
            Util.setSVGImage(imageName: "videoBlack", imgView: img)
        }
        else if pathType.caseInsensitiveCompare(Constant.MEDIA_TYPE_AUDIO) == ComparisonResult.orderedSame
        {
            Util.setSVGImage(imageName: "micBlack", imgView: img)
        }
    }
    
    static func setMediaTypeIconWhite(pathType : String , img : UIImageView)
    {
        if pathType.caseInsensitiveCompare(Constant.MEDIA_TYPE_PHOTO) == ComparisonResult.orderedSame
        {
            Util.setSVGImage(imageName: "cameraWhite", imgView: img)
        }
        else if pathType.caseInsensitiveCompare(Constant.MEDIA_TYPE_VIDEO) == ComparisonResult.orderedSame
        {
            Util.setSVGImage(imageName: "videoWhite", imgView: img)
        }
        else if pathType.caseInsensitiveCompare(Constant.MEDIA_TYPE_AUDIO) == ComparisonResult.orderedSame
        {
            Util.setSVGImage(imageName: "micWhite", imgView: img)
        }
    }
    
    static func deleteMediaFromAppDirecory(fileName : String)
    {
        let fileManager = FileManager.default
        let fileExist = Util.isFileExistAtDirectory(directoryName: Constant.DIR_MY_VIDEOS, fileName: fileName)
        if fileExist == true
        {
            let path = Util.getDirectoryPath(directoryName: Constant.DIR_MY_VIDEOS)
            do {
                let url = "\(path)\(fileName)"
                try fileManager.removeItem(at: URL(string: url)!)
            } catch {
                print("error while delete media from directory : \(error)")
            }
        }
        
//        let fileManager = FileManager.default
//        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
//        
//        let documentsPath = documentsUrl.path
//        
//        do {
//            if let documentPath = documentsPath
//            {
//                let fileNames = try fileManager.contentsOfDirectory(atPath: "\(documentPath)")
//                print("all files in cache: \(fileNames)")
////                for fileName in fileNames {
//                
//                        var arrData = fileName1.components(separatedBy: "Documents/")
//                        print("0 : \(arrData[0])")
//                        print("1 : \(arrData[1])")
//                
//                        let filePathName = arrData[1]
//                        try fileManager.removeItem(atPath: "\(documentPath)/\(filePathName)")
////                        try fileManager.removeItem(at: URL(fileURLWithPath: filePathName))
////                }
//                
//                let files = try fileManager.contentsOfDirectory(atPath: "\(documentPath)")
//                print("all files in cache after deleting images: \(files)")
//            }
//            
//        } catch {
//            print("Could not clear temp folder: \(error)")
//        }
    }
    
    static func getDeviceDirectoryPath(fileName : String , pathForImage : Bool) -> String
    {
        let fileManager = FileManager.default
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
        
        let documentsPath = documentsUrl.path
        
        var arrData = fileName.components(separatedBy: "Documents/")
        print("0 : \(arrData[0])")
        print("1 : \(arrData[1])")
        
        let filePathName = arrData[1]
        var strResponse : String = String()
        if pathForImage == true
        {
            strResponse = "file://\(documentsPath!)/\(filePathName)"
        }
        else
        {
            strResponse = "\(documentsPath!)/\(filePathName)"
        }
        print("strResponse : \(strResponse)")
        return strResponse
    }
    
    static func getDirectoryPathOnly() -> String
    {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
        let documentsPath = documentsUrl.path
        
        return "file://\(documentsPath!)/"
    }
    
    static func loadImageFromUrl(imgView : UIImageView , strPath : String)
    {
        let url = URL(string: strPath)
        imgView.kf.indicatorType = .activity
        imgView.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(0.0))], progressBlock: nil, completionHandler: { (img, err, type, url) in
            if err != nil || img == nil
            {
                imgView.kf.indicatorType = .none
                imgView.image = UIImage(named: "DefaultReachout")
                print("Problem in caching image")
            }
        })
    }
    
    // This function will use image download and store only in cache with not much impotance and data which change frequatly, like dashboard.
    static func loadImageWithCacheFromUrlWithSignedUrl(imgView : UIImageView , strPath : String)
    {
        var isImageExist = ImageCache.default.isImageCached(forKey: strPath)
        if isImageExist.cached == true
        {
            ImageCache.default.retrieveImage(forKey: strPath, options: [.transition(.fade(0.0))]) { (img, cacheType) in
                imgView.image = img!
            }
        }
        else
        {
            self.getDownloadMediaThumbSignedURL(strPath) { (isSuccess, signedUrl, baseUrl) in
                if isSuccess == true
                {
                    let url = URL(string: signedUrl!)
                    let resource = ImageResource(downloadURL: url!, cacheKey: baseUrl!)
                    imgView.kf.indicatorType = .activity
                    imgView.kf.setImage(with: resource, placeholder: nil, options: [.transition(.fade(0.0))], progressBlock: nil, completionHandler: { (img, err, type, url) in
                        if err != nil || img == nil
                        {
                            imgView.kf.indicatorType = .none
                            imgView.image = UIImage(named: "DefaultReachout")
                            print("Problem in caching image")
                        }
                    })
                }
                else
                {
                    imgView.image = UIImage(named: "DefaultReachout")
                }
            }
        }
    }
    
    static func getCachedImageOrSignedURL(baseUrl : String ,  _ resBlock : @escaping ImageDownloaderBlock)
    {
        let isImageExist = ImageCache.default.isImageCached(forKey: baseUrl)
        if isImageExist.cached == true
        {
            ImageCache.default.retrieveImage(forKey: baseUrl, options: [.transition(.fade(0.0))]) { (img, cacheType) in
                if img != nil
                {
                    resBlock(img! , nil)
                }
                else
                {
                    resBlock(nil , nil)
                }
            }
        }
        else
        {
            self.getDownloadMediaThumbSignedURL(baseUrl) { (isSuccess, signedUrl, baseUrl) in
                if isSuccess == true
                {
                    var imgView = UIImageView()
                    let url = URL(string: signedUrl!)
                    let resource = ImageResource(downloadURL: url!, cacheKey: baseUrl!)
                    imgView.kf.setImage(with: resource, placeholder: nil, options: [.transition(.fade(0.0))], progressBlock: nil, completionHandler: { (img, err, type, url) in
                        if img != nil
                        {
                            resBlock(nil, (url!).absoluteString)
                        }
                        else
                        {
                            resBlock(nil, nil)
                        }
                    })
                }
                else
                {
                    resBlock(nil, nil)
                }
            }
        }
    }
    
    static func getCachedImageOrSignedURLForDashboardOnly(baseUrl : String ,  _ resBlock : @escaping ImageDownloaderBlock)
    {
        let isImageExist = ImageCache.default.isImageCached(forKey: baseUrl)
        if isImageExist.cached == true
        {
            ImageCache.default.retrieveImage(forKey: baseUrl, options: [.transition(.fade(0.0))]) { (img, cacheType) in
                if img != nil
                {
                    resBlock(img! , nil)
                }
                else
                {
                    resBlock(nil , nil)
                }
            }
        }
        else
        {
            self.getDownloadMediaThumbSignedURL(baseUrl) { (isSuccess, signedUrl, baseUrl) in
                if isSuccess == true
                {
                    var imgView = UIImageView()
                    let url = URL(string: signedUrl!)
                    ImageDownloader.default.downloadImage(with: url!, options: [.transition(.fade(0.0))], progressBlock: nil) {
                        (image, error, urlOriginal, data) in
                        if error == nil
                        {
                            // Store image into cache.
                            var strSigned = urlOriginal?.absoluteString
                            var arrBase = (strSigned!).components(separatedBy: "?response-content")
                            var strBaseUrl = "\(arrBase[0])"
                            print("Base URL to store into cache.: \(strBaseUrl)")
                            ImageCache.default.store(image!, forKey: strBaseUrl)
                            resBlock(image!, strBaseUrl)
                        }
                        if error != nil
                        {
                            resBlock(nil, nil)
                        }
                    }
                }
                else
                {
                    resBlock(nil, nil)
                }
            }
        }
    }
    
    static func loadImageFromUrlForProfile(imgView : UIImageView , strPath : String)
    {
        let url = URL(string: strPath)
        imgView.kf.indicatorType = .activity
        imgView.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(0.0))], progressBlock: nil, completionHandler: { (img, err, type, url) in
            if err != nil || img == nil
            {
                imgView.kf.indicatorType = .none
                imgView.image = UIImage(named: "user")
                print("Problem in caching Profile image")
            }
        })
    }
    
    static func loadImageFromUrlNoActivityIndicator(imgView : UIImageView , strPath : String)
    {
        let url = URL(string: strPath)
        imgView.kf.indicatorType = .none
        imgView.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(0.0))], progressBlock: nil, completionHandler: { (img, err, type, url) in
            if err != nil || img == nil
            {
                print("Problem in caching image")
            }
        })
    }
    
    static func compressImage(image: UIImage) -> UIImage {
        var actualHeight: Float = Float(image.size.height)
        var actualWidth: Float = Float(image.size.width)
        let maxHeight: Float = 350.0
        let maxWidth: Float = 350.0
        var imgRatio: Float = actualWidth / actualHeight
        let maxRatio: Float = maxWidth / maxHeight
        let compressionQuality: Float = 0.5
        //50 percent compression
        
        if actualHeight > maxHeight || actualWidth > maxWidth {
            if imgRatio < maxRatio {
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight
                actualWidth = imgRatio * actualWidth
                actualHeight = maxHeight
            }
            else if imgRatio > maxRatio {
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth
                actualHeight = imgRatio * actualHeight
                actualWidth = maxWidth
            }
            else {
                actualHeight = maxHeight
                actualWidth = maxWidth
            }
        }
        
        let rect = CGRect(x: 0.0, y: 0.0, width: CGFloat(actualWidth), height: CGFloat(actualHeight))
        UIGraphicsBeginImageContext(rect.size)
        image.draw(in: rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        let imageData = UIImageJPEGRepresentation(img!,CGFloat(compressionQuality))
        UIGraphicsEndImageContext()
        return UIImage(data: imageData!)!
    }
    
    static func setProfileImage(imgView : UIImageView)
    {
        let imgName = Util.Default.value(forKey: Constant.KEY_PROFILE_IMAGE_NAME) as! String
        let url = URL(string: "\(Constant.PROFILE_IMG_URL)\(imgName)")
        
        if Util.isConnectedToNetwork() == true
        {
            Util.imageDownload(String(describing: url!), nil, resBlock: { (img, identifier) in
                if img != nil
                {
                    Util.Default.set(UIImageJPEGRepresentation(img!, 100), forKey: Constant.KEY_PROFILE_IMAGE)
                    imgView.image = img
                }
                else
                {
                    imgView.image = UIImage(named: "user")
                }
            })
        }
        else
        {
            imgView.image = UIImage(named: "user")
        }
    }
    
    static func deviceTimerDisable(_ status : Bool)
    {
        UIApplication.shared.isIdleTimerDisabled = status
    }
    
    static func setImageAsPerType(imgView : UIImageView , objDashboard : Dashboard) // This method is used only for dashboar purpose...
    {
        imgView.image = UIImage(named: "DefaultReachout")
        imgView.backgroundColor = Constant.COLOR_IMG_BACKGROUND
        if objDashboard.media.type.caseInsensitiveCompare(Constant.MEDIA_TYPE_PHOTO) == ComparisonResult.orderedSame
        {
            var url = getDownloadMediaUrl(mediaId: objDashboard.media.id, fileName: objDashboard.media.path)
            Util.loadImageWithCacheFromUrlWithSignedUrl(imgView: imgView, strPath: url)
//            Util.loadImageFromUrl(imgView: imgView, strPath: url)
        }
        else if objDashboard.media.type.caseInsensitiveCompare(Constant.MEDIA_TYPE_VIDEO) == ComparisonResult.orderedSame
        {
            var url = getDownloadMediaThumbUrl(objDashboard.media.thumbPath)
            Util.loadImageWithCacheFromUrlWithSignedUrl(imgView: imgView, strPath: url)
//            Util.loadImageFromUrl(imgView: imgView, strPath: url)
        }
        else if objDashboard.media.type.caseInsensitiveCompare(Constant.MEDIA_TYPE_AUDIO) == ComparisonResult.orderedSame
        {
            imgView.image = UIImage(named: "DefaultAudio")
            imgView.contentMode = .scaleAspectFit
        }
    }
    
    static func setImageAsPerType(imgView : UIImageView , objMedia : Media)
    {
        imgView.backgroundColor = Constant.COLOR_BLACK
        if objMedia.type.caseInsensitiveCompare(Constant.MEDIA_TYPE_PHOTO) == ComparisonResult.orderedSame
        {
            var url = getDownloadMediaUrl(mediaId: objMedia.mediaId, fileName: objMedia.path)
            Util.loadImageWithCacheFromUrlWithSignedUrl(imgView: imgView, strPath: url)
//            Util.loadImageFromUrl(imgView: imgView, strPath: url)
        }
        else if objMedia.type.caseInsensitiveCompare(Constant.MEDIA_TYPE_VIDEO) == ComparisonResult.orderedSame
        {
            var url = getDownloadMediaThumbUrl(objMedia.thumbPath)
            Util.loadImageWithCacheFromUrlWithSignedUrl(imgView: imgView, strPath: url)
//            Util.loadImageFromUrl(imgView: imgView, strPath: url)
        }
        else if objMedia.type.caseInsensitiveCompare(Constant.MEDIA_TYPE_AUDIO) == ComparisonResult.orderedSame
        {
            imgView.image = UIImage(named: "DefaultAudio")
            imgView.contentMode = .scaleAspectFit
        }
    }
    
    static func setImageAsPerType(imgView : UIImageView , objMediaRequest : MediaRequest)
    {
        imgView.backgroundColor = Constant.COLOR_BLACK
        if objMediaRequest.sampleType.caseInsensitiveCompare(Constant.MEDIA_TYPE_PHOTO) == ComparisonResult.orderedSame
        {
            var url = getDownloadMediaSampleUrl(mediaId: objMediaRequest.sampleId, fileName: objMediaRequest.samplePath)
            Util.loadImageWithCacheFromUrlWithSignedUrl(imgView: imgView, strPath: url)
//            Util.loadImageFromUrl(imgView: imgView, strPath: url)
        }
        else if objMediaRequest.sampleType.caseInsensitiveCompare(Constant.MEDIA_TYPE_VIDEO) == ComparisonResult.orderedSame
        {
            var url = getDownloadMediaSampleThumbUrl(objMediaRequest.sampleThumbPath)
            Util.loadImageWithCacheFromUrlWithSignedUrl(imgView: imgView, strPath: url)
//            Util.loadImageFromUrl(imgView: imgView, strPath: url)
        }
        else if objMediaRequest.sampleType.caseInsensitiveCompare(Constant.MEDIA_TYPE_AUDIO) == ComparisonResult.orderedSame
        {
            imgView.image = UIImage(named: "DefaultAudio")
            imgView.contentMode = .scaleAspectFit
        }
    }
    
    static func setUserImage(imgView : UIImageView , objDashboard : Dashboard)
    {
        self.imageRound(image: imgView)
        if Util.targetOfProject() == Constant.TARGET_BLACK
        {
            imgView.layer.borderWidth = 1.0
        }
        
        Util.setSVGImage(imageName: "user", imgView: imgView)
        if objDashboard.user.profileImgName != ""
        {
            let url = "\(Constant.PROFILE_IMG_URL)\(objDashboard.user.profileImgName)"
//            Util.loadImageFromUrlNoActivityIndicator(imgView: imgView, strPath: url)
            Util.loadImageFromUrlForProfile(imgView: imgView, strPath: url)
        }
        else
        {
            Util.setSVGImage(imageName: "user", imgView: imgView)
        }
    }
    
    static func setUserImage(imgView : UIImageView , objMedia : Media)
    {
        self.imageRound(image: imgView)
//        Util.setSVGImage(imageName: "user", imgView: imgView)
        imgView.image = UIImage(named : "user")
        if objMedia.user.profileImgName != ""
        {
            let url = "\(Constant.PROFILE_IMG_URL)\(objMedia.user.profileImgName)"
//            Util.loadImageFromUrlNoActivityIndicator(imgView: imgView, strPath: url)
            Util.loadImageFromUrlForProfile(imgView: imgView, strPath: url)
        }
        else
        {
            imgView.image = UIImage(named : "user")
//            Util.setSVGImage(imageName: "user", imgView: imgView)
        }
    }
    
    static func setOrganizationImage(imgView : UIImageView , objMediaRequest : MediaRequest)
    {
//        Util.setSVGImage(imageName: "DefaultReachout", imgView: imgView)
        imgView.image = UIImage(named: "DefaultReachout")
        if objMediaRequest.mediaHouse.logoUrl != ""
        {
            let url = "\(Constant.ORG_PROFILE_IMG_URL)\(objMediaRequest.mediaHouse.logoUrl)"
//            Util.loadImageFromUrlNoActivityIndicator(imgView: imgView, strPath: url)
            Util.loadImageFromUrl(imgView: imgView, strPath: url)
        }
        else
        {
            Util.setSVGImage(imageName: "DefaultReachout", imgView: imgView)
        }
    }
    
    
    // below funcation will set image on that imageview.. if not in DIR_MY_VIDEOS than download nd copy into that, else take from DIR_MY_VIDEOS..
    
    static func cancelDownloadingImage()
    {
        
    }
    
    static func imageDownload(_ path : String ,_ identifer : String? , resBlock : @escaping ImageDownloaderBlock)
    {
        let url = URL(string: path)
        if url != nil
        {
            ImageDownloader.default.downloadImage(with: url!, options: [.transition(.fade(0.0))], progressBlock: nil) {
                (image, error, url, data) in
                if error == nil
                {
                    var arrFileName = (url?.lastPathComponent)!.components(separatedBy: "-")
                    Util.copyImageToDirectory(directoryName: Constant.DIR_MY_VIDEOS, image: image!, fileName: arrFileName[arrFileName.count - 1])
                    resBlock(image!, identifer)
                }
                if error != nil
                {
                    resBlock(nil, identifer) // At here, We can set image if error occure.. something static image.
                }
            }
        }
        else
        {
            resBlock(nil, identifer)
        }
    }
    
    static func imageDownloadThumb(_ path : String ,_ identifer : String? , resBlock : @escaping ImageDownloaderBlock)
    {
        let url = URL(string: path)
        if url != nil
        {
            ImageDownloader.default.downloadImage(with: url!, options: [.transition(.fade(0.0))], progressBlock: nil) {
                (image, error, url, data) in
                if error == nil
                {
                    var arrFileName = (url?.lastPathComponent)!.components(separatedBy: "/")
                    Util.copyImageToDirectory(directoryName: Constant.DIR_MY_VIDEOS, image: image!, fileName: arrFileName[arrFileName.count - 1])
                    resBlock(image!, identifer)
                }
                if error != nil
                {
                    resBlock(nil, identifer) // At here, We can set image if error occure.. something static image.
                }
            }
        }
        else
        {
            resBlock(nil, identifer)
        }
    }
    
    static func takeScreenshot(view: UIView) -> UIImage {
//        UIGraphicsBeginImageContext(view.frame.size)
//        view.layer.render(in: UIGraphicsGetCurrentContext()!)
//        let image = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
        
//        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, UIScreen.main.scale)
//        view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
//        let image = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
        
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        for window in UIApplication.shared.windows {
            window.drawHierarchy(in: window.bounds, afterScreenUpdates: false)
        }
        
//        view.layer.render(in: context!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    static func renameFileName(oldName : String , newName : String)
    {
        do {
            let path = self.getDirectoryPath(directoryName: Constant.DIR_MY_VIDEOS)
            let documentDirectory = URL(fileURLWithPath: path)
            let originPath = documentDirectory.appendingPathComponent(oldName)
            let destinationPath = documentDirectory.appendingPathComponent(newName)
            print("OldName Path : \(originPath) , NewName Path : \(destinationPath)")
            
            if isFileExistAtDirectory(directoryName: Constant.DIR_MY_VIDEOS, fileName: oldName)
            {
                try FileManager.default.moveItem(at: originPath, to: destinationPath)
            }
//            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
//            let documentDirectory = URL(fileURLWithPath: path)
//            let originPath = documentDirectory.appendingPathComponent("currentname.pdf")
//            let destinationPath = documentDirectory.appendingPathComponent("newname.pdf")
//            try FileManager.default.moveItem(at: originPath, to: destinationPath)
        } catch {
            print(error)
        }
    }
    
    // below functin will copy image to desire directory..
    static func copyImageToDirectory(directoryName : String , image : UIImage , fileName : String) -> (Code : Int,msg : String)
    {
        let path = Util.getDirectoryPath(directoryName: directoryName)
        let fileURL = path.appending(fileName)
        let finalPath = URL(string: fileURL)
        
        if !Util.isFileExistAtDirectory(directoryName: directoryName, fileName: fileName)
        {
            do {
                try UIImagePNGRepresentation(image)!.write(to: finalPath!)
                print("Image downloaded and copied into document directory successfully")
                return ( 0 , "Success")
                
            } catch {
                print(error)
                return ( 1 , "Fail")
            }
        }
        else
        {
            print("Image already exist")
            return ( 2 , "Alreadt Exist")
        }
    }
    
    static func copyVideoToDirectory(directoryName : String , videoURL : URL , fileName : String) -> (Code : Int,msg : String)
    {
        let path = Util.getDirectoryPath(directoryName: directoryName)
        let fileURL = path.appending(fileName)
        let finalPath = URL(string: fileURL)
        
        if !Util.isFileExistAtDirectory(directoryName: directoryName, fileName: fileName)
        {
            let myVideoVarData = try! Data(contentsOf: videoURL)
            
            do {
                try? myVideoVarData.write(to: finalPath!, options: [])
                return ( 0 , "Success")
            } catch {
                print(error)
                return ( 1 , "Fail")
            }
        }
        else
        {
            print("Image already exist")
            return ( 2 , "Alreadt Exist")
        }
    }
    
    static func copyAudioToDirectory(directoryName : String , videoURL : URL , fileName : String) -> (Code : Int,msg : String)
    {
        let path = Util.getDirectoryPath(directoryName: directoryName)
        let fileURL = path.appending(fileName)
        let finalPath = URL(string: fileURL)
        
        if !Util.isFileExistAtDirectory(directoryName: directoryName, fileName: fileName)
        {
            do {
                
                let myVideoVarData = try! Data(contentsOf: videoURL)
                
                let recordSettings:[String : AnyObject] = [
                    AVFormatIDKey:             NSNumber(value: kAudioFormatAppleLossless),
                    AVEncoderAudioQualityKey : NSNumber(value:AVAudioQuality.max.rawValue),
                    AVEncoderBitRateKey :      NSNumber(value:320000),
                    AVNumberOfChannelsKey:     NSNumber(value:2),
                    AVSampleRateKey :          NSNumber(value:44100.0)
                ]
                try? myVideoVarData.write(to: finalPath!, options: [])
//                try? AVAudioRecorder(url: finalPath!, settings: recordSettings)
                
                return ( 0 , "Success")
            } catch {
                print(error)
                return ( 1 , "Fail")
            }
        }
        else
        {
            print("Image already exist")
            return ( 2 , "Alreadt Exist")
        }
    }
    
    // This is the original function from where all url are created to download media.
    static func getDownloadMediaUrl(mediaId : String , fileName : String) -> String
    {
        return "\(Constant.MEDIA_DOWNLOAD_URL)original/\(mediaId)-\(fileName)"
//        return "\(Constant.MEDIA_DOWNLOAD_URL)\(mediaId)-\(fileName)"
    }
    
    static func getDownloadMediaSampleUrl(mediaId : String , fileName : String) -> String
    {
        return "\(Constant.MEDIA_DOWNLOAD_URL)samples/\(mediaId)-\(fileName)"
    }
    
    static func getDownloadMediaSignedURL(url : String , _ resBlock : @escaping SignedURLBlock)
    {
        var concatedUrl = url
        
        var objMedia = Media()
        objMedia.getSignedURL(mediaUrl: concatedUrl) { (_ resObj : NSObject ,_ resCode : Int,_ resMessage : String) -> Void in
            if resCode == Constant.RES_CODE_SUCCESS
            {
                var objMedia = resObj as! Media
                print("SIGN URL : \(objMedia.signedURL)")
                resBlock(true, objMedia.signedURL , objMedia.baseURL)
            }
            else
            {
                resBlock(false, nil, nil)
            }
        }
    }
    
    static func getDownloadMediaSampleThumbUrl(_ thumbName : String) -> String
    {
        var strConcatedUrl = ""
        if UIScreen.main.scale == 1.0
        {
            strConcatedUrl = "\(Constant.MEDIA_DOWNLOAD_URL)samples/\(thumbName)"
        }
        else if UIScreen.main.scale == 2.0
        {
            strConcatedUrl = "\(Constant.MEDIA_DOWNLOAD_URL)samples/\(thumbName)"
        }
        else
        {
            strConcatedUrl = "\(Constant.MEDIA_DOWNLOAD_URL)samples/\(thumbName)"
        }
        return strConcatedUrl
    }
    
    // This is the original function from where all url are created to download media.
    static func getDownloadMediaThumbUrl(_ thumbName : String) -> String
    {
        var strConcatedUrl = ""
        if UIScreen.main.scale == 1.0
        {
            strConcatedUrl = "\(Constant.MEDIA_DOWNLOAD_URL)thumbnails/\(thumbName)"
        }
        else if UIScreen.main.scale == 2.0
        {
            strConcatedUrl = "\(Constant.MEDIA_DOWNLOAD_URL)thumbnails/\(thumbName)"
        }
        else
        {
            strConcatedUrl = "\(Constant.MEDIA_DOWNLOAD_URL)thumbnails/\(thumbName)"
        }
        return strConcatedUrl
    }
    
    
    // This is function which generated signd url for the thumb purpose.
    static func getDownloadMediaThumbSignedURL(_ thumbName : String , _ resBlock : @escaping SignedURLBlock)
    {
//        var strConcatedUrl = ""
        var strConcatedUrl = thumbName
//        if UIScreen.main.scale == 1.0
//        {
//            strConcatedUrl = "\(Constant.MEDIA_DOWNLOAD_URL)thumbnails/\(thumbName)"
//        }
//        else if UIScreen.main.scale == 2.0
//        {
//            strConcatedUrl = "\(Constant.MEDIA_DOWNLOAD_URL)thumbnails/\(thumbName)"
//        }
//        else
//        {
//            strConcatedUrl = "\(Constant.MEDIA_DOWNLOAD_URL)thumbnails/\(thumbName)"
//        }
        
        var objMedia = Media()
        objMedia.getSignedURL(mediaUrl: strConcatedUrl) { (_ resObj : NSObject ,_ resCode : Int,_ resMessage : String) -> Void in
            if resCode == Constant.RES_CODE_SUCCESS
            {
                var objMedia = resObj as! Media
                print("SIGN URL : \(objMedia.signedURL)")
                resBlock(true, objMedia.signedURL , objMedia.baseURL)
            }
            else
            {
                resBlock(false, nil, nil)
            }
        }
    }
    
    static func makeThumbName(_ mediaId : String) -> String
    {
        var strConcatedUrl = ""
        if UIScreen.main.scale == 1.0
        {
            strConcatedUrl = "\(mediaId)-small.jpg"
        }
        else if UIScreen.main.scale == 2.0
        {
            strConcatedUrl = "\(mediaId)-medium.jpg"
        }
        else
        {
            strConcatedUrl = "\(mediaId)-large.jpg"
        }
        return strConcatedUrl
    }
    
    static func convertStrToUtf8(strToConvert  : String) -> String
    {
        let strSyncDate = String(utf8String: strToConvert.cString(using: .utf8)!)!
        return strSyncDate
    }
    
    static func convertStrToUrl(strToConvert  : String) -> String
    {
        var strSyncDate = strToConvert.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
        strSyncDate = strSyncDate?.replace(target: "+", withString: "%2b")
        return strSyncDate!
    }
    
    static func loginWithFB(vcName : UIViewController , resBlock:  @escaping trueFalseBlock)
    {
        trueFalseCompletion = resBlock
        
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.loginBehavior = FBSDKLoginBehavior.native
        
        fbLoginManager.logIn(withPublishPermissions: ["publish_actions"], from: vcName) { (result, err) in
            if err != nil
            {
                print("fb login fail : \(err)")
                Util.Default.setValue("false", forKey: Constant.KEY_FACEBOOK_LOGIN)
                trueFalseCompletion(false)
                return
            }
            else if result?.isCancelled == true
            {
                print("cancel alled at share permission time  : \(result?.isCancelled)")
                Util.Default.setValue("false", forKey: Constant.KEY_FACEBOOK_LOGIN)
                trueFalseCompletion(false)
            }
            else
            {
                print("token : \(FBSDKAccessToken.current().tokenString!)")

                Util.Default.setValue("true", forKey: Constant.KEY_FACEBOOK_LOGIN)
                trueFalseCompletion(true)
            }
        }
    }
    
    static func loginWithLinkedIn(resBlock:  @escaping trueFalseBlock)
    {
        trueFalseCompletion = resBlock
        
        LISDKSessionManager.createSession(withAuth: [ LISDK_W_SHARE_PERMISSION , LISDK_BASIC_PROFILE_PERMISSION , LISDK_EMAILADDRESS_PERMISSION], state: nil, showGoToAppStoreDialog: true, successBlock: { (success) in
            var session = LISDKSessionManager.sharedInstance().session
            
            let url = "https://api.linkedin.com/v1/people/~"
            if (LISDKSessionManager.hasValidSession())
            {
                LISDKAPIHelper.sharedInstance().getRequest(url, success: { (response) in
                    print("response : \(response?.data)")
                    Util.Default.setValue("true", forKey: Constant.KEY_LINKEDIN_LOGIN)
                    trueFalseCompletion(true)
                }, error: { (error) in
                    print("error : \(error)")
                    Util.Default.setValue("false", forKey: Constant.KEY_LINKEDIN_LOGIN)
                    trueFalseCompletion(false)
                })
            }
        }) { (error) in
            print("error  : \(error)")
            
            Util.Default.setValue("false", forKey: Constant.KEY_LINKEDIN_LOGIN)
            trueFalseCompletion(false)
        }
    }
    
    static func commonDefaltMediaDetails() -> NSMutableDictionary
    {
        var dicSave : NSMutableDictionary = NSMutableDictionary()
        dicSave["created_date"] = "\(Util.getCurrentUTCDateTime())"
        dicSave["updated_date"] = "\(Util.getCurrentUTCDateTime())"
        dicSave["title"] = Constant.DEFAULT_TITLE
        dicSave["desc"] = Constant.DEFAULT_DESCRIPTION
        dicSave["media_lat"] = "\(Util.getCurrentLocationLatitude())"
        dicSave["media_long"] = "\(Util.getCurrentLocationLongitude())"
        dicSave["media_status"] = "2"
        dicSave["city"] = "\(Util.getCurrentLocationCity())"
        dicSave["address"] = "\(Util.getCurrentLocationAddress())"
        dicSave["is_sold"] = "\(Constant.BOOL_FALSE)"
        dicSave["is_for_sell"] = "\(Constant.BOOL_FALSE)"
        dicSave["is_ready_for_sell"] = "\(Constant.BOOL_FALSE)"
        dicSave["is_favourite"] = "\(Constant.BOOL_FALSE)"
        dicSave["rec_price"] = "0"
        dicSave["exc_price"] = "0"
        dicSave["user_price"] = "0"
        dicSave["media_ratting"] = "2.5"
        dicSave["download_status"] = "\(Constant.MEDIA_DOWNLOAD_UPLOAD_STATUS_COMPLETED)"
        dicSave["thumb_upload_status"] = "\(Constant.MEDIA_DOWNLOAD_UPLOAD_STATUS_COMPLETED)"
        dicSave["thumb_download_status"] = "\(Constant.MEDIA_DOWNLOAD_UPLOAD_STATUS_COMPLETED)"
        return dicSave
    }
    
    static func getOtp(dic : NSDictionary,apiName : String) -> String
    {
        var strOtp : String = String()
        let dicOtp = dic["otpMap"] as! NSDictionary
        if apiName == Constant.ACTION_USER_CREATE
        {
            let dicOtpData = dicOtp["registration"] as! NSDictionary
            strOtp = dicOtpData["code"] as! String
        }
        else if apiName == Constant.ACTION_UPDATE || apiName == Constant.ACTION_CHANGE_EMAIL
        {
            let dicOtpData = dicOtp["email varification"] as! NSDictionary
            strOtp = dicOtpData["code"] as! String
        }
        else if apiName == Constant.ACTION_CHANGE_USERNAME
        {
            let dicOtpData = dicOtp["change username verification"] as! NSDictionary
            strOtp = dicOtpData["code"] as! String
        }
        else if apiName == Constant.ACTION_VERIFY_PAYTM_NUMBER
        {
            let dicOtpData = dicOtp["Paytm verification"] as! NSDictionary
            strOtp = dicOtpData["code"] as! String
        }
        return strOtp
    }
    
    static func targetOfProject() -> String
    {
        
//        var target = Constant.TARGET_RED
        let target = Constant.TARGET_BLACK

//        #if TARGET_RED
//            print("RED")
//            target = Constant.TARGET_RED
//        #else
//            print("black")
//            target = Constant.TARGET_BLACK
//        #endif
        
        return target
    }
    
    static func selectStoryboard() -> UIStoryboard
    {
//        #if TARGET_RED
//            print("++--RED")
//            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        #else
//            print("++--BLACK")
            let storyBoard : UIStoryboard = UIStoryboard(name: "MainBlack", bundle: nil)
//        #endif
        return storyBoard
    }
    
    static func flashUserData()
    {
        let cacheImages : ImageCache = ImageCache.default
        cacheImages.clearDiskCache()
        
        self.clearFolder(dirName: Constant.DIR_MY_VIDEOS)
        SRVideoDownloader().clearCachedVideos()
        
        DatabaseHelper().deleteAllRecord(tblName: Constant.TBL_CATEGORY)
        DatabaseHelper().deleteAllRecord(tblName: Constant.TBL_MEDIA)
        DatabaseHelper().deleteAllRecord(tblName: Constant.TBL_MEDIA_SOCIAL_SHARE)
        DatabaseHelper().deleteAllRecord(tblName: Constant.TBL_MEDIA_REQUEST)
        DatabaseHelper().deleteAllRecord(tblName: Constant.TBL_TRANSACTION)
        DatabaseHelper().deleteAllRecord(tblName: Constant.TBL_QUESTION)
        DatabaseHelper().deleteAllRecord(tblName: Constant.TBL_ANSWER)
        DatabaseHelper().deleteAllRecord(tblName: Constant.TBL_OPTION)
        DatabaseHelper().deleteAllRecord(tblName: Constant.TBL_SURVEY_SYNC_STATUS)
        
        DatabaseHelper.deleteDatabaseFromDevice(databaseName: Constant.databaseName)
        DatabaseHelper.createDatabaseFromAssests(databaseName: Constant.databaseName)
    }
    
//    static func printDebug(_ log : Any)
//    {
//        print(log)
//    }
    
    static func printDebug(_ log : Any)
    {
        print(log)
    }
    
    static func socialLogout()
    {
        FBSDKLoginManager().logOut()
        LISDKSessionManager.clearSession()
        twitterHelper.logoutUserFromTwitter()
//        googlePlusHelper.logoutUserFromGooglePlus()
        pintrestHelper.logutUserFromPintRest()
    }
    
    static func logOutReachout(isManualLogout : String )
    {
        self.showLoading()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//        DispatchQueue.main.async {
            
            let appdelegate = UIApplication.shared.delegate as! AppDelegate
            appdelegate.viewCheckAccess.layer.zPosition = 0
            
            ETechAsyncRequest.stopAllSessions()
            ImageCache.default.clearMemoryCache()
            socialLogout()
            appDele.uploadService.cancelAllUploads()
//            appDele.syncObj.helperObj.disconnectSFTP()
            appDele.syncObj.isDeleting = false
            appDele.syncObj.isUpdating = false
            appDele.syncObj.isUpdatingSharing = false

            appDele.syncDownloadObj.downloadAllCancel()

            Util.Default.setValue(false, forKey: Constant.KEY_IS_DOWNLOAD_ALLOWED)
            Util.Default.setValue(false, forKey: Constant.KEY_IS_AUTHENTICATED)
            Util.Default.setValue(nil, forKey: Constant.KEY_DASHBOARD_INDEX_VALUE)
            Util.Default.setValue(nil, forKey: Constant.KEY_WALLET_FILTER_DATA)
            Util.Default.setValue(nil, forKey: Constant.KEY_DATA_USER)
            Util.Default.setValue(nil, forKey: Constant.KEY_TOKENS)
            Util.Default.setValue(nil, forKey: Constant.KEY_ACCESS_TOKEN_DUE_TIME_TO_EXPIRE)            
            Util.Default.setValue(nil, forKey: Constant.KEY_USERNAME)
            Util.Default.setValue(nil, forKey: Constant.KEY_USER_INFO)
            Util.Default.setValue(nil, forKey: Constant.KEY_PROFILE_IMAGE_NAME)
            Util.Default.setValue(nil, forKey: Constant.KEY_PROFILE_IMAGE)
            Util.Default.setValue(nil, forKey: Constant.KEY_IS_LOGIN)
            Util.Default.setValue(nil, forKey: Constant.KEY_IS_USER_ID)
            Util.Default.setValue(nil, forKey: Constant.KEY_NOTIFICATION_DEVICE_TOKEN_REGISTERED)
            Util.Default.setValue(nil, forKey: Constant.KEY_USER_TYPE)
            Util.Default.setValue(nil, forKey: Constant.KEY_USER_MOBILE_NUMBER)
            
            
            Util.Default.setValue(nil, forKey: Constant.KEY_WALLET_SYNC_DATE)
            Util.Default.setValue(nil, forKey: Constant.KEY_SEEN_LIST_SYNC_DATE)
            Util.Default.setValue(nil, forKey: Constant.KEY_SHARED_WITH_ME_SYNC_DATE)
            Util.Default.setValue(nil, forKey: Constant.KEY_MY_REQUEST_SYNC_DATE)
            
            Util.Default.setValue(nil, forKey: Constant.KEY_PUSH_NOTIFICATION_MEDIA_REQUEST)
            Util.Default.setValue(nil, forKey: Constant.KEY_PUSH_NOTIFICATION_MEDIA_SOLD)
            Util.Default.setValue(nil, forKey: Constant.KEY_PUSH_NOTIFICATION_MEDIA_VIEWED)
            Util.Default.setValue(nil, forKey: Constant.KEY_PUSH_NOTIFICATION_SHARED_WITH_ME)
            
            self.hideLoading()
            
            if isManualLogout == Constant.LOGOUT_GOTO_LOGIN_FROM_SYNC
            {
                print("Sync fail logout")
                flashUserData()
            }
            else
            {
                let appdelegate = UIApplication.shared.delegate as! AppDelegate
                let storyboard = self.selectStoryboard()
                let gotoLoginVC = storyboard.instantiateViewController(withIdentifier: Constant.loginVCIdentifierName) as! LoginVC
                gotoLoginVC.isFromLogout = true
                let nav : UINavigationController = UINavigationController()
                nav.viewControllers  = [gotoLoginVC]
                nav.isNavigationBarHidden = true
                appdelegate.window?.rootViewController = nav
            }
            
            if isManualLogout == "\(Constant.BOOL_FALSE)"
            {
                flashUserData()
                Util.showSystemAlert(type: "single", title: "Authentication Failed", msg: "Relogin Again", positiveBlock: nil, negativeBlock: nil)
            }
            else if isManualLogout == "\(Constant.LOGOUT_DEVICE_CHANGE)"
            {
                print("Device Change logout")
                flashUserData()
            }           
        }
    }
    
    //MARK:- Permission check functions
    
    static func isConnectedToNetwork() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
    
    static func isLocationDenied() -> Bool
    {
        var isDenied = false
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.denied
        {
            isDenied = true
        }
        return isDenied
    }
    
    static func isBackgroundRefreshOff() -> Bool
    {
        var isOff = false
        if UIApplication.shared.backgroundRefreshStatus == .denied
        {
            isOff = true
        }
        return isOff
    }
    
    static func isOnCall() -> Bool
    {
        if #available(iOS 10.0, *) {
            for call in CXCallObserver().calls {
                if call.hasEnded == false {
                    return true
                }
            }
        } else {
            // Fallback on earlier versions
            return false
        }
        return false
    }
    
    //MARK:- iOS System functions
    
    static func getVersion() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
//        return "\(version) Build : \(build)"
        return "\(version)"
    }
    
    static func readDashboardTemplateJsonFile() -> NSMutableArray?
    {
        var arrTemplate : NSMutableArray = NSMutableArray()
        if let url = Bundle.main.url(forResource: "template_dashboard", withExtension: "json") {
            if let data = NSData(contentsOf: url) {
                do {
                    let array = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments) as? NSArray
                    arrTemplate = array?.mutableCopy() as! NSMutableArray
                    return arrTemplate
                } catch {
                    print("Error!! Unable to parse  template_dashboard.json")
                }
            }
            return arrTemplate
            print("Error!! Unable to load  template_dashboard.json")
        }
        return arrTemplate
    }
    
    static func createDirectory(dirName: String)
    {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dataPath = documentsDirectory.appendingPathComponent(dirName)
        
        do {
            try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: false, attributes: nil)
        } catch let error as NSError {
            //            print("Error creating directory: \(error.localizedDescription)")
        }
    }
    
    static func deleteFile(fileName : String , dirName : String) -> Bool
    {
        var isDelete:Bool = false
        let fileManager = FileManager()
        var filePath = Util.getDirectoryPath(directoryName: dirName)
        var arrfilePath = filePath.components(separatedBy: "file://")
        filePath = arrfilePath[1]
        let completePath = filePath.appending(fileName)
        
        print("deleteFile : completePath to delete : \(completePath)")
        if fileManager.fileExists(atPath: completePath) {
            print("fileExists")
        } else {
            print("fileExists not")
        }
        if fileManager.fileExists(atPath: completePath) {
            isDelete = ((try? fileManager.removeItem(atPath: completePath)) != nil)
        } else {
            isDelete = true
        }
        if fileManager.fileExists(atPath: completePath) {
            print("fileExists")
        } else {
            print("fileExists not")
        }
        return isDelete
    }
    
    static func clearFolder(dirName : String)
    {
        let path = Util.getDirectoryPath(directoryName: dirName)
        
        let fileManager = FileManager.default
        let fileUrls = fileManager.enumerator(at: URL(string: path)!, includingPropertiesForKeys: nil)
        
        while let fileUrl = fileUrls?.nextObject() {
            do {
                try fileManager.removeItem(at: fileUrl as! URL)
            } catch {
                print(error)
            }
        }
    }
    
    static func isFileExistAtDirectory(directoryName : String , fileName : String) -> Bool
    {
        let path = Util.getDirectoryPath(directoryName: directoryName)
        let filePath = URL(string: "\(path)\(fileName)")
        print("fileName : \(fileName)")
        if filePath != nil
        {
            if FileManager.default.fileExists(atPath: (filePath?.path)!)
            {
                return true
            }
            else
            {
                return false
            }
        }
        else
        {
            return false
        }
    }
    
    static func getDirectoryPath(directoryName : String) -> String
    {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dataPath = documentsDirectory.appendingPathComponent(directoryName)
        return String(describing: dataPath)
    }
    
    static func isFacebookInstalled() -> Bool
    {
        if UIApplication.shared.canOpenURL(NSURL(string:"fbauth2://")! as URL) == true
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    static func isTwitterInstalled() -> Bool
    {
        if UIApplication.shared.canOpenURL(NSURL(string:"twitter://")! as URL) == true
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    static func isLinkedinInstalled() -> Bool
    {
        if UIApplication.shared.canOpenURL(NSURL(string:"linkedin://")! as URL) == true
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    //MARK:- End OFF Util Functions =============================================================
    
}


var trueFalseCompletion1 : trueFalseBlock = { successFail in }
var twitterHelper = TwitterHelper()
//var googlePlusHelper = GooglePlusHelper()
var pintrestHelper = PintrestHelper()

extension UIViewController :  PintrestHelperDelegate, TwitterHelperDelegate  {
    
    func dismissModalStack(animated: Bool, completion: (() -> Void)?) {
        let fullscreenSnapshot = UIApplication.shared.delegate?.window??.snapshotView(afterScreenUpdates: false)
        if !isBeingDismissed {
            var rootVc = presentingViewController
            while rootVc?.presentingViewController != nil {
                rootVc = rootVc?.presentingViewController
            }
            let secondToLastVc = rootVc?.presentedViewController
            if fullscreenSnapshot != nil {
                secondToLastVc?.view.addSubview(fullscreenSnapshot!)
            }
            secondToLastVc?.dismiss(animated: false, completion: {
                rootVc?.dismiss(animated: true, completion: completion)                
            })
        }
    }
    
    func dismissModalStack1(animated: Bool, completion: (() -> Void)?) {
        let fullscreenSnapshot = UIApplication.shared.delegate?.window??.snapshotView(afterScreenUpdates: false)
        if !isBeingDismissed {
            var rootVc = presentingViewController
            while rootVc?.presentingViewController != nil {
                rootVc = rootVc?.presentingViewController
            }
            let secondToLastVc = rootVc?.presentedViewController
            if fullscreenSnapshot != nil {
                secondToLastVc?.view.addSubview(fullscreenSnapshot!)
            }
//            secondToLastVc?.dismiss(animated: false, completion: {
//                rootVc?.dismiss(animated: true, completion: completion)
//            })
        }
    }
    
    //MARK:- Share on Twitter
    
    func loginWithTwitter(resBlock:  @escaping trueFalseBlock)
    {
        twitterHelper = TwitterHelper()
        trueFalseCompletion1 = resBlock
        twitterHelper.objTwitterDelegate = self
        twitterHelper.loginTwitter()
    }
    
//    func logoutTwitter(resBlock:  @escaping trueFalseBlock)
//    {
//        let twitterHelper : TwitterHelper = TwitterHelper()
//        trueFalseCompletion1 = resBlock
//        twitterHelper.objTwitterDelegate = self
//        twitterHelper.logoutUserFromTwitter()
//    }
    
    func uploadImageTwitter(img : UIImage? , type : String? , resBlock:  @escaping trueFalseBlock)
    {
        twitterHelper = TwitterHelper()
        trueFalseCompletion1 = resBlock
        twitterHelper.objTwitterDelegate = self
        twitterHelper.uploadImageWithImageUrl(twitterImage: img!, withTwittertext: "Reachout", inViewController: self)
    }
    
    func uploadVideoTwitter(url : String? , resBlock:  @escaping trueFalseBlock)
    {
        twitterHelper = TwitterHelper()
        trueFalseCompletion1 = resBlock
        twitterHelper.objTwitterDelegate = self
        twitterHelper.uploadVideoWithThumbImage(withTweetText: "Reachout", videoFilePath: url!, inViewController: self)
    }
    
    //MARK:- TwitterHelperDelegate methods
    public func loginResponseTwitter(resultLogin: Bool, ifErrorFound: String) {
        if resultLogin == true
        {
            trueFalseCompletion1(true)
        }
        else
        {
            trueFalseCompletion1(false)
        }
    }
    
    public func mediaUploadStatusSuccessOrFailedTwitter(succedResponse: String, succedStatus: Bool) {
        if succedStatus == true
        {
            trueFalseCompletion1(true)
        }
        else
        {
            trueFalseCompletion1(false)
        }
    }
    
    public func mediaUploadCanceledTwitter(uploadCanceled: String) {
        print("UTILL:: \(uploadCanceled)")
    }
    
    
    //MARK:- Share on Pintrest
    
    func loginWithPintrest(resBlock:  @escaping trueFalseBlock)
    {
        pintrestHelper = PintrestHelper()
        trueFalseCompletion1 = resBlock
        pintrestHelper.pintrestHellperDelegate = self
        pintrestHelper.loginWithPintrest(with: self)
    }
    
    func uploadImagePintrest(img : UIImage? , resBlock:  @escaping trueFalseBlock)
    {
        pintrestHelper = PintrestHelper()
        trueFalseCompletion1 = resBlock
        pintrestHelper.pintrestHellperDelegate = self
        pintrestHelper.postImageInPintrest(with: img!, uploadURLLink: URL(string : ""), withBoardDescription: "", pinDescription: "")
    }
    
    //MARK:- PintrestHelperDelegate methods
    
    public func userLoginStatusPintrest(_ isLogin: Bool, withSuccedOrFailedMsg loginMsg: String!) {
        if isLogin == true
        {
            trueFalseCompletion1(true)
        }
        else
        {
            trueFalseCompletion1(false)
        }
    }
    
    public func mediaUploadResponseProcessPintrest(_ uploadProcess: CGFloat) {
        print("Media Upload Progress \(uploadProcess) %")
    }
    
    public func mediaUploadResponsePintrest(_ uploadStatus: Bool, withMessage uploadMsg: String!) {
        if uploadStatus == true
        {
            trueFalseCompletion1(true)
        }
        else
        {
            trueFalseCompletion1(false)
        }
    }
    
    //MARK:- Others
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboardView))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboardView() {
        view.endEditing(true)
    }
    
    func alertGotoSetting(msg: String , cancel:((UIAlertAction?) -> Void)?)
    {
        let strMsg = Util.localizedString(value: msg)
        let alert = UIAlertController(title: Util.applicationName, message: strMsg, preferredStyle: .alert )
        alert.addAction(UIAlertAction(title: "Goto Settings", style: .default) { alert in
            self.dismiss(animated: true, completion: nil)
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        })
        alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: cancel))
        present(alert, animated: true, completion: nil)
    }
    
    func alertGotoSetting(msg: String)
    {
        let strMsg = Util.localizedString(value: msg)
        let alert = UIAlertController(title: Util.applicationName, message: strMsg, preferredStyle: .alert )
        alert.addAction(UIAlertAction(title: "Goto Settings", style: .default) { alert in
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        })
        alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func showAlert(msg: String) -> Void {
        
        let strMsg = Util.localizedString(value: msg)
        let alertController = UIAlertController(title: Util.applicationName, message: strMsg, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: Util.localizedString(value: "OK_BTN_ON_ALERT") , style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showAlertWithYesNo(_ controller:UIViewController, msg:String, action:((UIAlertAction?) -> Void)?, cancel:((UIAlertAction?) -> Void)?)
    {
        let alertController = UIAlertController(title: Util.applicationName, message: Util.localizedString(value: msg), preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "YES", style: .default, handler: action)
        let noAction = UIAlertAction(title: "NO", style: .cancel, handler: cancel)
        
        alertController.addAction(noAction)
        alertController.addAction(yesAction)
        
        controller.present(alertController, animated: true, completion: nil)
    }
    
    func showAlertWithOk(_ controller:UIViewController, msg:String, action:((UIAlertAction?) -> Void)?)
    {
        let alertController = UIAlertController(title: Util.applicationName, message: Util.localizedString(value: msg), preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: action)
        
        alertController.addAction(okAction)
        
        controller.present(alertController, animated: true, completion: nil)
    }
    
    
}

extension String {
    
    func capitalizeFirst() -> String {
        let firstIndex = self.index(startIndex, offsetBy: 1)
        return self.substring(to: firstIndex).capitalized + self.substring(from: firstIndex).lowercased()
    }
    
    func replace(target: String, withString: String) -> String
    {
        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }
    
    var length: Int {
        return self.characters.count
    }
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstraintedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return ceil(boundingBox.width)
    }
}

extension UITextView {
    
    func addDoneButton() {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                            target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done,
                                            target: self, action: #selector(UIView.endEditing(_:)))
        keyboardToolbar.items = [flexBarButton, doneBarButton]
        self.inputAccessoryView = keyboardToolbar
    }
    
}

extension UIImageView{
    
//    func imageWithInsets(insetDimen: CGFloat) -> UIImage {
//        return imageWithInsets(insetDimen: UIEdgeInsets(top: insetDimen, left: insetDimen, bottom: insetDimen, right: insetDimen))
//    }
    
    func addImagePadding(x: CGFloat, y: CGFloat) -> UIImage? {
        
        let width: CGFloat = self.layer.frame.size.width + x
        let height: CGFloat = self.layer.frame.size.width + y
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, 0)
        let origin: CGPoint = CGPoint(x: (width - self.layer.frame.size.width) / 2, y: (height - self.layer.frame.size.height) / 2)
        self.draw(CGRect(origin: origin, size: CGSize(width: width, height: height)))      
        let imageWithPadding = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return imageWithPadding
    }
    
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { () -> Void in
                self.image = image
            }
            }.resume()
    }
    
    func setImageFromURl(stringImageUrl url: String){
        
        let fileManager = FileManager.default
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
        let documentsPath = documentsUrl.path
        
        var arrData = url.components(separatedBy: "Documents/")
        print("0 : \(arrData[0])")
        print("1 : \(arrData[1])")
        
        let fileURL = "file://\(documentsPath!)/\(arrData[1])"
        
        if let url = NSURL(string: fileURL) {
            if let data = NSData(contentsOf: url as URL) {
                self.image = UIImage(data: data as Data)
            }
        }
    }
}


class SearchBarContainerView: UIView {
    
    let searchBar: UISearchBar
    
    init(customSearchBar: UISearchBar) {
        searchBar = customSearchBar
        super.init(frame: CGRect.zero)
        
        searchBar.placeholder = "Search"
        searchBar.barTintColor = UIColor.white
        searchBar.searchBarStyle = .minimal
        searchBar.returnKeyType = .search
        searchBar.showsCancelButton = true
        addSubview(searchBar)
    }
    override convenience init(frame: CGRect) {
        self.init(customSearchBar: UISearchBar())
        self.frame = frame
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        searchBar.frame = bounds
    }
}
