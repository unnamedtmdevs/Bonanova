import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasOnboarded") private var hasOnboarded = false
    @StateObject private var vm = OnboardingViewModel()

    var body: some View {
        ZStack {
            Theme.bgPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                // Page indicators
                HStack(spacing: 6) {
                    ForEach(0..<vm.pages.count, id: \.self) { i in
                        Capsule()
                            .fill(i == vm.currentPage
                                  ? Theme.namedColor(vm.pages[i].colorName)
                                  : Color.secondary.opacity(0.3))
                            .frame(width: i == vm.currentPage ? 28 : 8, height: 8)
                            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: vm.currentPage)
                    }
                }
                .padding(.top, 60)
                .padding(.bottom, Theme.spacingXL)

                // Pages
                TabView(selection: $vm.currentPage) {
                    ForEach(0..<vm.pages.count, id: \.self) { i in
                        OnboardingPageView(page: vm.pages[i])
                            .tag(i)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(maxHeight: .infinity)

                // Actions
                VStack(spacing: Theme.spacingMD) {
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            if vm.isLastPage {
                                hasOnboarded = true
                            } else {
                                vm.nextPage()
                            }
                        }
                    }) {
                        Text(vm.isLastPage ? "Start Planning" : "Continue")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Theme.namedColor(vm.pages[vm.currentPage].colorName))
                            .cornerRadius(Theme.cornerLG)
                            .animation(.easeInOut(duration: 0.2), value: vm.currentPage)
                    }

                    if !vm.isLastPage {
                        Button(action: { hasOnboarded = true }) {
                            Text("Skip")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        Spacer().frame(height: 20)
                    }
                }
                .padding(.horizontal, Theme.spacingXL)
                .padding(.bottom, 40)
            }
        }
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: Theme.spacingXXL) {
            ZStack {
                Circle()
                    .fill(Theme.namedColor(page.colorName).opacity(0.12))
                    .frame(width: 180, height: 180)

                Circle()
                    .fill(Theme.namedColor(page.colorName).opacity(0.06))
                    .frame(width: 220, height: 220)

                Image(systemName: page.icon)
                    .font(.system(size: 72))
                    .foregroundColor(Theme.namedColor(page.colorName))
            }

            VStack(spacing: Theme.spacingMD) {
                Text(page.title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)

                Text(page.subtitle)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, Theme.spacingXL)
            }
        }
        .padding(.horizontal, Theme.spacingXL)
    }
}

#Preview {
    OnboardingView()
}
