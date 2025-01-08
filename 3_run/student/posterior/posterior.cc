#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "posterior.h"
#include "esp_log.h"
#include "esp_timer.h"

PosteriorHandler::PosteriorHandler(uint32_t history_length, uint8_t trigger_threshold_single,
                                   uint32_t suppression_ms, uint32_t category_count)
    : posterior_history_length_(history_length),
      posterior_trigger_threshold_(trigger_threshold_single * history_length),
      posterior_suppression_ms_(suppression_ms),
      posterior_category_count_(category_count) {
  posterior_history_ = (uint8_t**)malloc(category_count * sizeof(uint8_t*));
  for (size_t i = 0; i < category_count; i++) {
    posterior_history_[i] = (uint8_t*)calloc(history_length, sizeof(uint8_t));
  }
  last_detection_time_ = (uint32_t*)calloc(category_count, sizeof(uint32_t));
}

PosteriorHandler::~PosteriorHandler() {
  for (size_t i = 0; i < posterior_category_count_; i++) {
    free(posterior_history_[i]);
  }
  free(posterior_history_);
  free(last_detection_time_);
}

esp_err_t PosteriorHandler::Handle(uint8_t* new_posteriors, uint32_t time_ms,
                                   size_t* top_category_index, bool* trigger) {
  *trigger = false;
  *top_category_index = 0;
  size_t best_index = 0;
  uint32_t best_value = 0;

  for (size_t i = 0; i < posterior_category_count_; i++) {
    // Update moving average history
    uint32_t sum = 0;
    for (size_t j = 1; j < posterior_history_length_; j++) {
      posterior_history_[i][j - 1] = posterior_history_[i][j];
      sum += posterior_history_[i][j - 1];
    }
    posterior_history_[i][posterior_history_length_ - 1] = new_posteriors[i];
    sum += new_posteriors[i];

    // Calculate moving average
    uint32_t moving_average = sum / posterior_history_length_;

    // Find the best category
    if (moving_average > best_value) {
      best_value = moving_average;
      best_index = i;
    }

    // Check trigger condition
    if (moving_average > posterior_trigger_threshold_ &&
        (time_ms - last_detection_time_[i]) > posterior_suppression_ms_) {
      *trigger = true;
      *top_category_index = i;
      last_detection_time_[i] = time_ms;
    }
  }

  // If no trigger, assign best category
  if (!(*trigger)) {
    *top_category_index = best_index;
  }

  return ESP_OK;
}
