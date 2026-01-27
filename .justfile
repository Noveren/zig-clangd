build sub:
    cd example/{{sub}} && zig build -p build -Dcompdb

export sub *args:
    cd example/{{sub}} && zig build export {{args}}
