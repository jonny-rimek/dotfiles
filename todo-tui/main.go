package main

import (
	"flag"
	"fmt"
	"os"

	tea "github.com/charmbracelet/bubbletea"

	"todo-tui/internal/clip"
	"todo-tui/internal/todo"
	"todo-tui/internal/tui"
)

func main() {
	file := flag.String("file", "", "single TODO file to browse")
	all := flag.Bool("all", false, "browse all TODO files (system + ~/dev scan)")
	flag.Parse()

	var files []string
	switch {
	case *file != "":
		if err := todo.Ensure(*file); err != nil {
			fatal(err)
		}
		files = []string{*file}
	case *all:
		files = todo.AllFiles()
	default:
		fmt.Fprintln(os.Stderr, "todo-tui: pass --file PATH or --all")
		os.Exit(2)
	}

	p := tea.NewProgram(tui.New(files), tea.WithAltScreen())
	out, err := p.Run()
	if err != nil {
		fatal(err)
	}
	if m, ok := out.(tui.Model); ok {
		if it := m.Selected(); it != nil {
			if err := clip.Copy(it.Text); err != nil {
				fatal(err)
			}
		}
	}
}

func fatal(err error) {
	fmt.Fprintln(os.Stderr, "todo-tui:", err)
	os.Exit(1)
}
