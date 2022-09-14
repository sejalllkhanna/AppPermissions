//
//  GrantPermissionModel.swift
//  GrantPermissionModel
//
//  Created by Sejal Khanna on 25/09/21.
//

import Foundation

struct GrantPermissionModel{
    let PermissionsArray: [GrantPermission]
}

struct GrantPermission: Codable {
    let TitleLabel: String
    let TitleSubLabel: String
    let SerialNumberLabel: String
    let Selected: Bool
}



