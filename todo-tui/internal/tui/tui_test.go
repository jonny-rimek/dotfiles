package tui

import (
	"os"
	"path/filepath"
	"regexp"
	"strings"
	"testing"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
	"github.com/muesli/termenv"
)

var ansiRe = regexp.MustCompile(`\x1b\[[0-9;]*m`)

func stripANSI(s string) string { return ansiRe.ReplaceAllString(s, "") }

func writeTODO(t *testing.T, content string) []string {
	t.Helper()
	path := filepath.Join(t.TempDir(), "TODO.md")
	if err := os.WriteFile(path, []byte(content), 0o644); err != nil {
		t.Fatal(err)
	}
	return []string{path}
}

func typeRunes(m Model, s string) Model {
	nm, _ := m.Update(tea.KeyMsg{Type: tea.KeyRunes, Runes: []rune(s)})
	return nm.(Model)
}

func pressDown(m Model) Model {
	nm, _ := m.Update(tea.KeyMsg{Type: tea.KeyDown})
	return nm.(Model)
}

func pressTab(m Model) Model {
	nm, _ := m.Update(tea.KeyMsg{Type: tea.KeyTab})
	return nm.(Model)
}

func resize(m Model, w, h int) Model {
	nm, _ := m.Update(tea.WindowSizeMsg{Width: w, Height: h})
	return nm.(Model)
}

func TestStatusBarShowsInsertMode(t *testing.T) {
	m := resize(New(nil), 80, 10)
	view := m.View()
	if !strings.Contains(view, "-- INSERT --") {
		t.Errorf("view should show INSERT mode, got:\n%s", view)
	}
	if !strings.Contains(view, "Esc normal") {
		t.Errorf("insert hints missing, got:\n%s", view)
	}
}

func TestStatusBarShowsNormalMode(t *testing.T) {
	m := resize(New(nil), 80, 10)
	nm, _ := m.Update(tea.KeyMsg{Type: tea.KeyEsc})
	m2 := nm.(Model)
	view := m2.View()
	if !strings.Contains(view, "-- NORMAL --") {
		t.Errorf("view should show NORMAL mode, got:\n%s", view)
	}
	if !strings.Contains(view, "i insert") {
		t.Errorf("normal hints missing, got:\n%s", view)
	}
}

func TestStatusBarNarrowWidth(t *testing.T) {
	m := resize(New(nil), 30, 10)
	view := m.View()
	if !strings.Contains(view, "-- INSERT --") {
		t.Errorf("mode label should survive narrow width, got:\n%s", view)
	}
	if strings.Contains(view, "Enter copy") {
		t.Errorf("full hints should be dropped on narrow width, got:\n%s", view)
	}
}

func TestSearchResetsSelectionToFirst(t *testing.T) {
	files := writeTODO(t, "# TODO\n- [ ] alpha\n- [ ] beta\n- [ ] gamma\n- [ ] alphabet\n\n## DONE\n")
	m := resize(New(files), 80, 12)
	if m.current() == nil || m.current().Text != "alpha" {
		t.Fatalf("initial selection = %v, want alpha", m.current())
	}
	for i := 0; i < 3; i++ {
		m = pressDown(m)
	}
	if m.current().Text != "alphabet" {
		t.Fatalf("after moving selection = %v, want alphabet", m.current())
	}
	m = typeRunes(m, "a")
	if m.sel != 0 {
		t.Errorf("selection index = %d, want 0 after query change", m.sel)
	}
	if m.rows[0].item == nil {
		t.Errorf("first filtered row should be an item, got header")
	}
}

func TestSingleFileModeHasNoHeaderRows(t *testing.T) {
	files := writeTODO(t, "# TODO\n- [ ] alpha\n- [ ] beta\n\n## DONE\n")
	m := resize(New(files), 80, 12)
	for _, r := range m.rows {
		if r.header != "" {
			t.Errorf("single-file mode should not render header rows, got %q", r.header)
		}
	}
	if m.current() == nil || m.current().Text != "alpha" {
		t.Errorf("first item should be selected, got %v", m.current())
	}
}

func TestTabTogglesAllView(t *testing.T) {
	files := writeTODO(t, "# TODO\n- [ ] alpha\n- [ ] beta\n\n## DONE\n")
	other := filepath.Join(t.TempDir(), "other", "TODO.md")
	if err := os.MkdirAll(filepath.Dir(other), 0o755); err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(other, []byte("# TODO\n- [ ] gamma\n\n## DONE\n"), 0o644); err != nil {
		t.Fatal(err)
	}

	m := resize(New(files), 80, 12)
	m.allFn = func() []string { return append([]string{}, files[0], other) }

	m = pressTab(m)
	if !m.viewAll {
		t.Fatal("Tab should switch to all view")
	}
	if len(m.rows) == 0 || m.rows[0].header == "" {
		t.Errorf("all view should show file headers, rows=%d", len(m.rows))
	}
	if m.current() == nil || m.current().Text != "alpha" {
		t.Errorf("selection should reset to first item of all view, got %v", m.current())
	}
	if !strings.Contains(m.View(), "Tab back") {
		t.Errorf("all view should show Tab back hint")
	}

	m = pressTab(m)
	if m.viewAll {
		t.Fatal("second Tab should switch back to single-file view")
	}
	for _, r := range m.rows {
		if r.header != "" {
			t.Errorf("single-file view should not show headers, got %q", r.header)
		}
	}
	if m.current() == nil || m.current().Text != "alpha" {
		t.Errorf("selection should reset to first item, got %v", m.current())
	}
}

func TestTabDoesNothingInAllMode(t *testing.T) {
	files := writeTODO(t, "# TODO\n- [ ] alpha\n\n## DONE\n")
	m := resize(New(files), 80, 12)
	m.files = []string{files[0], "/nonexistent/TODO.md"}
	m.fileFiles = m.files
	before := len(m.rows)
	m = pressTab(m)
	if m.viewAll || len(m.rows) != before {
		t.Error("Tab should be a no-op when started in all mode")
	}
}

func TestSelectedRowFullyStyledWhenFiltering(t *testing.T) {
	lipgloss.SetColorProfile(termenv.ANSI)
	defer lipgloss.SetColorProfile(termenv.Ascii)

	files := writeTODO(t, "# TODO\n- [ ] alpha one\n\n## DONE\n")
	m := resize(New(files), 80, 12)
	m = typeRunes(m, "al")
	row := m.renderRow(m.sel, true)
	stripped := stripANSI(row)
	if !strings.HasPrefix(stripped, "> alpha one") {
		t.Errorf("selected row content = %q, want prefix %q", stripped, "> alpha one")
	}
	if len([]rune(stripped)) != 80 {
		t.Errorf("selected row should span full width, got %d chars", len([]rune(stripped)))
	}
	if !strings.Contains(row, "\x1b[0m\x1b[") {
		t.Errorf("selected row should restyle every segment, got %q", row)
	}
}
