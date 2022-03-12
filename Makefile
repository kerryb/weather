.PHONY: all asdf assets bootstrap burn check-formatted clean credo deps dialyzer format help setup test update-deps
all: check-formatted credo dialyzer test # Help: Run tests and other checks
asdf: # Help: Install correct Erlang/OTP and Elixir versions using asdf
	asdf install
assets: # Help: Build web assets for UI app
	cd weather_ui && mix assets.deploy
bootstrap: # Help: Install the nerves bootstrap archive
	mix archive.install hex nerves_bootstrap
burn: assets # Help: Generate firmware and burn to an SD card
	cd weather_firmware && MIX_ENV=prod MIX_TARGET=rpi0 mix firmware.burn
check-formatted: # Help: Check all Elixir source files are correctly formatted
	cd weather_ui && mix format --check-formatted
	cd weather_firmware && mix format --check-formatted
clean: # Help: Clean firmware and UI projects (dev and test environments)
	cd weather_ui && mix clean && MIX_ENV=test mix clean
	cd weather_firmware && mix clean && MIX_ENV=test mix clean
credo: # Help: Run credo style checker on firmware and UI projects
	cd weather_ui && mix credo --strict --all
	cd weather_firmware && mix credo --strict --all
deps: # Help: Download dependencies for firmware and UI projects
	cd weather_ui && mix deps.get
	cd weather_firmware && mix deps.get
dialyzer: # Help: Run dialyxir on firmware and UI projects
	cd weather_ui && mix dialyzer
	cd weather_firmware && mix dialyzer
format: # Help: Format all Elixir source files
	cd weather_ui && mix format
	cd weather_firmware && mix format
help: # Help: Show this help message
	@echo 'The following make targets are available.'
	@sed -n 's/^\([^:]*:\).*# [H]elp: \(.*\)/"%-20s %s\\n" "\1" "\2"/p' Makefile | xargs -n 3 printf | sort	
test: # Help: Run tests in firmware and UI projects
	cd weather_ui && mix test
	cd weather_firmware && mix test
update-deps: # Help: Update dependencies for firmware and UI projects
	cd weather_ui && mix deps.update --all
	cd weather_firmware && MIX_TARGET=rpi0 mix deps.update --all
