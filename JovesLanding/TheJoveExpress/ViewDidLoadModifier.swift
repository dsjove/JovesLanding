//
//  ViewDidLoadModifier.swift
//  JovesLanding
//
//  Created by David Giovannini on 12/10/22.
//

import SwiftUI

struct ViewDidLoadModifier: ViewModifier {
	@State private var didLoad = false
	private let action: (() -> Void)?

	init(perform action: (() -> Void)? = nil) {
		self.action = action
	}

	func body(content: Content) -> some View {
		content.onAppear {
			if didLoad == false {
				didLoad = true
				action?()
			}
		}
	}
}

extension View {
	func onLoad(perform action: (() -> Void)? = nil) -> some View {
		modifier(ViewDidLoadModifier(perform: action))
	}
}
