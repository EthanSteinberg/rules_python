# Copyright 2025 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""
{#python-apis-libraries-bzl}
Loading-phase APIs specific to libraries.

:::{versionadded} 1.3.0
:::
"""

load("//python/private:py_library.bzl", "create_py_library_rule_builder")

libraries = struct(
    py_library_rule_builder = create_py_library_rule_builder,
)
