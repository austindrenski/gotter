# gotter

> ## gotter
> ___got·ter___
> <br>
> _/ˈä-tər /_
> <br>
> ___noun___
>
> 1. _<b><u>Go</u></b> <b><u>T</u></b>ext <b><u>T</u></b>emplat<b><u>er</u></b>_
>    > *"The Go Text Templater is just a repackaging of the Go `text/template` package."*
> 2. The past-tense of _getter_; see [_getter_](https://youtu.be/dQw4w9WgXcQ)

## Getting Started

### Build from source

```shell
docker buildx bake https://github.com/austindrenski/gotter.git#refs/heads/main
```

### Run as a container

```shell
docker run --rm ghcr.io/austindrenski/gotter -text "Hello, {{ .Name }}!" -data '{ "Name": "world" }'
```
