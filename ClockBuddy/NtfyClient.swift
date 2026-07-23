import Foundation

final class NtfyClient {
    private let session = URLSession.shared

    func send(serverURL: String, topic: String, message: String) {
        let server = serverURL
            .trimmingCharacters(in: .whitespaces)
            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let topic = topic.trimmingCharacters(in: .whitespaces)

        guard !server.isEmpty, !topic.isEmpty,
              let url = URL(string: "\(server)/\(topic)") else {
            print("NtfyClient: invalid server/topic — server='\(serverURL)', topic='\(topic)'")
            return
        }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("text/plain; charset=utf-8", forHTTPHeaderField: "Content-Type")
        req.httpBody = message.data(using: .utf8)

        session.dataTask(with: req) { _, response, error in
            if let error {
                print("NtfyClient: send failed: \(error.localizedDescription)")
                return
            }
            if let http = response as? HTTPURLResponse,
               !(200..<300).contains(http.statusCode) {
                print("NtfyClient: HTTP \(http.statusCode)")
            }
        }.resume()
    }
}
