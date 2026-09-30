import { CustomEditor, type ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { CURSOR_MARKER } from "@earendil-works/pi-tui";

const INVERSE_VIDEO = "\x1b[7m";

class HardwareCursorEditor extends CustomEditor {
  render(width: number): string[] {
    return super.render(width).map((line) => {
      const marker = line.indexOf(CURSOR_MARKER);
      if (marker === -1) return line;

      const cursorStyle = marker + CURSOR_MARKER.length;
      if (!line.startsWith(INVERSE_VIDEO, cursorStyle)) return line;

      // Keep the marker so Pi positions the terminal cursor, but remove the
      // inverse-video style used to draw its always-visible fake cursor.
      return line.slice(0, cursorStyle) +
        line.slice(cursorStyle + INVERSE_VIDEO.length);
    });
  }
}

export default function (pi: ExtensionAPI) {
  pi.on("session_start", (_event, ctx) => {
    if (ctx.mode !== "tui") return;
    ctx.ui.setEditorComponent((tui, theme, keybindings) =>
      new HardwareCursorEditor(tui, theme, keybindings)
    );
  });
}
