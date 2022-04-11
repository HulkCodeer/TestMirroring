//
//  StationInfoDto.swift
//  evInfra
//
//  Created by Michael Lee on 2020/06/09.
//  Copyright © 2020 soft-berry. All rights reserved.
//

import Foundation
import GRDB
import SwiftyJSON

class StationInfoDto : Record{
    required init(row: Row) {
        mLatitude = row["mLatitude"]
        mLongitude = row["mLongitude"]
        mChargerId = row["mChargerId"]
        mSnm = row["mSnm"]
        mAddress = row["mAddress"]
        mAddressDetail = row["mAddressDetail"]
        mHoliday = row["mHoliday"]
        mSkind = row["mSkind"]
        mCompanyId = row["mCompanyId"]
        mPark = row["mPark"]
        mPay = row["mPay"]
        mIsPilot = row["mIsPilot"]
        mArea = row["mArea"]
        mDirection = row["mDirection"]
        mOperator = row["mOperator"]
        mTel = row["mTel"]
        mUtime = row["mUtime"]
        mMemo = row["mMemo"]
        mSnmSearchWord = row["mSnmSearchWord"]
        mAddressSearchWord = row["mAddressSearchWord"]
        mAddressDetailSearchWord = row["mAddressDetailSearchWord"]
        mRoof = row["mRoof"]
        mDel = row["mDel"]
        mZcode = row["mZcode"]
        super.init(row: row)
    }
    
    override init() {
        super.init()
    }
    
    override class var databaseTableName: String {
        return "StationInfo"
    }
    
    override func encode(to container: inout PersistenceContainer) {
        container["mLatitude"] = mLatitude
        container["mLongitude"] = mLongitude
        container["mChargerId"] = mChargerId
        container["mSnm"] = mSnm
        
        container["mAddress"] = mAddress
        container["mAddressDetail"] = mAddressDetail
        container["mHoliday"] = mHoliday
        container["mSkind"] = mSkind
        container["mCompanyId"] = mCompanyId
        container["mPark"] = mPark
        container["mPay"] = mPay
        container["mIsPilot"] = mIsPilot
        container["mArea"] = mArea
        container["mDirection"] = mDirection
        container["mOperator"] = mOperator
        container["mTel"] = mTel
        container["mUtime"] = mUtime
        container["mMemo"] = mMemo
        container["mSnmSearchWord"] = mSnmSearchWord
        container["mAddressSearchWord"] = mAddressSearchWord
        container["mAddressDetailSearchWord"] = mAddressDetailSearchWord
        
        container["mRoof"] = mRoof
        container["mDel"] = mDel
        container["mZcode"] = mZcode
    }
    
    // 1. 위도
    //@SerializedName("x")
    public var mLatitude : Double?

    // 2. 경도
    //@SerializedName("y")
    public var mLongitude : Double?

    // 3. 충전소 id
    //@SerializedName("id")
    public var mChargerId : String?

    // 4. 충전소 이름
    //@SerializedName("snm")
    public var mSnm : String?

    // 5. 충전소 주소
    //@SerializedName("adr")
    public var mAddress : String?

    // 6. 충전소 상세 주소
    //@SerializedName("dtl")
    public var mAddressDetail : String?

    // 7. 휴무일(Y,N)
    //@SerializedName("hol")
    public var mHoliday : String?

    // 8. 장소특성(01:이마트 02:관공서 03:공영주차장 04:마을회관 05:고속도로 06:테마파크(공원) 07:광장)
    //@SerializedName("sk")
    public var mSkind : String?

    // 9. 0.환경공단 1.한전 2.BMW 3.chargeEV 4.현대자동차 5.기아자동차 6.LG서비스센터 7.한국GM 8.르노삼성 9. 이케아
    //@SerializedName("op_id")
    public var mCompanyId : String?

    // 10. 주차가능
    //@SerializedName("park")
    public var mPark : Int?

    // 11. Y : 유료, N : 무료
    //@SerializedName("pay")
    public var mPay : String?

    // 12. 시험 운영
    //@SerializedName("plt")
    public var mIsPilot : Bool?

    // 13. 지역코드
    //@SerializedName("ar")
    public var mArea : Int?

    // 14. 고속 도로 방향
    //@SerializedName("drt")
    public var mDirection : Int?

    // 15. 운영 기관
    //@SerializedName("op")
    public var mOperator : String?

    // 16. 운영 기관 전화 번호
    //@SerializedName("tel")
    public var mTel : String?

    // 17. 이용 시간
    //@SerializedName("ut")
    public var mUtime : String?

    // 18. 메모
    //@SerializedName("mm")
    public var mMemo : String?

    // 19. 충전소 이름 초성
    public var mSnmSearchWord : String?

    // 20. 충전소 주소 초성
    public var mAddressSearchWord : String?

    // 21. 충전소 상세 주소 초성
    public var mAddressDetailSearchWord : String?
    
    // 22. 실내/외
    public var mRoof : String?
    
    // 23. 삭제 여부
    public var mDel : Bool?
    
    // 24. 법정동 코드
    public var mZcode : String?
    
    public func setStationInfo(json : JSON){
        let latitude = json["x"]
        let longitude = json["y"]
        let chargerId = json["id"]
        let snm = json["snm"]
        let address = json["adr"]
        let addressDetail = json["dtl"]
        let holiday = json["hol"]
        let skind = json["sk"]
        let companyId = json["op_id"]
        let park = json["park"]
        
        let pay = json["pay"]
        let isPilot = json["plt"]
        let area = json["ar"]
        let direction = json["drt"]
        let op = json["op"]
        let tel = json["tel"]
        let utime = json["ut"]
        let memo = json["mm"]
        
        let roof = json["r"]
        let del = json["d"]
        let zcode = json["zc"]
        
        self.mLatitude = latitude.doubleValue
        self.mLongitude = longitude.doubleValue
        self.mChargerId = chargerId.stringValue
        self.mSnm = snm.stringValue
        self.mAddress = address.stringValue
        self.mAddressDetail = addressDetail.stringValue
        self.mHoliday = holiday.stringValue
        self.mSkind = skind.stringValue
        self.mCompanyId = companyId.stringValue
        
        self.mPark = park.intValue
        self.mPay = pay.stringValue
        self.mIsPilot = isPilot.boolValue
        self.mArea = area.intValue
        self.mDirection = direction.intValue
        self.mOperator = op.stringValue
        self.mTel = tel.stringValue
        self.mUtime = utime.stringValue
        self.mMemo = memo.stringValue
        
        self.mRoof = roof.stringValue
        self.mDel = del.boolValue
        self.mZcode = zcode.stringValue
    }
}
