export const ToolOptimizerPlugin = async () => {
  return {
    "chat.params": async (input, output) => {
      // Check if tools are being sent in the options
      if (output.options?.tools) {
        // Simplify each tool definition
        output.options.tools = output.options.tools.map(tool => {
          // Keep minimal tool info
          const simplified = {
            type: tool.type,
            function: {
              name: tool.function.name,
              // First line only
              description: tool.function.description?.split('\n')[0] || tool.function.description,
              parameters: tool.function.parameters
            }
          };

          // Simplify parameter descriptions if they exist
          if (simplified.function.parameters?.properties) {
            for (const [key, schema] of Object.entries(simplified.function.parameters.properties)) {
              if (schema.description) {
                schema.description = schema.description.split('\n')[0];
              }
            }
          }

          return simplified;
        });
      }
    }
  };
};
