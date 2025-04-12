import SwiftUI
import Charts

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @State private var selectedTab: Tab = .insights
    
    enum Tab: String, CaseIterable {
        case insights = "Insights"
        case dreams = "Dreams"
        case health = "Health"
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.comet.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    headerView
                    tabPicker
                    contentView
                }
            }
            .navigationDestination(for: Dream.self) { dream in
                DreamDetailView(dream: dream)
            }
            .sheet(isPresented: $viewModel.showLogDream) {
                LogDreamView(viewModel: viewModel)
            }
            .alert("Error", isPresented: .constant(viewModel.error != nil), presenting: viewModel.error) { error in
                Button("OK", role: .cancel) { viewModel.error = nil }
            } message: { error in
                Text(error.localizedDescription)
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            Text("Dream Journal")
                .font(.largeTitle.bold())
                .foregroundColor(.white)
            
            Spacer()
            
            Button {
                viewModel.showLogDream = true
            } label: {
                Image(systemName: "plus")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.purpleHaze)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }
    
    private var tabPicker: some View {
        HStack {
            ForEach(Tab.allCases, id: \.self) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    Text(tab.rawValue)
                        .font(.headline)
                        .foregroundColor(selectedTab == tab ? .white : .white.opacity(0.6))
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(
                            Capsule()
                                .fill(selectedTab == tab ? Color.purpleHaze : Color.clear)
                        )
                }
            }
        }
        .padding(.vertical, 8)
        .background(Color.cometDarker)
        .clipShape(Capsule())
        .padding(.horizontal)
        .padding(.bottom, 10)
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch selectedTab {
        case .insights:
            InsightsView(viewModel: viewModel)
        case .dreams:
            DreamListView(viewModel: viewModel)
        case .health:
            HealthView(viewModel: viewModel)
        }
    }
}

struct InsightsView: View {
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let report = viewModel.weeklyReport {
                    summaryCard(report: report)
                    
                    if !report.emotionDistribution.isEmpty {
                        emotionsCard(emotions: report.emotionDistribution)
                    }
                    
                    if !report.archetypeFrequency.isEmpty {
                        archetypesCard(archetypes: report.archetypeFrequency)
                    }
                } else {
                    ProgressView()
                }
                
                if !viewModel.tips.isEmpty {
                    tipsCard
                }
            }
            .padding()
        }
    }
    
    private func summaryCard(report: WeeklyReport) -> some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Weekly Summary")
                    .font(.title2.bold())
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("\(report.dreamCount)")
                            .font(.system(size: 42, weight: .bold))
                            .foregroundColor(.purpleHaze)
                        Text("Dreams")
                            .font(.headline)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        if let emotion = report.dominantEmotion {
                            Text("Dominant Emotion")
                                .font(.caption)
                            Text(emotion.capitalized)
                                .font(.title3.bold())
                                .foregroundColor(.purpleHaze)
                        }
                    }
                }
                
                if let quality = report.avgSleepQuality {
                    HStack {
                        Text("Avg. Sleep Quality:")
                        Spacer()
                        Text(String(format: "%.1f/5", quality))
                            .bold()
                    }
                    .padding(.top, 8)
                }
            }
        }
    }
    
    private func emotionsCard(emotions: [String: Int]) -> some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Emotion Distribution")
                    .font(.title2.bold())
                
                Chart {
                    ForEach(emotions.sorted(by: { $0.value > $1.value }), id: \.key) { emotion in
                        BarMark(
                            x: .value("Emotion", emotion.key.capitalized),
                            y: .value("Count", emotion.value)
                        )
                        .foregroundStyle(by: .value("Emotion", emotion.key))
                        .annotation(position: .top) {
                            Text("\(emotion.value)")
                                .font(.caption)
                        }
                    }
                }
                .chartForegroundStyleScale([
                    "joy": Color(hex: "#FFD700"),
                    "fear": Color(hex: "#800080"),
                    "anger": Color(hex: "#FF0000"),
                    "sadness": Color(hex: "#1E90FF"),
                    "surprise": Color(hex: "#FFA500"),
                    "disgust": Color(hex: "#008000")
                ])
                .frame(height: 200)
            }
        }
    }
    
    private func archetypesCard(archetypes: [String: Int]) -> some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Common Archetypes")
                    .font(.title2.bold())
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(archetypes.sorted(by: { $0.value > $1.value }), id: \.key) { archetype in
                            VStack {
                                Text(archetype.key.capitalized)
                                    .font(.headline)
                                Text("\(archetype.value)")
                                    .font(.title.bold())
                                    .foregroundColor(.purpleHaze)
                            }
                            .padding()
                            .frame(width: 120)
                            .background(Color.cometDarker)
                            .cornerRadius(10)
                        }
                    }
                }
            }
        }
    }
    
    private var tipsCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Personalized Tips")
                    .font(.title2.bold())
                
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(viewModel.tips.prefix(3), id: \.self) { tip in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(.yellow)
                            Text(tip)
                                .font(.subheadline)
                        }
                    }
                }
            }
        }
    }
}

