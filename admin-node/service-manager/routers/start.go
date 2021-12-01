package routers

import (
	"context"
	"fmt"
	"github.com/docker/docker/api/types"
	"github.com/docker/docker/api/types/container"
	"github.com/docker/docker/api/types/mount"
	"github.com/docker/docker/client"
	"github.com/docker/go-connections/nat"
	"io"
	"net/http"
	"os"
	"path"
)

var DestConfigPath = "/etc/prometheus/prometheus.yml"
var DestDataPath = "/data"

func StartContainer(w http.ResponseWriter, r *http.Request) {
	ctx := context.Background()
	cli, err := client.NewClientWithOpts(client.FromEnv, client.WithAPIVersionNegotiation())
	if err != nil {
		panic(err)
	}

	imageName := "prom/prometheus"

	out, err := cli.ImagePull(ctx, imageName, types.ImagePullOptions{})
	if err != nil {
		panic(err)
	}
	io.Copy(os.Stdout, out)
	pwd := os.Getenv("HOST_PWD")
	sourceConfigPath := path.Join(pwd, os.Getenv("CONFIG"))

	sourceDataPath := path.Join(pwd, os.Getenv("DATA"))

	resp, err := cli.ContainerCreate(ctx, &container.Config{
		Image: imageName,
	}, &container.HostConfig{
		Mounts: []mount.Mount{
			{
				Type:   mount.TypeBind,
				Source: sourceConfigPath,
				Target: DestConfigPath,
			},
			{
				Type:   mount.TypeBind,
				Source: sourceDataPath,
				Target: DestDataPath,
			},
		},
		AutoRemove: true,
		PortBindings: nat.PortMap{
			nat.Port("9090/tcp"): []nat.PortBinding{{HostPort: "9090"}},
		},
	}, nil, nil, "prometheus")
	if err != nil {
		panic(err)
	}

	if err := cli.ContainerStart(ctx, resp.ID, types.ContainerStartOptions{}); err != nil {
		panic(err)
	}

	fmt.Fprintf(w, "promtheus id: %s\n", resp.ID)
}
