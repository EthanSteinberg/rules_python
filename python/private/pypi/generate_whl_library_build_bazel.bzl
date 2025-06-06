# Copyright 2023 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Generate the BUILD.bazel contents for a repo defined by a whl_library."""

load("//python/private:text_util.bzl", "render")

_RENDER = {
    "copy_executables": render.dict,
    "copy_files": render.dict,
    "data": render.list,
    "data_exclude": render.list,
    "entry_points": render.dict,
    "extras": render.list,
    "group_deps": render.list,
    "requires_dist": render.list,
    "srcs_exclude": render.list,
    "target_platforms": lambda x: render.list(x) if x else "target_platforms",
}

# NOTE @aignas 2024-10-25: We have to keep this so that files in
# this repository can be publicly visible without the need for
# export_files
_TEMPLATE = """\
{loads}

package(default_visibility = ["//visibility:public"])

whl_library_targets_from_requires(
{kwargs}
)
"""

def generate_whl_library_build_bazel(
        *,
        annotation = None,
        default_python_version = None,
        **kwargs):
    """Generate a BUILD file for an unzipped Wheel

    Args:
        annotation: The annotation for the build file.
        default_python_version: The python version to use to parse the METADATA.
        **kwargs: Extra args serialized to be passed to the
            {obj}`whl_library_targets`.

    Returns:
        A complete BUILD file as a string
    """

    loads = [
        """load("@rules_python//python/private/pypi:whl_library_targets.bzl", "whl_library_targets_from_requires")""",
    ]
    if not kwargs.setdefault("target_platforms", None):
        dep_template = kwargs["dep_template"]
        loads.append(
            "load(\"{}\", \"{}\")".format(
                dep_template.format(name = "", target = "config.bzl"),
                "target_platforms",
            ),
        )

    additional_content = []
    if annotation:
        kwargs["data"] = annotation.data
        kwargs["copy_files"] = annotation.copy_files
        kwargs["copy_executables"] = annotation.copy_executables
        kwargs["data_exclude"] = kwargs.get("data_exclude", []) + annotation.data_exclude_glob
        kwargs["srcs_exclude"] = annotation.srcs_exclude_glob
        if annotation.additive_build_content:
            additional_content.append(annotation.additive_build_content)
    if default_python_version:
        kwargs["default_python_version"] = default_python_version

    contents = "\n".join(
        [
            _TEMPLATE.format(
                loads = "\n".join(loads),
                kwargs = render.indent("\n".join([
                    "{} = {},".format(k, _RENDER.get(k, repr)(v))
                    for k, v in sorted(kwargs.items())
                ])),
            ),
        ] + additional_content,
    )

    # NOTE: Ensure that we terminate with a new line
    return contents.rstrip() + "\n"
