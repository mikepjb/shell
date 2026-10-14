import fcntl
import os
import pathlib
import pty
import runpy
import select
import struct
import subprocess
import termios
import time
import unittest


SCRIPT = pathlib.Path(__file__).resolve().parents[1] / "bin" / "spear"
spear = runpy.run_path(str(SCRIPT))


class MatchingTests(unittest.TestCase):
    def test_case_insensitive_subsequence(self):
        self.assertEqual(spear["rank"](["a/b-c", "acb", "ABC"], "abc"),
                         [(2, 0, 2), (0, 0, 4)])

    def test_empty_query_preserves_input_order(self):
        self.assertEqual(spear["rank"](["b", "a"], ""),
                         [(0, None, None), (1, None, None)])

    def test_unmatched_query(self):
        self.assertEqual(spear["rank"](["alpha"], "z"), [])

    def test_best_start_and_stable_ties(self):
        self.assertEqual(spear["find_match"]("a---ab", "ab"), (2, 4, 5))
        self.assertEqual(spear["rank"](["ABC", "abc"], "abc"),
                         [(0, 0, 2), (1, 0, 2)])

    def test_paths_with_spaces(self):
        self.assertEqual(spear["rank"](["my path.py"], "path"), [(0, 3, 6)])

    def test_ctrl_w(self):
        self.assertEqual(spear["delete_word"]("one two  "), "one ")
        self.assertEqual(spear["delete_word"]("one"), "")

    def test_control_characters_are_not_rendered_raw(self):
        rendered, _ = spear["display"]("a\x1bb\t", 20)
        self.assertEqual(rendered, "a?b?")


class TerminalTests(unittest.TestCase):
    def invoke(self, keys, candidates=b"alpha\nbeta\n", args=()):
        master, slave = pty.openpty()
        fcntl.ioctl(slave, termios.TIOCSWINSZ, struct.pack("HHHH", 24, 80, 0, 0))

        def controlling_tty():
            os.setsid()
            fcntl.ioctl(slave, termios.TIOCSCTTY, 0)

        process = subprocess.Popen(
            [str(SCRIPT), *args], stdin=subprocess.PIPE, stdout=subprocess.PIPE,
            stderr=subprocess.PIPE, pass_fds=(slave,), preexec_fn=controlling_tty,
        )
        os.close(slave)
        try:
            process.stdin.write(candidates)
            process.stdin.close()
            process.stdin = None
            # Wait until the UI is visible, so keys cannot arrive before cbreak mode.
            output = b""
            deadline = time.monotonic() + 3
            while b">" not in output and time.monotonic() < deadline:
                ready, _, _ = select.select([master], [], [], max(0, deadline - time.monotonic()))
                if ready:
                    output += os.read(master, 65536)
            self.assertIn(b">", output, "selector did not draw a prompt")
            os.write(master, keys)
            stdout, stderr = process.communicate(timeout=3)
            return process.returncode, stdout, stderr
        finally:
            if process.poll() is None:
                process.kill()
                process.communicate()
            os.close(master)

    def test_search_and_select(self):
        self.assertEqual(self.invoke(b"b\r"), (0, b"beta\n", b""))

    def test_initial_search(self):
        self.assertEqual(self.invoke(b"\r", args=("-s", "be")),
                         (0, b"beta\n", b""))

    def test_arrow_and_ctrl_n(self):
        self.assertEqual(self.invoke(b"\x1b[B\r"), (0, b"beta\n", b""))
        self.assertEqual(self.invoke(b"\x0e\r"), (0, b"beta\n", b""))

    def test_backspace_and_clear(self):
        self.assertEqual(self.invoke(b"bz\x7f\r"), (0, b"beta\n", b""))
        self.assertEqual(self.invoke(b"z\x15\r"), (0, b"alpha\n", b""))

    def test_empty_input_produces_no_output(self):
        self.assertEqual(self.invoke(b"\r", candidates=b""), (0, b"", b""))

    def test_no_matches_produces_no_output(self):
        self.assertEqual(self.invoke(b"z\r"), (0, b"", b""))

    def test_ctrl_c_restores_terminal_and_cancels(self):
        code, stdout, stderr = self.invoke(b"\x03")
        self.assertEqual((code, stdout, stderr), (130, b"", b""))


if __name__ == "__main__":
    unittest.main()
