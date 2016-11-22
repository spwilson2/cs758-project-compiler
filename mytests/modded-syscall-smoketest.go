package main

import "fmt"
import "os"
import "syscall"

func main() {
	if syscall.Nothing() == 1 {
		fmt.Printf("(OK) %s\n", os.Args[0])
		os.Exit(0)
	} else {
		fmt.Printf("(FAILED) %s\n", os.Args[0])
		os.Exit(1)
	}
}
