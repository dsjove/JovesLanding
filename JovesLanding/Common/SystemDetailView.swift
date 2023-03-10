//
//  SystemDetailView.swift
//  JovesLanding
//
//  Created by David Giovannini on 12/10/22.
//

import SwiftUI
import BTByJove
import Infrastructure

struct SystemDetailView: View {
	let impl: Any?

	var body: some View {
		Group {
			if let impl {
				switch impl
				{
				case is TheJoveExpress:
					TheJoveExpressView(train: impl as! TheJoveExpress);
				case is JoveMetroLine:
					JoveMetroLineView(rail: impl as! JoveMetroLine)
				default:
					NotSupportedView(text: "Unsupported")
				}
			}
			else {
				NotSupportedView(text: "No system selected.")
			}
		}
	}
}

struct NotSupportedView: View {
	var text: String

	var body: some View {
		Text(text)
	}
}

struct SystemDetailView_Previews: PreviewProvider {
	static var previews: some View {
		SystemDetailView(impl: nil)
	}
}
