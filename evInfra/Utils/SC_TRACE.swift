//
//  SC_TRACE.swift
//  evInfra
//
//  Created by 박현진 on 2022/05/13.
//  Copyright © 2022 soft-berry. All rights reserved.
//

/// log를 콘솔에 보여준다.
/// - debug시만 발생
///
/// - Parameters:
///   - filename: function이 발생한 file 명
///   - funcname: 발생한 function 명
///   - line: 발생 라인 수
public func printLog(_ filename: String = #file, at funcname: String = #function, on line: Int = #line) {
    #if DEBUG
        let dateFormatter: DateFormatter = {
            $0.locale = Locale.current // 지역 설정
            $0.dateFormat = "yyyy-MM-dd hh:mm:ss.SSSS" // 시간 형식 설정
            return $0
        }(DateFormatter())
        let nowTime = Date()
        let nowTimeStr = dateFormatter.string(from: nowTime)
        print("< \(nowTimeStr): \(funcname) [Line \(line)]\n\(filename)\n")
    #endif
}

/// log로 output 값을 콘솔에 보여준다.
/// - debug시만 발생
///
/// - Parameters:
///   - filename: function이 발생한 file 명
///   - funcname: 발생한 function 명
///   - line: 발생 라인 수
///   - output: 추가로 보여줄 string값
public func printLog(_ filename: String = #file, at funcname: String = #function, on line: Int = #line, out output: Any...) {
    #if DEBUG
        let dateFormatter: DateFormatter = {
            $0.locale = Locale.current // 지역 설정
            $0.dateFormat = "yyyy-MM-dd hh:mm:ss.SSSS" // 시간 형식 설정
            return $0
        }(DateFormatter())
        let nowTime = Date()
        let nowTimeStr = dateFormatter.string(from: nowTime)
        if output.count == 1 {
            let printOutput = output.first ?? ""
            print("< \(nowTimeStr): /* \(printOutput) */ \(funcname) [Line \(line)]\n\(filename)\n")
        } else {
            print("< \(nowTimeStr): /*")
            for ch in output {
                print(ch)
            }
            print("*/ \(funcname) [Line \(line)]\n\(filename)\n")
        }
    #endif
}
