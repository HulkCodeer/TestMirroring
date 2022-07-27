//
//  MyPageViewController.swift
//  evInfra
//
//  Created by zenky1 on 2018. 4. 24..
//  Copyright © 2018년 soft-berry. All rights reserved.
//

import UIKit
import DropDown
import Material
import MaterialComponents.MaterialSnackbar
import SwiftyJSON
import UIImageCropper

internal final class MyPageViewController: UIViewController {

    @IBOutlet weak var nickNameField: TextField!
    @IBOutlet weak var locationSpinnerBtn: UIButton!
    @IBOutlet weak var carKindSpinnerBtn: UIButton!
    @IBOutlet weak var profileImgBtn: UIButton!
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var addrView: UIStackView!

    // 차량번호
    @IBOutlet weak var carNoField: UITextField!
    
    @IBOutlet weak var scrollViewBottom: NSLayoutConstraint!
    
    // 주소
    @IBOutlet weak var zipCodeField: UITextField!
    @IBOutlet weak var addrInfoField: UITextField!
    @IBOutlet weak var addrInfoDetailField: UITextField!
    @IBOutlet weak var searchZipCodeBtn: UIButton!
    @IBOutlet weak var updateBtn: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    private let dropDwonLocation = DropDown()
    private let dropDwonCarKind = DropDown()
    private let dropDwonProfileImg = DropDown()
    private let carModelList = CarModels.init()
    
    private var profileName = ""
    private var oldProfileName = ""
    private var viewHeight:CGFloat = 0
    
    let picker = UIImagePickerController()
    let cropper = UIImageCropper(cropRatio: 1/1)

    @IBAction func onClickLocation(_ sender: Any) {
        self.dropDwonLocation.show()
    }
    
    @IBAction func onClickCarKind(_ sender: Any) {
        self.dropDwonCarKind.show()
    }
    
    @IBAction func onClickProfileImg(_ sender: Any) {
        self.dropDwonProfileImg.show()
    }
    
    @IBAction func onClickRegBtn(_ sender: Any) {
        self.updateMemberInfo()
    }
    
    @IBAction func onClickSearchZipCode(_ sender: Any) {
        let mapStoryboard = UIStoryboard(name : "Map", bundle: nil)
        let saVC = mapStoryboard.instantiateViewController(withIdentifier: "SearchAddressViewController") as! SearchAddressViewController
        saVC.searchAddressDelegate = self
        navigationController?.push(viewController: saVC)
    }
    
