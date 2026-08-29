package clip

import (
	"encoding/base64"
	"fmt"
	"os"
	"os/exec"
	"strings"
)

func Copy(text string) error {
	if os.Getenv("WAYLAND_DISPLAY") != "" {
		if _, err := exec.LookPath("wl-copy"); err == nil {
			return run(exec.Command("wl-copy"), text)
		}
	}
	if os.Getenv("DISPLAY") != "" {
		if _, err := exec.LookPath("xclip"); err == nil {
			return run(exec.Command("xclip", "-selection", "clipboard"), text)
		}
	}
	return OSC52(text)
}

func run(cmd *exec.Cmd, text string) error {
	cmd.Stdin = strings.NewReader(text)
	return cmd.Run()
}

func OSC52(text string) error {
	b64 := base64.StdEncoding.EncodeToString([]byte(text))
	_, err := fmt.Fprintf(os.Stdout, "\033]52;c;%s\a", b64)
	return err
}
