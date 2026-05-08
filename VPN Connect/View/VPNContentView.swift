//
//  VPNContentView.swift
//  VPN Connect
//
//  Created by Влад Шимченко on 8.05.26.
//

import SwiftUI


// MARK: - View
struct VPNContentView: View {

    @StateObject private var viewModel = VPNConnectViewModel()

    @State private var pulse = false
    @State private var rotate = false

    var body: some View {

        VStack(spacing: 28) {

            headerSection

            vpnStatusSection

            Spacer()

            serverSection

            connectButton

            Spacer()

            footerSection
        }
        .padding(32)
        .background(VPNUI.Colors.backgroundGradient())
        .onAppear {
            pulse = true
            rotate = true
        }
    }
}

// MARK: - Sections
private extension VPNContentView {

    // MARK: - Header Section
    var headerSection: some View {
        VStack(spacing: 6) {
            Text(VPNUI.Text.title)
                .font(.largeTitle)
                .fontWeight(.bold)
            Text(viewModel.status.rawValue)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Status Section
    var vpnStatusSection: some View {
        ZStack {
            Circle()
                .fill(VPNUI.Colors.main(for: viewModel.status).opacity(0.25))
                .frame(
                    width: VPNUI.Layout.vpnCircleSize,
                    height: VPNUI.Layout.vpnCircleSize
                )
                .blur(radius: 25)
                .scaleEffect(pulse ? 1.05 : 0.92)
                .animation(
                    viewModel.status == .connecting
                    ? .easeInOut(duration: 1.3)
                        .repeatForever(autoreverses: true)
                    : .easeOut(duration: 0.3),
                    value: pulse
                )

            Circle()
                .stroke(
                    Color.white.opacity(0.08),
                    lineWidth: 10
                )
                .frame(
                    width: VPNUI.Layout.vpnRingSize,
                    height: VPNUI.Layout.vpnRingSize
                )

            Circle()
                .trim(
                    from: 0,
                    to: viewModel.status == .connecting ? 0.72 : 1
                )
                .stroke(
                    VPNUI.Colors.main(for: viewModel.status),
                    style: StrokeStyle(
                        lineWidth: 10,
                        lineCap: .round
                    )
                )
                .frame(
                    width: VPNUI.Layout.vpnRingSize,
                    height: VPNUI.Layout.vpnRingSize
                )
                .rotationEffect(.degrees(rotate ? 360 : 0))
                .animation(
                    viewModel.status == .connecting
                    ? .linear(duration: 1.1)
                        .repeatForever(autoreverses: false)
                    : .spring(response: 0.4),
                    value: rotate
                )

            VStack(spacing: 14) {
                Image(systemName: VPNUI.Icons.name(for: viewModel.status))
                    .font(.system(size: 42))
                    .foregroundStyle(VPNUI.Colors.main(for: viewModel.status))
                VStack(spacing: 4) {
                    Text(viewModel.status.rawValue)
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text(viewModel.selectedServer)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(height: 240)
    }

    // MARK: - Server Section
    var serverSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(VPNUI.Text.server)
                .font(.headline)
            Picker(
                VPNUI.Text.server,
                selection: $viewModel.selectedServer
            ) {
                ForEach(viewModel.servers, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(.menu)
            .frame(maxWidth: 300, alignment: .leading)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(
                    cornerRadius: 16
                )
                .fill(Color.white.opacity(0.06))
            )
        }
    }

    // MARK: - Connect Button
    var connectButton: some View {
        Button {
            viewModel.toggleConnection()
        } label: {
            HStack(spacing: 10) {
                if viewModel.status == .connecting {
                    ProgressView()
                        .controlSize(.small)
                        .tint(.white)
                }

                Text(viewModel.buttonTitle)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.white)
        .frame(maxWidth: 320)
        .background(VPNUI.Colors.buttonGradient(for: viewModel.status))
        .clipShape(
            RoundedRectangle(
                cornerRadius: VPNUI.Layout.buttonCornerRadius
            )
        )
        .shadow(
            color: VPNUI.Colors.main(for: viewModel.status).opacity(0.45),
            radius: 16
        )
        .scaleEffect(
            viewModel.status == .connecting
            ? 0.98
            : 1
        )
        .animation(
            .spring(response: 0.35),
            value: viewModel.status
        )
        .disabled(viewModel.status == .connecting)
    }

    // MARK: - Footer Section
    var footerSection: some View {
        HStack {
            Button(VPNUI.Text.settings) {
                print(VPNUI.Text.settings)
            }

            Spacer()

            Button(VPNUI.Text.help) {
                print(VPNUI.Text.help)
            }
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }
}


// MARK: - Constants
private extension VPNContentView {
    private enum VPNUI {

        // MARK: - Text
        enum Text {
            static let title = "VPN"
            static let server = "Server"
            static let settings = "Settings"
            static let help = "Help"

            static let connect = "Connect"
            static let disconnect = "Disconnect"

            static let disconnected = "Disconnected"
            static let connecting = "Connecting"
            static let connected = "Connected"
        }

        // MARK: - Layout
        enum Layout {
            static let cardCornerRadius: CGFloat = 24
            static let buttonCornerRadius: CGFloat = 18

            static let vpnCircleSize: CGFloat = 170
            static let vpnRingSize: CGFloat = 150
        }

        // MARK: - Icons
        enum Icons {
            static func name(for status: ConnectionStatus) -> String {
                switch status {
                case .disconnected:
                    return "lock.slash"
                case .connecting:
                    return "arrow.triangle.2.circlepath"
                case .connected:
                    return "checkmark.shield.fill"
                }
            }
        }

        // MARK: - Colors
        enum Colors {
            static func main(for status: ConnectionStatus) -> Color {
                switch status {
                case .disconnected:
                    return .red
                case .connecting:
                    return .yellow
                case .connected:
                    return .green
                }
            }

            static func backgroundGradient() -> LinearGradient {
                LinearGradient(
                    colors: [
                        Color(red: 0.08, green: 0.09, blue: 0.10),
                        Color(red: 0.10, green: 0.15, blue: 0.20)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }

            static func buttonGradient(for status: ConnectionStatus) -> LinearGradient {
                let colors: [Color]

                switch status {
                case .disconnected:
                    colors = [.blue, .cyan]
                case .connecting:
                    colors = [.orange, .yellow]
                case .connected:
                    colors = [.green, .mint]
                }

                return LinearGradient(
                    colors: colors,
                    startPoint: .leading,
                    endPoint: .trailing
                )
            }
        }
    }
}