struct DreamListView: View {
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if viewModel.dreams.isEmpty {
                    emptyState
                } else {
                    ForEach(viewModel.dreams) { dream in
                        NavigationLink(value: dream) {
                            DreamCard(dream: dream, viewModel: viewModel)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        viewModel.deleteDream(dream)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding()
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "moon.zzz")
                .font(.system(size: 50))
                .foregroundColor(.purpleHaze)
            
            Text("No Dreams Recorded")
                .font(.title2.bold())
            
            Text("Tap the + button to log your first dream")
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
    }
}

struct HealthView: View {
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if viewModel.healthData.isEmpty {
                    connectHealthView
                } else {
                    sleepChart
                    
                    if let report = viewModel.weeklyReport, let quality = report.avgSleepQuality {
                        sleepQualityCard(quality: quality)
                    }
                }
            }
            .padding()
        }
    }
    
    private var connectHealthView: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.text.square")
                .font(.system(size: 50))
                .foregroundColor(.purpleHaze)
            
            Text("Connect Health Data")
                .font(.title2.bold())
            
            Text("View correlations between your dreams and sleep patterns")
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
            
            Button {
                viewModel.checkHealthAuthorization()
            } label: {
                Text("Connect")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.purpleHaze)
                    .cornerRadius(10)
            }
            .padding(.top, 20)
        }
        .padding(40)
    }
    
    private var sleepChart: some View {
        CardView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Sleep Patterns")
                    .font(.title2.bold())
                
                Chart(viewModel.healthData) { data in
                    BarMark(
                        x: .value("Date", data.date, unit: .day),
                        y: .value("Hours", data.sleepHours)
                    )
                    .foregroundStyle(Color.purpleHaze.gradient)
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { value in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                    }
                }
                .frame(height: 200)
            }
        }
    }
    
    private func sleepQualityCard(quality: Double) -> some View {
        CardView {
            HStack {
                VStack(alignment: .leading) {
                    Text("Avg. Sleep Quality")
                        .font(.headline)
                    Text(String(format: "%.1f/5", quality))
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(quality > 3 ? .green : .orange)
                }
                
                Spacer()
                
                Image(systemName: quality > 3 ? "moon.stars.fill" : "moon.zzz")
                    .font(.system(size: 40))
                    .foregroundColor(quality > 3 ? .purpleHaze : .orange)
            }
        }
    }
}

struct DreamCard: View {
    let dream: Dream
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(dream.timestamp.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                Spacer()
                
                if let quality = dream.sleepQuality {
                    HStack(spacing: 4) {
                        Image(systemName: "moon.zzz")
                        Text("\(quality)/5")
                    }
                    .font(.caption)
                    .foregroundColor(quality > 3 ? .green : .orange)
                }
            }
            
            Text(dream.text)
                .font(.body)
                .lineLimit(2)
            
