import importlib.machinery
import importlib.util
import pathlib
import unittest


SCRIPT = pathlib.Path(__file__).parents[1] / "bin" / "proton-archive"
loader = importlib.machinery.SourceFileLoader("proton_archive", str(SCRIPT))
spec = importlib.util.spec_from_loader(loader.name, loader)
proton_archive = importlib.util.module_from_spec(spec)
loader.exec_module(proton_archive)


class MatchingTest(unittest.TestCase):
    def test_decodes_headers(self):
        headers = (
            b"From: Amazon Orders <dispatch@updates.amazon.co.uk>\r\n"
            b"Subject: Your =?utf-8?q?delivery?= is ready\r\n\r\n"
        )

        senders, subject = proton_archive.decoded_headers(headers)

        self.assertEqual(senders, ["dispatch@updates.amazon.co.uk"])
        self.assertEqual(subject, "Your delivery is ready")

    def test_sender_wildcard_is_case_insensitive(self):
        rule = proton_archive.matching_rule(
            ["Dispatch@Amazon.CO.UK"],
            "An unrelated subject",
            [{"sender": "*@amazon.co.uk"}],
        )

        self.assertEqual(rule, {"sender": "*@amazon.co.uk"})

    def test_subject_is_a_case_insensitive_partial_match(self):
        rule = proton_archive.matching_rule(
            ["person@example.com"],
            "Your DELIVERY is on its way",
            [{"subject": "delivery"}],
        )

        self.assertEqual(rule, {"subject": "delivery"})

    def test_rules_are_or_conditions(self):
        rule = proton_archive.matching_rule(
            ["person@example.com"],
            "Order dispatched",
            [{"sender": "*@amazon.co.uk"}, {"subject": "dispatched"}],
        )

        self.assertEqual(rule, {"subject": "dispatched"})

    def test_rejects_ambiguous_rule(self):
        with self.assertRaisesRegex(ValueError, "use exactly one"):
            proton_archive.matching_rule(
                ["person@example.com"],
                "Delivery",
                [{"sender": "*@example.com", "subject": "delivery"}],
            )


if __name__ == "__main__":
    unittest.main()
