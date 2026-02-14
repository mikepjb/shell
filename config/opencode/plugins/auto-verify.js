export const AutoVerifyPlugin = async ({ $, client, project }) => {
  return {
    event: async ({ event }) => {
      if (event.type === "session.idle") {
        try {
          // Run verify script
          await $`/home/mikepjb/src/shell/bin/verify`.cwd(project.worktree);
          // Success - do nothing
        } catch (error) {
          // Get failure output
          const output = error.stderr?.toString() || error.stdout?.toString() || 'Verification failed';

          // Append to prompt buffer so user sees it and LLM gets it in next turn
          await client.tui.appendPrompt({
            body: {
              text: `\n\n🔴 Verification failed:\n${output}\n\nPlease fix the failing tests.`
            }
          });
        }
      }
    }
  };
};
