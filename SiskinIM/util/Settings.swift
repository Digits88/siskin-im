//
// Settings.swift
//
// Siskin IM
// Copyright (C) 2016 "Tigase, Inc." <office@tigase.com>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. Look for COPYING file in the top folder.
// If not, see https://www.gnu.org/licenses/.
//

import Foundation

public enum Settings: String {
    case DeleteChatHistoryOnChatClose
    case EnableMessageCarbons
    case StatusType
    case StatusMessage
    case RosterType
    case RosterItemsOrder
    case RosterAvailableOnly
    case RosterDisplayHiddenGroup
    case AutoSubscribeOnAcceptedSubscriptionRequest
    case DeviceToken
    case NotificationsFromUnknown
    case RecentsMessageLinesNo
    case RecentsOrder
    case SharingViaHttpUpload
    case MaxImagePreviewSize
    case MessageDeliveryReceiptsEnabled
    case SimplifiedLinkToFileIfPreviewIsAvailable
    case SendMessageOnReturn
    case CopyMessagesWithTimestamps
    case XmppPipelining
    case AppearanceTheme
    case EnableBookmarksSync
    
    public static let SETTINGS_CHANGED = Notification.Name("settingsChanged");
    
    fileprivate static var store: UserDefaults {
        return UserDefaults.standard;
    }
    
    fileprivate static var sharedDefaults = UserDefaults(suiteName: "group.TigaseMessenger.Share");
    
    public static func initialize() {
        let defaults: [String: AnyObject] = [
            "DeleteChatHistoryOnChatClose" : false as AnyObject,
            "EnableMessageCarbons" : true as AnyObject,
            "RosterType" : "flat" as AnyObject,
            "RosterItemsOrder" : RosterSortingOrder.alphabetical.rawValue as AnyObject,
            "RosterAvailableOnly" : false as AnyObject,
            "RosterDisplayHiddenGroup" : false as AnyObject,
            "AutoSubscribeOnAcceptedSubscriptionRequest" : false as AnyObject,
            "NotificationsFromUnknown" : true as AnyObject,
            "RecentsMessageLinesNo" : 2 as AnyObject,
            "RecentsOrder" : "byTime" as AnyObject,
            "SendMessageOnReturn" : true as AnyObject,
            "AppearanceTheme": "classic" as AnyObject
        ];
        store.register(defaults: defaults);
        store.dictionaryRepresentation().forEach { (k, v) in
            if let key = Settings(rawValue: k) {
                if isShared(key: key) {
                    sharedDefaults!.set(v, forKey: key.rawValue);
                }
            }
        }
    }
    
    public func setValue(_ value: String?) {
        let currValue = getString();
        guard currValue != value else {
            return;
        }
        Settings.store.set(value, forKey: self.rawValue);
        Settings.valueChanged(forKey: self, oldValue: currValue, newValue: value);
    }
    
    public func setValue(_ value: Bool) {
        let currValue = getBool();
        guard currValue != value else {
            return;
        }
        Settings.store.set(value, forKey: self.rawValue);
        Settings.valueChanged(forKey: self, oldValue: currValue, newValue: value);
    }
    
    public func setValue(_ value: Int) {
        Settings.store.set(value, forKey: self.rawValue);
    }
    
    public func getBool() -> Bool {
        return Settings.store.bool(forKey: self.rawValue);
    }
    
    public func getString() -> String? {
        return Settings.store.string(forKey: self.rawValue);
    }
    
    public func getInt() -> Int {
        return Settings.store.integer(forKey: self.rawValue);
    }
    
    fileprivate static func valueChanged(forKey key: Settings, oldValue: Any?, newValue: Any?) {
        var data: [AnyHashable:Any] = ["key": key.rawValue];
        if oldValue != nil {
            data["oldValue"] = oldValue!;
        }
        if newValue != nil {
            data["newValue"] = newValue!;
        }
        if isShared(key: key) {
            sharedDefaults!.set(newValue, forKey: key.rawValue);
        }
        NotificationCenter.default.post(name: Settings.SETTINGS_CHANGED, object: nil, userInfo: data);
    }
    
