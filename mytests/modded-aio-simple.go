package main

import "fmt"
import "os"
import "syscall"
import _ "unsafe"

var testfile string = "modded-aio-simple.go"

const BUFSIZE int = 55

func cleanup(ctx syscall.AioContext_t) {
	if err := syscall.IoDestroy(ctx); err != nil {
		fmt.Printf("(FAILED) %s\n", os.Args[0])
		os.Exit(-1)
	}
}

// TODO: Up to Ricky to implement this sort of thing - look at
//
// https://git.fedorahosted.org/cgit/libaio.git/tree/src/libaio.h
// for implementations of these helpers.
//
//func io_prep_pread(iocb *syscall.Iocb, fd int, buf unsafe.Pointer, count uintptr, offset uint64)
//{
//	// TODO: Clear out the iocb
//	// memset(iocb, 0, sizeof(*iocb));
//
//	iocb.aio_fildes = fd;
//	iocb.aio_lio_opcode = syscall.IO_CMD_PREAD;
//	iocb.aio_reqprio = 0;
//	iocb.buf = buf;
//	iocb.nbytes = count;
//	iocb.offset = offset;
//}

func main() {

	var ctx syscall.AioContext_t
	ctx = 0

	var err error

	if err = syscall.IoSetup(128, &ctx); err != nil {
		fmt.Printf("(FAILED) %s\n", os.Args[0])
		os.Exit(-1)
	}
	defer cleanup(ctx)

	//TODO: Up to ricky to test this sort of thing.
	//fd, err := syscall.Open(testfile)
	//if err != nil {
	//	fmt.Printf("(FAILED) %s\n", os.Args[0])
	//	os.Exit(-1)
	//}

	//var iocb syscall.Iocb
	//_ = iocb

	fmt.Printf("(OK) %s\n", os.Args[0])
}
