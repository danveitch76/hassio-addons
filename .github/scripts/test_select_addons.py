import unittest
from select_addons import select_addons


class SelectionTests(unittest.TestCase):
    def setUp(self):
        self.addons = ["logger", "nginx"]

    def test_workflow_only_change_builds_every_addon(self):
        self.assertEqual(select_addons(self.addons, [".github/workflows/builder.yml"]), self.addons)

    def test_shared_changes_do_not_select_production_publication(self):
        self.assertEqual(select_addons(self.addons, [".github/workflows/builder.yml"], include_shared=False), [])

    def test_mixed_changes_publish_only_affected_addon(self):
        self.assertEqual(select_addons(self.addons, [".github/workflows/builder.yml", "logger/Dockerfile"], include_shared=False), ["logger"])

    def test_selector_change_builds_every_addon(self):
        self.assertEqual(select_addons(self.addons, [".github/scripts/select_addons.py"]), self.addons)

    def test_addon_code_or_deletion_builds_affected_addon(self):
        self.assertEqual(select_addons(self.addons, ["nginx/rootfs/etc/nginx.conf"]), ["nginx"])

    def test_documentation_does_not_build(self):
        self.assertEqual(select_addons(self.addons, ["README.md", "logger/DOCS.md"]), [])

    def test_whitespace_and_shell_characters_are_data(self):
        self.assertEqual(select_addons(self.addons, ["logger/rootfs/a file; $(anything)"]), ["logger"])

    def test_directory_prefix_does_not_match_another_addon(self):
        self.assertEqual(select_addons(self.addons, ["logger-old/Dockerfile"]), [])

    def test_shared_build_script_builds_every_addon(self):
        self.assertEqual(select_addons(self.addons, ["build.sh"]), self.addons)


if __name__ == "__main__":
    unittest.main()