    deinit {
        printLog(out: "\(type(of: self)): Deinited")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "개인정보관리 화면"
        nickNameField.delegate = self
        carNoField.delegate = self
        addrInfoDetailField.delegate = self
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))
        
        keyboardViewMove()
        prepareActionBar()
        prepareSpinnerView()
        prepareView()
        
        getMemberInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @objc func endEditing() {
        nickNameField.resignFirstResponder()
        carNoField.resignFirstResponder()
        addrInfoDetailField.resignFirstResponder()
    }
    
    func keyboardViewMove() {
        // 키보드 관리 (show/hide)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        self.view.frame.origin.y = -self.viewHeight
    }

    @objc func keyboardWillHide(_ notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.view.frame.origin.y = keyboardSize.height * 1/4
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func prepareView() {
        cropper.picker = picker
        cropper.delegate = self
        
        profileImgView.layer.borderWidth = 1
        profileImgView.layer.masksToBounds = false
        profileImgView.layer.borderColor = UIColor.white.cgColor
        profileImgView.layer.cornerRadius = profileImgView.frame.height/2
        profileImgView.clipsToBounds = true
        
        updateBtn.layer.cornerRadius = 4
        
        nickNameField.delegate = self as UITextFieldDelegate
        
        if zipCodeField.text != "" && addrInfoField.text != "" ||
            !zipCodeField.isEqual(nil) && !addrInfoField.isEqual(nil) {
            self.addrInfoDetailField.isUserInteractionEnabled = true
        } else {
            self.addrInfoDetailField.isUserInteractionEnabled = false
        }
    }
    
    func prepareSpinnerView() {
        DropDown.startListeningToKeyboard()
        DropDown.appearance().textColor = UIColor.black
        DropDown.appearance().textFont = UIFont.systemFont(ofSize: 15)
        DropDown.appearance().backgroundColor = UIColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.85)
        DropDown.appearance().selectionBackgroundColor = UIColor.lightGray
        DropDown.appearance().cellHeight = 36
        
        // 지역
        dropDwonLocation.anchorView = self.locationSpinnerBtn
        dropDwonLocation.dataSource = ["선택", "서울", "부산", "대구", "인천", "광주", "대전", "울산", "세종", "경기", "강원", "충북", "충남", "전북","전남", "경북", "경남", "제주"]
        dropDwonLocation.width = locationSpinnerBtn.frame.width * 2 / 3
        dropDwonLocation.selectionAction = { [unowned self] (index:Int, item:String) in
            self.locationSpinnerBtn.setTitle(item, for: UIControlState.normal)
        }
        dropDwonLocation.selectRow(at: getRegionIndex(region: UserDefault().readString(key: UserDefault.Key.MB_REGION)))
        locationSpinnerBtn.setTitle(dropDwonLocation.selectedItem, for: UIControlState.normal)
        
        // 차종
        dropDwonCarKind.anchorView = self.carKindSpinnerBtn
        dropDwonCarKind.dataSource = ["선택"]
        dropDwonCarKind.width = carKindSpinnerBtn.frame.width * 2 / 3
        dropDwonCarKind.selectionAction = { [unowned self] (index:Int, item:String) in
            self.carKindSpinnerBtn.setTitle(item, for: UIControlState.normal)
        }
        
        dropDwonProfileImg.anchorView = profileImgBtn
        dropDwonProfileImg.width = 57;//profileImgBtn.frame.width
        dropDwonProfileImg.dataSource = ["카메라", "갤러리"]
        dropDwonProfileImg.selectionAction = { [unowned self] (index:Int, item:String) in
            if index == 0 {
                self.openCamera()
            } else {
                self.openPhotoLib()
            }
        }
    }
    
    func openCamera() {
        picker.sourceType = .camera
        self.present(picker, animated: false, completion: nil)
    }
    
    func openPhotoLib() {
        picker.sourceType = .photoLibrary
        self.present(picker, animated: false, completion: nil)
    }
}

extension MyPageViewController {
    func prepareActionBar() {
        let backButton = IconButton(image: Icon.cm.arrowBack)
        backButton.tintColor = UIColor(named: "content-primary")
        backButton.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
        
        let logoutButton = UIButton()
        logoutButton.setTitle("로그아웃", for: .normal)
        logoutButton.setTitleColor(UIColor(named: "content-primary")!, for: .normal)
        logoutButton.titleLabel?.font = .systemFont(ofSize: 16)
        logoutButton.addTarget(self, action: #selector(handlelogoutButton), for: .touchUpInside)
        
        navigationItem.hidesBackButton = true
        navigationItem.leftViews = [backButton]
        navigationItem.rightViews = [logoutButton]
        navigationItem.titleLabel.textColor = UIColor(named: "content-primary")
        navigationItem.titleLabel.text = "개인정보관리"
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @objc
    fileprivate func handleBackButton() {
        self.navigationController?.pop()
    }
    
    @objc
    fileprivate func handlelogoutButton() {
        var actions = Array<UIAlertAction>()
        let ok = UIAlertAction(title: "확인", style: .default, handler:{ (ACTION) -> Void in
            self.logout()
        })
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler:{ (ACTION) -> Void in
            self.dismiss(animated: false, completion: nil)
        })
        actions.append(ok)
        actions.append(cancel)
        UIAlertController.showAlert(title: "로그아웃 하시겠습니까?", message: "", actions: actions)
    }

    func logout() {
        self.indicator.startAnimating()
        LoginHelper.shared.logout(completion: { success in
            self.indicator.stopAnimating()
            if success {
                Snackbar().show(message: "로그아웃 되었습니다.")
                self.navigationController?.pop()
            } else {
                Snackbar().show(message: "다시 시도해 주세요.")
            }
        })
    }
}

extension MyPageViewController : UIImageCropperProtocol {
    func didCropImage(originalImage: UIImage?, croppedImage: UIImage?) {
        self.profileImgView.image = croppedImage?.resize(withWidth: 600.0)
        let memberId = MemberManager.shared.memberId
        let curTime = Int64(NSDate().timeIntervalSince1970 * 1000)
        self.profileName = memberId + "_" + "\(curTime).jpg"
        self.profileImgView.image?.saveImage(self.profileName)
    }
    
