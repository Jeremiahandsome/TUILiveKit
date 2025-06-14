//
//  LSRouteState.swift
//  TUILiveKit
//
//  Created by jeremiawang on 2024/11/20.
//

import Foundation
import LiveStreamCore
import RTCRoomEngine

struct LSRouterState {
    var routeStack: [LSRoute] = []
    var dismissEvent: (() -> Void)?
}

enum LSDismissType {
    case panel
    case alert
}

enum LSRouterAction {
    case routeTo(_ route: LSRoute)
    case present(_ route: LSRoute)
    case dismiss(_ type: LSDismissType = .panel, completion: (() -> Void)? = nil)
    case exit
}

enum LSRoute {
    case anchor
    case audience
    case roomInfo
    case recentViewer
    case liveLinkControl
    case connectionControl
    case linkInviteControl(_ index: Int)
    case linkType(_ data: [LinkMicTypeCellData])
    case linkSetting
    case featureSetting(_ settingModel: LSFeatureClickPanelModel)
    case listMenu(_ data: ActionPanelData)
    case audioEffect
    case beauty
    case giftView
    case prepareSetting
    case battleCountdown(_ countdownTime: TimeInterval)
    case alert(info: LSAlertInfo)
    case streamDashboard
    case userManagement(_ user: TUIUserInfo, type: UserManagePanelType)
}

extension LSRoute: Equatable {
    static func == (lhs: LSRoute, rhs: LSRoute) -> Bool {
        switch (lhs, rhs) {
            case (.anchor,.anchor),
                (.audience,.audience),
                (.roomInfo,.roomInfo),
                (.recentViewer,.recentViewer),
                (.liveLinkControl,.liveLinkControl),
                (.connectionControl,.connectionControl),
                (.linkType, .linkType),
                (.linkSetting, .linkSetting),
                (.audioEffect,.audioEffect),
                (.beauty, .beauty),
                (.giftView, .giftView),
                (.prepareSetting, .prepareSetting),
                (.alert, .alert),
                (.streamDashboard, .streamDashboard):
                return true
            case let (.featureSetting(l), .featureSetting(r)):
                return l == r
            case let (.listMenu(l), .listMenu(r)):
                return l == r
            case let (.linkInviteControl(l), .linkInviteControl(r)):
                return l == r
            case let (.battleCountdown(l), .battleCountdown(r)):
                return l == r
            case let (.userManagement(l1, l2), .userManagement(r1, r2)):
                return l1 == r1 && l2 == r2
            case (.anchor, _),
                (.audience, _),
                (.roomInfo, _),
                (.recentViewer, _),
                (.liveLinkControl, _),
                (.connectionControl, _),
                (.linkInviteControl, _),
                (.linkType, _),
                (.linkSetting, _),
                (.featureSetting, _),
                (.listMenu, _),
                (.audioEffect, _),
                (.beauty, _),
                (.giftView, _),
                (.prepareSetting, _),
                (.battleCountdown, _),
                (.alert, _),
                (.streamDashboard, _),
                (.userManagement, _):
                return false
            default:
                break
        }
    }
}

extension LSRoute: Hashable {
    func convertToString() -> String {
        switch self {
            case .anchor:
                return "anchor"
            case .audience:
                return "audience"
            case .roomInfo:
                return "roomInfo"
            case .recentViewer:
                return "recentViewer"
            case .liveLinkControl:
                return "liveLinkControl"
            case .connectionControl:
                return "connectionControl"
            case .linkInviteControl(let index):
                return "linkInviteControl \(index)"
            case .linkType:
                return "linkType"
            case .linkSetting:
                return "linkSetting"
            case .featureSetting(let settingModel):
                return "featureSetting" + settingModel.id.uuidString
            case .listMenu(let data):
                var result = "listMenu"
                data.items.forEach { item in
                    result += item.id.uuidString
                }
                return result
            case .audioEffect:
                return "audioEffect"
            case .beauty:
                return "beauty"
            case .giftView:
                return "giftView"
            case .prepareSetting:
                return "prepareSetting"
            case .battleCountdown(let countdownTime):
                return "battleCountdown \(countdownTime)"
            case .alert(let alertInfo):
                return "alert \(alertInfo.description)"
            case .streamDashboard:
                return "streamDashboard"
            case .userManagement(let user, let type):
                return "userManagement \(user.userId) type: \(type)"
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.convertToString())
    }
}
