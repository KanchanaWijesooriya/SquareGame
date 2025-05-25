import SwiftUI

struct ButtonStyleConfig: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title2)
            .padding(.horizontal, 40)
            .padding(.vertical, 15)
            .background(Color.white.opacity(configuration.isPressed ? 0.7 : 0.9))
            .foregroundColor(.blue)
            .cornerRadius(12)
            .shadow(radius: 5)
    }
}

func colorfulBackground() -> LinearGradient {
    LinearGradient(
        gradient: Gradient(colors: [.pink, .purple, .orange, .yellow, .cyan, .green]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

