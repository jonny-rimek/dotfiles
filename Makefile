CONFIG_FILE := mise/.config/mise/config.toml

.PHONY: check-updates
check-updates:
	@today=$$(date -u +%Y-%m-%d); \
	tools="ruby node pipx uv"; \
	updated=""; \
	for tool in $$tools; do \
		current=$$(grep -E "^$$tool " $(CONFIG_FILE) | sed 's/.*"\(.*\)".*/\1/'); \
		if [ "$$tool" = "node" ]; then \
			lts_major=$$(curl -fsSL https://raw.githubusercontent.com/nodejs/release/main/schedule.json 2>/dev/null \
				| jq -r 'to_entries[] | select(.value.lts and (.value.lts <= "'$$today'") and (.value.end > "'$$today'")) | .key | ltrimstr("v")' 2>/dev/null \
				| sort -n | tail -1); \
			latest=$$(mise ls-remote $$tool 2>/dev/null | grep -E "^$$lts_major\.[0-9]+\.[0-9]+$$" | tail -1); \
			latest_display="$$latest (LTS major $$lts_major)"; \
		else \
			latest=$$(mise ls-remote $$tool 2>/dev/null | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$$' | tail -1); \
			latest_display="$$latest"; \
		fi; \
		echo; \
		echo "  $$tool"; \
		echo "    pinned:  $$current"; \
		echo "    latest:  $$latest_display"; \
		if [ "$$current" = "$$latest" ]; then \
			echo "    status:  up to date"; \
		else \
			echo "    status:  update available"; \
			read -p "    update $$tool to $$latest_display? [y/N] " ans; \
			if [ "$$ans" = "y" ] || [ "$$ans" = "Y" ]; then \
				sed -i "s|^$$tool = \".*\"|$$tool = \"$$latest\"|" $(CONFIG_FILE); \
				echo "    -> pinned to $$latest"; \
				updated="$$updated $$tool"; \
			else \
				echo "    -> skipped"; \
			fi; \
		fi; \
	done; \
	if [ -n "$$updated" ]; then \
		echo; \
		read -p "Run 'mise install' now for$$updated? [Y/n] " ans; \
		if [ "$$ans" != "n" ] && [ "$$ans" != "N" ]; then \
			mise install; \
		else \
			echo "Run 'mise install' later to apply."; \
		fi; \
	fi; \
	echo
