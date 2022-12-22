//
//  CircleText.swift
//  JovesLanding
//
//  Created by David Giovannini on 12/12/22.
//  Based on: https://github.com/viettrungphan/SwiftUIGeometryPractice

import Foundation
import SwiftUI

struct CircleText_Preview: PreviewProvider {
	static var previews: some View {
		CircleText(text: "The quick brown fox jumps over the lazy dog.", angle: Angle(degrees: 60))
			.font(.title2)
			.frame(width: 200, height: 300)
			.border(Color.green, width: 5)
	}
}

public struct CircleText: View {
	var text: String
	var angle: Angle = Angle()
	var alignment: Double = 0.5
	var tooFar: Angle = Angle(degrees: 360)

	@State private var textSizes: [Int:CGSize] = [:]

	public var body: some View {
		GeometryReader { geometry in
			let diameter = min(geometry.size.width, geometry.size.height)
			let radius =  diameter / 2.0
			let fullAngle = self.angle(at: self.textSizes.count, radius: radius)
			ZStack {
				Color.clear
				ForEach(Array(text.enumerated()), id: \.self.offset) { (offset, element) in
					VStack {
						Text(String(element))
							.background(Sizeable())
							.onPreferenceChange(WidthPreferenceKey.self, perform: { size in
								self.textSizes[offset] = size
							})
						//.border(Color.green, width: 1)
						Spacer()
					}
					.frame(width: diameter, height: diameter)
					.rotationEffect(self.angle(at: offset, radius: radius))
				}
			}
			.rotationEffect(-fullAngle * self.alignment  + self.angle)
			.opacity(fullAngle <= tooFar ? 1.0 : tooFar.degrees / fullAngle.degrees)
		}
	}

	private func angle(at index: Int, radius: Double) -> Angle {
		guard textSizes.isEmpty == false else { return Angle(); }
		var prefixLength = textSizes.filter{$0.key < index}.map{$0.value.width}.reduce(0,+)
		let height: Double
		if let mySize = textSizes[index] {
			prefixLength += mySize.width * 0.5
			height = mySize.height
		}
		else {
			height = textSizes.first!.value.height
		}
		return .radians(prefixLength/(radius - height))
	}
}

private struct WidthPreferenceKey: PreferenceKey {
	typealias Value = CGSize
	static var defaultValue = CGSize()
	static func reduce(value: inout Value, nextValue: () -> Value) {
		value = nextValue()
	}
}

private struct Sizeable: View {
	var body: some View {
		GeometryReader { geometry in
			Color.clear
				.preference(key: WidthPreferenceKey.self, value: geometry.size)
		}
	}
}
