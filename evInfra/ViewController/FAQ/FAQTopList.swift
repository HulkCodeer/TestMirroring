//
//  FAQTopList.swift
//  evInfra
//
//  Created by SooJin Choi on 2021/09/06.
//  Copyright © 2021 soft-berry. All rights reserved.
//

import UIKit
import Material
import Foundation
public class FAQTopList {
    var mFAQTopArr:[FAQTop] = [FAQTop]()
    
    func getFAQTopArr() -> [FAQTop] {
        setFAQTopData()
        sortArr()
        return self.mFAQTopArr
    }
    
    func setFAQTopData() {
        // 카드 신청
        let content1Arr:[FAQContent] = [FAQContent]() // Content Setting
        let faq1Content:FAQContent = FAQContent()
        setContentData(faqContent: faq1Content, contentArr: content1Arr,
                       content: "EV Infra 카드 신청을 하기위해서\n", imgName: nil)
        let faq1Content2:FAQContent = FAQContent()
        setContentData(faqContent: faq1Content2, contentArr: content1Arr,
                       content: "첫째. 회원가입 후 로그인합니다. (로그인은 카카오계정 연동)\n", imgName: nil)
        let faq1Content3:FAQContent = FAQContent()
        setContentData(faqContent: faq1Content3, contentArr: content1Arr,
                       content: "둘째. 좌측 상단 메뉴 → 마이페이지 → PAY 카테고리에서 충전 카드 등록 메뉴를 통해 먼저 결제 카드를 등록합니다.\n", imgName: "q2_01_menu");     // R.drawable.q2_01_menu
        let faq1Content3Comment:FAQContent = FAQContent()
        setContentData(faqContent: faq1Content3Comment, contentArr: content1Arr,
                       content: "\n카드 등록을 위해서는 본인인증이 필요합니다.\n", imgName: nil);
        let faq1Content4:FAQContent = FAQContent()
        setContentData(faqContent: faq1Content4, contentArr: content1Arr,
                       content: "셋째. 결제 카드가 등록이 완료되었다면 다음으로 충전카드 등록이 진행됩니다.", imgName: nil);
        let faq1Content5:FAQContent = FAQContent()
        setContentData(faqContent: faq1Content5, contentArr: content1Arr,
                       content: "\n충전 카드가 정상적으로 신청이 되었는지는 마이페이지→ PAY→ 충전카드등록  에서 카드 번호 발급되었는지 확인 가능합니다.\n\n아래와 같이 나온다면 정상적으로 등록이 완료된 상태입니다.\n", imgName: "q2_02_complete");      //R.drawable.q2_02_complete

        let faqTopTest1:FAQTop = FAQTop() // Title setting
        setData(faqTop: faqTopTest1, title: "EV Infra 카드 신청을 어떻게 하나요?", faqContentArr: content1Arr, priority: 1);

        // 카드 사용처
        let content2Arr:[FAQContent] = [FAQContent]()
        let faq2Content:FAQContent = FAQContent()
        setContentData(faqContent: faq2Content,  contentArr: content2Arr,
                       content: "EV Infra 카드가 사용 가능 한 곳은 공용급속충전기 중 한국전력, 에스트래픽  GS칼텍스 가능합니다.\n", imgName: nil);
        let faq2Content1:FAQContent = FAQContent()
        setContentData(faqContent: faq2Content1, contentArr: content2Arr,
                       content: "결제수단은 하기내용 참조\n", imgName: nil);
        let faq2Content2:FAQContent = FAQContent()
        setContentData(faqContent: faq2Content2, contentArr: content2Arr,
                       content: "1. 한국전력 : EV Infra카드 , 카드번호 , 베리 적립&사용(포인트)\n", imgName: nil);
        let faq2Content3:FAQContent = FAQContent()
        setContentData(faqContent: faq2Content3, contentArr: content2Arr,
                       content: "2. GS칼텍스 : QR결제(간편충전) , 베리 사용(포인트)\n", imgName: nil);
        let faq2Content4:FAQContent = FAQContent()
        setContentData(faqContent: faq2Content4, contentArr: content2Arr,
                       content: "3. 에스트래픽(SS차저) : EV Infra카드\n\n", imgName: nil);
        let faq2Content5:FAQContent = FAQContent()
        setContentData(faqContent: faq2Content5, contentArr: content2Arr,
                       content: "* 빠른 시일내로 타 충전기관(완속, 비공용, 환경부 등)연동 계획에 있습니다.", imgName: nil);

        let faqTopTest2:FAQTop? = FAQTop()
        setData(faqTop: faqTopTest2!, title: "EV Infra 카드를 어디에서 사용할 수 있나요?", faqContentArr: content2Arr, priority: 2);

        // 카드 사용법
        let content3Arr:[FAQContent]? = [FAQContent]()
        let faq3Content:FAQContent? = FAQContent()
        setContentData(faqContent: faq3Content!,  contentArr: content3Arr!,
                       content: "EV Infra 카드는 수령 즉시 바로 사용 가능하며, 타 충전 앱에 절대 등록하지 않고 사용합니다.", imgName: nil);
        let faq3Content1:FAQContent = FAQContent()
        setContentData(faqContent: faq3Content1, contentArr: content3Arr!,
                       content: "한국전력, 에스트래픽  GS칼텍스에서 충전 시 사용 가능합니다.\n\n", imgName: nil);
        let faq3Content2:FAQContent = FAQContent()
        setContentData(faqContent: faq3Content2, contentArr: content3Arr!,
                       content: "사용방법 : \n", imgName: nil);
        let faq3Content3:FAQContent = FAQContent()
        setContentData(faqContent: faq3Content3, contentArr: content3Arr!,
                       content: "첫째, 한전, GS칼텍스, 에스트레픽 소유의 충전소에 방문합니다.\n", imgName: nil);
        let faq3Content4:FAQContent = FAQContent()
        setContentData(faqContent: faq3Content4, contentArr: content3Arr!,
                       content: "둘째, 충전 타입을 선택 후 결제 방법을 회원카드로 선택합니다.\n", imgName: nil);
        let faq3Content5:FAQContent = FAQContent()
        setContentData(faqContent: faq3Content5, contentArr: content3Arr!,
                       content: "셋째, 충전완료 후 결제 시 카드 태깅을 하여 결제를 진행합니다.\n\n", imgName: nil);
        let faq3Content6:FAQContent = FAQContent()
        setContentData(faqContent: faq3Content6, contentArr: content3Arr!,
                       content: "결제 수단은 하기내용 참조\n", imgName: nil);
        let faq3Content7:FAQContent = FAQContent()
        setContentData(faqContent: faq3Content7, contentArr: content3Arr!,
                       content: "1. 한국전력 : EV Infra카드 , 카드번호 , 베리(포인트)\n\n2. GS칼텍스 : QR결제(간편충전), 베리(포인트)\n\n에스트래픽(SS차저) : EV Infra카드\n", imgName: nil);

        let faqTopTest3:FAQTop = FAQTop()
        setData(faqTop: faqTopTest3, title: "EV Infra 카드를 어떻게 사용 하나요?",faqContentArr: content3Arr! ,priority: 3)

        // 이력 조회
        let content4Arr:[FAQContent] = [FAQContent]()
        let faq4Content:FAQContent = FAQContent()
        setContentData(faqContent: faq4Content,  contentArr: content4Arr,
                       content: nil, imgName: "q7_01_menu") // R.drawable.q7_01_menu
        let faq4ContentComment:FAQContent = FAQContent()
        setContentData(faqContent: faq4ContentComment,  contentArr: content4Arr,
                       content: "\n위 두 메뉴 화면에서 모두 이력 조회가 안된다면, 아래 내용을 참고해주시기 바랍니다.\n", imgName: nil)
        let faq4Content0:FAQContent = FAQContent()
        setContentData(faqContent: faq4Content0,  contentArr: content4Arr,
                       content: "1. 베리는 한국전력에서만 충전 했을때 적립 가능하며, EV Infra카드를 타 충전기관 앱에 등록을 하였는지 확인이 필요합니다.\n", imgName: nil)
        let faq4Content1:FAQContent = FAQContent()
        setContentData(faqContent: faq4Content1, contentArr: content4Arr,
                       content: "2. EV Infra 카드는 수령 즉시 바로 사용 가능하며, 타 충전기관 앱에 등록 하지 않고 사용합니다.\n", imgName: nil)
        let faq4Content2:FAQContent = FAQContent()
        setContentData(faqContent: faq4Content2, contentArr: content4Arr,
                       content: "3. EV Infra 카드를 타 충전기관에 등록 하였을 경우 \n\n해결 방법 : ", imgName: nil)
        let faq4Content3:FAQContent = FAQContent()
        setContentData(faqContent: faq4Content3, contentArr: content4Arr,
                       content: "타충전기관에 등록되어 있는 EV Infra 카드를 타 충전기관 카드로 변경 하여 사용합니다.\n", imgName: nil)
        let faq4Content4:FAQContent = FAQContent()
        setContentData(faqContent: faq4Content4, contentArr: content4Arr,
                       content: "세 가지가 해당 안됨에도 불구하고 조회가 안되는 경우, 고객센터로 전화 주시기 바랍니다.\n", imgName: nil)

        let faqTopTest4:FAQTop = FAQTop()
        setData(faqTop: faqTopTest4, title: "EV Infra 카드로 충전을 했는데 베리적립, 충전이력 조회가 안돼요. 어떻게 하나요?", faqContentArr: content4Arr, priority: 6)

        // 회원탈퇴
        let content5Arr:[FAQContent] = [FAQContent]()
        let faq5Content:FAQContent = FAQContent()
        setContentData(faqContent: faq5Content,  contentArr: content5Arr,
                       content: "EV Infra 회원아이디는 카카오톡 계정과 연동되어 있기때문에 카카오톡 에서 진행 하셔야 합니다.\n", imgName: nil);
        let faq5Content1:FAQContent = FAQContent()
        setContentData(faqContent: faq5Content1, contentArr: content5Arr,
                       content: "아래 내용을 참고하셔서 진행 부탁드리며, 문의사항이 있으시면 고객센터로 전화주세요.\n", imgName: nil);
        let faq5Content2:FAQContent = FAQContent()
        setContentData(faqContent: faq5Content2, contentArr: content5Arr,
                       content: "1. 카카오톡 실행 후 환경설정 들어가기\n", imgName: nil);
        let faq5Content3:FAQContent = FAQContent()
        setContentData(faqContent: faq5Content3, contentArr: content5Arr,
                       content: "2. 개인/보안 → 개인정보관리 → 카카오계정 및 연결된 서비스\n", imgName: "q10_01_kakao1");  // R.drawable.q10_01_kakao1
        let faq5ContentImg2:FAQContent = FAQContent()
        setContentData(faqContent: faq5ContentImg2, contentArr: content5Arr,
                       content: "\n", imgName: "q10_02_kakao2");  // R.drawable.q10_02_kakao2
        let faq5ContentImg3:FAQContent = FAQContent()
        setContentData(faqContent: faq5ContentImg3, contentArr: content5Arr,
                       content: "\n", imgName: "q10_03_kakao3");  // R.drawable.q10_03_kakao3
        let faq5Content4:FAQContent = FAQContent()
        setContentData(faqContent: faq5Content4, contentArr: content5Arr,
                       content: "\n3. 연결된서비스 관리 → 외부서비스\n", imgName: nil);
        let faq5Content5:FAQContent = FAQContent()
        setContentData(faqContent: faq5Content5, contentArr: content5Arr,
                       content: "4. EV Infra 선택 후 모든정보삭제", imgName: nil);

        let faqTopTest5:FAQTop = FAQTop()
        setData(faqTop: faqTopTest5, title: "EV Infra 회원탈퇴는 어디서 하나요?",faqContentArr: content5Arr, priority: 9);

        // 베리 사용 방법
        let content6Arr:[FAQContent] = [FAQContent]()
        let faq6Content:FAQContent = FAQContent()
        setContentData(faqContent: faq6Content,  contentArr: content6Arr,
                       content: "베리 적립 가능 충전소 : 한국전력", imgName: nil);
        let faq6Content1:FAQContent = FAQContent()
        setContentData(faqContent: faq6Content1, contentArr: content6Arr,
                       content: "베리사용 가능 충전소 : 한국전력, GS칼텍스\n", imgName: nil);
        let faq6Content2:FAQContent = FAQContent()
        setContentData(faqContent: faq6Content2, contentArr: content6Arr,
                       content: "방법 : \n", imgName: nil);
        let faq6Content3:FAQContent = FAQContent()
        setContentData(faqContent: faq6Content3, contentArr: content6Arr,
                       content: "첫째. 충전 중에 사용해야 합니다.\n", imgName: nil);
        let faq6Content4:FAQContent = FAQContent()
        setContentData(faqContent: faq6Content4, contentArr: content6Arr,
                       content: "둘째. 앱 하단에 간편충전 메뉴\n(안드로이드는 충전 중으로 메뉴변경 됨)에서 하단의 '베리 사용하기' 버튼을 통해 남은 베리 확인 후 원하는 베리만큼 입력하여 결제합니다.\n", imgName: "q5_01_charging");  // R.drawable.q5_01_charging
        let faq61Content4:FAQContent = FAQContent()
        setContentData(faqContent: faq61Content4, contentArr: content6Arr,
                       content: "\n", imgName: "q5_02_berry");  // R.drawable.q5_02_berry
        let faq6Content5:FAQContent = FAQContent()
        setContentData(faqContent: faq6Content5, contentArr: content6Arr,
                       content: "   \n셋째. 충전 금액 중 사용한 베리 금액을 제외한 나머지 금액이 결제카드에서 승인됩니다.\n\n아래 충전이력 조회 및 포인트 조회에서 이력 확인이 가능합니다.\n", imgName: "q5_03_menu");  // R.drawable.q5_03_menu

        let faqTopTest6:FAQTop = FAQTop()
        setData(faqTop: faqTopTest6, title: "베리는 어떻게 사용 하나요?",faqContentArr: content6Arr, priority: 4);

        // 카드발송
        let content7Arr:[FAQContent] = [FAQContent]()
        let faq7Content:FAQContent = FAQContent()
        setContentData(faqContent: faq7Content,  contentArr: content7Arr,  content: "신청카드는 신청 하신 후 약 7일 정도 소요되며, 기재해주신 주소로 일반우편으로 보내드리오니 우편함을 꼭 확인 해 주세요.\n", imgName: nil);
        let faq7Content1:FAQContent = FAQContent()
        setContentData(faqContent: faq7Content1,  contentArr: content7Arr,  content: "우편 참고 이미지\n", imgName: "q6_01_card_bag");  // R.drawable.q6_01_card_bag

        let faqTopTest7:FAQTop = FAQTop()
        setData(faqTop: faqTopTest7, title: "신청한 카드는 언제오나요?", faqContentArr: content7Arr, priority: 5);

        // 지도
        let content8Arr:[FAQContent] = [FAQContent]()
        let faq8Content:FAQContent = FAQContent()
        setContentData(faqContent: faq8Content,  contentArr: content8Arr,
                       content: "1. 지도는 현재 내 위치를 기준으로 충전기관 위치정보를 보여줍니다. 이는 마커로 표시되며 마커 중앙의 이미지는 충전 기관을 나타내고 마커의 색상은 충전소의 상태를 나타냅니다.\n\n", imgName: nil);
        let faq8Content1:FAQContent = FAQContent()
        setContentData(faqContent: faq8Content1, contentArr: content8Arr,
                       content: "마커색상\n", imgName: nil);
        let faq8Content2:FAQContent = FAQContent()
        setContentData(faqContent: faq8Content2, contentArr: content8Arr,
                       content: "• 파란색 : 대기중 충전소를 의미합니다.\n\n• 초록색 : 사용중 충전소를 의미합니다. \n충전소의 모든 충전기가 충전중인 경우 사용중으로 상태가 변경됩니다.\n\n" +
                        "• 노란색 : 통신미연결/상태미확인 충전소를 의미합니다.\n\n• 빨간색 : 고장/운영중지 충전소를 의미합니다.\n", imgName: "q1_01_marker");  // R.drawable.q1_01_marker
        let faq8Content3:FAQContent = FAQContent()
        setContentData(faqContent: faq8Content3, contentArr: content8Arr,
                       content: "\n2. 내가 원하는 지역의 충전기관을 선택하고 싶을 경우\n\n첫째, 지도로 지역 이동 or 검색으로 지역 이동 합니다.\n\n둘째, 좌측 필터 버튼 클릭 후 맨 하단의 충전기관을 선택 후 필터 적용시 지도에 반영됩니다.\n", imgName: "q1_02_chargercompany");  // R.drawable.q1_02_chargercompany
        let faq8Content4:FAQContent = FAQContent()
        setContentData(faqContent: faq8Content4, contentArr: content8Arr,
                       content: "\n3. 지도에 표시 된 마커를 선택하면 충전소에 대한 요약정보가 노출됩니다.\n", imgName: "q1_03_station_summary");  // R.drawable.q1_03_station_summary
        let faq8Content5:FAQContent = FAQContent()
        setContentData(faqContent: faq8Content5, contentArr: content8Arr,
                       content: "\n충전 타입, 사용 가능 충전기 대수, 충전기 속도, 유무료, 실내외 등 충전소에 대한 간략한 안내를 보실 수 있습니다.\n\n4. 하단에 상세요약을 위로 올리거나, 요약을 클릭하면 더 자세한 충전소 상세 정보가 보여집니다.\n",  imgName: "q1_04_station_detail");  // R.drawable.q1_04_station_detail

        let faqTopTest8:FAQTop = FAQTop()
        setData(faqTop: faqTopTest8, title: "지도 보는 방법을 알려주세요.", faqContentArr: content8Arr, priority: 0);

        // 충전오류
        let content9Arr:[FAQContent] = [FAQContent]()
        let faq9Content:FAQContent = FAQContent()
        setContentData(faqContent: faq9Content,  contentArr: content9Arr,
                       content: "충전이 안되는 경우 먼저 확인 할 사항은 아래와 같습니다.\n", imgName: nil);
        let faq9Content1:FAQContent = FAQContent()
        setContentData(faqContent: faq9Content1, contentArr: content9Arr,
                       content: "1. EV Infra 카드 연동 가능한 충전기관인지 확인합니다.\n\n카드 : 공용급속 중전기 중  한국전력, 에스트래픽(SS차저)\n간편충전(QR결제) : 공용급속충전기 GS칼텍스\n", imgName: nil);
        let faq9Content2:FAQContent = FAQContent()
        setContentData(faqContent: faq9Content2, contentArr: content9Arr,
                       content: "2. 결제카드 사용이 일시 중지되었는지 확인합니다. \n\n좌측 상단 메뉴 > 마이페이지 > PAY > 결제정보 관리로 진입 해주세요.\n", imgName: "q8_01_");  // R.drawable.q8_01_
        let faq9Content3:FAQContent = FAQContent()
        setContentData(faqContent: faq9Content3, contentArr: content9Arr,
                       content: "\n전기차 충전 중 충전 카드에 연결된 결제카드가 문제(한도초과, 분실카드, 유효기간 오류등)로 승인이 안날 경우 시스템에서 자동 중지 됩니다.\n", imgName: "q8_02_card_error");  // R.drawable.q8_02_card_error
        let faq9Content4:FAQContent = FAQContent()
        setContentData(faqContent: faq9Content4, contentArr: content9Arr,
                       content: "\n이러한 경우 고객센터로 연락주시면 미승인 건을 처리 한 후 결제카드를 변경하실 수 있습니다.", imgName: nil);
        let faq9Content5:FAQContent = FAQContent()
        setContentData(faqContent: faq9Content5, contentArr: content9Arr,
                       content: "\n위 두가지 문제가 아닐 경우, 일시적인 시스템 통신 오류 가능성이 있으므로 고객센터로 연락주시기 바랍니다.", imgName: nil);

        let faqTopTest9:FAQTop = FAQTop()
        setData(faqTop: faqTopTest9, title: "충전이 안될경우, 어떻게 진행해야 하나요?", faqContentArr: content9Arr, priority: 7);

        // 결제카드 변경
        let content10Arr:[FAQContent] = [FAQContent]()
        let faq10Content:FAQContent = FAQContent()
        setContentData(faqContent: faq10Content,  contentArr: content10Arr,
                       content: "1. 결제카드 변경 방법\n", imgName: nil);
        let faq10Content1:FAQContent = FAQContent()
        setContentData(faqContent: faq10Content1, contentArr: content10Arr,
                       content: "앱 실행 → 마이페이지 → PAY → 결제정보관리에서 변경합니다.\n", imgName: "q9_01_menu");  // R.drawable.q9_01_menu
        let faq10Content2:FAQContent = FAQContent()
        setContentData(faqContent: faq10Content2, contentArr: content10Arr,
                       content: "\n2. 결제카드 변경이 안될 경우\n", imgName: nil);
        let faq10Content3:FAQContent = FAQContent()
        setContentData(faqContent: faq10Content3, contentArr: content10Arr,
                       content: "이전에 충전 했을 때  결제카드 문제로 정상적으로 승인이 나지 않을 경우 자동으로 시스템에서 일시정지 처리됩니다.\n", imgName: "q9_02_card_error");  // R.drawable.q9_02_card_error
        let faq10Content4:FAQContent = FAQContent()
        setContentData(faqContent: faq10Content4, contentArr: content10Arr,
                       content: "\n이러한 경우 고객센터로 연락주시면 미승인 건을 처리 한 후 결제카드 변경하실 수 있습니다.", imgName: nil);

        let faqTopTest10:FAQTop = FAQTop()
        setData(faqTop: faqTopTest10, title: "결제카드 변경 방법 및 변경이 안될 경우 어떻게 하나요?", faqContentArr: content10Arr,priority: 8);
    }
    
    func setContentData(faqContent:FAQContent?, contentArr:[FAQContent]?, content:String?, imgName:String?) {
        var faqContentArr:[FAQContent] = contentArr!
        faqContent!.setComment(comment: content ?? "")
        faqContent!.setImgName(imgName: imgName ?? "")
        faqContentArr.append(faqContent!)
    }
    
    func setData(faqTop:FAQTop, title:String, faqContentArr:[FAQContent], priority:Int) {
        faqTop.setFAQTitle(title: title)
        faqTop.setFAQContentArr(contentArr: faqContentArr)
        faqTop.setFAQPriority(priority: priority)
        mFAQTopArr.append(faqTop)
    }
    
    func sortArr() {
        if mFAQTopArr.count > 0 {
            mFAQTopArr = mFAQTopArr.sorted(by: {
                $0.getFAQPriority() < $1.getFAQPriority()
            })
        }
    }
}
