import UIKit

print("-----(1)-----")
print("特にないためスルー")


print("-----(2)-----")
enum FormatError : Error {    // エラーに列挙型を使うと便利
    case notHex(Character)    // エラーの原因の文字を返す
    case space                // 不正な位置に空白がある
}

func hex(_ c: Unicode.Scalar) throws -> Int { // 16進→整数
    var d = 0
    switch c { // ASCIIコードに基づく
    case Unicode.Scalar("A") ... Unicode.Scalar("F"):
        d = 0x41 - 10
    case Unicode.Scalar("a") ... Unicode.Scalar("f"):
        d = 0x61 - 10
    case Unicode.Scalar("0") ... Unicode.Scalar("9"):
        d = 0x30
    default: throw FormatError.notHex(Character(c))
    }
    return Int(c.value) - d
}

func hexToBytes(_ s:String) throws -> [UInt8] {
    let s = s + " "           // 末尾の空白はセンチネル（番兵）
    var bytes = [UInt8]()     // バイトを格納する
    var first: Int? = nil     // １桁目をすでに読んでいるなら数値を持つ
    do {
        for uc in s.unicodeScalars {
            if let v = first {         // １桁目がすでにある
                if uc == " " {         // ２桁目がない場合はエラー
                    throw FormatError.space
                }
                let w = try hex(uc)    // ２桁目を変換
                bytes.append(UInt8((v << 4)|w))
                first = nil
            } else if uc != " " {
                first = try hex(uc)    // １桁目を変換
            }                          // 空白は読み飛ばし
        }
    } catch FormatError.space {        // 空白位置のエラーを捕捉
        print("16進数は偶数桁で読み込みます")
    }
    return bytes
}

for str in [ "0fff80", "0D 0E 10 2030", "ffee aaa", "00FFHH" ] {
    print("input = \"\(str)\"")
    do {
        let bytes = try hexToBytes(str)
        print(bytes)
    }catch {
        print(error)
    }
}

print("------")

// p.272
if let bin = try? hexToBytes("2BAD 4ACE") {
    print(bin)
}

