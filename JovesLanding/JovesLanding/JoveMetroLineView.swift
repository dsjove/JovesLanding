//
//  JoveMetroLineView.swift
//  JovesLanding
//
//  Created by David Giovannini on 12/5/22.
//

import SwiftUI
import Infrastructure
import BLEByJove

struct JoveMetroLineView: View {
	@ObservedObject var facility: JoveMetroLine

	@State private var presentEditName = false
	@State private var editingName = ""

	var body: some View {
		ZStack {
			Image("Metal")
				.resizable()
				.ignoresSafeArea()
			HVStack(spacing: 8) {
				FacilityConnectionView(facility) { facility in
					MotorizedFacilityGauageView(facility: facility)
				}
				JoveMetroLineControlsView(facility: facility)
			}.padding(8)
		}
		.navigationBarTitle(facility.name)
		.toolbar {
			Button {
					presentEditName = true
			} label: {
				Image(systemName: "tag.fill")
					.resizable()
			}
				.frame(width: 44)
				.aspectRatio(1, contentMode: .fit)
		}
		.alert("Name", isPresented: $presentEditName,
			actions: {
				TextField(facility.name, text: $editingName)
				Button("OK", action: {
					if editingName.isEmpty == false {
						facility.change(name: editingName)
					}
					editingName = ""
				})
				Button("Cancel", role: .cancel, action: {
					editingName = ""
				})
			},
			message: {
				Text("Enter new name.")
			})
	}
}

#Preview {
	JoveMetroLineView(facility: JoveMetroLine())
}
