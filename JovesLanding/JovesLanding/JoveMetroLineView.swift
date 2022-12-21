//
//  JoveMetroLineView.swift
//  JovesLanding
//
//  Created by David Giovannini on 12/5/22.
//

import SwiftUI
import TrainsByJove

struct JoveMetroLineView: View {
	@ObservedObject var rail: JoveMetroLine
    @State private var presentEditName = false
    @State private var editingName = ""

    init(rail: JoveMetroLine) {
		self.rail = rail
	}

	var body: some View {
		ZStack {
			Image("Metal")
				.resizable()
				.ignoresSafeArea()
			ViewThatFits(in: .horizontal) {
				HStack(alignment: .center, spacing: 24.0) {
					JoveMetroLineGauageView(rail: rail)
					JoveMetroLineControlsView(rail: rail)
					Spacer()
				}
				VStack(alignment: .center, spacing: 24.0) {
					JoveMetroLineGauageView(rail: rail)
					JoveMetroLineControlsView(rail: rail)
					Spacer()
				}
			}
			.padding(44)
		}
		.toolbarBackground(Color.green.opacity(1.0), for: .navigationBar)
		#if os(iOS) || os(watchOS)
		.navigationBarTitleDisplayMode(.inline)
		#endif
		.navigationBarTitle(rail.name)
		.toolbar {
			Button {
				presentEditName = true
			} label: {
				Image(systemName: "tag.fill")
					.resizable()
			}.frame(width: 44)
		.aspectRatio(contentMode: .fit)
			ConnectionButtonView(rail: rail)
		.frame(width: 44)
		.aspectRatio(contentMode: .fit)
		}
		.alert("Name", isPresented: $presentEditName,
			actions: {
				TextField(rail.name, text: $editingName)
				Button("OK", action: {
					if editingName.isEmpty == false {
						rail.change(name: editingName)
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

struct ConnectionButtonView: View {
	@ObservedObject var rail: JoveMetroLine

	var body: some View {
		Button {
			if rail.connectionState == .connected {
				rail.fullStop()
			}
			else {
				rail.connect()
			}
		} label: {
			if rail.connectionState == .connected {
				Image(systemName: "exclamationmark.octagon.fill")
					.resizable()
					.foregroundColor(Color("Motor/Stop"))
					.aspectRatio(contentMode: .fit)
			}
			else if rail.connectionState == .disconneted {
				Image(systemName: "powerplug.fill")
					.resizable()
					.aspectRatio(contentMode: .fit)
			}
			else if rail.connectionState == .connecting {
				Image(systemName: "rays")
					.resizable()
					.aspectRatio(contentMode: .fit)
			}
		}
	}
}

struct JoveMetroLineControlsView: View {
	@ObservedObject var rail: JoveMetroLine

	var body: some View {
		Grid(alignment: .leading, horizontalSpacing: 12) {
			GridRow() {
				Text("Speed").font(.headline)
				ScrubView(
					value: $rail.power,
					label: "Speed",
					range: -1.0 ... 1.0,
					thumbColor: Color("Controls/ScrubberThumb"),
					minTrackColor: Color("Motor/Reverse"),
					maxTrackColor: Color("Motor/Forward"))
						.frame(height: 44)
			}
			Divider()
			GridRow {
				Text("Idle").font(.headline)
				ScrubView(
					value: $rail.calibration,
					label: "Idle",
					thumbColor: Color("Controls/ScrubberThumb"),
					minTrackColor: Color("Motor/Idle"),
					maxTrackColor: Color("Motor/Go"))
						.frame(height: 44)
			}
			Divider()
			GridRow {
				Text("Lights").font(.headline)
				ScrubView(
					value: $rail.lights,
					label: "Lights",
					thumbColor: Color("Controls/ScrubberThumb"),
					minTrackColor: Color("Lights/Off"),
					maxTrackColor: Color("Lights/On"))
						.frame(height: 44)
			}
		}
	}
}
