//
//  VPNConnectViewModel.swift
//  VPN Connect
//
//  Created by Влад Шимченко on 8.05.26.
//

/*
 ViewModel, который имитирует работу VPN-подключения.

 Это демонстрационная (mock) реализация без реального VPN и сетевого взаимодействия.
 Используется для показа UI-состояний, анимаций и логики переключения состояний.

 Состояния подключения:
 disconnected — VPN выключен (начальное состояние)
 connecting — процесс подключения (симуляция задержки)
 connected — VPN “подключён”

 Логика работы:
 При нажатии Connect
 → состояние меняется: disconnected → connecting → connected
 → через 2 секунды автоматически устанавливается состояние connected

 При нажатии Disconnect
 → состояние сразу сбрасывается: connected → disconnected
*/

import SwiftUI
import Combine


final class VPNConnectViewModel: ObservableObject {

    @Published var status: ConnectionStatus = .disconnected
    @Published var selectedServer: String = "Germany"

    let servers = [
        "Germany",
        "USA",
        "Japan",
        "Netherlands"
    ]

    var isConnected: Bool {
        status == .connected
    }

    var buttonTitle: String {
        isConnected ? "Disconnect" : "Connect"
    }

    func toggleConnection() {
        switch status {
        case .disconnected:
            connect()
        case .connected:
            disconnect()
        case .connecting:
            break
        }
    }

    private func connect() {
        withAnimation(.easeInOut(duration: 0.3)) {
            status = .connecting
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                self.status = .connected
            }
        }
    }

    private func disconnect() {
        withAnimation(.easeInOut(duration: 0.25)) {
            status = .disconnected
        }
    }
}
