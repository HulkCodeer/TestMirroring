//
//  StationInfoDB.swift
//  evInfra
//
//  Created by 소프트베리 on 2022/10/15.
//  Copyright © 2022 soft-berry. All rights reserved.
//

import RealmSwift
import SwiftyJSON

internal final class StationInfoDB: Object {
    // 1. 위도
    //@SerializedName("x")
    @Persisted var mLatitude : Double?

    // 2. 경도
    //@SerializedName("y")
    @Persisted var mLongitude : Double?

    // 3. 충전소 id
    //@SerializedName("id")
    @Persisted(primaryKey: true) var mChargerId : String?

    // 4. 충전소 이름
    //@SerializedName("snm")
    @Persisted var mSnm : String?

    // 5. 충전소 주소
    //@SerializedName("adr")
    @Persisted var mAddress : String?

    // 6. 충전소 상세 주소
    //@SerializedName("dtl")
    @Persisted var mAddressDetail : String?

    // 7. 휴무일(Y,N)
    //@SerializedName("hol")
    @Persisted var mHoliday : String?

    // 8. 장소특성(01:이마트 02:관공서 03:공영주차장 04:마을회관 05:고속도로 06:테마파크(공원) 07:광장)
    //@SerializedName("sk")
    @Persisted var mSkind : String?

    // 9. 0.환경공단 1.한전 2.BMW 3.chargeEV 4.현대자동차 5.기아자동차 6.LG서비스센터 7.한국GM 8.르노삼성 9. 이케아
    //@SerializedName("op_id")
    @Persisted var mCompanyId : String?

    // 10. 주차가능
    //@SerializedName("park")
    @Persisted var mPark : Int?

    // 11. Y : 유료, N : 무료
    //@SerializedName("pay")
    @Persisted var mPay : String?

    // 12. 시험 운영
    //@SerializedName("plt")
    @Persisted var mIsPilot : Bool?

    // 13. 지역코드
    //@SerializedName("ar")
    @Persisted var mArea : Int?

    // 14. 고속 도로 방향
    //@SerializedName("drt")
    @Persisted var mDirection : Int?

    // 15. 운영 기관
    //@SerializedName("op")
    @Persisted var mOperator : String?

    // 16. 운영 기관 전화 번호
    //@SerializedName("tel")
    @Persisted var mTel : String?

    // 17. 이용 시간
    //@SerializedName("ut")
    @Persisted var mUtime : String?

    // 18. 메모
    //@SerializedName("mm")
    @Persisted var mMemo : String?

    // 19. 충전소 이름 초성
    @Persisted var mSnmSearchWord : String?

    // 20. 충전소 주소 초성
    @Persisted var mAddressSearchWord : String?

    // 21. 충전소 상세 주소 초성
    @Persisted var mAddressDetailSearchWord : String?
    
    // 22. 실내/외
    @Persisted var mRoof : String?
    
    // 23. 삭제 여부
    @Persisted var mDel : Bool?
    
    // 24. 법정동 코드
    @Persisted var mZcode : String?
    
    convenience init(_ json: JSON) {
        self.init()
        
        self.mLatitude = json["x"].doubleValue
        self.mLongitude = json["y"].doubleValue
        self.mChargerId = json["id"].stringValue
        self.mSnm = json["snm"].stringValue
        self.mAddress = json["adr"].stringValue
        self.mAddressDetail = json["dtl"].stringValue
        self.mHoliday = json["hol"].stringValue
        self.mSkind = json["sk"].stringValue
        self.mCompanyId = json["op_id"].stringValue
        self.mPark = json["park"].intValue
        self.mPay = json["pay"].stringValue
        self.mIsPilot = json["plt"].boolValue
        self.mArea = json["ar"].intValue
        self.mDirection = json["drt"].intValue
        self.mOperator = json["op"].stringValue
        self.mTel = json["tel"].stringValue
        self.mUtime =  json["ut"].stringValue
        self.mMemo = json["mm"].stringValue
        self.mSnmSearchWord = json["mSnmSearchWord"].stringValue
        self.mAddressSearchWord = json["mAddressSearchWord"].stringValue
        self.mAddressDetailSearchWord = json["mAddressDetailSearchWord"].stringValue
        self.mRoof = json["r"].stringValue
        self.mDel = json["d"].boolValue
        self.mZcode = json["zc"].stringValue
        
        
        if let _mSnm = self.mSnm, !_mSnm.isEmpty {
            self.mSnmSearchWord = HangulUtils.getChosung(_mSnm.replaceAll(of: "\\s+", with: "").lowercased())
        }
        
        if let _mAddress = self.mAddress, !_mAddress.isEmpty {
            self.mAddressSearchWord = HangulUtils.getChosung(_mAddress.replaceAll(of: "\\s+", with: "").lowercased())
        }
        
        if let _mAddressDetail = self.mAddressDetail, !_mAddressDetail.isEmpty {            
            self.mAddressDetailSearchWord = HangulUtils.getChosung(_mAddressDetail.replaceAll(of: "\\s+", with: "").lowercased())
        }
    }
}
