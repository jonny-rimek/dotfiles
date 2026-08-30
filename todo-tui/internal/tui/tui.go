package tui

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"sort"
	"strings"
	"time"

	"github.com/charmbracelet/bubbles/textinput"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
	"github.com/sahilm/fuzzy"

	"todo-tui/internal/theme"
	"todo-tui/internal/todo"
)

type styles struct {
	bar         lipgloss.Style
	normalChip  lipgloss.Style
	insertChip  lipgloss.Style
	normalCount lipgloss.Style
	insertCount lipgloss.Style
	header      lipgloss.Style
	sel         lipgloss.Style
	selMatch    lipgloss.Style
	match       lipgloss.Style
	age         lipgloss.Style
	ageSel      lipgloss.Style
	scope       lipgloss.Style
	projA       lipgloss.Style
	projB       lipgloss.Style
	projASel    lipgloss.Style
	projBSel    lipgloss.Style
	err         lipgloss.Style
}

func newStyles(c theme.Colors) styles {
	return styles{
		bar:         lipgloss.NewStyle().Foreground(lipgloss.Color(c.Text)).Background(lipgloss.Color(c.BarBg)),
		normalChip:  lipgloss.NewStyle().Bold(true).Foreground(lipgloss.Color(c.ChipFg)).Background(lipgloss.Color(c.Normal)),
		insertChip:  lipgloss.NewStyle().Bold(true).Foreground(lipgloss.Color(c.ChipFg)).Background(lipgloss.Color(c.Insert)),
		normalCount: lipgloss.NewStyle().Foreground(lipgloss.Color(c.Normal)).Background(lipgloss.Color(c.SelBg)),
		insertCount: lipgloss.NewStyle().Foreground(lipgloss.Color(c.Insert)).Background(lipgloss.Color(c.SelBg)),
		header:      lipgloss.NewStyle().Bold(true).Foreground(lipgloss.Color(c.HeaderFg)),
		sel:         lipgloss.NewStyle().Bold(true).Foreground(lipgloss.Color(c.SelFg)).Background(lipgloss.Color(c.SelBg)),
		selMatch:    lipgloss.NewStyle().Bold(true).Foreground(lipgloss.Color(c.Match)).Background(lipgloss.Color(c.SelBg)),
		match:       lipgloss.NewStyle().Foreground(lipgloss.Color(c.Match)),
		age:         lipgloss.NewStyle().Foreground(lipgloss.Color(c.HeaderFg)),
		ageSel:      lipgloss.NewStyle().Foreground(lipgloss.Color(c.HeaderFg)).Background(lipgloss.Color(c.SelBg)),
		scope:       lipgloss.NewStyle().Foreground(lipgloss.Color(c.Gray)),
		projA:       lipgloss.NewStyle().Foreground(lipgloss.Color(c.Ok)),
		projB:       lipgloss.NewStyle().Foreground(lipgloss.Color(c.ErrFg)),
		projASel:    lipgloss.NewStyle().Foreground(lipgloss.Color(c.Ok)).Background(lipgloss.Color(c.SelBg)),
		projBSel:    lipgloss.NewStyle().Foreground(lipgloss.Color(c.ErrFg)).Background(lipgloss.Color(c.SelBg)),
		err:         lipgloss.NewStyle().Foreground(lipgloss.Color(c.ErrFg)),
	}
}

type Mode int

const (
	ModeInsert Mode = iota
	ModeNormal
)

const selBottom = -2

type row struct {
	proj    string
	projIdx int
	item    *todo.Item
	age     string
}

type Model struct {
	mode      Mode
	input     textinput.Model
	files     []string
	fileFiles []string
	allFn     func() []string
	viewAll   bool
	items     []todo.Item
	rows      []row
	sel       int
	offset    int
	width     int
	height    int
	shown     int
	lastQuery string
	pendingG  bool
	ageW      int
	projW     int
	nowFn     func() time.Time
	selected  *todo.Item
	err       string
	st        styles
}

type markDoneMsg struct{ err error }
type editedMsg struct{ err error }

func New(files []string) Model {
	ti := textinput.New()
	ti.Prompt = ""
	ti.CharLimit = 200
	m := Model{
		mode:      ModeNormal,
		input:     ti,
		files:     files,
		fileFiles: files,
		allFn:     todo.AllFiles,
		sel:       selBottom,
		nowFn:     time.Now,
		st:        newStyles(theme.Current()),
	}
	m.loadFiles()
	return m
}

func (m Model) Selected() *todo.Item { return m.selected }

