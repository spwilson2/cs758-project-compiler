package main

import "fmt"
import "os"
import "syscall"

func main() {
	var i syscall.Iocb
	syscall.IoSubmit(&i)
	fmt.Printf("(OK) %s\n", os.Args[0])
}
