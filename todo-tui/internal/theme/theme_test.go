package theme

import (
	"os"
	"path/filepath"
	"testing"
)

func writeTheme(t *testing.T, home, slug, colorsToml string, lightMode bool) {
	t.Helper()
	dir := filepath.Join(home, ".config", "omarchy", "current")
	if err := os.MkdirAll(filepath.Join(dir, "theme"), 0o755); err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(filepath.Join(dir, "theme.name"), []byte(slug+"\n"), 0o644); err != nil {
		t.Fatal(err)
	}
	if colorsToml != "" {
		if err := os.WriteFile(filepath.Join(dir, "theme", "colors.toml"), []byte(colorsToml), 0o644); err != nil {
			t.Fatal(err)
		}
	}
	if lightMode {
		if err := os.WriteFile(filepath.Join(dir, "theme", "light.mode"), []byte(""), 0o644); err != nil {
			t.Fatal(err)
		}
	}
}

func TestForRosePine(t *testing.T) {
	home := t.TempDir()
	writeTheme(t, home, "Rose Pine", `accent = "#56949f"
foreground = "#575279"
background = "#faf4ed"
selection_foreground = "#575279"
selection_background = "#dfdad9"
color1 = "#b4637a"
color3 = "#ea9d34"
`, true)

	c := For(home)
	if c.Normal != "#d7827e" {
		t.Errorf("Normal = %q, want #d7827e", c.Normal)
	}
	if c.Insert != "#56949f" {
		t.Errorf("Insert = %q, want #56949f", c.Insert)
	}
	if c.Text != "#575279" {
		t.Errorf("Text = %q, want #575279", c.Text)
	}
	if c.Match != "#ea9d34" {
		t.Errorf("Match = %q, want #ea9d34", c.Match)
	}
	if c.SelBg != "#dfdad9" || c.SelFg != "#575279" {
		t.Errorf("selection = %q/%q, want #dfdad9/#575279", c.SelBg, c.SelFg)
	}
	if c.BarBg != "#faf4ed" {
		t.Errorf("BarBg = %q, want #faf4ed", c.BarBg)
	}
	if c.HeaderFg != "#56949f" {
		t.Errorf("HeaderFg = %q, want #56949f", c.HeaderFg)
	}
	if c.ErrFg != "#b4637a" {
		t.Errorf("ErrFg = %q, want #b4637a", c.ErrFg)
	}
	if c.ChipFg != "#faf4ed" {
		t.Errorf("ChipFg = %q, want #faf4ed", c.ChipFg)
	}
}

func TestForTokyoNight(t *testing.T) {
	home := t.TempDir()
	writeTheme(t, home, "Tokyo Night", `accent = "#7aa2f7"
foreground = "#a9b1d6"
background = "#1a1b26"
selection_foreground = "#c0caf5"
selection_background = "#7aa2f7"
color1 = "#f7768e"
color3 = "#e0af68"
`, false)

	c := For(home)
	if c.Normal != "#7aa2f7" {
		t.Errorf("Normal = %q, want #7aa2f7", c.Normal)
	}
	if c.Insert != "#9ece6a" {
		t.Errorf("Insert = %q, want #9ece6a", c.Insert)
	}
	if c.Text != "#a9b1d6" {
		t.Errorf("Text = %q, want #a9b1d6", c.Text)
	}
	if c.SelBg != "#7aa2f7" {
		t.Errorf("SelBg = %q, want #7aa2f7", c.SelBg)
	}
}

func TestForQuattroStatePath(t *testing.T) {
	home := t.TempDir()
	dir := filepath.Join(home, ".local", "state", "omarchy", "current")
	if err := os.MkdirAll(filepath.Join(dir, "theme"), 0o755); err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(filepath.Join(dir, "theme.name"), []byte("rose-pine\n"), 0o644); err != nil {
		t.Fatal(err)
	}
	c := For(home)
	if c.Normal != "#d7827e" || c.Insert != "#56949f" {
		t.Errorf("quattro state path not resolved: %q/%q", c.Normal, c.Insert)
	}
}

func TestForUnknownThemeUsesDefaults(t *testing.T) {
	home := t.TempDir()
	c := For(home)
	if c.Normal != "#7aa2f7" || c.Insert != "#9ece6a" {
		t.Errorf("fallback chips = %q/%q", c.Normal, c.Insert)
	}
	if c.Text != "#c0caf5" || c.SelBg != "#292e42" {
		t.Errorf("fallback palette = %+v", c)
	}
}

func TestParseColors(t *testing.T) {
	m := parseColors(`# comment
accent = "#56949f"

[sections.are.skipped]
foreground='#575279'
broken = green
`)
	if m["accent"] != "#56949f" {
		t.Errorf("accent = %q", m["accent"])
	}
	if m["foreground"] != "#575279" {
		t.Errorf("foreground = %q", m["foreground"])
	}
	if _, ok := m["broken"]; ok {
		t.Errorf("non-hex value should be skipped")
	}
	if len(m) != 2 {
		t.Errorf("unexpected entries: %v", m)
	}
}
