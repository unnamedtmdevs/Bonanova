import SwiftUI

struct StatCardView: View {
    let title: String
    let value: String
    let icon: String
    let colorName: String

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacingSM) {
            HStack {
                Image(systemName: icon)
                    .font(.callout)
                    .foregroundColor(Theme.namedColor(colorName))
                Spacer()
            }

            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)
                .minimumScaleFactor(0.7)
                .lineLimit(1)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(Theme.spacingMD)
        .background(
            RoundedRectangle(cornerRadius: Theme.cornerMD)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
        )
    }
}
