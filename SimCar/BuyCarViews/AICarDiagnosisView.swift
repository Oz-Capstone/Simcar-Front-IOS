import SwiftUI

struct AICarDiagnosis: Codable, Identifiable {
    var id: Int { carId }
    let carId: Int
    let reliabilityScore: Int
    let evaluationComment: String
}

struct AICarDiagnosisView: View {
    var carId: Int
    @Environment(\.presentationMode) var presentationMode  // 모달 닫기를 위한 변수

    @State private var diagnosis: AICarDiagnosis?
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if isLoading {
                    ProgressView("진단 결과를 불러오는 중...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .foregroundColor(Color(hex: "#9575CD"))
                } else if let errorMessage = errorMessage {
                    Text("오류: \(errorMessage)")
                        .foregroundColor(.red)
                } else if let diagnosis = diagnosis {
                    VStack(spacing: 20) {
                        Text("차량 진단 결과")
                            .foregroundColor(Color(hex: "#9575CD"))
                            .font(.largeTitle)
                            .bold()
                            .padding()
                        
                        // 도넛 모양 게이지
                        DonutProgressView(finalProgress: CGFloat(diagnosis.reliabilityScore) / 100.0)
                        
                        Text("평가 코멘트:")
                            .foregroundColor(Color(hex: "#9575CD"))
                            .font(.title)
                            .bold()
                            .padding()
                        
                        Text(diagnosis.evaluationComment)
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color(hex: "#9575CD"))
                            .font(.title2)
                            .bold()
                    }
                } else {
                    Text("진단 결과가 없습니다.")
                        .foregroundColor(Color(hex: "#9575CD"))
                }
                Spacer()
                
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("확인")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.purple]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: Color.blue.opacity(0.8), radius: 5, x: 0, y: 0)
                }
                .buttonStyle(PressableButtonStyle())
                .padding(.horizontal)
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            fetchDiagnosis()
        }
    }
    
    private func fetchDiagnosis() {
        guard let url = URL(string: API.car + "\(carId)/diagnosis") else {
            errorMessage = "잘못된 URL입니다."
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                defer { isLoading = false }
                if let error = error {
                    errorMessage = "네트워크 오류: \(error.localizedDescription)"
                    return
                }
                if let httpResponse = response as? HTTPURLResponse,
                   !(200...299).contains(httpResponse.statusCode) {
                    errorMessage = "서버 오류: \(httpResponse.statusCode)"
                    return
                }
                guard let data = data else {
                    errorMessage = "데이터를 받을 수 없습니다."
                    return
                }
                do {
                    let diagnosisResult = try JSONDecoder().decode(AICarDiagnosis.self, from: data)
                    self.diagnosis = diagnosisResult
                } catch {
                    errorMessage = "데이터 파싱 오류: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}


// MARK: - Donut Progress View
struct DonutProgressView: View {
    /// 최종 progress (0.0 ~ 1.0)
    var finalProgress: CGFloat
    @State private var animatedProgress: CGFloat = 0.0

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 20)
            
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.blue, location: 0.0),
                            .init(color: Color.purple, location: 0.5),
                            .init(color: Color.blue, location: 1.0)
                        ]),
                        center: .center,
                        startAngle: .degrees(90),
                        endAngle: .degrees(450)
                    ),
                    style: StrokeStyle(lineWidth: 20, lineCap: .round)
                )
                .rotationEffect(Angle(degrees: 90))
                .animation(.easeInOut(duration: 3.0), value: animatedProgress)
            
            Text("\(Int(animatedProgress * 100))")
                .font(.largeTitle)
                .bold()
                .foregroundColor(Color(hex: "#9575CD"))
        }
        .frame(width: 150, height: 150)
        .onAppear {
            // 0에서 최종값으로 애니메이션
            animatedProgress = finalProgress
        }
    }
}

