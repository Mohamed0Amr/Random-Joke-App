import SwiftUI

struct ContentView: View {
    @State private var joke: Joke?
    @State private var isLoading = false
    @State private var showContent = false

    var body: some View {
        ZStack {
            // MARK: Background Gradient
            LinearGradient(
                gradient: Gradient(colors: [.blue.opacity(0.2), .white]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // MARK: Main VStack
            VStack(spacing: 28) {
                // Title
                Text("😂 Random Joke App")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.blue)
                    .multilineTextAlignment(.center)
                    .opacity(showContent ? 1 : 0)
                    .animation(.easeOut(duration: 0.6), value: showContent)

                // Joke Card / Loading / Placeholder
                Group {
                    if isLoading {
                        ProgressView("Fetching a funny joke...")
                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                            .font(.headline)
                            .transition(.opacity)
                    } else if let joke = joke {
                        VStack(spacing: 18) {
                            Text(joke.setup)
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)

                            Divider()

                            Text(joke.punchline)
                                .font(.title2.bold())
                                .foregroundColor(.green)
                                .multilineTextAlignment(.center)
                        }
                        .padding(30)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                                .shadow(color: .gray.opacity(0.3), radius: 12, x: 0, y: 6)
                        )
                        .padding(.horizontal)
                        .transition(.scale.combined(with: .opacity))
                    } else {
                        Text("Tap below to get a random joke 😄")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .transition(.opacity)
                    }
                }

                // Button
                Button(action: {
                    Task { await fetchJoke() }
                }) {
                    Label("Get Joke", systemImage: "arrow.triangle.2.circlepath.circle.fill")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(colors: [.blue, .blue.opacity(0.8)], startPoint: .leading, endPoint: .trailing)
                        )
                        .foregroundColor(.white)
                        .cornerRadius(14)
                        .shadow(color: .blue.opacity(0.4), radius: 8, x: 0, y: 3)
                        .padding(.horizontal, 50)
                }
                .buttonStyle(.plain)
                .transition(.opacity)

            }
            .frame(maxWidth: 600) // keeps it neat on large screens
            .multilineTextAlignment(.center)
            .padding()
            .onAppear {
                // simple fade-in animation when app starts
                withAnimation(.easeOut(duration: 0.8)) {
                    showContent = true
                }
            }
        }
        .animation(.easeInOut(duration: 0.4), value: joke)
    }

    // MARK: - Fetch Joke Function
    @MainActor
    func fetchJoke() async {
        guard let url = URL(string: "https://official-joke-api.appspot.com/random_joke") else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(Joke.self, from: data)
            withAnimation {
                joke = decoded
            }
        } catch {
            print("❌ Error fetching joke: \(error.localizedDescription)")
        }
    }
}