    func didCancel() {
        picker.dismiss(animated: true, completion: nil)
    }
}

/*
 * Server Access
 */
extension MyPageViewController {
    
    internal func getMemberInfo() {
        // 지역
        let mbRegion = UserDefault().readString(key: UserDefault.Key.MB_REGION)
        self.dropDwonLocation.selectRow(self.getRegionIndex(region: mbRegion))
        self.locationSpinnerBtn.setTitle(self.dropDwonLocation.selectedItem, for: UIControlState.normal)
        
        // profile image
        profileName = UserDefault().readString(key: UserDefault.Key.MB_PROFILE_NAME)
        oldProfileName = profileName
        if profileName.count > 14 {
            loadingProfileImage(fileName:profileName)
        }
        
        Server.getMemberinfo{ (isSuccess, value) in
            if isSuccess {
                self.responseGetMemberInfo(json: JSON(value))
            }
            self.indicator.stopAnimating()
        }
        
        // 차량
        Server.getEvList { (isSuccess, value) in
            if isSuccess {
                let json = JSON(value)
                
                // 차량 모델 리스트
                self.carModelList.setData(json: json)
                var carList = self.carModelList.getNameList()
                carList.insert("선택", at: 0)
                self.dropDwonCarKind.dataSource = carList
                
                // 회원이 저장해 놓은 차량이 있을 경우 해당 차량으로 선택
                let model = UserDefault().readInt(key: UserDefault.Key.MB_CAR_ID)
                var car_row = 0
                if let carRow = carList.firstIndex(of: (self.carModelList.getCarList().first(where: {$0.id == model})?.name ?? "선택")) {
                    car_row = carRow
                }
                
                self.dropDwonCarKind.selectRow(car_row)
                self.carKindSpinnerBtn.setTitle(self.dropDwonCarKind.selectedItem, for: UIControlState.normal)
            }
            self.indicator.stopAnimating()
        }
    }
    
    internal func updateMemberInfo() {
        if checkData() {
            updateProfileImage() // update user profile image
            
//            let addressDetail = addrInfoDetailField.text ?? ""
//            let carNo = carNoField.text ?? ""
//            let zipCode = zipCodeField.text ?? ""
//            let address = addrInfoField.text ?? ""
            let nickName = nickNameField.text ?? ""
            
            var carId = 0
            if let _carId = self.carModelList.getCarList().first(where: {$0.name.isEqual(dropDwonCarKind.selectedItem!)})?.id {
                carId = _carId
            }
            
            let region = dropDwonLocation.selectedItem!
            Server.updateMemberInfo(nickName: nickName, region: region, profile: profileName, carId: carId) { (isSuccess, value) in
                if isSuccess {
                    self.responseUpdateMemberInfo(json: JSON(value))
                }
            }
        }
    }
    
    func checkData() -> Bool {
        // nickname 검사
        if let nickName = nickNameField.text {
            if nickName.count == 0 {
                Snackbar().show(message: "별명을 작성해 주세요.")
                return false
            } else if nickName.count > 12 {
                Snackbar().show(message: "별명은 최대 12자까지 입력가능합니다")
                return false
            }
        }
        
        // 차량번호 유효성 검사
//        do {
//            carNoField.text = try carNoField.validatedText(validationType: .carnumber)
//        } catch (let error) {
//            Snackbar().show(message: (error as! ValidationError).message)
//            return false
//        }
        
        // 주소가 있는데 상세 주소가 없는 경우
//        if let addressDetail = addrInfoDetailField.text {
//            if (addressDetail.isEmpty) {
//                Snackbar().show(message: "상세주소를 입력해 주세요.")
//                return false
//            }
//        }
        return true
    }
    
