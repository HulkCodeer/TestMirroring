//
//  PaymentStatus.swift
//  evInfra
//
//  Created by bulacode on 04/07/2019.
//  Copyright © 2019 soft-berry. All rights reserved.
//

import Foundation

public class PaymentStatus {
    public static let PAY_PAYMENT_SUCCESS = 8000 //결제성공
    public static let PAY_PAYMENT_FAIL = 8004    //VAN 실패 응답
    public static let PAY_PAYMENT_FAIL_LESS_AMOUNT = 8043 // 1000원 미만결제
    public static let PAY_PAYMENT_FAIL_CARD_LESS = 8044 //잔액부족
    public static let PAY_PAYMENT_FAIL_CARD_NO = 8045 //카드번호 오류
    public static let PAY_PAYMENT_FAIL_CARD_CERT = 8046 //인증불가 카드
    public static let PAY_PAYMENT_FAIL_CARD_COM = 8047 //카드사 인증 에러
    
    public static let PAY_REGISTER_SUCCESS = 8100 // 카드등록 성공
    public static let PAY_REGISTER_CANCEL_FROM_USER = 8140 // 유저에 의한 카드등록 취소
    public static let PAY_REGISTER_FAIL = 8144 // 카드등록 실패
    public static let PAY_REGISTER_FAIL_PG = 8145 // VAN사의 Register 기타 오류 9999
    
    public static let PAY_CARD_DELETE_SUCCESS = 8200 // 카드삭제 성공
    public static let PAY_CARD_DELETE_FAIL_NO_USER = 8203 // 카드삭제 실패 (등록한 사람이 DB에 없음)
    public static let PAY_CARD_DELETE_FAIL = 8204 // 카드삭제 실패
    
    public static let PAY_MEMBER_DELETE_SUCESS = 8320 // 결제정보 멤버 삭제
    public static let PAY_MEMBER_DELETE_FAIL_NO_USER = 8323 //결제정보 멤버 삭제 실패 (등록한 사람이 DB에 없음)
    public static let PAY_MEMBER_DELETE_FAIL_DB = 8324 //DB 삭제 에러
    public static let PAY_MEMBER_DELETE_FAIL = 8304 // 결제정보 멤버 삭제 실패
    
    public static let PAY_FINE_USER = 8800 // 유저체크
    public static let PAY_NO_CARD_USER = 8801 // 카드등록 아니된 멤버
    public static let PAY_NO_VERIFY_USER = 8802 // 인증 되지 않은 멤버 *헤커 의심
    public static let PAY_DELETE_FAIL_USER = 8803 // 비정상적인 삭제 멤버
    public static let PAY_DEBTOR_USER = 8804 // 돈안낸 유저
    public static let PAY_NO_USER = 8844 // 미등록 멤버
}
