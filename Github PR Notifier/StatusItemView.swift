import SwiftUI

struct StatusItemView: View {
    var count: Int
    
    var body: some View {
        ZStack {
            if count > 0 {
                Image(nsImage: NSImage(named: NSImage.Name("LogoIcon")) ?? NSImage())
                Text("\(count)")
                    .foregroundColor(.white)
                    .font(.system(size: 11))
                    .padding(3)
                    .background(Color.red)
                    .clipShape(Circle())
                    .offset(x: 3, y: 3)
            } else {
                Image(nsImage: NSImage(named: NSImage.Name("LogoIcon")) ?? NSImage())
            }
        }
    }
}
