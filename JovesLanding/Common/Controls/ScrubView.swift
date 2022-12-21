//
//  ScrubView.swift
//  JovesLanding
//
//  Created by David Giovannini on 12/15/22.
//

import SwiftUI

private extension ClosedRange {
    func clamp(_ value : Bound) -> Bound {
        return self.lowerBound > value ? self.lowerBound
            : self.upperBound < value ? self.upperBound
            : value
    }
}

struct ScrubView: View {
	@Binding var value: Double
	var label: String = ""
	var range: ClosedRange<Double> = 0.0 ... 1.0

	var thumbColor: Color = .gray
	var minTrackColor: Color = .red
	var maxTrackColor: Color = .green
	//var textColor: Color = .black

    //@FocusState private var focused: Bool
    //@Environment (\.isFocused) var isFocused: Bool

    @State var dragging: Bool = false

	private var valueSide: Bool {
		value >= range.lowerBound + (range.upperBound - range.lowerBound)*0.5
	}

	var body: some View {
		GeometryReader { gr in
			let width = gr.size.width
			let height = gr.size.height
			let inset = width * 0.015
			let railHeight = height * 0.25
			let thumbWidth = height

			let minPos = inset + thumbWidth * 0.5
			let maxPos = width - minPos
			let posLength = maxPos - minPos

			let valueLength = range.upperBound - range.lowerBound
			let safeValue = range.clamp(self.value)
			let normValue = (safeValue - range.lowerBound) / valueLength
			let sliderPos = minPos + (normValue * posLength)

			ZStack {
				Group {
					HStack {
						RoundedRectangle(cornerRadius: railHeight * 0.5)
							.frame(width: sliderPos, height: height * 0.25)
							.foregroundColor(minTrackColor)
							.border(thumbColor, width: 0.5)
						Spacer()
					}
					HStack {
						Spacer()
						RoundedRectangle(cornerRadius: railHeight * 0.5)
							.frame(width: width - sliderPos, height: height * 0.25)
							.foregroundColor(maxTrackColor)
							.border(thumbColor, width: 0.5)
					}
				}
//				#if os(tvOS)
//				#else
#if os(iOS) || os(watchOS)
				.onTapGesture { location in
					let normPos = (location.x - minPos) / posLength
					let value = range.lowerBound + (normPos * valueLength)
					self.value = range.clamp(value)
				}
#endif
//				#endif
/*
				Text(label)
					.foregroundColor(textColor)
					.offset(x: {
						var po = sliderPos * 0.5
						if valueSide {
							po -= width * 0.5
						}
						return po
					}())
					.opacity(dragging ? 0.3 : 1.0)
					.frame(height: thumbWidth * 0.5)
*/
				HStack {
					RoundedRectangle(cornerRadius: thumbWidth * 0.5)
						.frame(width: thumbWidth)
						.foregroundColor(thumbColor)
						.offset(x: sliderPos - thumbWidth * 0.5)
						//.shadow(radius: focused ? 0.0 : thumbWidth * 0.5)
//					#if os(tvOS)
//					#else
#if os(iOS) || os(watchOS)
					.gesture(DragGesture(minimumDistance: 0)
						.onChanged { drag in
							dragging = true
							let normPos = (drag.location.x - minPos) / posLength
							let value = range.lowerBound + (normPos * valueLength)
							self.value = range.clamp(value)
						}.onEnded({ _ in
							dragging = false
						}))
#endif
//					#endif
					Spacer()
				}
			}
		}//.focused($focused)
	}
}


struct ScrubView_Previews: PreviewProvider {
	static var previews: some View {
		ScrubView(value: .constant(0.333))
	}
}
