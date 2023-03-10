//
//  ConnectionIndicatorView.swift
//  JovesLanding
//
//  Created by David Giovannini on 12/16/22.
//

import SwiftUI
import Infrastructure

struct ConnectionIndicatorView: View {
	let connectionState: ConnectionState

    static func color(connectionState: ConnectionState) -> Color {
		switch connectionState {
		case .disconneted:
			return Color("Connection/Disconnected")
		case .connecting:
			return Color("Connection/Connecting")
		case.connected:
			return Color("Connection/Connected")
		}
    }

    var body: some View {
		ZStack {
			Image(systemName: iconName())
				.resizable()
				.aspectRatio(contentMode: .fit)
				.symbolRenderingMode(.palette)
				.foregroundStyle(Self.color(connectionState: connectionState))
		}
    }

    private func iconName() -> String {
		switch connectionState {
		case .disconneted:
			return "powerplug"
		case .connecting:
			return "rays"
		case .connected:
			return "powerplug"
		}
    }
}

struct ConnectionIndicatorView_Previews: PreviewProvider {
    static var previews: some View {
		VStack {
			ConnectionIndicatorView(connectionState: .connected)
			ConnectionIndicatorView(connectionState: .connecting)
			ConnectionIndicatorView(connectionState: .disconneted)
		}
    }
}
