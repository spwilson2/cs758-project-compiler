package main

// #include <stdio.h>
// typedef int (*intFunc) ();
//
// int
// bridge_int_func()
// {
//		/*printf("Compiler works for cgo!\n");*/
//		return 42;
// }
import "C"
import "fmt"

func main() {
	if 42 != int(C.bridge_int_func()) {
		fmt.Println("Broken for cgo! :(")
	}
}
