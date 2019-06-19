package main

import (
    "net/http"
    "io/ioutil"
    "os"
    "sync/atomic"

    "github.com/fatih/color"
    "log"
    "time"
    "os/signal"
)

type HttpSinkHandler struct {}

var color1 = color.New(color.FgRed, color.Bold)
var color2 = color.New(color.FgBlue, color.Bold)
var bold = color.New(color.Bold)

var counter uint64 = 0

func (h *HttpSinkHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
    w.Write([]byte("OK"))

    body, _ := ioutil.ReadAll(r.Body)

    log.Printf(
        "%s %s %s %s",
        color1.Sprintf("%d.", atomic.AddUint64(&counter, 1)),
        bold.Sprintf("%s %s %s", r.Method, r.URL, r.Proto),
        color2.Sprint("Body:"),
        bold.Sprint(string(body)),
    )

    if r.Method == "RESET" {
        atomic.StoreUint64(&counter, 0)
    }
}

func main() {
    log.SetFlags(log.Ltime | log.Lmicroseconds)

    go func() {
        sigchan := make(chan os.Signal, 1)
        signal.Notify(sigchan, os.Interrupt)
        signal.Notify(sigchan, os.Kill)

        <-sigchan

        log.Println("httpsink exits")

        os.Exit(0)
    }()

    var port string
    var exists bool

    if port, exists = os.LookupEnv("PORT"); !exists {
        port = "12345"
    }

    hostname, _ := os.Hostname()

    log.Printf(
        "%s listening to %s",
        color1.Sprint("httpsink"),
        bold.Sprintf("http://%s:%s", hostname, port),
    )

    httpSinkServer := &http.Server{
        Addr: ":" + port,
        Handler: &HttpSinkHandler{},
        ReadHeaderTimeout: 3 * time.Second,
        ReadTimeout: 10 * time.Second,
        WriteTimeout: 10 * time.Second,
        IdleTimeout: 30 * time.Second,
    }

    err := httpSinkServer.ListenAndServe()

    if err != nil {
        log.Printf("error while running http sink server: %s", err.Error())
        os.Exit(1)
    }
}
