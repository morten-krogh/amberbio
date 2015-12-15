import Foundation

func gunzip(data data: NSData) -> NSData? {

        let bytes = UnsafePointer<Int8>(data.bytes)
        var output_size = 0 as CInt
        let output_bytes = gunzip(bytes, CInt(data.length), &output_size)

        if output_bytes == nil {
                return nil
        } else {
                return NSData(bytes: output_bytes, length: Int(output_size))
        }
}
