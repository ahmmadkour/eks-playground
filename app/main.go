package main

import (
	"fmt"
	"log"
	"net/http"
)

func main() {
	http.HandleFunc("/", HelloServer)
	err := http.ListenAndServe(":8080", nil)
	if err != nil {
		log.Fatalf("can't listen to port :8080; err: %v", err)
	}
}

func HelloServer(w http.ResponseWriter, r *http.Request) {
	log.Printf("%s %s %s %s", r.Method, r.URL.Path, r.RemoteAddr, r.UserAgent())
	fmt.Fprintf(w, "Hello, World!")
}
