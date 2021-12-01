package main

import (
	"crypto/subtle"
	"github.com/explabs/prometheus-manager/routers"
	"net/http"
	"os"
)

func BasicAuth(handler http.HandlerFunc, username, password, realm string) http.HandlerFunc {

	return func(w http.ResponseWriter, r *http.Request) {

		user, pass, ok := r.BasicAuth()

		if !ok || subtle.ConstantTimeCompare([]byte(user), []byte(username)) != 1 || subtle.ConstantTimeCompare([]byte(pass), []byte(password)) != 1 {
			w.Header().Set("WWW-Authenticate", `Basic realm="`+realm+`"`)
			w.WriteHeader(401)
			w.Write([]byte("Unauthorised.\n"))
			return
		}

		handler(w, r)
	}
}

func main() {
	username := "admin"
	password := os.Getenv("ADMIN_PASS")
	http.HandleFunc("/start", BasicAuth(routers.StartContainer, username, password, ""))
	http.HandleFunc("/stop", BasicAuth(routers.StopContainer, username, password, ""))
	http.HandleFunc("/generate", BasicAuth(routers.GenerateConfigHandler, username, password, ""))
	http.ListenAndServe(":9091", nil)
}
