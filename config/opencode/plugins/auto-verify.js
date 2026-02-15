export const AutoVerifyPlugin = async ({ $, client, project }) => {
  return {
    event: async ({ event }) => {
      if (event.type === "session.idle") {
        // Show status: verification running
        await client.toast({
          title: "Verifying",
          message: "Running verification checks...",
          variant: "info",
          duration: 2000
        });

        try {
          // Run verify script
          await $`/home/mikepjb/src/shell/bin/verify`.cwd(project.worktree);

          // Success - show confirmation
          await client.toast({
            title: "Verification Passed",
            message: "All checks passed ✓",
            variant: "success",
            duration: 2000
          });
        } catch (error) {
          // Get failure output
          const output = error.stderr?.toString() || error.stdout?.toString() || 'Verification failed';

          // Show failure notification
          await client.toast({
            title: "Verification Failed",
            message: "Tests failed - check conversation",
            variant: "error",
            duration: 3000
          });

          // Add verification failure as a message the LLM can see and react to
          await client.session.prompt({
            path: { id: event.session.id },
            body: {
              parts: [{ type: "text", text: `🔴 Verification failed:\n${output}\n\nPlease fix the failing tests.` }]
            }
          });
        }
      }
    }
  };
};
