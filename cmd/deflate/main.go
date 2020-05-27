package main

import (
	"bufio"
	"compress/flate"
	"flag"
	"log"
	"os"
)

var (
	infile  = flag.String("f", "", "输入文件")
	outfile = flag.String("o", "", "输出文件")
)

func main() {
	flag.Parse()
	if *outfile == "" {
		*outfile = *infile + ".flate"
	}
	file, err := os.Open(*infile)
	if err != nil {
		log.Fatalln(err)
		return
	}
	defer file.Close()
	fileinfo, err := file.Stat()
	if err != nil {
		log.Fatalln(err)
		return
	}
	var fileReader *bufio.Reader
	if fileinfo.Size() <= 4096 {
		fileReader = bufio.NewReader(file)
	} else {
		fileReader = bufio.NewReaderSize(file, 1024*1024)
	}

	fileWriter, err := os.Create(*outfile)
	if err != nil {
		log.Fatalln(err)
		return
	}
	defer fileWriter.Close()

	flateWrite, err := flate.NewWriter(fileWriter, flate.BestCompression)
	if err != nil {
		log.Fatalln(err)
		return
	}
	defer flateWrite.Close()
	fileReader.WriteTo(flateWrite)
	flateWrite.Flush()
}
