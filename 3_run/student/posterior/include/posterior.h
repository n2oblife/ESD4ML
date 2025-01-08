#ifndef POSTERIOR_H
#define POSTERIOR_H

#include "esp_err.h"  // Include ESP-IDF error codes

// Default configurations for posterior handler
#ifndef CONFIG_MICRO_KWS_POSTERIOR_HISTORY_LENGTH
#define CONFIG_MICRO_KWS_POSTERIOR_HISTORY_LENGTH 35
#endif

#ifndef CONFIG_MICRO_KWS_POSTERIOR_TRIGGER_THRESHOLD_SINGLE
#define CONFIG_MICRO_KWS_POSTERIOR_TRIGGER_THRESHOLD_SINGLE 100
#endif

#ifndef CONFIG_MICRO_KWS_POSTERIOR_SUPPRESSION_MS
#define CONFIG_MICRO_KWS_POSTERIOR_SUPPRESSION_MS 100
#endif

#ifndef CONFIG_MICRO_KWS_NUM_CLASSES
#define CONFIG_MICRO_KWS_NUM_CLASSES 4
#endif

class PosteriorHandler {
 public:
  // Constructor with default parameter values
  explicit PosteriorHandler(
      uint32_t history_length = CONFIG_MICRO_KWS_POSTERIOR_HISTORY_LENGTH,
      uint8_t trigger_threshold_single = CONFIG_MICRO_KWS_POSTERIOR_TRIGGER_THRESHOLD_SINGLE,
      uint32_t suppression_ms = CONFIG_MICRO_KWS_POSTERIOR_SUPPRESSION_MS,
      uint32_t category_count = CONFIG_MICRO_KWS_NUM_CLASSES);

  // Destructor
  ~PosteriorHandler();

  // Method to handle posteriors and determine if a trigger occurs
  esp_err_t Handle(uint8_t* new_posteriors, uint32_t time_ms,
                   size_t* top_category_index, bool* trigger);

 private:
  // Configuration parameters
  uint32_t posterior_history_length_;       // History buffer length
  uint32_t posterior_trigger_threshold_;    // Trigger threshold for detection
  uint32_t posterior_suppression_ms_;       // Suppression time in milliseconds
  uint32_t posterior_category_count_;       // Number of categories

  // Working variables
  uint8_t** posterior_history_;             // 2D array for storing posterior history
  uint32_t* last_detection_time_;           // Array to track last detection timestamps

  // Optional: Friend class for unit testing (if private members need access)
  friend class PosteriorHandlerTest;
};

#endif  // POSTERIOR_H
