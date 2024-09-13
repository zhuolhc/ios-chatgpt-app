import SwiftUI

struct ContentView: View {
    @State private var message = ""
    @State private var chatMessages: [ChatMessage] = []
    @State private var isDarkMode = false
    @FocusState private var isInputActive: Bool
    
    private let openAIService = OpenAIService(apiKey: "YOUR_API-KEY(sk-*******)")
    
    init() {
        _chatMessages = State(initialValue: [
            ChatMessage(content: "你好！有什么我可以帮忙的吗？", isUser: false)
        ])
    }
    
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    ForEach(chatMessages) { message in
                        MessageView(message: message)
                    }
                }
                .gesture(TapGesture().onEnded {
                    isInputActive = false
                })
                
                HStack {
                    TextField("Sending message here...", text: $message)
                        .padding(10)
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        .foregroundColor(isDarkMode ? .white : .black)
                        .focused($isInputActive)
                        .onTapGesture {
                            isInputActive = true
                        }
                    
                    Button(action: sendMessage) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(isDarkMode ? .white : .blue)
                    }
                }
                .padding()
            }
            .navigationTitle("ChatGPT")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: toggleDarkMode) {
                        Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                            .foregroundColor(isDarkMode ? .white : .blue)
                    }
                }
            }
            .background(isDarkMode ? Color.black : Color(UIColor.systemBackground))
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
    
    func sendMessage() {
        if !message.isEmpty {
            let userMessage = ChatMessage(content: message, isUser: true)
            chatMessages.append(userMessage)
            
            openAIService.sendMessage(message) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        let assistantMessage = ChatMessage(content: response, isUser: false)
                        chatMessages.append(assistantMessage)
                    case .failure(let error):
                        print("Error: \(error.localizedDescription)")
                        // 这里可以添加错误处理逻辑,比如显示一个错误消息
                    }
                }
            }
            
            message = ""
            isInputActive = false
        }
    }
    
    func toggleDarkMode() {
        isDarkMode.toggle()
    }
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
}

struct MessageView: View {
    let message: ChatMessage
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
            }
            Text(message.content)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(message.isUser ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(message.isUser ? .white : (colorScheme == .dark ? .white : .black))
                .cornerRadius(10)
            if !message.isUser {
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