func (m *Model) toggleAllFiles() {
	if len(m.fileFiles) != 1 {
		return
	}
	if m.viewAll {
		m.files = m.fileFiles
	} else {
		all := m.allFn()
		if len(all) == 0 {
			return
		}
		m.files = all
	}
	m.viewAll = !m.viewAll
	m.sel = selBottom
	m.loadFiles()
	m.resizeInput()
}

func (m Model) textIndent() int {
	return m.projW + m.ageW + 6
}

func (m *Model) resizeInput() {
	if w := m.width - m.textIndent(); w > 0 {
		m.input.Width = w
	}
}

func (m Model) scopeName() string {
	if len(m.files) == 1 {
		return projectLabel(m.files[0])
	}
	return "all"
}

func (m Model) scopeLine() string {
	inner := m.textIndent() - 3
	if inner < 1 {
		return m.st.scope.Render("[]")
	}
	label := m.scopeName()
	pad := inner - len([]rune(label))
	if pad < 0 {
		pad = 0
	}
	left := pad / 2
	return m.st.scope.Render("[") + m.st.scope.Render(strings.Repeat(" ", left)+label+strings.Repeat(" ", pad-left)) + m.st.scope.Render("]")
}

func projectLabel(path string) string {
	home, err := os.UserHomeDir()
	if err == nil && home != "" && path == filepath.Join(home, "TODO.md") {
		return "~"
	}
	return filepath.Base(filepath.Dir(path))
}

func (m Model) Init() tea.Cmd { return nil }

func (m *Model) loadFiles() {
	m.items = nil
	for _, f := range m.files {
		its, err := todo.ParseFile(f)
		if err != nil {
			continue
		}
		m.items = append(m.items, its...)
	}
	m.rebuildRows()
}

func (m *Model) rebuildRows() {
	q := m.input.Value()
	if q != m.lastQuery {
		m.sel = selBottom
		m.lastQuery = q
	}
	m.rows = nil
	now := m.nowFn()
	all := len(m.files) > 1
	projIdx := map[string]int{}
	assign := func(name string) int {
		if _, ok := projIdx[name]; !ok {
			projIdx[name] = len(projIdx) % 2
		}
		return projIdx[name]
	}
	if q == "" {
		for i := range m.items {
			m.rows = append(m.rows, itemRow(&m.items[i], now, all, assign))
		}
	} else {
		texts := make([]string, len(m.items))
		for i := range m.items {
			texts[i] = m.items[i].Text
		}
		matches := fuzzy.Find(q, texts)
		sort.SliceStable(matches, func(i, j int) bool {
			if matches[i].Score != matches[j].Score {
				return matches[i].Score < matches[j].Score
			}
			return matches[i].Index < matches[j].Index
		})
		for _, match := range matches {
			m.rows = append(m.rows, itemRow(&m.items[match.Index], now, all, assign))
		}
	}
	m.shown = 0
	m.ageW = 0
	m.projW = 0
	for _, r := range m.rows {
		if r.item != nil {
			m.shown++
			if w := len([]rune(r.age)); w > m.ageW {
				m.ageW = w
			}
			if w := len([]rune(r.proj)); w > m.projW {
				m.projW = w
			}
		}
	}
	m.snapSel()
	m.ensureVisible()
}

func itemRow(it *todo.Item, now time.Time, all bool, assign func(string) int) row {
	r := row{item: it, age: ageLabel(it.CreatedAt, now)}
	if all {
		r.proj = projectLabel(it.File)
		r.projIdx = assign(r.proj)
	}
	return r
}

func (m *Model) snapSel() {
	if len(m.rows) == 0 {
		m.sel = -1
		return
	}
	if m.sel == selBottom {
		m.sel = len(m.rows)
	}
	if m.sel < 0 || m.sel >= len(m.rows) || m.rows[m.sel].item == nil {
		found := -1
		for i := max(m.sel, 0); i < len(m.rows); i++ {
			if m.rows[i].item != nil {
				found = i
				break
			}
		}
		if found < 0 {
			for i := len(m.rows) - 1; i >= 0; i-- {
				if m.rows[i].item != nil {
					found = i
					break
				}
			}
		}
		m.sel = found
	}
}

func (m *Model) move(delta int) {
	step := 1
	if delta < 0 {
		step = -1
	}
	n := delta
	if n < 0 {
		n = -n
	}
	moved := 0
	for i := m.sel + step; i >= 0 && i < len(m.rows) && moved < n; i += step {
		if m.rows[i].item != nil {
			m.sel = i
			moved++
		}
	}
	m.ensureVisible()
}

func halfPage(h int) int {
	if h/2 < 1 {
		return 1
	}
	return h / 2
}