    fileprivate static func isShared(key: Settings) -> Bool {
        return key == Settings.RosterDisplayHiddenGroup || key == Settings.SharingViaHttpUpload;
    }
}

public enum AccountSettings {
    case MessageSyncAutomatic(String)
    case MessageSyncPeriod(String)
    case MessageSyncTime(String)
    case PushNotificationsForAway(String)
    case LastError(String)
    case KnownServerFeatures(String)
    
    public func getAccount() -> String {
        switch self {
        case .MessageSyncAutomatic(let account):
            return account;
        case .MessageSyncPeriod(let account):
            return account;
        case .MessageSyncTime(let account):
            return account;
        case .PushNotificationsForAway(let account):
            return account;
        case .LastError(let account):
            return account;
        case .KnownServerFeatures(let account):
            return account;
        }
    }
    
    public func getName() -> String {
        switch self {
        case .MessageSyncAutomatic( _):
            return "MessageSyncAutomatic";
        case .MessageSyncPeriod( _):
            return "MessageSyncPeriod";
        case .MessageSyncTime( _):
            return "MessageSyncTime";
        case .PushNotificationsForAway( _):
            return "PushNotificationsForAway";
        case .LastError(_):
            return "LastError";
        case .KnownServerFeatures( _):
            return "KnownServerFeatures";
        }
    }
    
    fileprivate func getKey() -> String {
        return "Account-" + getAccount() + "-" + getName();
    }
    
    public func getString() -> String? {
        return Settings.store.string(forKey: getKey());
    }
    
    public func getBool() -> Bool {
        return Settings.store.bool(forKey: getKey());
    }
    
    public func getDouble() -> Double {
        return Settings.store.double(forKey: getKey());
    }
    
    public func getDate() -> Date? {
        let value = Settings.store.double(forKey: getKey());
        if value == 0 {
            return nil;
        } else {
            return Date(timeIntervalSince1970: value);
        }
    }
    
    public func getStrings() -> [String]? {
        let obj = Settings.store.object(forKey: getKey());
        return obj as? [String];
    }
    
    public func set(bool value: Bool) {
        Settings.store.set(value, forKey: getKey());
    }
    
    public func set(double value: Double) {
        Settings.store.set(value, forKey: getKey());
    }
    
    public func set(date value: Date?, condition: ComparisonResult? = nil) {
        if value == nil {
            Settings.store.set(nil, forKey: getKey());
        } else {
            let key = getKey();
            let oldValue = Settings.store.double(forKey: key)
            let newValue = value!.timeIntervalSince1970;
            if condition != nil {
                switch condition! {
                case .orderedAscending:
                    if oldValue >= newValue {
                        return;
                    }
                case .orderedDescending:
                    if oldValue <= newValue {
                        return;
                    }
                default:
                    break;
                }
            }
            Settings.store.set(newValue, forKey: key);
        }
    }
    
    public func set(string value: String?) {
        if value != nil {
            Settings.store.setValue(value, forKey: getKey());
        } else {
            Settings.store.removeObject(forKey: getKey());
        }
    }
    
    public func set(strings value: [String]?) {
        if value != nil {
            Settings.store.set(value, forKey: getKey());
        } else {
            Settings.store.removeObject(forKey: getKey());
        }
    }
    
    public static func removeSettings(for account: String) {
        let toRemove = Settings.store.dictionaryRepresentation().keys.filter { (key) -> Bool in
            return key.hasPrefix("Account-" + account + "-");
        };
        toRemove.forEach { (key) in
            Settings.store.removeObject(forKey: key);
        }
    }
    
    public static func initialize() {
        let accounts = AccountManager.getAccounts();
        let toRemove = Settings.store.dictionaryRepresentation().keys.filter { (key) -> Bool in
            return key.hasPrefix("Account-") && accounts.firstIndex(where: { (account) -> Bool in
                return key.hasPrefix("Account-" + account + "-");
            }) == nil;
        };
        toRemove.forEach { (key) in
            Settings.store.removeObject(forKey: key);
        }
    }
    
}
