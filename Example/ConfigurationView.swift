//
//  ConfigurationView.swift
//  Zone5 Example
//
//  Created by Daniel Farrelly on 25/10/19.
//  Copyright © 2019 JellyStyle Media. All rights reserved.
//

import SwiftUI
import Zone5

struct ConfigurationView: View {

	let apiClient: Zone5

	let userDefaults: UserDefaults

	@Environment(\.presentationMode) var presentationMode

	@State var baseURL: String = "https://example.com"

	@State var clientID: String = ""

	@State var clientSecret: String = ""

	@State var username: String = ""

	@State var password: String = ""

	init(apiClient: Zone5 = .shared, userDefaults: UserDefaults = .standard) {
		self.apiClient = apiClient
		self.userDefaults = userDefaults
	}

	var body: some View {
		NavigationView {
			Form {
				Section(header: Text("Base URL")) {
					TextField("Base URL", text: $baseURL)
						.textContentType(.URL)
						.keyboardType(.URL)
				}
				Section(header: Text("Client Details")) {
					TextField("ID", text: $clientID)
					TextField("Secret", text: $clientSecret)
				}
				Section(header: Text("User Details")) {
					TextField("Username", text: $username)
						.textContentType(.emailAddress)
						.keyboardType(.emailAddress)
					SecureField("Password", text: $password)
						.textContentType(.password)
				}
				Section {
					Button(action: configureAndDismiss, label: {
						Text("Continue")
					})
				}
			}
			.onAppear {
				if let value = self.userDefaults.string(forKey: "Zone5_baseURL") ?? self.apiClient.baseURL?.absoluteString {
					self.baseURL = value
				}

				if let value = self.userDefaults.string(forKey: "Zone5_clientID") ?? self.apiClient.clientID {
					self.clientID = value
				}

				if let value = self.userDefaults.string(forKey: "Zone5_clientSecret") ?? self.apiClient.clientSecret {
					self.clientSecret = value
				}

				if let value = self.userDefaults.string(forKey: "Zone5_username") {
					self.username = value
				}

				if let value = self.userDefaults.string(forKey: "Zone5_password") {
					self.password = value
				}
			}
			.listStyle(GroupedListStyle())
			.navigationBarTitle("Configuration", displayMode: .inline)
		}
	}

	func configureAndDismiss() {
		userDefaults.set(baseURL, forKey: "Zone5_baseURL")
		userDefaults.set(clientID, forKey: "Zone5_clientID")
		userDefaults.set(clientSecret, forKey: "Zone5_clientSecret")
		userDefaults.set(username, forKey: "Zone5_username")
		userDefaults.set(password, forKey: "Zone5_password")

		if let baseURL = URL(string: baseURL), !clientID.isEmpty, !clientSecret.isEmpty {
			apiClient.configure(for: baseURL, clientID: clientID, clientSecret: clientSecret)
		}

		apiClient.oAuth.accessToken(username: username, password: password) { result in
			switch result {
			case .failure(let error):
				break

			case .success(_):
				self.presentationMode.wrappedValue.dismiss()
			}
		}
	}

}

struct ConfigurationView_Previews: PreviewProvider {
    static var previews: some View {
        ConfigurationView()
    }
}

