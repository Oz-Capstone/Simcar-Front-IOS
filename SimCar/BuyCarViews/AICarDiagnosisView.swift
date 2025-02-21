import SwiftUI

struct AICarDiagnosis: Codable, Identifiable {
    var id: Int { carId }  // Identifiable 준수를 위해 carId를 id로 사용
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
                } else if let errorMessage = errorMessage {
                    Text("오류: \(errorMessage)")
                        .foregroundColor(.red)
                } else if let diagnosis = diagnosis {
                    VStack(spacing: 10) {
                        Text("신뢰도 점수: \(diagnosis.reliabilityScore)")
                            .font(.title)
                        Text("평가 코멘트:")
                            .font(.subheadline)
                        Text(diagnosis.evaluationComment)
                            .multilineTextAlignment(.center)
                    }
                } else {
                    Text("진단 결과가 없습니다.")
                }
                Spacer()
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("확인")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
            }
            .padding()
            .navigationTitle("차량 진단 결과")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            fetchDiagnosis()
        }
    }
    
    private func fetchDiagnosis() {
        guard let url = URL(string: "http://13.124.141.50:8080/api/cars/\(carId)/diagnosis") else {
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
