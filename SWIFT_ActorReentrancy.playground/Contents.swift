import Foundation
import PlaygroundSupport

/// Actor Reentrancy
/// - actor의 재진입 가능성을 의미함
/// - actor가 await로 인해 일시 중단되었을 때 다른 작업 (Task)가 해당 actor에 진입하여 작업될 수 있는 특성
///
/// actor는 한번에 하나의 작업만 실행함
/// - actor 내부 함수에서 await를 만날 경우 현재 작업이 중단됨
/// - actor가 다른 작업 (Task)를 실행할 수 있게 됨에 따라 다른 Task의 진입을 허용함
/// -> await 전후로 actor의 내부 환경이 변경될 수 있음
///
/// actor의 직렬화는 한 순간은 보장하지만 await 전후의 상황은 보장하지 않음
/// - await로 인해 현재 Task가 중단된 경우 대기 중인 다른 Task가 actor에 진입할 수 있음
/// + Global Actor도 동일
///
/// 해결방법
/// 1. await 전후로 내부 상태를 확인
/// 2. sync 함수로 사용 (비동기 작업은 외부에서 진행)
/// 3. Task를 내부에서 캐싱하여 중복 작업을 최소화
/// - 이미지, API 통신과 같은 경우
/// 4. await 작업의 타이밍 변경

// async await 사용 제약 해제
PlaygroundPage.current.needsIndefiniteExecution = true

func toEmoji(_ isTrue: Bool) -> String {
    return isTrue ? "✅" : "⛔️"
}

actor SettingManager {
    private var isDarkMode = false
    
    func setDarkMode(_ isDarkMode: Bool, _ id: String) async {
        print("🎬 \(id): 기존 다크모드 여부 \(toEmoji(self.isDarkMode))")
        print("-----------")
        
        self.isDarkMode = isDarkMode
        print("💾 \(id): 다크모드 여부 변경 완료 \(toEmoji(self.isDarkMode))")
        print("-----------")
        try? await Task.sleep(for: .seconds(1))
        
        print("🔚 \(id): 대기 후 다크모드 여부 \(toEmoji(self.isDarkMode))")
        print("-----------")
    }
}

Task {
    let manager = SettingManager()
    
    Task {
        await manager.setDarkMode(true, "1")
    }
    
    Task {
        await manager.setDarkMode(false, "2")
    }
}
