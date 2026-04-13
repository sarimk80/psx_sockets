//
//  MoreView.swift
//  psx_sockets
//
//  Created by sarim khan on 03/04/2026.
//

import SwiftUI

struct MoreView: View {
    
    @Environment(MoreNavigation.self) private var moreNavigation
    @Environment(\.openURL) private var openURL
    @State private var showConfirmDialog = false
    @State private var psxVM = PsxViewModel(psxServiceManager: PsxServiceManager())

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                SectionCard(header: "Explore") {
                    MoreRow(
                        icon: "magnifyingglass",
                        iconColor: .green,
                        title: "Search",
                        subtitle: "Find stocks, sectors & more"
                    ) {
                        moreNavigation.push(route: .searchView)
                    }
                    
//                    Divider()
//                    
//                    MoreRow(
//                        icon: "mount",
//                        iconColor: .yellow,
//                        title: "Metals",
//                        subtitle: "Find stocks, sectors & more"
//                    ) {
//                        moreNavigation.push(route: .searchView)
//                    }
//                    
//                    Divider()
//                    
//                    MoreRow(
//                        icon: "pesetasign.bank.building",
//                        iconColor: .pink,
//                        title: "Currency Exchange",
//                        subtitle: "Find stocks, sectors & more"
//                    ) {
//                        moreNavigation.push(route: .searchView)
//                    }
//                    
//                    Divider()
//                    
//                    MoreRow(
//                        icon: "bolt.slash",
//                        iconColor: .mint,
//                        title: "Circult Breaker",
//                        subtitle: "Find stocks, sectors & more"
//                    ) {
//                        moreNavigation.push(route: .searchView)
//                    }
                }

                SectionCard(header: "App Settings") {
                    MoreRow(
                        icon: "lock.shield",
                        iconColor: .orange,
                        title: "Privacy Policy",
                        subtitle: "How we handle your data"
                    ) {
                        if let url = URL(string: "https://sarim-pix.hf.space/PrivacyPolicy") {
                            openURL(url)
                        }
                    }
                    
//                    Divider()
//
//                    MoreRow(
//                        icon: "globe",
//                        iconColor: .purple,
//                        title: "Change Language",
//                        subtitle: "Remove all cached data",
//                    ) {
//                    }

                    Divider()

                    MoreRow(
                        icon: "trash",
                        iconColor: .red,
                        title: "Clear All Data",
                        subtitle: "Remove all cached data",
                        isDestructive: true
                    ) {
                        showConfirmDialog.toggle()
                    }
                    
                    
                }

                // MARK: - App Info Footer
                VStack(spacing: 4) {
                    Text("Stokistan")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text("Version 1.0.0")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 4)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .alert("Clear All Data", isPresented: $showConfirmDialog, actions: {
            Button("Clear All Data", role: .destructive) {
                Task{
                    await psxVM.clearAllData()
                }
            }
            Button("Cancel", role: .cancel) {
                showConfirmDialog.toggle()
            }
        }, message: {
            Text("All cached data will be permanently removed. This action cannot be undone.")
        })
        .background(Color(.systemGroupedBackground))
        .navigationTitle("More")
        
    }
}


struct SectionCard<Content: View>: View {
    let header: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(header.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.leading, 4)
                .padding(.bottom, 6)

            VStack(spacing: 0) {
                content()
            }
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
}

// MARK: - More Row

struct MoreRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    var isDestructive: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                // Icon Badge
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(iconColor.opacity(0.2))
                        .frame(width: 34, height: 34)
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(iconColor)
                }

                // Text
                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .font(.body)
                        .foregroundStyle(isDestructive ? .red : .primary)
//                    Text(subtitle)
//                        .font(.caption)
//                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        MoreView()
    }
}
