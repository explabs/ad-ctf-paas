package routers

import (
	"context"
	"fmt"
	"github.com/docker/docker/client"
	"net/http"
)

func StopContainer(w http.ResponseWriter, r *http.Request) {
	ctx := context.Background()
	cli, err := client.NewClientWithOpts(client.FromEnv, client.WithAPIVersionNegotiation())
	if err != nil {
		panic(err)
	}

	containerName := "prometheus"
	if err := cli.ContainerStop(ctx, containerName, nil); err != nil {
		fmt.Fprintf(w, "Unable to stop container %s: %s", containerName, err)
	}
	fmt.Fprintf(w, "prometheus stopped\n")
}
