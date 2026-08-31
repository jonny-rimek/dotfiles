package tui

import (
	"fmt"
	"os"
	"path/filepath"
	"regexp"
	"strings"
	"testing"
	"time"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
	"github.com/muesli/termenv"
	"github.com/sahilm/fuzzy"
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

func pressUp(m Model) Model {
	nm, _ := m.Update(tea.KeyMsg{Type: tea.KeyUp})
	return nm.(Model)
}

func pressCtrlD(m Model) Model {
	nm, _ := m.Update(tea.KeyMsg{Type: tea.KeyCtrlD})
	return nm.(Model)
}

func pressCtrlU(m Model) Model {
	nm, _ := m.Update(tea.KeyMsg{Type: tea.KeyCtrlU})
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

func TestLongTodoWrapsToMultipleLines(t *testing.T) {
	long := strings.Repeat("word ", 30)
	files := writeTODO(t, "# TODO\n- [ ] "+strings.TrimSpace(long)+"\n- [ ] short\n\n## DONE\n")
	m := resize(New(files), 40, 12)
	if len(m.rows[0].lines) < 2 {
		t.Fatalf("long todo should wrap to multiple lines, got %d", len(m.rows[0].lines))
	}
	view := stripANSI(m.View())
	if strings.Contains(view, "…") {
		t.Error("long todo should wrap, not truncate with ellipsis")
	}
	if !strings.Contains(view, "short") {
		t.Error("second item should still be visible below wrapped row")
	}
	for i, line := range strings.Split(view, "\n") {
		if w := len([]rune(line)); w > 40 {
			t.Errorf("line %d exceeds terminal width: %d chars: %q", i, w, line)
		}
	}
}

func TestWrappedRowContinuationIndented(t *testing.T) {
	files := writeTODO(t, "# TODO\n- [ ] aaaaaa bbbbbb cccccc dddddd eeeeee ffffff\n\n## DONE\n")
	m := resize(New(files), 20, 12)
	lines := strings.Split(stripANSI(m.View()), "\n")
	first := -1
	for i, l := range lines {
		if strings.Contains(l, "aaaaaa") {
			first = i
			break
		}
	}
	if first < 0 {
		t.Fatalf("wrapped row missing from view:\n%s", strings.Join(lines, "\n"))
	}
	wrapped := 1
	for i := first + 1; i < len(lines) && strings.HasPrefix(strings.TrimSpace(lines[i]), "cccccc"); i++ {
		if !strings.HasPrefix(lines[i], "      ") {
			t.Errorf("wrapped continuation should be indented, got %q", lines[i])
		}
		wrapped++
	}
	if wrapped < 2 {
		t.Errorf("row should wrap to multiple lines, got %d", wrapped)
	}
}

func TestSelectionScrollsThroughWrappedLines(t *testing.T) {
	var b strings.Builder
	b.WriteString("# TODO\n")
	for i := 1; i <= 5; i++ {
		fmt.Fprintf(&b, "- [ ] filler %d\n", i)
	}
	b.WriteString("- [ ] " + strings.Repeat("wrapme ", 20) + "\n\n## DONE\n")
	files := writeTODO(t, b.String())

	m := resize(New(files), 40, 8)
	if m.current() == nil || !strings.HasPrefix(m.current().Text, "wrapme") {
		t.Fatalf("selection = %v, want wrapped item", m.current())
	}
	view := stripANSI(m.View())
	if !strings.Contains(view, "wrapme wrapme wrapme wrapme") {
		t.Error("wrapped item text should be visible")
	}
	m = pressUp(m)
	if m.current().Text != "filler 5" {
		t.Errorf("selection = %v, want filler 5", m.current())
	}
	if !strings.Contains(stripANSI(m.View()), "filler 5") {
		t.Error("previous item should be visible after moving up")
	}
}

func TestWrapPlainBreaksLongWords(t *testing.T) {
	lines, offs := wrapPlain("aaa bbb ccc", 7)
	if len(lines) != 2 || lines[0] != "aaa bbb" || lines[1] != "ccc" {
		t.Errorf("wrapPlain = %v, want [aaa bbb ccc]", lines)
	}
	if len(offs) != 2 || offs[0] != 0 || offs[1] != 8 {
		t.Errorf("offs = %v, want [0 8]", offs)
	}
	hard, hoffs := wrapPlain("abcdefghij", 4)
	if len(hard) != 3 || hard[0] != "aaaa" && hard[0] != "abcd" {
		t.Errorf("hard wrap = %v", hard)
	}
	if len(hoffs) != len(hard) || hoffs[0] != 0 {
		t.Errorf("offs = %v for hard wrap", hoffs)
	}
	empty, eoffs := wrapPlain("", 10)
	if len(empty) != 1 || empty[0] != "" || len(eoffs) != 1 {
		t.Errorf("wrapPlain empty = %v", empty)
	}
}

func TestStatusBarShowsNormalMode(t *testing.T) {
	m := resize(New(nil), 80, 10)
	view := m.View()
	if !strings.Contains(view, "-- NORMAL --") {
		t.Errorf("view should show NORMAL mode, got:\n%s", view)
	}
	if !strings.Contains(view, "i/a insert") {
		t.Errorf("normal hints missing, got:\n%s", view)
	}
}

func TestStatusBarShowsInsertMode(t *testing.T) {
	m := resize(New(nil), 80, 10)
	m = typeRunes(m, "i")
	view := m.View()
	if !strings.Contains(view, "-- INSERT --") {
		t.Errorf("view should show INSERT mode, got:\n%s", view)
	}
	if !strings.Contains(view, "Esc normal") {
		t.Errorf("insert hints missing, got:\n%s", view)
	}
}

func TestKeyAEntersInsertMode(t *testing.T) {
	m := resize(New(nil), 80, 10)
	m = typeRunes(m, "a")
	if m.mode != ModeInsert {
		t.Errorf("mode = %v, want ModeInsert after pressing a", m.mode)
	}
	if !m.input.Focused() {
		t.Error("input should be focused after pressing a")
	}
}

func TestStatusBarNarrowWidth(t *testing.T) {
	m := resize(New(nil), 30, 10)
	view := m.View()
	if !strings.Contains(view, "-- NORMAL --") {
		t.Errorf("mode label should survive narrow width, got:\n%s", view)
	}
	if strings.Contains(view, "Space done") {
		t.Errorf("full hints should be dropped on narrow width, got:\n%s", view)
	}
}

func TestSearchPutsBestMatchAtBottom(t *testing.T) {
	files := writeTODO(t, "# TODO\n- [ ] alpha\n- [ ] beta\n- [ ] gamma\n- [ ] alphabet\n\n## DONE\n")
	m := resize(New(files), 80, 12)
	if m.current() == nil || m.current().Text != "alphabet" {
		t.Fatalf("initial selection = %v, want alphabet (newest)", m.current())
	}
	for i := 0; i < 3; i++ {
		m = pressUp(m)
	}
	if m.current().Text != "alpha" {
		t.Fatalf("after moving selection = %v, want alpha", m.current())
	}
	m = typeRunes(m, "i")
	m = typeRunes(m, "a")
	if m.sel != len(m.rows)-1 {
		t.Errorf("selection index = %d, want %d (bottom) after query change", m.sel, len(m.rows)-1)
	}
	best := fuzzy.Find("a", []string{"alpha", "beta", "gamma", "alphabet"})[0].Str
	if m.current() == nil || m.current().Text != best {
		t.Errorf("best match %q should be selected at the bottom, got %v", best, m.current())
	}
}

func TestSingleFileModeHasNoProjectColumn(t *testing.T) {
	files := writeTODO(t, "# TODO\n- [ ] alpha\n- [ ] beta\n\n## DONE\n")
	m := resize(New(files), 80, 12)
	if m.projW != 0 {
		t.Errorf("single-file mode should not show project column")
	}
	if m.current() == nil || m.current().Text != "beta" {
		t.Errorf("newest item should be selected, got %v", m.current())
	}
}

func TestTabTogglesAllView(t *testing.T) {
	files := writeTODO(t, "# TODO\n- [ ] alpha\n- [ ] beta\n\n## DONE\n")
	otherDir := filepath.Join(t.TempDir(), "other")
	other := filepath.Join(otherDir, "TODO.md")
	if err := os.MkdirAll(otherDir, 0o755); err != nil {
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
	if m.projW == 0 {
		t.Errorf("all view should show project column")
	}
	if len(m.rows) != 3 {
		t.Fatalf("all view should have one row per item, got %d", len(m.rows))
	}
	if m.current() == nil || m.current().Text != "gamma" {
		t.Errorf("selection should reset to newest item of all view, got %v", m.current())
	}
	view := stripANSI(m.View())
	if !strings.Contains(view, "other") {
		t.Errorf("all view should show project names, got:\n%s", view)
	}
	if !strings.Contains(m.View(), "Tab back") {
		t.Errorf("all view should show Tab back hint")
	}

	m = pressTab(m)
	if m.viewAll {
		t.Fatal("second Tab should switch back to single-file view")
	}
	if m.projW != 0 {
		t.Errorf("single-file view should not show project column")
	}
	if m.current() == nil || m.current().Text != "beta" {
		t.Errorf("selection should reset to newest item, got %v", m.current())
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
	m = typeRunes(m, "i")
	m = typeRunes(m, "al")
	row := m.renderRow(m.sel, true, 0, len(m.rows[m.sel].lines))
	stripped := stripANSI(row)
	if !strings.Contains(stripped, "> alpha one") {
		t.Errorf("selected row content = %q, want %q", stripped, "> alpha one")
	}
	if len([]rune(stripped)) != 80 {
		t.Errorf("selected row should span full width, got %d chars", len([]rune(stripped)))
	}
	if !strings.Contains(row, "\x1b[0m\x1b[") {
		t.Errorf("selected row should restyle every segment, got %q", row)
	}
}

func TestAgeLabel(t *testing.T) {
	now := time.Date(2026, 8, 29, 12, 0, 0, 0, time.UTC)
	cases := []struct {
		created time.Time
		want    string
	}{
		{time.Time{}, ""},
		{now.Add(-2 * time.Hour), "today"},
		{now.AddDate(0, 0, -1), "1d ago"},
		{now.AddDate(0, 0, -6), "6d ago"},
		{now.AddDate(0, 0, -14), "2w ago"},
		{now.AddDate(0, 0, -60), "2mo ago"},
		{now.AddDate(-2, 0, 0), "2y ago"},
	}
	for _, c := range cases {
		if got := ageLabel(c.created, now); got != c.want {
			t.Errorf("ageLabel = %q, want %q", got, c.want)
		}
	}
}

func TestInitialSelectionNewestByCreatedAt(t *testing.T) {
	day := func(n int) string { return time.Now().AddDate(0, 0, -n).Format("02.01.2006") }
	files := writeTODO(t, fmt.Sprintf(
		"# TODO\n- [ ] old <!-- created_at %s -->\n- [ ] middle <!-- created_at %s -->\n- [ ] fresh <!-- created_at %s -->\n\n## DONE\n",
		day(6), day(14), day(2)))
	m := resize(New(files), 80, 12)
	if m.current() == nil || m.current().Text != "fresh" {
		t.Fatalf("selection = %v, want newest item fresh", m.current())
	}
	view := stripANSI(m.View())
	if !strings.Contains(view, "6d ago") {
		t.Errorf("age column should show 6d ago for old item, got:\n%s", view)
	}
	if !strings.Contains(view, "2w ago") {
		t.Errorf("age column should show 2w ago for middle item, got:\n%s", view)
	}
	if !strings.Contains(view, "2d ago") {
		t.Errorf("age column should show 2d ago for fresh item, got:\n%s", view)
	}
}

func TestViewLayoutListBottomQueryAboveStatus(t *testing.T) {
	files := writeTODO(t, "# TODO\n- [ ] alpha\n\n## DONE\n")
	m := resize(New(files), 80, 10)
	lines := strings.Split(m.View(), "\n")
	if len(lines) != 10 {
		t.Fatalf("view should have %d lines, got %d", 10, len(lines))
	}
	if strings.TrimSpace(lines[0]) != "" {
		t.Errorf("list should be anchored to the bottom, top line = %q", lines[0])
	}
	if !strings.Contains(lines[7], "alpha") {
		t.Errorf("item row should sit just above the scope line, got %q", lines[7])
	}
	m = typeRunes(m, "i")
	m = typeRunes(m, "t")
	line := stripANSI(strings.Split(m.View(), "\n")[8])
	if !strings.HasPrefix(line, "[") {
		t.Errorf("scope label should start the search line, got %q", line)
	}
	if idx := strings.Index(line, "t"); idx != m.textIndent() {
		t.Errorf("search text should start at text column %d, got %d in %q", m.textIndent(), idx, line)
	}
	if !strings.Contains(strings.Split(m.View(), "\n")[9], "-- INSERT --") {
		t.Errorf("status bar should be last, got %q", strings.Split(m.View(), "\n")[9])
	}
}

func TestProjectColorsAlternate(t *testing.T) {
	files := writeTODO(t, "# TODO\n- [ ] alpha\n- [ ] beta\n\n## DONE\n")
	otherDir := filepath.Join(t.TempDir(), "other")
	other := filepath.Join(otherDir, "TODO.md")
	if err := os.MkdirAll(otherDir, 0o755); err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(other, []byte("# TODO\n- [ ] gamma\n\n## DONE\n"), 0o644); err != nil {
		t.Fatal(err)
	}

	m := resize(New(files), 80, 12)
	m.allFn = func() []string { return []string{files[0], other} }
	m = pressTab(m)

	if m.st.projA.GetForeground() == m.st.projB.GetForeground() {
		t.Fatal("project styles should use different colors")
	}
	if fg := m.st.age.GetForeground(); fg == nil {
		t.Errorf("age color should be set")
	}
	if m.rows[0].projIdx != 0 || m.rows[1].projIdx != 0 {
		t.Errorf("first project should use color 0, got %d/%d", m.rows[0].projIdx, m.rows[1].projIdx)
	}
	if m.rows[2].projIdx != 1 {
		t.Errorf("second project should use color 1, got %d", m.rows[2].projIdx)
	}

	single := resize(New(files), 80, 12)
	if single.rows[0].projIdx != 0 {
		t.Errorf("single-file rows should default to color 0, got %d", single.rows[0].projIdx)
	}
}

func TestSearchShrinkingResultsStayVisible(t *testing.T) {
	var b strings.Builder
	b.WriteString("# TODO\n")
	for i := 1; i <= 30; i++ {
		fmt.Fprintf(&b, "- [ ] filler item %d\n", i)
	}
	b.WriteString("- [ ] unique omarchy entry\n\n## DONE\n")
	files := writeTODO(t, b.String())

	m := resize(New(files), 80, 12)
	if m.offset == 0 {
		t.Fatalf("precondition: bottom selection should pin offset, got %d", m.offset)
	}

	m = typeRunes(m, "i")
	m = typeRunes(m, "omarchy")
	if len(m.rows) != 1 {
		t.Fatalf("rows = %d, want 1", len(m.rows))
	}
	if !strings.Contains(stripANSI(m.View()), "unique omarchy entry") {
		t.Error("single match should be rendered after filtering")
	}

	m2 := resize(New(files), 80, 12)
	m2 = typeRunes(m2, "i")
	m2 = typeRunes(m2, "filler")
	if len(m2.rows) != 30 {
		t.Fatalf("rows = %d, want 30", len(m2.rows))
	}
	maxOff := len(m2.rows) - m2.listHeight()
	if m2.offset != maxOff {
		t.Errorf("offset = %d, want clamped to %d", m2.offset, maxOff)
	}
	if m2.current() == nil || !strings.Contains(stripANSI(m2.View()), m2.current().Text) {
		t.Error("selected best match should be rendered in the clamped window")
	}
}

func TestAllViewGroupsProjectsByLatestItem(t *testing.T) {
	day := func(n int) string { return time.Now().AddDate(0, 0, -n).Format("02.01.2006") }
	home := writeTODO(t, "# TODO\n- [ ] home old <!-- created_at "+day(10)+" -->\n- [ ] home fresh <!-- created_at "+day(1)+" -->\n\n## DONE\n")
	otherDir := filepath.Join(t.TempDir(), "other")
	if err := os.MkdirAll(otherDir, 0o755); err != nil {
		t.Fatal(err)
	}
	other := filepath.Join(otherDir, "TODO.md")
	if err := os.WriteFile(other, []byte("# TODO\n- [ ] other mid <!-- created_at "+day(5)+" -->\n\n## DONE\n"), 0o644); err != nil {
		t.Fatal(err)
	}
	thirdDir := filepath.Join(t.TempDir(), "third")
	if err := os.MkdirAll(thirdDir, 0o755); err != nil {
		t.Fatal(err)
	}
	third := filepath.Join(thirdDir, "TODO.md")
	if err := os.WriteFile(third, []byte("# TODO\n- [ ] third oldest <!-- created_at "+day(20)+" -->\n\n## DONE\n"), 0o644); err != nil {
		t.Fatal(err)
	}

	m := resize(New([]string{home[0], other, third}), 80, 20)
	var got []string
	for _, r := range m.rows {
		got = append(got, r.item.Text)
	}
	want := []string{"third oldest", "other mid", "home old", "home fresh"}
	if strings.Join(got, ",") != strings.Join(want, ",") {
		t.Errorf("rows = %v, want %v", got, want)
	}
	if m.current() == nil || m.current().Text != "home fresh" {
		t.Errorf("selection = %v, want home fresh", m.current())
	}
}

func TestHalfPageUpDown(t *testing.T) {
	var b strings.Builder
	b.WriteString("# TODO\n")
	for i := 1; i <= 10; i++ {
		fmt.Fprintf(&b, "- [ ] item%d\n", i)
	}
	b.WriteString("\n## DONE\n")
	files := writeTODO(t, b.String())

	m := resize(New(files), 80, 12)
	if m.listHeight() != 10 {
		t.Fatalf("list height = %d, want 10", m.listHeight())
	}
	if m.current().Text != "item10" {
		t.Fatalf("initial selection = %v, want item10", m.current())
	}

	m = pressCtrlU(m)
	if m.current().Text != "item5" {
		t.Errorf("after ctrl+u selection = %v, want item5", m.current())
	}
	m = pressCtrlU(m)
	if m.current().Text != "item1" {
		t.Errorf("after second ctrl+u selection = %v, want item1 (clamped)", m.current())
	}
	m = pressCtrlD(m)
	if m.current().Text != "item6" {
		t.Errorf("after ctrl+d selection = %v, want item6", m.current())
	}
	m = pressCtrlD(m)
	m = pressCtrlD(m)
	if m.current().Text != "item10" {
		t.Errorf("after ctrl+d at bottom selection = %v, want item10 (clamped)", m.current())
	}
}

func TestHalfPageMinimum(t *testing.T) {
	if got := halfPage(1); got != 1 {
		t.Errorf("halfPage(1) = %d, want 1", got)
	}
	if got := halfPage(10); got != 5 {
		t.Errorf("halfPage(10) = %d, want 5", got)
	}
}

func TestScopeLabelAndProjectColumn(t *testing.T) {
	dir := filepath.Join(t.TempDir(), "dotfiles")
	file := filepath.Join(dir, "TODO.md")
	if err := os.MkdirAll(dir, 0o755); err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(file, []byte("# TODO\n- [ ] alpha\n\n## DONE\n"), 0o644); err != nil {
		t.Fatal(err)
	}

	single := resize(New([]string{file}), 80, 10)
	if got := single.scopeName(); got != "dotfiles" {
		t.Errorf("single scope name = %q, want dotfiles", got)
	}
	scope := stripANSI(single.scopeLine())
	if !strings.HasPrefix(scope, "[") || !strings.HasSuffix(scope, "]") || !strings.Contains(scope, "dotfiles") {
		t.Errorf("single scope line = %q, want centered bracketed dotfiles", scope)
	}

	all := resize(New([]string{file, filepath.Join(dir, "x")}), 80, 10)
	if got := all.scopeName(); got != "all" {
		t.Errorf("all scope name = %q, want all", got)
	}
	scope = stripANSI(all.scopeLine())
	if !strings.HasPrefix(scope, "[") || !strings.HasSuffix(scope, "]") || !strings.Contains(scope, "all") {
		t.Errorf("all scope line = %q, want centered bracketed all", scope)
	}

	m := resize(New([]string{file, filepath.Join(dir, "x")}), 80, 10)
	m.files = []string{file, file}
	m.loadFiles()
	m = typeRunes(m, "i")
	m = typeRunes(m, "alp")
	indent := m.projW + m.ageW + 6
	line := stripANSI(m.scopeLine() + m.queryLine())
	if !strings.HasPrefix(line, "[") {
		t.Errorf("scope label should start the search line, got %q", line)
	}
	if idx := strings.Index(line, "alp"); idx != indent {
		t.Errorf("search text should start at text column %d, got %d in %q", indent, idx, line)
	}
}
