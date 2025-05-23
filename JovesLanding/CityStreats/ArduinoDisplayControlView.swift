//
//  ArduinoDisplayControlView.swift
//  JovesLanding
//
//  Created by David Giovannini on 3/25/25.
//

import SwiftUI
import BLEByJove
import Infrastructure

struct ArduinoDisplayControlView: View {
	@ObservedObject var display: ArduinoDisplay.Power
	@State private var isScrolling = false

	var body: some View {
		VStack {
			HStack() {
				ShareButtonView() {
					display.control.export(name: $0);
				}
				Button("Fill") {
					display.control.fill(.on)
				}
				.frame(maxWidth: .infinity)
				Button("Clear") {
					display.control.fill(.off)
				}
				.frame(maxWidth: .infinity)
				Button("Invert") {
					display.control.fill(.toggle)
				}
				.frame(maxWidth: .infinity)
				Button("Flip X") {
					display.control.flip(true, false)
				}
				.frame(maxWidth: .infinity)
				Button("Flip Y") {
					display.control.flip(false, true)
				}
				.frame(maxWidth: .infinity)
				Toggle(isOn: $isScrolling) {
					Text("Scroll")
						.font(.headline)
				}
#if !os(tvOS)
				.toggleStyle(ButtonToggleStyle())
#endif
				.frame(maxWidth: .infinity)
			}
			ArduinoR4MatrixView(value: display.feedback, interactive: isScrolling ? .scroll : .draw) {
				display.control = $0
			}
		}
	}
}

#Preview {
	ArduinoDisplayControlView(display: ArduinoDisplay.Power(
			broadcaster: BTDevice(preview: "Sample"),
			characteristic: BTCharacteristicIdentity(),
			transfomer: .init()))
}

struct ShareButtonView: View {
	@State private var isAlertPresented = false
	@State private var enteredName = ""
	let generateContent: (String) -> String
	let fileExtension = ".h"

	var body: some View {
		Button(action: {
			isAlertPresented = true
		}) {
			Image(systemName: "square.and.arrow.up").font(.title)
		}
		.alert("Enter Name", isPresented: $isAlertPresented) {
			TextField("Name", text: $enteredName)
			Button("Cancel", role: .cancel) {
				enteredName = ""
			}
#if !os(tvOS)
			Button("Share") {
				share()
			}
#endif
		} message: {
		}
	}

#if !os(tvOS)
	func share() {
		let santiziedName = sanitizeCString(enteredName)
		let content = generateContent(santiziedName)
		let fileName = fileExtension.isEmpty ? "" : santiziedName + fileExtension
		presentShareSheet(fileName: fileName, content: content)
	}
#endif

	func isValidCVariableName(_ name: String) -> Bool {
		let regex = "^[a-zA-Z_][a-zA-Z0-9_]*$"
		return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: name)
	}

	func sanitizeCString(_ input: String) -> String {
		if isValidCVariableName(input) {
			return input
		}

		var sanitizedName = ""
		if let first = input.first, String(first).range(of: "^[a-zA-Z_]$", options: .regularExpression) != nil {
			sanitizedName.append(first)
		}
		else {
			sanitizedName.append("_") // Default to '_' if invalid first character
		}
		let validSubsequentRegex = "[a-zA-Z0-9_]"
		for char in input.dropFirst() {
			if String(char).range(of: validSubsequentRegex, options: .regularExpression) != nil {
				sanitizedName.append(char)
			}
			else {
				sanitizedName.append("_")
			}
		}
		return sanitizedName
	}

#if !os(tvOS)
	func presentShareSheet(fileName: String, content: String) {
		var activityItems: [Any] = [content]
		do {
			if !fileName.isEmpty {
				let temporaryURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
				try content.write(to: temporaryURL, atomically: true, encoding: .utf8)
				activityItems.append(temporaryURL)
			}
		}
		catch {
		}
		let activityController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
		topViewController().present(activityController, animated: true, completion: nil)
	}
#endif

	func topViewController() -> UIViewController! {
		guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let rootController = windowScene.windows.first?.rootViewController else {
			return nil
		}
		var topController = rootController
		while let presentedController = topController.presentedViewController {
			topController = presentedController
		}
		return topController
	}
}
