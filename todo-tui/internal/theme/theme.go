package theme

import (
	"os"
	"path/filepath"
	"strings"
)

type Colors struct {
	Normal   string
	Insert   string
	Text     string
	Match    string
	SelBg    string
	SelFg    string
	BarBg    string
	HeaderFg string
	ErrFg    string
	ChipFg   string
}

var chipPalette = map[string][2]string{
	"rose-pine":   {"#d7827e", "#56949f"},
	"tokyo-night": {"#7aa2f7", "#9ece6a"},
}

var defaultChips = [2]string{"#7aa2f7", "#9ece6a"}

func Current() Colors {
	home, err := os.UserHomeDir()
	if err != nil {
		return For("")
	}
	return For(home)
}

func For(home string) Colors {
	c := Colors{
		Normal:   defaultChips[0],
		Insert:   defaultChips[1],
		Text:     "#c0caf5",
		Match:    "#e0af68",
		SelBg:    "#292e42",
		SelFg:    "#c0caf5",
		BarBg:    "#1a1b26",
		HeaderFg: "#7aa2f7",
		ErrFg:    "#f7768e",
		ChipFg:   "#1a1b26",
	}
	if chips, ok := chipPalette[themeName(home)]; ok {
		c.Normal, c.Insert = chips[0], chips[1]
	}
	p := palette(home)
	set := func(dst *string, key string) {
		if v, ok := p[key]; ok {
			*dst = v
		}
	}
	set(&c.Text, "foreground")
	set(&c.Match, "color3")
	set(&c.SelBg, "selection_background")
	set(&c.SelFg, "selection_foreground")
	set(&c.BarBg, "background")
	set(&c.HeaderFg, "accent")
	set(&c.ErrFg, "color1")
	set(&c.ChipFg, "background")
	return c
}

func currentBases(home string) []string {
	return []string{
		filepath.Join(home, ".config", "omarchy", "current"),
		filepath.Join(home, ".local", "state", "omarchy", "current"),
	}
}

func themeName(home string) string {
	for _, base := range currentBases(home) {
		data, err := os.ReadFile(filepath.Join(base, "theme.name"))
		if err == nil {
			return normalizeName(string(data))
		}
	}
	return ""
}

func palette(home string) map[string]string {
	for _, base := range currentBases(home) {
		data, err := os.ReadFile(filepath.Join(base, "theme", "colors.toml"))
		if err == nil {
			return parseColors(string(data))
		}
	}
	return nil
}

func normalizeName(s string) string {
	return strings.ReplaceAll(strings.ToLower(strings.TrimSpace(s)), " ", "-")
}

func parseColors(toml string) map[string]string {
	m := map[string]string{}
	for _, line := range strings.Split(toml, "\n") {
		line = strings.TrimSpace(line)
		if line == "" || strings.HasPrefix(line, "#") || strings.HasPrefix(line, "[") {
			continue
		}
		key, value, ok := strings.Cut(line, "=")
		if !ok {
			continue
		}
		value = strings.Trim(strings.TrimSpace(value), "\"'")
		if strings.HasPrefix(value, "#") {
			m[strings.TrimSpace(key)] = value
		}
	}
	return m
}
