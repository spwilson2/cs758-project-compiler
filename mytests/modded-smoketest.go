package main

import (
	"fmt"
	"os"
	"syscall"
)

func main() {
	if syscall.Echo("Hello") == "Hello" {
		fmt.Printf("(OK) %s\n", os.Args[0])
		os.Exit(0)
	} else {
		fmt.Printf("(FAILED) %s\n", os.Args[0])
		os.Exit(1)
	}
}
