//
//  DashboardView.swift
//  HealthAndWellness
//
//  Created by Sengi Mathias on 4/12/25.
//

import SwiftUI
import Charts

struct DashboardView: View {
    @StateObject var viewModel = DashboardViewModel()
    @State private var selectedTab: DashboardTab = .insights
    
    enum DashboardTab: String, CaseIterable {
        case insights = "Insights"
        case dreams = "Dreams"
        case health = "Health"
    }
    
    var body: some View {
        ZStack {
            Color.comet
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Dream Journal")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.showPopup = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.purpleHaze)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 15)
                .padding(.bottom, 10)
                
                // Tab Selector
                HStack {
                    ForEach(DashboardTab.allCases, id: \.self) { tab in
                        Button(action: {
                            selectedTab = tab
                        }) {
                            Text(tab.rawValue)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(selectedTab == tab ? .white : .white.opacity(0.6))
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(
                                    selectedTab == tab ? Color.purpleHaze : Color.clear
                                )
                                .cornerRadius(20)
                        }
                    }
                }
                .padding(.vertical, 8)
                .background(Color.cometDarker)
                .cornerRadius(25)
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
                
                // Main Content
                ScrollView {
                    VStack(spacing: 20) {
                        switch selectedTab {
                        case .insights:
                            InsightsView(viewModel: viewModel)
                        case .dreams:
                            DreamListView(viewModel: viewModel)
                        case .health:
                            HealthIntegrationView(viewModel: viewModel)
                        }
                    }
                    .padding(.bottom, 80)
                }
            }
        }
        .fullScreenCover(isPresented: $viewModel.showPopup) {
            LogDreamView(viewModel: viewModel)
        }
        .onAppear {
            viewModel.loadData()
        }
    }
}

// MARK: - Subviews

private struct InsightsView: View {
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            // Weekly Summary Card
            CardView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Weekly Summary")
                        .font(.headline)
                    
                    if let report = viewModel.weeklyReport {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("\(report.dreamCount) Dreams")
                                    .font(.title3)
                                Text("Avg. Sleep: \(report.avgSleepQuality ?? 0, specifier: "%.1f")/5")
                                    .font(.subheadline)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text("Dominant Emotion")
                                    .font(.caption)
                                Text(report.dominantEmotion ?? "Unknown")
                                    .font(.title3)
                            }
                        }
                        
                        Chart(report.emotionDistribution.sorted(by: { $0.value > $1.value }), id: \.key) { emotion in
                            BarMark(
                                x: .value("Emotion", emotion.key),
                                y: .value("Count", emotion.value)
                            )
                            .foregroundStyle(by: .value("Emotion", emotion.key))
                        }
                        .frame(height: 200)
                        .chartLegend(.hidden)
                    } else {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            
            // Dream Tips
            if !viewModel.tips.isEmpty {
                CardView {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Personalized Tips")
                            .font(.headline)
                        
                        ForEach(viewModel.tips.prefix(3), id: \.self) { tip in
                            HStack(alignment: .top) {
                                Image(systemName: "lightbulb")
                                    .foregroundColor(.yellow)
                                Text(tip)
                                    .font(.subheadline)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

private struct DreamListView: View {
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            if viewModel.dreams.isEmpty {
                EmptyStateView(
                    icon: "moon.zzz",
                    title: "No Dreams Logged",
                    message: "Tap the + button to log your first dream"
                )
            } else {
                ForEach(viewModel.dreams) { dream in
                    DreamCard(dream: dream) {
                        viewModel.selectedDream = dream
                    }
                    .contextMenu {
                        Button(role: .destructive) {
                            viewModel.deleteDream(dream)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .sheet(item: $viewModel.selectedDream) { dream in
            DreamDetailView(dream: dream)
        }
    }
}

private struct HealthIntegrationView: View {
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Health Integration")
                    .font(.headline)
                
                if viewModel.healthData.isEmpty {
                    Button(action: {
                        Task {
                            await viewModel.connectHealthData()
                        }
                    }) {
                        HStack {
                            Image(systemName: "heart.text.square")
                            Text("Connect Health Data")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Chart(viewModel.healthData, id: \.date) { item in
                        LineMark(
                            x: .value("Date", item.date),
                            y: .value("Hours", item.sleepHours)
                        )
                    }
                    .frame(height: 200)
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Components

private struct CardView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack {
            content
        }
        .padding()
        .background(Color.cometDarker)
        .cornerRadius(12)
    }
}

private struct DreamCard: View {
    let dream: Dream
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(dream.timestamp.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text(dream.text.prefix(100) + (dream.text.count > 100 ? "..." : ""))
                        .font(.body)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    if !dream.archetypes.isEmpty {
                        HStack {
                            ForEach(dream.archetypes.prefix(3), id: \.self) { archetype in
                                Text(archetype.capitalized)
                                    .font(.caption)
                                    .padding(4)
                                    .background(Color.purpleHaze)
                                    .cornerRadius(4)
                            }
                        }
                    }
                }
                
                Spacer()
                
                if let dominantEmotion = dream.emotions.max(by: { $0.score < $1.score }) {
                    Circle()
                        .fill(Color(dominantEmotion.color))
                        .frame(width: 20, height: 20)
                }
            }
            .padding()
            .background(Color.cometDarker)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

private struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(.purpleHaze)
            Text(title)
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(Color.cometDarker)
        .cornerRadius(12)
    }
}

// MARK: - Preview

#Preview {
    DashboardView()
}

// MARK: - Color Extensions

extension Color {
    static let comet = Color(red: 0.11, green: 0.07, blue: 0.20)
    static let cometDarker = Color(red: 0.08, green: 0.05, blue: 0.15)
    static let purpleHaze = Color(red: 0.45, green: 0.25, blue: 0.75)
}
