import { isAbsolute, relative, resolve, sep } from "node:path";
import type { ExtensionAPI, SessionEntry } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

function formatCwd(cwd: string): string {
  const home = process.env.HOME || process.env.USERPROFILE;
  if (!home) return cwd;

  const relativeToHome = relative(resolve(home), resolve(cwd));
  const insideHome = relativeToHome === "" ||
    (relativeToHome !== ".." && !relativeToHome.startsWith(`..${sep}`) && !isAbsolute(relativeToHome));
  if (!insideHome) return cwd;
  return relativeToHome === "" ? "~" : `~${sep}${relativeToHome}`;
}

function formatTokens(tokens: number | null | undefined): string {
  return tokens == null ? "?k" : `${(tokens / 1000).toFixed(1)}k`;
}

function formatCost(cost: number): string {
  return `$${cost.toFixed(3)}`;
}

/** Total billed cost for the session, matching Pi's own session stats. */
function getSessionCost(entries: readonly SessionEntry[]): number {
  let cost = 0;
  for (const entry of entries) {
    if (entry.type === "usage") {
      cost += entry.usage.cost.total;
    } else if ((entry.type === "branch_summary" || entry.type === "compaction") && entry.usage) {
      cost += entry.usage.cost.total;
    } else if (entry.type === "message") {
      const message = entry.message;
      if (message.role === "assistant") {
        cost += message.usage.cost.total;
      } else if (message.role === "toolResult" && message.usage) {
        cost += message.usage.cost.total;
      }
    }
  }
  return cost;
}

export default function (pi: ExtensionAPI) {
  pi.on("session_start", (_event, ctx) => {
    if (ctx.mode !== "tui") return;

    ctx.ui.setFooter((tui, theme, footerData) => {
      const unsubscribe = footerData.onBranchChange(() => tui.requestRender());

      return {
        dispose: unsubscribe,
        invalidate() {},
        render(width: number): string[] {
          const branch = footerData.getGitBranch();
          const cwd = formatCwd(ctx.sessionManager.getCwd());
          const contextUsage = ctx.getContextUsage();
          const currentTokens = formatTokens(contextUsage?.tokens);
          const totalTokens = formatTokens(contextUsage?.contextWindow ?? ctx.model?.contextWindow);

          const cost = getSessionCost(ctx.sessionManager.getEntries());

          const left = `${cwd}${branch ? ` (${branch})` : ""} ${currentTokens} / ${totalTokens} ${formatCost(cost)}`;

          const model = ctx.model;
          let modelAndThinking = model?.id || "no-model";
          if (model?.reasoning) {
            const thinking = ctx.thinkingLevel || "off";
            modelAndThinking += thinking === "off" ? " • thinking off" : ` • ${thinking}`;
          }
          const right = model ? `(${model.provider}) ${modelAndThinking}` : modelAndThinking;

          const gap = 2;
          const rightWidth = visibleWidth(right);
          const availableLeft = width - rightWidth - gap;
          if (availableLeft <= 0) {
            return [theme.fg("dim", truncateToWidth(right, width, ""))];
          }

          const fittedLeft = truncateToWidth(left, availableLeft, "...");
          const padding = " ".repeat(width - visibleWidth(fittedLeft) - rightWidth);
          return [theme.fg("dim", fittedLeft + padding + right)];
        },
      };
    });
  });
}
