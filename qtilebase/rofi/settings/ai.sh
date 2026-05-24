#!/usr/bin/env bash

SETTINGS_DIR="$HOME/.config/rofi/settings"

options="\
Local Engines
UI / Workflow
Back
Search
"

choice=$(echo "$options" | rofi -dmenu -p "Intelligence & AI")

case "$choice" in
    "Local Engines")
        sub=$(echo -e "LLM Server\nImage Generation\nBack" | rofi -dmenu -p "Engines")
        case "$sub" in
            "LLM Server") alacritty -e ollama run llama2 ;;
            "Image Generation") alacritty -e ./stable-diffusion-webui/webui.sh ;;
            "Back") $0 ;;
        esac ;;
    "UI / Workflow")
        sub=$(echo -e "AI Browser UI\nPattern Prompts\nBack" | rofi -dmenu -p "Workflow")
        case "$sub" in
            "AI Browser UI") alacritty -e open-webui ;;
            "Pattern Prompts") alacritty -e fabric ;;
            "Back") $0 ;;
        esac ;;
    "Back")
        $SETTINGS_DIR/settings-rofi.sh ;;
    "Search")
        # Local search list for Intelligence & AI only
        options="\
AI → Engines → LLM Server
AI → Engines → Image Generation
AI → Workflow → AI Browser UI
AI → Workflow → Pattern Prompts
Back
"

        choice=$(echo "$options" | rofi -dmenu -p "Search AI")

        case "$choice" in
            *"LLM Server") alacritty -e ollama run llama2 ;;
            *"Image Generation") alacritty -e ./stable-diffusion-webui/webui.sh ;;
            *"AI Browser UI") alacritty -e open-webui ;;
            *"Pattern Prompts") alacritty -e fabric ;;
            "Back") $0 ;;
        esac ;;
esac
