//
//  CalendarConstants.swift
//  Outlook
//
//  Created by abhishek dutt on 03/09/17.
//  Copyright © 2017 abhishek dutt. All rights reserved.
//

import Foundation
import UIKit

enum OutlookCalendar {
    
    enum DateView {
        static let DaysInARow = 7
        static let RowsInFoucssedState = 5
        static let RowsInNormalState = 2
        
        //consider work load in focussed state
        enum CellState {
            case SelectedState(isDayOne: Bool)
            case CurrentDayState(isDayOne: Bool, state: ViewsState)
            case NormalState(isDayOne: Bool, isCurrentYear: Bool, state: ViewsState)
            
            func getCurrentCellBackgroundType(previousBackgroundType: Background) -> Background {
                switch self {
                //priority
                case .SelectedState(let isDayOne):
                    if isDayOne{
                        return previousBackgroundType.normalRevert()
                    }
                    return previousBackgroundType
                case .CurrentDayState(let isDayOne, _):
                    if isDayOne{
                        return previousBackgroundType.normalRevert()
                    }
                    return Background.Bluish
                case .NormalState(let isDayOne, _, _):
                    if isDayOne{
                        return previousBackgroundType.normalRevert()
                    }
                    return previousBackgroundType
                }
            }
            
            enum Background {
                case Light
                case White
                case Bluish
                
                func normalRevert() -> Background {
                    switch self {
                    case .Light:
                        return .White
                    case .White:
                        return .Light
                    default:
                        return .White
                    }
                }
            }
            
            enum WorkLoadWeight: Int {
                case None = 0
                case Light = 1
                case Medium = 2
                case Heavy = 3
            }
        }
    }
    
    enum EventView {
        
    }
    
    enum ViewsCategory {
        case DateView(state: ViewsState)
        case EventView
        
        func visibleRows() -> Int {
            switch self {
            case .DateView(let state):
                switch state {
                case .Focussed:
                    return OutlookCalendar.DateView.RowsInFoucssedState
                case .Normal:
                    return OutlookCalendar.DateView.RowsInNormalState
                }
            default:
                return 0
            }
        }
    }
    
    static func getDateViewVisibleHeight(forDateView dateView: ViewsCategory, andContainerViewFrameSize size: CGSize) -> CGFloat {
        let rows = dateView.visibleRows()
        let dateViewVisibleHeight = Float(rows) * Float(size.width / 7)
        return CGFloat(dateViewVisibleHeight)
        
    }
    
    enum ViewsState {
        case Focussed
        case Normal
    }
}

