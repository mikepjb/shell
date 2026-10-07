import { mkdirSync, writeFileSync } from "node:fs";
import { dirname, isAbsolute, resolve } from "node:path";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { Key } from "@earendil-works/pi-tui";

type Message = {
  role: string;
  content?: unknown;
  provider?: string;
  model?: string;
  errorMessage?: string;
  toolName?: string;
  command?: string;
  output?: string;
  exitCode?: number;
  display?: boolean;
  customType?: string;
};

function safeFilenamePart(value: string): string {
  return value.replace(/[^a-zA-Z0-9._-]+/g, "-").replace(/^-+|-+$/g, "") || "unknown-model";
}

function defaultFilename(ctx: ExtensionContext): string {
  const model = safeFilenamePart(ctx.model?.id || "unknown-model");
  const timestamp = new Date().toISOString().replace(/[:.]/g, "-");
  return `chat-${model}-${timestamp}.md`;
}

function codeBlock(value: string, language = "text"): string {
  const longestRun = Math.max(0, ...Array.from(value.matchAll(/`+/g), (match) => match[0].length));
  const fence = "`".repeat(Math.max(3, longestRun + 1));
  return `${fence}${language}\n${value}\n${fence}`;
}

function renderContent(content: unknown): string {
  if (typeof content === "string") return content;
  if (!Array.isArray(content)) return "";

  return content
    .map((part) => {
      if (!part || typeof part !== "object") return "";
      const item = part as Record<string, unknown>;
      if (item.type === "text" && typeof item.text === "string") return item.text;
      if (item.type === "image") return `_[Image: ${String(item.mimeType || "unknown type")}]_`;
      if (item.type === "thinking" && typeof item.thinking === "string") {
        return `<details>\n<summary>Thinking</summary>\n\n${item.thinking}\n\n</details>`;
      }
      if (item.type === "toolCall") {
        const name = typeof item.name === "string" ? item.name : "unknown";
        const args = JSON.stringify(item.arguments ?? {}, null, 2);
        return `<details>\n<summary>Tool call: ${name}</summary>\n\n${codeBlock(args, "json")}\n\n</details>`;
      }
      return "";
    })
    .filter(Boolean)
    .join("\n\n");
}

function renderMessage(message: Message): string | undefined {
  if (message.role === "user") {
    return `## User\n\n${renderContent(message.content)}`;
  }

  if (message.role === "assistant") {
    const model = [message.provider, message.model].filter(Boolean).join("/");
    const heading = model ? `## Assistant — ${model}` : "## Assistant";
    const content = renderContent(message.content);
    const error = message.errorMessage ? `\n\n_Error: ${message.errorMessage}_` : "";
    return `${heading}\n\n${content || "_(No text response)_"}${error}`;
  }

  if (message.role === "toolResult") {
    const content = renderContent(message.content);
    return `<details>\n<summary>Tool result: ${message.toolName || "unknown"}</summary>\n\n${content}\n\n</details>`;
  }

  if (message.role === "bashExecution") {
    const command = codeBlock(message.command || "", "sh");
    const output = codeBlock(message.output || "");
    return `<details>\n<summary>Shell command (exit ${message.exitCode ?? "unknown"})</summary>\n\n${command}\n\n${output}\n\n</details>`;
  }

  if (message.role === "custom" && message.display !== false) {
    return `## ${message.customType || "Note"}\n\n${renderContent(message.content)}`;
  }

  return undefined;
}

function saveHistory(ctx: ExtensionContext, requestedPath?: string): string {
  const outputPath = requestedPath?.trim() || defaultFilename(ctx);
  const filePath = isAbsolute(outputPath) ? outputPath : resolve(ctx.cwd, outputPath);
  const exportedAt = new Date().toISOString();
  const currentModel = ctx.model ? `${ctx.model.provider}/${ctx.model.id}` : "unknown";
  const messages = ctx.sessionManager
    .getBranch()
    .filter((entry) => entry.type === "message")
    .map((entry) => renderMessage(entry.message as Message))
    .filter((message): message is string => Boolean(message));

  const markdown = [
    "# Chat transcript",
    `- **Model at export:** ${currentModel}`,
    `- **Exported:** ${exportedAt}`,
    `- **Working directory:** ${ctx.sessionManager.getCwd()}`,
    ...messages,
  ].join("\n\n");

  mkdirSync(dirname(filePath), { recursive: true });
  writeFileSync(filePath, `${markdown}\n`);
  return filePath;
}

export default function (pi: ExtensionAPI) {
  const save = (ctx: ExtensionContext, requestedPath?: string) => {
    try {
      const filePath = saveHistory(ctx, requestedPath);
      ctx.ui.notify(`Chat history saved to: ${filePath}`, "info");
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      ctx.ui.notify(`Failed to save chat history: ${message}`, "error");
    }
  };

  pi.registerShortcut(Key.ctrl("x"), {
    description: "Save chat history as Markdown",
    handler: (ctx) => save(ctx),
  });

  pi.registerCommand("save-history", {
    description: "Save the current chat branch as Markdown",
    handler: async (args, ctx) => save(ctx, args),
  });
}
