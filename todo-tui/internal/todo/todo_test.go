package todo

import (
	"os"
	"path/filepath"
	"testing"
)

func writeFile(t *testing.T, content string) string {
	t.Helper()
	path := filepath.Join(t.TempDir(), "TODO.md")
	if err := os.WriteFile(path, []byte(content), 0o644); err != nil {
		t.Fatal(err)
	}
	return path
}

func readFile(t *testing.T, path string) string {
	t.Helper()
	data, err := os.ReadFile(path)
	if err != nil {
		t.Fatal(err)
	}
	return string(data)
}

func TestParseFile(t *testing.T) {
	path := writeFile(t, "# TODO\n"+
		"- [ ] one <!-- created_at 29.08.2026 -->\n"+
		"not an item\n"+
		"- [ ] two\n"+
		"- [x] done <!-- created_at 01.01.2026 --> <!-- closed_at 02.01.2026 -->\n"+
		"\n## DONE\n"+
		"- [x] old\n")

	items, err := ParseFile(path)
	if err != nil {
		t.Fatal(err)
	}
	if len(items) != 2 {
		t.Fatalf("want 2 items, got %d", len(items))
	}
	if items[0].Line != 2 || items[0].Text != "one" {
		t.Errorf("items[0] = %+v, want line 2 text one", items[0])
	}
	if items[1].Line != 4 || items[1].Text != "two" {
		t.Errorf("items[1] = %+v, want line 4 text two", items[1])
	}
}

func TestMarkDone(t *testing.T) {
	old := Today
	Today = func() string { return "01.02.2026" }
	defer func() { Today = old }()

	path := writeFile(t, "# TODO\n"+
		"- [ ] first <!-- created_at 29.08.2026 -->\n"+
		"- [ ] second\n"+
		"\n## DONE\n"+
		"- [x] old <!-- closed_at 03.03.2026 -->\n")

	if err := MarkDone(path, 3); err != nil {
		t.Fatal(err)
	}

	want := "# TODO\n" +
		"- [ ] first <!-- created_at 29.08.2026 -->\n" +
		"\n## DONE\n" +
		"- [x] second <!-- closed_at 01.02.2026 -->\n" +
		"- [x] old <!-- closed_at 03.03.2026 -->\n"
	if got := readFile(t, path); got != want {
		t.Errorf("MarkDone result:\n%q\nwant:\n%q", got, want)
	}
}

func TestMarkDoneWithoutDoneSection(t *testing.T) {
	old := Today
	Today = func() string { return "01.02.2026" }
	defer func() { Today = old }()

	path := writeFile(t, "# TODO\n- [ ] only\n")
	if err := MarkDone(path, 2); err != nil {
		t.Fatal(err)
	}

	want := "# TODO\n- [x] only <!-- closed_at 01.02.2026 -->\n"
	if got := readFile(t, path); got != want {
		t.Errorf("MarkDone result:\n%q\nwant:\n%q", got, want)
	}
}

func TestMarkDoneRejectsNonOpen(t *testing.T) {
	path := writeFile(t, "# TODO\n- [x] done\n\n## DONE\n")
	if err := MarkDone(path, 2); err == nil {
		t.Error("want error for done line")
	}
	if err := MarkDone(path, 99); err == nil {
		t.Error("want error for out-of-range line")
	}
}

func TestEnsureCreatesBootstrap(t *testing.T) {
	path := filepath.Join(t.TempDir(), "sub", "TODO.md")
	if err := Ensure(path); err != nil {
		t.Fatal(err)
	}
	if got := readFile(t, path); got != "# TODO\n\n## DONE\n" {
		t.Errorf("Ensure result: %q", got)
	}
}

func TestEnsureEmptyFile(t *testing.T) {
	path := writeFile(t, "")
	if err := Ensure(path); err != nil {
		t.Fatal(err)
	}
	if got := readFile(t, path); got != "# TODO\n\n## DONE\n" {
		t.Errorf("Ensure result: %q", got)
	}
}

func TestEnsurePrependsHeaderAndAppendsDone(t *testing.T) {
	path := writeFile(t, "- [ ] one\n")
	if err := Ensure(path); err != nil {
		t.Fatal(err)
	}
	want := "# TODO\n\n- [ ] one\n\n## DONE\n"
	if got := readFile(t, path); got != want {
		t.Errorf("Ensure result:\n%q\nwant:\n%q", got, want)
	}
}

func TestEnsureNoop(t *testing.T) {
	content := "# TODO\n\n- [ ] x\n\n## DONE\n"
	path := writeFile(t, content)
	if err := Ensure(path); err != nil {
		t.Fatal(err)
	}
	if got := readFile(t, path); got != content {
		t.Errorf("Ensure changed content:\n%q\nwant:\n%q", got, content)
	}
}
