package main

// package main must be the first thing in this program for the test to work.

import "fmt"
import "os"
import "syscall"
import "reflect"
import "unsafe"

var testfile string = "modded-aio-simple.go"

const BUFSIZE int = 64
const (
	IO_CMD_PREAD  = syscall.IOCB_CMD_PREAD
	IO_CMD_PWRITE = syscall.IOCB_CMD_PWRITE
	IO_CMD_FSYNC  = syscall.IOCB_CMD_FSYNC
	IO_CMD_FDSYNC = syscall.IOCB_CMD_FDSYNC
	/*
	* These two are experimental.
	* IO_CMD_PREAD  = syscall.IOCB_CMD_PREAD
	* IO_CMD_POLL   = syscall.IOCB_CMD_POLL
	 */
	IO_CMD_NOOP    = syscall.IOCB_CMD_NOOP
	IO_CMD_PREADV  = syscall.IOCB_CMD_PREADV
	IO_CMD_PWRITEV = syscall.IOCB_CMD_PWRITEV
)

func cleanup(ctx syscall.AioContext_t) {
	if err := syscall.IoDestroy(ctx); err != nil {
		fmt.Printf("(FAILED) %s\n", os.Args[0])
		os.Exit(-1)
	}
}

func print_fields(iocb syscall.Iocb) {
	s := reflect.ValueOf(&iocb).Elem()
	typeOfT := s.Type()

	for i := 0; i < s.NumField(); i++ {
		f := s.Field(i)
		fmt.Printf("%d: %s %s = %v\n", i,
			typeOfT.Field(i).Name, f.Type(), f.Interface())
	}
}

// Look at
// https://git.fedorahosted.org/cgit/libaio.git/tree/src/libaio.h
// for implementations of these helpers.
//
func io_prep_pread(iocb *syscall.Iocb, fd int, buf []byte, count int, offset uint) {

	// TODO: Clear out the iocb
	// memset(iocb, 0, sizeof(*iocb));

	iocb.Fildes = uint32(fd)
	iocb.Lio_opcode = IO_CMD_PREAD
	iocb.Reqprio = 0
	iocb.Buf = uint64(uintptr(unsafe.Pointer(&buf[0])))
	iocb.Nbytes = uint64(count)
	iocb.Offset = int64(offset)

}

func main() {

	var ctx syscall.AioContext_t
	ctx = 0

	var err error

	if err = syscall.IoSetup(128, &ctx); err != nil {
		fmt.Printf("(FAILED) %s\n", os.Args[0])
		os.Exit(-1)
	}
	defer cleanup(ctx)

	fd, err := syscall.Open(testfile, syscall.O_RDONLY, 0)
	if err != nil {
		fmt.Printf("(FAILED) %s\n", os.Args[0])
		os.Exit(-1)
	}
	_ = fd

	var iocb syscall.Iocb
	iocbp := &iocb
	buffer := make([]byte, BUFSIZE, BUFSIZE)
	_ = buffer

	// (len - 1  since we need to store null byte)
	io_prep_pread(iocbp, fd, buffer, len(buffer)-1, 0)

	err = syscall.IoSubmit(ctx, 1, &iocbp)
	if err != nil {
		fmt.Printf("(FAILED) %s\n", os.Args[0])
		os.Exit(-1)
	}

	var event syscall.IoEvent
	var timeout syscall.Timespec
	timeout.Sec = 10

	events := syscall.IoGetevents(ctx, 1, 1, &event, &timeout)
	if events == 0 {
		fmt.Printf("(FAILED) %s\n", os.Args[0])
		os.Exit(-1)
	} else if events < 0 {
		fmt.Printf("(FAILED) %s\n", os.Args[0])
		os.Exit(-1)
	}

	// Check the result..
	valid_string := "package main"

	if string(buffer[0:len(valid_string)]) == valid_string {
		fmt.Printf("(OK) %s\n", os.Args[0])
	} else {
		fmt.Printf("(FAILED) %s\n", os.Args[0])
		os.Exit(-1)
	}

}
