//
//  HVStack.swift
//  JovesLanding
//
//  Created by David Giovannini on 4/3/25.
//

import SwiftUI

struct HVStack<Content: View>: View {
	let spacing: CGFloat?
	let match: Bool
	let content: Content

	init(spacing: CGFloat? = nil, match: Bool = true, @ViewBuilder content: () -> Content) {
		self.spacing = spacing
		self.match = match
		self.content = content()
	}
	
	var body: some View {
		GeometryReader { geom in
			if (geom.size.width > geom.size.height) == match {
				HStack(spacing: spacing) {
					content
				}
			}
			else {
				VStack(spacing: spacing) {
					content
				}
			}
		}
	}
}
