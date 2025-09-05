package main

import (
	"context"
	"encoding/json"
	"flag"
	"fmt"
	"log"
	"os"

	"go.austindrenski.io/gotter/templates"
	"go.austindrenski.io/gotter/utils"

	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/codes"
)

const scopeName = "go.austindrenski.io/gotter"

func main() {
	ctx := context.Background()

	end := utils.Start(ctx)
	defer end(ctx)

	ctx, span := otel.Tracer(scopeName).Start(ctx, "main")
	defer span.End()

	var data string
	var name string
	var text string
	var version bool

	flag.StringVar(&data, "data", "", "The JSON data passed to the template")
	flag.StringVar(&name, "name", "", "An optional name for the template")
	flag.StringVar(&text, "text", "", "The Go text template to execute")
	flag.BoolVar(&version, "version", false, "Print version information and quit")
	flag.Parse()

	if version {
		fmt.Printf("gotter version %s, build %s\n", utils.OTEL_VCS_REF_HEAD_NAME, utils.OTEL_VCS_REF_HEAD_REVISION)
		return
	}

	var d any
	if len(data) == 0 {
		d = nil
	} else if err := json.Unmarshal([]byte(data), &d); err != nil {
		span.RecordError(err)
		span.SetStatus(codes.Error, "failed to unmarshall data as JSON")
		log.Fatal(err)
	}

	if t, err := templates.Parse(ctx, name, text, templates.WithFuncs(templates.Functions)); err != nil {
		span.RecordError(err)
		span.SetStatus(codes.Error, "failed to parse template")
		log.Fatal(err)
	} else if err := templates.Execute(ctx, t, d, os.Stdout); err != nil {
		span.RecordError(err)
		span.SetStatus(codes.Error, "failed to execute template")
		log.Fatal(err)
	}
}
