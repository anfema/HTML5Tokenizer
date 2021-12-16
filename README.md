# HTML5Tokenizer

HTML5 compliant tokenizer in pure swift. Only UTF-8 charset is supported.

## Requirements

- iOS 13.0+ / macOS 11.0+
- Xcode 13.1+
- Swift 5.5+

## Note

For Swift 2.2 or 2.3 support, use Tags < 2.0.0
For Swift 4 support, use Tags < 4.0.0
 
## Unsupported

- DOCTYPE is parsed as bogus comment
- Script and raw text (style tags) are not supported (wrap them in <![CDATA[ ]]> to use them)
- Tree generation phase is not implemented (no javascript execution)
- Compound named character entities are missing
