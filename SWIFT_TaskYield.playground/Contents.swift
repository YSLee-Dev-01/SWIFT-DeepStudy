import Foundation
import PlaygroundSupport

/// Task.yield
/// - 현재 실행 중인 비동기 작업이 자발적으로 실행 권한을 양보하는 것
/// - async await는 협력적 동시성으로 작동하며, 스스로 실행 권한을 양보해야만 다른 작업이 실행될 수 있는 구조
///
/// 양보범위 (우선순위)
/// - 현재 Task와 같은 컨텍스트에서 대기 중인 작업
/// - Task의 우선순위가 높은 작업
/// -> 먄약 대기 중인 작업이 없을 경우 바로 다음 코드가 실행될 수 있음
///
/// - 비동기 작업 중간에 업데이트를 해야하는 일이 있을 때 사용

// async await 사용 제약 해제
PlaygroundPage.current.needsIndefiniteExecution = true

@MainActor // 메인 스레드만 사용하도록 하여, yield 효과를 확인할 수 있도록 함
class SettingManager {
    func process1() async {
       print("🎬 process1 시작")
        
        for i in 1 ... 5 {
            _ = (0..<1_000_000).reduce(0, +)
            print("✅ process1 \(i)번째 완료")
            if i == 3 {
                print("✋ process1 - 양보")
                await Task.yield()
            }
        }
        
        print("🔚 process1 끝")
    }
    
    func process2() async {
        print("🎬 process2 시작")
        
        for i in 1 ... 1_000_000 {
            if i == 1_000_000/2 {
                print("✋ process2 - 양보")
                await Task.yield()
            }
        }
        print("✅ process2 완료")
        print("🔚 process2 끝")
    }
    
    func process3() async {
        print("🎬 process3 시작")
        print("✅ process3 완료")
        print("🔚 process3 끝")
    }
}


/// 하단 코드는 양보 없이 순차적으로 실행됨
///- yield는 이미 생성되어 대기 중인 Task에게 양보하는 키워드이기 때문
///-> process2, 3는 await로 인해 process 1이 완료될 때 까지 Task로 실행 조차 되지 않음

//Task {
//    let settingManager = SettingManager()
//    print("1️⃣")
//    
//    await settingManager.process1()
//    await settingManager.process2()
//    await settingManager.process3()
//    print("---------------")
//}

Task {
    let settingManager = SettingManager()
    print("2️⃣")
    
    async let p1 = settingManager.process1()
    async let p2 = settingManager.process2()
    async let p3 = settingManager.process3()
    
    await p1
    await p2
    await p3
}