            if !dream.archetypes.isEmpty {
                HStack {
                    ForEach(dream.archetypes.prefix(3), id: \.self) { archetype in
                        Text(archetype.capitalized)
                            .font(.caption)
                            .padding(4)
                            .background(Color.purpleHaze.opacity(0.2))
                            .cornerRadius(4)
                    }
                }
            }
            
            if dream.voiceMemoURL != nil || dream.soundscapeURL != nil {
                HStack {
                    Spacer()
                    Button {
                        viewModel.toggleAudioPlayback(for: dream)
                    } label: {
                        Image(systemName: viewModel.currentlyPlayingURL == dream.voiceMemoURL && viewModel.isPlayingAudio ? "stop.fill" : "play.fill")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.purpleHaze)
                            .clipShape(Circle())
                    }
                }
            }
        }
        .padding()
        .background(Color.cometDarker)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.purpleHaze.opacity(0.5), lineWidth: 1)
        )
    }
}

struct DreamDetailView: View {
    let dream: Dream
    @State private var isPlaying = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(dream.timestamp.formatted(date: .complete, time: .shortened))
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                
                Text(dream.text)
                    .font(.body)
                
                if !dream.emotions.isEmpty {
                    emotionsSection
                }
                
                if !dream.archetypes.isEmpty {
                    archetypesSection
                }
                
                if dream.voiceMemoURL != nil || dream.soundscapeURL != nil {
                    audioSection
                }
            }
            .padding()
        }
        .navigationTitle("Dream Details")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.comet.ignoresSafeArea())
    }
    
    private var emotionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Emotions")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(dream.emotions) { emotion in
                        VStack {
                            Text(emotion.label.capitalized)
                                .font(.caption)
                            Circle()
                                .fill(Color(hex: emotion.color))
                                .frame(width: 30, height: 30)
                            Text(String(format: "%.0f%%", emotion.score * 100))
                                .font(.caption2)
                        }
                        .padding(8)
                        .background(Color.cometDarker)
                        .cornerRadius(8)
                    }
                }
            }
        }
    }
    
    private var archetypesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Archetypes")
                .font(.headline)
            
            FlowLayout(spacing: 8) {
                ForEach(dream.archetypes, id: \.self) { archetype in
                    Text(archetype.capitalized)
                        .font(.caption)
                        .padding(8)
                        .background(Color.purpleHaze.opacity(0.2))
                        .cornerRadius(20)
                }
            }
        }
    }
    
    private var audioSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Audio")
                .font(.headline)
            
            if let voiceURL = dream.voiceMemoURL {
                AudioPlayerView(
                    title: "Voice Recording",
                    url: voiceURL,
                    isPlaying: $isPlaying
                )
            }
            
            if let soundscapeURL = dream.soundscapeURL {
                AudioPlayerView(
                    title: "Soundscape",
                    url: soundscapeURL,
                    isPlaying: $isPlaying
                )
            }
        }
    }
}

struct AudioPlayerView: View {
    let title: String
    let url: URL
    @Binding var isPlaying: Bool
    @State private var player: AVAudioPlayer?
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            Button {
                togglePlayback()
            } label: {
                Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.purpleHaze)
                    .clipShape(Circle())
            }
        }
        .padding()
        .background(Color.cometDarker)
        .cornerRadius(10)
        .onDisappear {
            player?.stop()
        }
    }
    
    private func togglePlayback() {
        if isPlaying {
            player?.stop()
            isPlaying = false
        } else {
            do {
                player = try AVAudioPlayer(contentsOf: url)
                player?.play()
                isPlaying = true
            } catch {
                print("Audio playback error: \(error)")
            }
        }
    }
}

struct FlowLayout<Data: Collection, Content: View>: View where Data.Element: Hashable {
    let data: Data
    let spacing: CGFloat
    let content: (Data.Element) -> Content
    @State private var height: CGFloat = 0
    
