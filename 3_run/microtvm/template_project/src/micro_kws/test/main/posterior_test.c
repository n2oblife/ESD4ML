/*
 * Copyright (c) 2022 TUM Department of Electrical and Computer Engineering.
 *
 * This file is part of the MicroKWS project.
 * See https://gitlab.lrz.de/de-tum-ei-eda-esl/ESD4ML/micro-kws for further
 * info.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// Test application for posterior component.

#include <stdio.h>
#include <string.h>
#include "unity.h"

static void print_banner(const char* text);

void app_main(void) {
  print_banner("Running all tests");
  UNITY_BEGIN();
  unity_run_all_tests();
  UNITY_END();
#if CONFIG_IDF_TARGET_LINUX
  exit(0);
#endif
}

static void print_banner(const char* text) { printf("\n#### %s #####\n\n", text); }