func (m *Model) firstItem() {
	for i := range m.rows {
		if m.rows[i].item != nil {
			m.sel = i
			m.ensureVisible()
			return
		}
	}
}

func (m *Model) lastItem() {
	for i := len(m.rows) - 1; i >= 0; i-- {
		if m.rows[i].item != nil {
			m.sel = i
			m.ensureVisible()
			return
		}
	}
}

func (m Model) current() *todo.Item {
	if m.sel >= 0 && m.sel < len(m.rows) {
		return m.rows[m.sel].item
	}
	return nil
}

func (m Model) listHeight() int {
	h := m.height - 2
	if h < 1 {
		h = 1
	}
	return h
}

func (m *Model) ensureVisible() {
	if m.sel < 0 {
		m.offset = 0
		return
	}
	h := m.listHeight()
	maxOff := len(m.rows) - h
	if maxOff < 0 {
		maxOff = 0
	}
	if m.sel < m.offset {
		m.offset = m.sel
	}
	if m.sel >= m.offset+h {
		m.offset = m.sel - h + 1
	}
	if m.offset > maxOff {
		m.offset = maxOff
	}
	if m.offset < 0 {
		m.offset = 0
	}
}

func (m Model) markDoneCmd() tea.Cmd {
	it := m.current()
	if it == nil {
		return nil
	}
	file, line := it.File, it.Line
	return func() tea.Msg {
		return markDoneMsg{err: todo.MarkDone(file, line)}
	}
}

func (m Model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.WindowSizeMsg:
		m.width = msg.Width
		m.height = msg.Height
		m.resizeInput()
		if maxOff := len(m.rows) - m.listHeight(); maxOff < 0 {
			m.offset = 0
		} else if m.offset > maxOff {
			m.offset = maxOff
		}
		m.ensureVisible()
		return m, nil

	case markDoneMsg:
		if msg.err != nil {
			m.err = msg.err.Error()
		} else {
			m.err = ""
		}
		m.loadFiles()
		return m, nil

	case editedMsg:
		if msg.err != nil {
			m.err = msg.err.Error()
		} else {
			m.err = ""
		}
		m.loadFiles()
		return m, nil

	case tea.KeyMsg:
		if msg.String() == "ctrl+c" {
			return m, tea.Quit
		}
		if m.mode == ModeInsert {
			switch msg.String() {
			case "esc":
				m.mode = ModeNormal
				m.input.Blur()
				return m, nil
			case "tab":
				m.toggleAllFiles()
				return m, nil
			case "enter":
				if it := m.current(); it != nil {
					m.selected = it
					return m, tea.Quit
				}
				return m, nil
			case "up":
				m.move(-1)
				return m, nil
			case "down":
				m.move(1)
				return m, nil
			}
			var cmd tea.Cmd
			m.input, cmd = m.input.Update(msg)
			m.rebuildRows()
			return m, cmd
		}
		if m.pendingG {
			m.pendingG = false
			if msg.String() == "g" {
				m.firstItem()
				return m, nil
			}
		}
		switch msg.String() {
		case "g":
			m.pendingG = true
		case "G":
			m.lastItem()
		case "j", "down":
			m.move(1)
		case "k", "up":
			m.move(-1)
		case "ctrl+d":
			m.move(halfPage(m.listHeight()))
		case "ctrl+u":
			m.move(-halfPage(m.listHeight()))
		case "i", "a":
			m.mode = ModeInsert
			m.input.Focus()
			return m, textinput.Blink
		case "tab":
			m.toggleAllFiles()
			return m, nil
		case " ":
			return m, m.markDoneCmd()
		case "enter":
			if it := m.current(); it != nil {
				m.selected = it
				return m, tea.Quit
			}
		case "e":
			if it := m.current(); it != nil {
				cmd := exec.Command("nvim", fmt.Sprintf("+%d", it.Line), it.File)
				return m, tea.ExecProcess(cmd, func(err error) tea.Msg { return editedMsg{err} })
			}
		}
		return m, nil
	}
	return m, nil
}

func (m Model) View() string {
	if m.width == 0 {
		return "Loading..."
	}
	var b strings.Builder
	listH := m.listHeight()
	start := m.offset
	end := start + listH
	if end > len(m.rows) {
		end = len(m.rows)
	}
	for i := 0; i < listH-(end-start); i++ {
		b.WriteString("\n")
	}
	for i := start; i < end; i++ {
		b.WriteString(m.renderRow(i, i == m.sel))
		b.WriteString("\n")
	}
	b.WriteString(m.scopeLine())
	b.WriteString(m.queryLine())
	b.WriteString("\n")
	b.WriteString(m.statusBar())
	return b.String()
}

