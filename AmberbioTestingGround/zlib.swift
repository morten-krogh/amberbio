import Foundation

func gunzip(data data: NSData) -> NSData? {

        let bytes = UnsafePointer<Int8>(data.bytes)

        var output_size = 0

        let output_bytes = gunzip(bytes, data.length, &output_size)

        print(output_size)


        return nil
}