    func responseUpdateMemberInfo(json: JSON) {
        switch json["code"].intValue {
        case 1000:
            Snackbar().show(message: "업데이트가 완료되었습니다.")
            
            let defaults = UserDefault()
            defaults.saveString(key: UserDefault.Key.MB_PROFILE_NAME, value: profileName)
            if let carIndex = dropDwonCarKind.indexForSelectedRow {
                if carIndex > 0 {
                    defaults.saveInt(key: UserDefault.Key.MB_CAR_TYPE, value: json["car_type"].intValue)
                }
                defaults.saveInt(key: UserDefault.Key.MB_CAR_ID, value: carIndex)
            }
            if dropDwonLocation.indexForSelectedRow != 0 {
                defaults.saveString(key: UserDefault.Key.MB_REGION, value: dropDwonLocation.selectedItem!)
            }
            
            NotificationCenter.default.post(name: Notification.Name("updateMemberInfo"), object: nil)
            break
            
        default: // COMMON ERROR 9000
            Snackbar().show(message: "업데이트를 실패했습니다.\n잠시 후 다시 시도해 주세요.")
            break
        }
    }
    
    func responseGetMemberInfo(json: JSON) {
        switch json["code"].intValue {
        case 1000:
            let zipcodeData = json["mb_zip_code"].stringValue
            if !zipcodeData.isEmpty && !zipcodeData.elementsEqual("") {
                self.zipCodeField.text = zipcodeData
            }
            let addressData = json["mb_addr"].stringValue
            if  !addressData.isEmpty && !addressData.elementsEqual("") {
                self.addrInfoField.text = addressData
            }
            let addressDetailData = json["mb_addr_detail"].stringValue
            if !addressDetailData.isEmpty && !addressDetailData.elementsEqual("") {
                self.addrInfoDetailField.text = addressDetailData
            }
            let carNoData = json["mb_car_no"].stringValue
            if !carNoData.isEmpty && !carNoData.elementsEqual("") {
                self.carNoField.text = carNoData
            }
            let nickNameData = json["mb_nickname"].stringValue
            if !nickNameData.isEmpty && !nickNameData.elementsEqual("") {
                self.nickNameField.text = nickNameData
            }
            
        default:
            Snackbar().show(message: "서비스 연결상태가 좋지 않습니다.\n잠시 후 다시 시도해 주세요.")
            break
        }
    }
    
    func getRegionIndex(region: String) -> Int {
        var index = 0
        if region.count > 0 {
            for item in self.dropDwonLocation.dataSource {
                if region == item {
                    break
                }
                index += 1
            }
        }
        return index
    }
    
    func loadingProfileImage(fileName:String) {
        self.profileImgView.sd_setImage(with: URL(string:"\(Const.urlProfileImage)\(profileName)"), placeholderImage: UIImage(named: "ic_person_base150"))
    }
    
    func updateProfileImage() {
        if self.oldProfileName != self.profileName {
            if self.profileName.count > 14 {
                let data: Data = UIImageJPEGRepresentation(self.profileImgView.image!, 1.0)!
                Server.uploadImage(data: data, filename: self.profileName, kind: Const.CONTENTS_THUMBNAIL, targetId: "\(MemberManager.shared.mbId)", completion: { (isSuccess, value) in
                    let json = JSON(value)
                    if(!isSuccess) {
                        print("upload image Error : \(json)")
                    }
                })
//                S3Util().removeProfileImage(name: self.oldProfileName) // exception 발생
            }
        }
    }
    
}

extension MyPageViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else {
            return false
        }
        let newLength = text.count + string.count - range.length
        if newLength > 12 {
            Snackbar().show(message: "닉네임은 최대 12자까지 입력가능합니다")
            return false
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField.tag {
        case 0: // "별명"
            self.viewHeight =
                profileImgView.frame.origin.y
        default:
            self.viewHeight = locationSpinnerBtn.frame.origin.y
        }
    }
}

extension MyPageViewController: SearchAddressViewDelegate {
    func recieveAddressInfo(zonecode: String, fullRoadAddr: String) {
        if String(describing: type(of: self)).elementsEqual("MyPageViewController") {
            self.zipCodeField.text = zonecode
            self.addrInfoField.text = fullRoadAddr
            
            self.checkAddrData()
        }
    }
    
    func checkAddrData() {
        let zipCode = zipCodeField.text ?? ""
        let address = addrInfoField.text ?? ""
        if zipCode.isEmpty && address.isEmpty {
            self.addrInfoDetailField.isUserInteractionEnabled = false
        } else {
            self.addrInfoDetailField.isUserInteractionEnabled = true
        }
    }
}
