#import "Basic";

foo :: () -> int {
    debug_break();
    return 0;
}

main :: () {
    print("Hello, Static Sailor\n");
    a := foo();
}
