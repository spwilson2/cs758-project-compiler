package main

// #include <stdio.h>
// typedef int (*intFunc) ();
//
// int
// bridge_int_func(intFunc f)
// {
//		printf("Compiler works for cgo!\n");
//		return f();
// }
//
// int fortytwo()
// {
//	    return 42;
// }
import "C"
import "fmt"

func main() {
	f := C.intFunc(C.fortytwo)
	if 42 != int(C.bridge_int_func(f)) {
		fmt.Println("Broken for cgo! :(")
	}
}
