import Foundation

// 서비스/계정과 분리한 고정 S2 표본. 새 추천이나 카피 생성 로직이 아니다.
enum ProbeData {
    static let contentID = "fixture:synthetic-portrait"
    static let copyID = contentID + ":copy:2"
    static let copy = "오늘 이 메뉴 만들어볼까?"
    static let category = "MOA_VISUAL_25"
    static let destination = URL(string: "nyammoaprobe://content/fixture?copy=2")!
}
