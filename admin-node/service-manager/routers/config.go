package routers

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"

	"gopkg.in/yaml.v2"
)

type PrometheusConfig struct {
	Global struct {
		ScrapeInterval     string `yaml:"scrape_interval"`
		ScrapeTimeout      string `yaml:"scrape_timeout"`
		EvaluationInterval string `yaml:"evaluation_interval"`
	} `yaml:"global"`
	ScrapeConfigs []ScrapeConfigs `yaml:"scrape_configs"`
}
type StaticConfigs struct {
	Targets []string `yaml:"targets"`
}

type BasicAuth struct {
	Username string `yaml:"username"`
	Password string `yaml:"password"`
}

type ScrapeConfigs struct {
	JobName        string          `yaml:"job_name"`
	MetricsPath    string          `yaml:"metrics_path,omitempty"`
	ScrapeInterval string          `yaml:"scrape_interval,omitempty"`
	ScrapeTimeout  string          `yaml:"scrape_timeout,omitempty"`
	StaticConfigs  []StaticConfigs `yaml:"static_configs"`
	BasicAuth      BasicAuth       `yaml:"basic_auth,omitempty"`
}
type Jobs struct {
	Jobs     []JsonData `json:"jobs"`
	Password string     `json:"password"`
	Target   string     `json:"target"`
	Interval string     `json:"interval"`
	Timeout  string     `json:"timeout"`
}
type JsonData struct {
	Name     string `json:"name"`
	Path     string `json:"path"`
	Interval string `json:"interval"`
}

// curl -u admin:admin -H "Content-Type: application/json" --data '{ "password": "test", "target": "192.168.100.105:8080", "interval": "30s", "timeout": "10s", "jobs": [{"name": "checker", "path": "api/v1/game/checker"}]}' http://localhost:9091/generate

func (j *Jobs) ConvertToYml() error {
	var p PrometheusConfig
	p.Global.ScrapeInterval = j.Interval
	p.Global.ScrapeTimeout = j.Timeout
	p.Global.EvaluationInterval = j.Interval
	targets := StaticConfigs{Targets: []string{j.Target}}
	auth := BasicAuth{"checker", j.Password}

	for _, job := range j.Jobs {
		scrapeConfig := ScrapeConfigs{
			JobName:        job.Name,
			MetricsPath:    job.Path,
			ScrapeInterval: job.Interval,
			ScrapeTimeout:  j.Timeout,
			StaticConfigs:  []StaticConfigs{targets},
			BasicAuth:      auth,
		}
		p.ScrapeConfigs = append(p.ScrapeConfigs, scrapeConfig)
	}
	p.GenerateConfig(DestConfigPath)
	return nil
}

func (p *PrometheusConfig) GenerateConfig(filepath string) error {
	fmt.Println(filepath, p)
	data, err := yaml.Marshal(&p)

	if err != nil {
		log.Fatal(err)
	}

	err2 := ioutil.WriteFile(filepath, data, 0644)

	if err2 != nil {
		log.Fatal(err2)
	}

	fmt.Println("data written")
	return nil
}

func GenerateConfigHandler(w http.ResponseWriter, r *http.Request) {

	var data Jobs
	err := json.NewDecoder(r.Body).Decode(&data)
	if err != nil {
		panic(err)
	}
	fmt.Println(data)
	data.ConvertToYml()
}
