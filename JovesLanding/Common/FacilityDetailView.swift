//
//  FacilityDetailView.swift
//  JovesLanding
//
//  Created by David Giovannini on 12/10/22.
//

import SwiftUI
import BLEByJove
import Infrastructure

struct FacilityHeaderView<F: Facility>: View {
	@ObservedObject var facility: F

	var body: some View {
		HStack {
			facility.image
			Text(facility.name)
		}
	}
}

struct FacilityLineView: View {
	let facility: any Facility

	var body: some View {
		switch facility
		{
		case is JoveMetroLine:
			FacilityHeaderView(facility: facility as! JoveMetroLine)
		case is CityStreets:
			FacilityHeaderView(facility: facility as! CityStreets)
		case is UnsupportedFacility:
			FacilityHeaderView(facility: facility as! UnsupportedFacility)
		default:
			FacilityHeaderView(facility: UnsupportedFacility(name: "Unsupported"))
		}
	}
}

struct FacilityDetailView: View {
	let impl: Any?

	var body: some View {
		if let impl {
			switch impl
			{
			case is JoveMetroLine:
				JoveMetroLineView(facility: impl as! JoveMetroLine)
			case is CityStreets:
				CityStreetsView(facility: impl as! CityStreets)
			case is UnsupportedFacility:
				NotSupportedView(text: "Unsupported")
			default:
				NotSupportedView(text: "Unsupported")
			}
		}
		else {
			NotSupportedView(text: "No facility selected.")
		}
	}
}

struct NotSupportedView: View {
	var text: String

	var body: some View {
		Text(text)
	}
}

#Preview {
	FacilityDetailView(impl: nil)
}
