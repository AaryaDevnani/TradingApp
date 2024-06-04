import SwiftUI
import Foundation

struct Toast: View {
    let message: String
    @Binding var isShowing: Bool
    
    var body: some View {
        VStack {
            Spacer()
            Text(message)
                .foregroundColor(.white)
                .padding(.horizontal, 50)
                .padding(.vertical, 20)
                .background(.gray)
                .cornerRadius(50)
                .opacity(isShowing ? 1 : 0)
                .animation(Animation.default, value: isShowing)
        }.onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                withAnimation {
                    self.isShowing = false
                }
            }
        }
    }
}
