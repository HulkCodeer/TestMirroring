//
//  DateUtils.swift
//  evInfra
//
//  Created by Michael Lee on 2020/10/15.
//  Copyright © 2020 soft-berry. All rights reserved.
//

import Foundation

class DateUtils {
    public static func currentTimeMillis() -> Int64 {
        let currentDate = Date()
        let since1970 = currentDate.timeIntervalSince1970
        return Int64(since1970 * 1000)
    }
    
    public static func getFormattedCurrentDate(format: String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        let dateStr = dateFormatter.string(from: Date())
        return dateStr
    }
    
    public static func getTimesAgoString(date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
    
        let date = dateFormatter.date(from: date)!
        
        let duration = DateUtils.currentTimeMillis() - Int64((date.timeIntervalSince1970) * 1000)
        let seconds = duration / 1000
        let minutes = seconds / 60
        let hours = minutes / 60
        
        if seconds < 60 {
            return "\(seconds)초 전"
        } else if minutes < 60 {
            return "\(minutes)분 전"
        } else if hours < 24 {
            return "\(hours)시간 전"
        } else {
            return date.toYearMonthDay()
        }
    }
    
    public static func getDateStringForDetail(date : String) -> String{
    /*
            Calendar today = Calendar.getInstance();
            Calendar inday = Calendar.getInstance();

            today.setTime(new Date(System.currentTimeMillis()));
            inday.setTime(date);

            if (today.get(Calendar.YEAR) > inday.get(Calendar.YEAR)){
                // years
                return today.get(Calendar.YEAR) - inday.get(Calendar.YEAR) + "년전";
            }else if (today.get(Calendar.MONTH) > inday.get(Calendar.MONTH)) {
                // month
                return today.get(Calendar.MONTH) - inday.get(Calendar.MONTH) + "달전";
            }else{
                int tday = today.get(Calendar.DATE);
                int tweek = tday / 7;
                int iday = inday.get(Calendar.DATE);
                int iweek = iday / 7;
                if (tweek > iweek){
                    return (tweek - iweek) + "주전";
                }else if (tday > iday){
                    return (tday - iday) + "일전";
                }else{
                    long duration = System.currentTimeMillis() - inday.getTime().getTime();
                    int seconds = (int) (duration / 1000);
                    int minutes = seconds / 60;
                    int hours = minutes / 60;
                    seconds = seconds % 60;
                    minutes = minutes % 60;

                    if(hours > 0){
                        return (hours) + "시간전";
                    }else if (minutes > 0){
                        return (minutes) + "분전";
                    }else if (seconds > 0){
                        return (seconds) + "초전";
                    }
                }
            }
    */
    
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "KST")
                
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                
        let iDate = dateFormatter.date(from: date)!
                
        dateFormatter.dateFormat = "yyyy. MM. dd."
        
        let duration = DateUtils.currentTimeMillis() - Int64((iDate.timeIntervalSince1970) * 1000)
        var seconds = duration / 1000
        var minutes = seconds / 60
        let hours = minutes / 60
        let day = hours / 24
        let week = day / 7
        let month = day / 30
        let year = day / 365
        
        seconds = seconds % 60
        minutes = minutes % 60

        if (year > 0) {
            // years
            return  "\(year)년전"
        } else if (month > 0) {
            // month
            return  "\(month)달전"
        } else if (week > 0) {
            // week
            return  "\(week)주전"
        } else if (day > 0) {
            // day
            return  "\(day)일전"
        } else if (hours > 0) {
            return  "\(hours)시간전"
        } else if (minutes > 0) {
            return  "\(minutes)분전"
        } else {
            return  "\(seconds)초전"
        }
    }
}
