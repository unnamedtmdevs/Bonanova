import SwiftUI

struct ProgressRingView: View {
    let progress: Double
    let colorName: String
    let size: CGFloat
    let lineWidth: CGFloat

    init(progress: Double, colorName: String = "Action_Primary", size: CGFloat = 56, lineWidth: CGFloat = 6) {
        self.progress = progress
        self.colorName = colorName
        self.size = size
        self.lineWidth = lineWidth
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Theme.namedColor(colorName).opacity(0.15), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: CGFloat(min(progress, 1.0)))
                .stroke(
                    Theme.namedColor(colorName),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)

            Text("\(Int(progress * 100))%")
                .font(.system(size: size * 0.22, weight: .bold))
                .foregroundColor(Theme.namedColor(colorName))
        }
        .frame(width: size, height: size)
    }
}

struct SmallProgressBar: View {
    let progress: Double
    let colorName: String

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Theme.namedColor(colorName).opacity(0.15))

                RoundedRectangle(cornerRadius: 4)
                    .fill(Theme.namedColor(colorName))
                    .frame(width: geo.size.width * CGFloat(min(progress, 1.0)))
                    .animation(.easeInOut(duration: 0.4), value: progress)
            }
        }
        .frame(height: 6)
    }
}
