import { readFileSync } from "node:fs";
import { join } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { getAgentDir } from "@earendil-works/pi-coding-agent";

const LOCAL_URL = "http://127.0.0.1:7777";
const LOCAL_PROVIDER = "local-llm";

type Preset = { provider: string; model: string; tools: string[]; thinkingLevel?: "off" | "minimal" | "low" | "medium" | "high" | "xhigh" | "max" };

export default function (pi: ExtensionAPI) {
  pi.registerFlag("preset", { description: "Start with a named preset", type: "string" });

  function loadPresets(): Record<string, Preset> {
    return JSON.parse(readFileSync(join(getAgentDir(), "presets.json"), "utf8"));
  }

  // llama.cpp reports its actual model ID; do not assume that the server accepts a fixed alias.
  async function discoverLocalModel(): Promise<string> {
    const response = await fetch(`${LOCAL_URL}/v1/models`, { signal: AbortSignal.timeout(3000) });
    if (!response.ok) throw new Error(`Local model discovery returned HTTP ${response.status}`);
    const body = await response.json() as { data?: Array<{ id?: string }> };
    const id = body.data?.find((item) => typeof item.id === "string" && item.id.length > 0)?.id;
    if (!id) throw new Error("No model ID returned by the local /v1/models endpoint");

    pi.registerProvider(LOCAL_PROVIDER, {
      name: "Local llama.cpp",
      baseUrl: `${LOCAL_URL}/v1`,
      api: "openai-completions",
      apiKey: "local-only",
      models: [{
        id,
        name: id,
        reasoning: false,
        input: ["text"],
        cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
        // Conservative defaults; adjust to match llama-server's configured context.
        contextWindow: 8192,
        maxTokens: 2048,
      }],
    });
    return id;
  }

  async function apply(name: string, ctx: import("@earendil-works/pi-coding-agent").ExtensionContext): Promise<boolean> {
    const preset = loadPresets()[name];
    if (!preset) {
      ctx.ui.notify(`Unknown preset: ${name}`, "error");
      return false;
    }
    // Apply tool restrictions first, even if model discovery or authentication fails.
    pi.setActiveTools(preset.tools);
    try {
      const id = preset.model === "$current" ? await discoverLocalModel() : preset.model;
      const model = ctx.modelRegistry.find(preset.provider, id);
      if (!model) throw new Error(`Model not available: ${preset.provider}/${id}`);
      if (!await pi.setModel(model)) throw new Error(`Authentication unavailable: ${preset.provider}/${id}`);
      if (preset.thinkingLevel) pi.setThinkingLevel(preset.thinkingLevel);
      ctx.ui.setStatus("preset", `preset: ${name}`);
      ctx.ui.notify(`Preset ${name}: ${preset.provider}/${id} (${preset.tools.join(", ")})`, "info");
      return true;
    } catch (error) {
      ctx.ui.notify(`Preset ${name} failed: ${error instanceof Error ? error.message : String(error)}`, "error");
      return false;
    }
  }

  pi.registerCommand("preset", {
    description: "Choose frontier or local-llm (model and tools together)",
    handler: async (args, ctx) => {
      const presets = loadPresets();
      const name = args.trim() || await ctx.ui.select("Select preset", Object.keys(presets));
      if (name) await apply(name, ctx);
    },
  });

  pi.on("session_start", async (event, ctx) => {
    if (event.reason !== "startup") return;
    const preset = pi.getFlag("preset");
    if (typeof preset === "string" && preset && !await apply(preset, ctx)) {
      // Do not run an initial prompt against the wrong model if the requested preset failed.
      ctx.shutdown();
    }
  });
}