func ageLabel(t, now time.Time) string {
	if t.IsZero() {
		return ""
	}
	from := time.Date(t.Year(), t.Month(), t.Day(), 0, 0, 0, 0, time.UTC)
	to := time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, time.UTC)
	days := int(to.Sub(from).Hours() / 24)
	switch {
	case days <= 0:
		return "today"
	case days < 7:
		return fmt.Sprintf("%dd ago", days)
	case days < 30:
		return fmt.Sprintf("%dw ago", days/7)
	case days < 365:
		return fmt.Sprintf("%dmo ago", days/30)
	default:
		return fmt.Sprintf("%dy ago", days/365)
	}
}

func (m Model) queryLine() string {
	if m.err != "" {
		return " " + m.st.err.Render(truncatePlain(m.err, m.width))
	}
	return " " + m.input.View()
}

func (m Model) renderRow(i int, selected bool) string {
	r := m.rows[i]
	proj := fmt.Sprintf("%*s", m.projW, r.proj)
	age := fmt.Sprintf("%*s", m.ageW, r.age)
	maxText := m.width - m.projW - m.ageW - 6
	if maxText < 1 {
		maxText = 1
	}
	text := truncatePlain(r.item.Text, maxText)
	body := m.highlight(text, selected)
	projS, projSelS := m.st.projA, m.st.projASel
	if r.projIdx%2 == 1 {
		projS, projSelS = m.st.projB, m.st.projBSel
	}
	if selected {
		pad := m.width - m.projW - m.ageW - 6 - len([]rune(text))
		if pad < 0 {
			pad = 0
		}
		return projSelS.Render(proj+"  ") + m.st.ageSel.Render(age+"  ") + m.st.sel.Render("> ") + body + m.st.sel.Render(strings.Repeat(" ", pad))
	}
	return projS.Render(proj) + "  " + m.st.age.Render(age) + "  " + "  " + body
}

func (m Model) highlight(text string, selected bool) string {
	if q := m.input.Value(); q != "" {
		if matches := fuzzy.Find(q, []string{text}); len(matches) > 0 {
			matched := make(map[int]bool, len(matches[0].MatchedIndexes))
			for _, i := range matches[0].MatchedIndexes {
				matched[i] = true
			}
			mStyle, pStyle := m.st.match, lipgloss.Style{}
			if selected {
				mStyle, pStyle = m.st.selMatch, m.st.sel
			}
			var b strings.Builder
			for bi, r := range text {
				if matched[bi] {
					b.WriteString(mStyle.Render(string(r)))
				} else {
					b.WriteString(pStyle.Render(string(r)))
				}
			}
			return b.String()
		}
	}
	if selected {
		return m.st.sel.Render(text)
	}
	return text
}

func (m Model) statusBar() string {
	var chipStyle, countStyle lipgloss.Style
	var label, hints string
	if m.mode == ModeInsert {
		chipStyle, countStyle = m.st.insertChip, m.st.insertCount
		label = "-- INSERT --"
		hints = "Enter copy · Esc normal"
	} else {
		chipStyle, countStyle = m.st.normalChip, m.st.normalCount
		label = "-- NORMAL --"
		hints = "Space done · e edit · i/a insert"
	}
	if len(m.fileFiles) == 1 {
		if m.viewAll {
			hints += " · Tab back"
		} else {
			hints += " · Tab all"
		}
	}
	chip := chipStyle.Render(" " + label + " ")
	chipW := lipgloss.Width(" " + label + " ")
	countStr := fmt.Sprintf(" %d open ", m.shown)
	count := countStyle.Render(countStr)
	countW := lipgloss.Width(countStr)
	closeStr := " ^C close "
	closeW := lipgloss.Width(closeStr)

	hintStr := " " + hints + " "
	pad := m.width - chipW - lipgloss.Width(hintStr) - countW - closeW
	right := m.st.bar.Render(hintStr) + count + m.st.bar.Render(closeStr)
	if pad < 1 {
		pad = m.width - chipW - countW - closeW
		right = count + m.st.bar.Render(closeStr)
	}
	if pad < 1 {
		pad = m.width - chipW - closeW
		right = m.st.bar.Render(closeStr)
	}
	if pad < 0 {
		pad = 0
	}
	return chip + m.st.bar.Render(strings.Repeat(" ", pad)) + right
}

func truncatePlain(s string, max int) string {
	if max <= 0 {
		return ""
	}
	r := []rune(s)
	if len(r) <= max {
		return s
	}
	if max == 1 {
		return "…"
	}
	return string(r[:max-1]) + "…"
}
