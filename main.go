package main

import (
	"encoding/json"
	"flag"
	"log"
	"os"
	"regexp"
	"text/template"
)

var functions = template.FuncMap{
	"match": func(pattern string, source string) (bool, error) {
		return regexp.MatchString(pattern, source)
	},
	"replace": func(pattern string, replacement string, source string) string {
		return regexp.MustCompile(pattern).ReplaceAllString(source, replacement)
	},
}

func main() {
	var data string
	var text string

	flag.StringVar(&data, "data", "{}", "The data passed to the template")
	flag.StringVar(&text, "text", "", "The text template to execute")
	flag.Parse()

	var d any
	if err := json.Unmarshal([]byte(data), &d); err != nil {
		log.Fatal(err)
	}

	t, err := template.New("").Funcs(functions).Parse(text)
	if err != nil {
		log.Fatal(err)
	}

	if err := t.Execute(os.Stdout, d); err != nil {
		log.Fatal(err)
	}
}