    init(spacing: CGFloat = 8, @ViewBuilder content: @escaping (Data.Element) -> Content) where Data == [String] {
        self.data = []
        self.spacing = spacing
        self.content = content
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                var width = CGFloat.zero
                var height = CGFloat.zero
                
                ForEach(data, id: \.self) { item in
                    content(item)
                        .padding([.trailing, .bottom], spacing)
                        .alignmentGuide(.leading) { d in
                            if (abs(width - d.width) > geometry.size.width) {
                                width = 0
                                height -= d.height
                            }
                            let result = width
                            if item == data.last {
                                width = 0
                            } else {
                                width -= d.width
                            }
                            return result
                        }
                        .alignmentGuide(.top) { d in
                            let result = height
                            if item == data.last {
                                height = 0
                            }
                            return result
                        }
                }
            }
        }
    }
}

struct CardView<Content: View>: View {
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

struct LogDreamView: View {
    @ObservedObject var viewModel: DashboardViewModel
    @State private var dreamText = ""
    @State private var isRecording = false
    @State private var audioRecorder: AVAudioRecorder?
    @State private var audioURL: URL?
    @State private var sleepQuality: Int?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.comet.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        TextEditor(text: $dreamText)
                            .frame(height: 200)
                            .padding()
                            .background(Color.cometDarker)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.purpleHaze, lineWidth: 1)
                            )
                        
                        sleepQualitySection
                        
                        audioRecordingSection
                        
                        Button {
                            viewModel.addDream(
                                text: dreamText,
                                audioURL: audioURL,
                                sleepQuality: sleepQuality
                            )
                        } label: {
                            Text("Save Dream")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.purpleHaze)
                                .cornerRadius(10)
                        }
                        .disabled(dreamText.isEmpty)
                    }
                    .padding()
                }
            }
            .navigationTitle("Log Dream")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.showLogDream = false
                    }
                }
            }
            .onDisappear {
                if isRecording {
                    stopRecording()
                }
            }
        }
    }
    
    private var sleepQualitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sleep Quality")
                .font(.headline)
            
            HStack {
                ForEach(1..<6) { index in
                    Button {
                        sleepQuality = index
                    } label: {
                        Image(systemName: index <= (sleepQuality ?? 0) ? "moon.fill" : "moon")
                            .font(.title2)
                            .foregroundColor(index <= (sleepQuality ?? 0) ? .purpleHaze : .white.opacity(0.5))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var audioRecordingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Voice Recording")
                .font(.headline)
            
            HStack {
                Button {
                    if isRecording {
                        stopRecording()
                    } else {
                        startRecording()
                    }
                } label: {
                    Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                        .foregroundColor(.white)
                        .padding()
                        .background(isRecording ? Color.red : Color.purpleHaze)
                        .clipShape(Circle())
                }
                
                if let audioURL = audioURL {
                    AudioPlayerView(
                        title: "Recording",
                        url: audioURL,
                        isPlaying: .constant(false)
                    )
                } else {
                    Text(isRecording ? "Recording..." : "No recording")
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
    }
    
    private func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let audioFilename = documentsPath.appendingPathComponent("recording-\(Date().timeIntervalSince1970).wav")
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatLinearPCM),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.record()
            isRecording = true
            audioURL = audioFilename
        } catch {
            print("Recording error: \(error)")
        }
    }
    
    private func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
    }
}

// MARK: - Extensions

extension Color {
    static let comet = Color(hex: "#1C1238")
    static let cometDarker = Color(hex: "#0F0A20")
    static let purpleHaze = Color(hex: "#7340BF")
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension Date {
    func formatted(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}

// MARK: - Previews

#Preview {
    DashboardView()
}

#Preview {
    LogDreamView(viewModel: DashboardViewModel())
}

#Preview {
    DreamDetailView(dream: Dream(
        text: "I was flying over mountains and felt completely free. The wind was cool against my face as I soared above the clouds.",
        emotions: [
            Emotion(label: "joy", score: 0.9),
            Emotion(label: "excitement", score: 0.7)
        ],
        archetypes: ["flying", "freedom"],
        sleepQuality: 4
    ))
}