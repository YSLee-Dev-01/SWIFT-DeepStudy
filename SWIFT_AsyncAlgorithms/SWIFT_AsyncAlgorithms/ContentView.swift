//
//  ContentView.swift
//  SWIFT_AsyncAlgorithms
//
//  Created by 이윤수 on 11/26/25.
//

import SwiftUI
import AsyncAlgorithms

/// AsyncAlgorithms
/// - Apple에서 제공하는 AsyncSequence 전용 연산자 라이브러리
/// - Sequence는 map, filter, reduce 등 고차함수 사용은 가능했지만, merage 같은 고급 기능은 지원하지 않았음
/// -> AsyncAlgorithms을 더 편하게 사용할 수 있는 연산자 패키지
///
/// - AsyncSequence는 SPM을 통해 따로 설치해서 사용해야 함
///
/// 주요 기능 (RxSwift, Combine과 비슷)
/// 1. deboude, throttle
/// - 이벤트 간격 조절
/// - deboude는 연속된 이벤트가 끝난 후 마지막 값을 사용
/// - throttle는 일정 간격마다 값 사용
///
/// 2. merge
/// - 여러 시퀀스를 하나로 합쳐서 사용
///
/// 3. zip
/// - 여러 시퀀스를 조합해서 사용함
/// - zip 내부 시퀀스가 전부 값을 내보내야 처리 (1:1 짝 맞춰서 리턴)
///
/// 4. combineLatest
/// - 하나라도 업데이트 된 경우 최신 조합 반환
/// - 단, 처음에는 모든 시퀀스가 값을 한번 이상 내보내야함
///
/// 5. removeDuplicates
/// - 중복 제거
///
/// 6. chain
/// - 스트림을 순차 연결해서 사용
///
/// AsyncChannel
/// - 값을 보내고 받을 수 있는 파이프 개념
/// - AsyncStream은 continuation 클로저 내부에서만 값을 전송할 수 있었지만, AsyncChannel은 어디서든 값을 전송할 수 있음
/// - RxSwift의 Observable - subject와 비슷
/// -> Observable = AsyncStream
/// -> AsyncChannel = PublishSubject

struct ContentView: View {
    private let queryChannel = AsyncChannel<String>()
    @State private var query: String = ""
    @State private var list: [String] = []
    
    var body: some View {
        ScrollView {
            VStack {
                VStack(spacing: 20) {
                    HStack {
                        Text("검색")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Spacer()
                    }
                    .padding(.top, 10)
                    
                    TextField(text: self.$query) {
                        Text("🔍 검색어를 입력하세요.")
                    }
                    .padding(10)
                    .background {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.gray.opacity(0.15))
                            .frame(height: 50)
                    }
                    .task(id: self.query) {
                        // AsyncChannel에 send를 하기 위해서는 await가 필수
                        await self.queryChannel.send(self.query)
                    }
                    .task {
                        // AsyncChannel에 debounce를 사용하여 이벤트 간격 조절
                        for await query in self.queryChannel.debounce(for: .seconds(1)) {
                            self.list = await self.requestSearch(for: query)
                        }
                    }
                }
                
                LazyVStack {
                    ForEach(self.list.enumerated(), id: \.offset) { data in
                        HStack {
                            Text(data.element)
                                .font(.title3)
                            
                            Spacer()
                        }
                    }
                }
            }
            .padding(20)
        }
    }
}

private extension ContentView {
    func requestSearch(for query: String) async -> [String] {
        return query.map {String($0)}
    }
}

#Preview {
    ContentView()
}
