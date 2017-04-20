package main

import (
	"flag"
	"fmt"
	"log"
	"net"
	"net/http"
	"os"
)

func main() {
	log.SetFlags(0)

	var listenAddress = flag.String("listen", ":8888", "Listen address.")

	flag.Parse()

	if flag.NArg() != 0 {
		flag.Usage()
		log.Fatalf("\nERROR You MUST NOT pass any positional arguments")
	}

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Printf("%s %s%s\n", r.Method, r.Host, r.URL)
		fmt.Fprintf(
			w,
			`Hello World!

HTTP Request: %s %s%s
Server IP address: %s
Client IP address: %s
Environment Variables:
`,
			r.Method,
			r.Host,
			r.URL,
			r.Context().Value(http.LocalAddrContextKey).(net.Addr).String(),
			r.RemoteAddr)
		for _, e := range os.Environ() {
			fmt.Fprintln(w, e)
		}
	})

	fmt.Printf("Listening at http://%s\n", *listenAddress)

	err := http.ListenAndServe(*listenAddress, nil)
	if err != nil {
		log.Fatalf("Failed to ListenAndServe: %v", err)
	}
}
