#include <stdint.h>
#include <stdio.h>

#include "posterior.h"

#include "esp_log.h"
#include "esp_timer.h"

/**
 * @brief Default constructor for posterior handler
 *
 * @param history_length Number of past model outputs du consider.
 * @param trigger_threshold_single Threshold value between 0 and 255 for moving average.
 * @param suppression_ms For how many my a new detection should be ignored.
 * @param category_count Number of used labels.

 */
PosteriorHandler::PosteriorHandler(uint32_t history_length, uint8_t trigger_threshold_single,
                                   uint32_t suppression_ms, uint32_t category_count)
    : posterior_history_length_(history_length),
      posterior_trigger_threshold_(trigger_threshold_single * history_length),
      posterior_suppression_ms_(suppression_ms),
      posterior_category_count_(category_count) {

  /* ------------------------ */
  /* ENTER STUDENT CODE BELOW */
  /* ------------------------ */

  /*
   * Hints:
   * - data structured defined in (posterior.h) have to be initialized here
   * - Normally an embedded developer wouln;t use malloc() to dynamically allocate arrays etc.
   * - However to enable unit testing the history_length as well as the category_count are
   *   not constant and therefore allocation has to be done i.e. using malloc.
   * - While you are allowed to use C++ data structures, it is completely fine if you just
   *   use plain C arrays/pointers/...
   */
  
  top_candidate_index_ = 0;
  last_updated_time_ = 0;
  total_posteriors_samples_= 0;


  posteriors_ = (uint8_t*)malloc(category_count*history_length*sizeof(uint8_t));
  per_class_moving_average_ = (uint32_t*)malloc(category_count*sizeof(uint32_t));
  per_class_supressed_time_left_ = (uint32_t*)malloc(category_count*sizeof(uint32_t));
  
  
  // Initialize posteriors array with zeros
  for (size_t i=0; i<history_length*category_count; i++){
      posteriors_[i] = 0;
  }
  // Initialize moving average and suppressed time left for each class
  for (size_t i=0; i<category_count; i++){
      per_class_moving_average_[i] = 0;
      per_class_supressed_time_left_[i] = 0;
  }



  /* ------------------------ */
  /* ENTER STUDENT CODE ABOVE */
  /* ------------------------ */
}

/**
 * @brief Destructor for posterior handler class
 */
PosteriorHandler::~PosteriorHandler() {

  /* ------------------------ */
  /* ENTER STUDENT CODE BELOW */
  /* ------------------------ */

  /*
   * Hints:
   * - Every data structure allocated in the constructor above has to be cleaned up properly
   * - This can for example be achieved using free()
   */
  
  free(posteriors_);
  free(per_class_moving_average_);
  free(per_class_supressed_time_left_);


  /* ------------------------ */
  /* ENTER STUDENT CODE ABOVE */
  /* ------------------------ */
}

/**
 * @brief Implementation of posterior hanlding algorithm.
 *
 * @param new_posteriors The raw model outputs with unsigned 8-bit values.
 * @param time_ms Timestamp for posterior handling (ms).
 * @param top_category_index The index of the detected category/label returned by pointer.
 * @param trigger Flag which should be raised to true if a new detection is available.
 *
 * @return ESP_OK if no error occured.
 */
esp_err_t PosteriorHandler::Handle(uint8_t* new_posteriors, uint32_t time_ms,
                                   size_t* top_category_index, bool* trigger) {

  /* ------------------------ */
  /* ENTER STUDENT CODE BELOW */
  /* ------------------------ */

  /*
   * Hints:
   * - The goal is to implement a posterior handling algorithm descibed in Figure 2.1
   *   and section 2.2.1 of the Lab 2 manual.
   * - By using a moving average over the model outputs, we want to reduce the number
   *   of incorrect classifications i.e. caused by random spikes.
   * - If the calculated moving average for a class exceeds the trigger threshold a
   *   detection should be triggered (unless the deactivation period for a past detection
   *   is still active)
   * - The trigger should be raised for all classes (including silence and unknown) since
   *   the KeywordCallback method in backend.cc is reponsible for deciding which labels should
   *   be ignored.
   * - The supression time (in ms) defines the duration in which registered labels shall
   *   not trigger a new detection. (However their moving average should continue to be updated)
   * - Only if a detection was classified (outside of the deactivation period) the trigger argument
   *   should be set to true by the algorithm
   * - If trigger is high, the detected category index has to updated as well using the argument.
   * - You are allowed (and required) to introduce class variables inside include/posterior.h which
   * may than be (de-)initialized in the constructor/destuctor above.
   */

  /*
   * The following code is a basic example (not an accepted solution)
   * It just returns the class with the highest probablity.
   */

  // Calculate the time elapsed since the last update
  uint32_t elapsed_time = time_ms - last_updated_time_;
  
  // Calculate the starting index for the new posteriors
  uint8_t posteriors_start_index = total_posteriors_samples_ * posterior_category_count_;
  
  // Update the last updated time to the current time
  last_updated_time_ = time_ms;
  
  // Increment the total posteriors samples and reset the counter to 0 when the history length is reached
  if (total_posteriors_samples_ < posterior_history_length_- 1){
    total_posteriors_samples_ += 1;
  } else {
    total_posteriors_samples_ = 0;
  }
  
  // Update the time left for suppression for each class based on elapsed time
  for (size_t i = 0; i < posterior_category_count_; i++){
      if (per_class_supressed_time_left_[i] > elapsed_time){
        per_class_supressed_time_left_[i] -= elapsed_time;   
      } else {
      per_class_supressed_time_left_[i] = 0;
      }
  }
  
  // Add the new posteriors to the array
  for (size_t i = 0; i < posterior_category_count_; i++){
        posteriors_[i + posteriors_start_index] = new_posteriors[i] ;
    }
  
  // Reset the moving average for each class
  for (size_t j = 0; j < posterior_category_count_; j++){
      per_class_moving_average_[j] = 0;
  }
  
  
  // Calculate the moving sum instead of moving average for each class
  for (size_t i = 0; i < posterior_history_length_; i++){
    for (size_t j = 0; j < posterior_category_count_; j++){
      per_class_moving_average_[j] += posteriors_[i*posterior_category_count_+j];
    }
  }

  
  // Determine the top class with respect to the moving sum
  top_candidate_index_= 0;
  for(size_t i = 0; i < posterior_category_count_; i++){
    if (per_class_moving_average_[i] >=per_class_moving_average_[top_candidate_index_]){
        top_candidate_index_ = i;
    }
  }
  
  // Check if the top class exceeds the trigger threshold and is not suppressed
  if ((per_class_moving_average_[top_candidate_index_] >= posterior_trigger_threshold_)&& 
      (per_class_supressed_time_left_[top_candidate_index_]== 0)) {
      // Set the top category index and trigger flag
      *top_category_index = top_candidate_index_;
      *trigger = true;
      // Set the suppression time for the triggered class
      per_class_supressed_time_left_[top_candidate_index_] = posterior_suppression_ms_;
  
    
  }
    

  /* ------------------------ */
  /* ENTER STUDENT CODE ABOVE */
  /* ------------------------ */

  return ESP_OK;
}