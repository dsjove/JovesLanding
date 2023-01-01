//
//  JoveMetroLine+SwiftUI.swift
//  
//
//  Created by David Giovannini on 12/26/22.
//


import SwiftUI

extension JoveMetroLine: InfrastructureImpl {
	public var category: InfrastructureCategory { .transportation }
	public var image: Image { Image(systemName: "train.side.front.car") }
}
