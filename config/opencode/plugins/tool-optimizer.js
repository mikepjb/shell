import { readFileSync } from 'fs';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';
import { homedir } from 'os';

const __dirname = dirname(fileURLToPath(import.meta.url));
const configPath = join(__dirname, '..', 'initial-context.json');

let optimizationConfig = null;
let cachedSystemPrompt = null;

function loadConfig() {
  if (optimizationConfig) return optimizationConfig;

  try {
    const configContent = readFileSync(configPath, 'utf-8');
    optimizationConfig = JSON.parse(configContent);
    return optimizationConfig;
  } catch (e) {
    console.warn('Failed to load tool optimization config');
    return { tools: {}, parameters: {}, systemPromptPrefix: '' };
  }
}

function buildSystemPrompt() {
  if (cachedSystemPrompt) return cachedSystemPrompt;

  const config = loadConfig();
  let prompt = config.systemPromptPrefix || '';

  // Try to load AGENTS.md
  try {
    const agentsPath = join(homedir(), '.config', 'opencode', 'AGENTS.md');
    const agentsContent = readFileSync(agentsPath, 'utf-8');
    prompt += '\n\n' + agentsContent;
  } catch (e) {
    // AGENTS.md not found, that's ok
  }

  cachedSystemPrompt = prompt;
  return prompt;
}

export const ToolOptimizerPlugin = async () => {
  const config = loadConfig();
  const systemPrompt = buildSystemPrompt();

  return {
    "chat.params": async (input, output) => {
      // Optimize tools
      if (output.options?.tools) {
        output.options.tools = output.options.tools.map(tool => {
          const name = tool.function.name.toLowerCase();
          const optimizedDesc = config.tools[name] || tool.function.description;

          // Optimize parameters if they exist
          let optimizedParams = tool.function.parameters;
          if (optimizedParams?.properties) {
            const optimizedProperties = {};

            for (const [paramName, paramSchema] of Object.entries(optimizedParams.properties)) {
              const paramKey = `${name}.${paramName}`;
              const optimizedParamDesc = config.parameters[paramKey] || paramSchema.description;

              optimizedProperties[paramName] = {
                ...paramSchema,
                description: optimizedParamDesc
              };
            }

            optimizedParams = {
              ...optimizedParams,
              properties: optimizedProperties
            };
          }

          return {
            type: tool.type,
            function: {
              name: tool.function.name,
              description: optimizedDesc,
              parameters: optimizedParams
            }
          };
        });
      }

      // Optimize system prompt
      if (output.messages?.[0]?.role === 'system') {
        output.messages[0].content = systemPrompt;
      }
    }
  };
};
