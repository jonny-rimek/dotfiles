package todo

import (
	"fmt"
	"io/fs"
	"os"
	"path/filepath"
	"regexp"
	"sort"
	"strings"
	"time"
)

var Today = func() string { return time.Now().Format("02.01.2006") }

type Item struct {
	File      string
	Line      int
	Text      string
	CreatedAt time.Time
}

var commentRe = regexp.MustCompile(`<!--[^>]*-->`)
var createdAtRe = regexp.MustCompile(`created_at (\d{2}\.\d{2}\.\d{4})`)

func displayText(raw string) string {
	return strings.TrimSpace(commentRe.ReplaceAllString(raw, " "))
}

func parseCreatedAt(raw string) time.Time {
	m := createdAtRe.FindStringSubmatch(raw)
	if m == nil {
		return time.Time{}
	}
	t, err := time.Parse("02.01.2006", m[1])
	if err != nil {
		return time.Time{}
	}
	return t
}

func ParseFile(path string) ([]Item, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}
	var items []Item
	for i, line := range strings.Split(string(data), "\n") {
		if strings.HasPrefix(line, "- [ ] ") {
			items = append(items, Item{
				File:      path,
				Line:      i + 1,
				Text:      displayText(strings.TrimPrefix(line, "- [ ] ")),
				CreatedAt: parseCreatedAt(line),
			})
		}
	}
	sort.SliceStable(items, func(i, j int) bool {
		return items[i].CreatedAt.Before(items[j].CreatedAt)
	})
	return items, nil
}

func WriteFileAtomic(path, content string) error {
	dir := filepath.Dir(path)
	tmp, err := os.CreateTemp(dir, filepath.Base(path)+".XXXXXX")
	if err != nil {
		return err
	}
	tmpName := tmp.Name()
	if _, err := tmp.WriteString(content); err != nil {
		tmp.Close()
		os.Remove(tmpName)
		return err
	}
	if err := tmp.Close(); err != nil {
		os.Remove(tmpName)
		return err
	}
	if err := os.Chmod(tmpName, 0o644); err != nil {
		os.Remove(tmpName)
		return err
	}
	if err := os.Rename(tmpName, path); err != nil {
		os.Remove(tmpName)
		return err
	}
	return nil
}

func hasHeader(content, header string) bool {
	for _, line := range strings.Split(content, "\n") {
		if strings.HasPrefix(line, header) {
			return true
		}
	}
	return false
}

func Ensure(path string) error {
	data, err := os.ReadFile(path)
	if err == nil {
		content := string(data)
		if strings.TrimSpace(content) == "" {
			return WriteFileAtomic(path, "# TODO\n\n## DONE\n")
		}
		out := content
		changed := false
		if !hasHeader(out, "# TODO") {
			out = "# TODO\n\n" + out
			changed = true
		}
		if !hasHeader(out, "## DONE") {
			if !strings.HasSuffix(out, "\n") {
				out += "\n"
			}
			out += "\n## DONE\n"
			changed = true
		}
		if changed {
			return WriteFileAtomic(path, out)
		}
		return nil
	}
	if !os.IsNotExist(err) {
		return err
	}
	if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
		return err
	}
	return WriteFileAtomic(path, "# TODO\n\n## DONE\n")
}

func MarkDone(path string, lineno int) error {
	data, err := os.ReadFile(path)
	if err != nil {
		return err
	}
	lines := strings.Split(string(data), "\n")
	if lineno < 1 || lineno > len(lines) {
		return fmt.Errorf("line %d out of range in %s", lineno, path)
	}
	target := lines[lineno-1]
	if !strings.HasPrefix(target, "- [ ] ") {
		return fmt.Errorf("line %d is not an open todo in %s", lineno, path)
	}
	done := "- [x] " + strings.TrimPrefix(target, "- [ ] ") + " <!-- closed_at " + Today() + " -->"
	if n := len(lines); n > 0 && lines[n-1] == "" {
		lines = lines[:n-1]
	}
	var b strings.Builder
	inserted := false
	for i, line := range lines {
		if i+1 == lineno {
			continue
		}
		b.WriteString(line)
		b.WriteString("\n")
		if !inserted && strings.HasPrefix(line, "## DONE") {
			b.WriteString(done)
			b.WriteString("\n")
			inserted = true
		}
	}
	if !inserted {
		b.WriteString(done)
		b.WriteString("\n")
	}
	return WriteFileAtomic(path, b.String())
}

func ScanDev() []string {
	home, err := os.UserHomeDir()
	if err != nil {
		return nil
	}
	root := filepath.Join(home, "dev")
	var out []string
	_ = filepath.WalkDir(root, func(p string, d fs.DirEntry, err error) error {
		if err != nil {
			return nil
		}
		rel, rerr := filepath.Rel(root, p)
		depth := 0
		if rerr == nil && p != root {
			depth = strings.Count(rel, string(filepath.Separator)) + 1
		}
		if d.IsDir() {
			if depth >= 3 {
				return fs.SkipDir
			}
			return nil
		}
		if d.Name() == "TODO.md" && depth <= 3 {
			out = append(out, p)
		}
		return nil
	})
	return out
}

func AllFiles() []string {
	home, err := os.UserHomeDir()
	if err != nil {
		return nil
	}
	sys := filepath.Join(home, "TODO.md")
	var files []string
	if _, err := os.Stat(sys); err == nil {
		files = append(files, sys)
	}
	for _, f := range ScanDev() {
		if f != sys {
			files = append(files, f)
		}
	}
	return files
}
