# Imports
from typing import Dict
import tensorflow as tf

# Further imports are NOT allowed, please use the APIs in `tf`, `tf.keras` and `tf.keras.backend`!


def recall(matrix: tf.Tensor, idx: int) -> tf.Tensor:
    """Calclate the recall metric for a given confusion matrix and category.

    Arguments
    ---------
    matrix : tensorflow.Tensor
        The confusion matrix for the trained model. (rows: real labels, cols: predicted labels)
    idx : int
        The category index (0: silence, 1: unknown, 2: ...)

    Returns
    -------
    recall : tensorflow.Tensor
        The calculated recall value (between 0 and 1)
    """

    recall = None

    ### ENTER STUDENT CODE BELOW ###
    # Extract the true positives for the category (diagonal element)
    TP = matrix.numpy()[idx, idx]

    # Sum all elements in the row corresponding to the category (actual occurrences of the category)
    FN = sum(matrix.numpy()[idx, :]) - TP

    # Compute recall: TP / (TP + FN), handling division by zero
    recall = TP / (TP + FN + tf.keras.backend.epsilon())
    ### ENTER STUDENT CODE ABOVE ###

    return recall


def precision(matrix: tf.Tensor, idx: int) -> tf.Tensor:
    """Calclate the precision metric for a given confusion matrix and category.

    Arguments
    ---------
    matrix : tensorflow.Tensor
        The confusion matrix for the trained model. (rows: real labels, cols: predicted labels)
    idx : int
        The category index (0: silence, 1: unknown, 2: ...)

    Returns
    -------
    recall : tensorflow.Tensor
        The calculated precision value (between 0 and 1)
    """

    precision = None

    ### ENTER STUDENT CODE BELOW ###
    # Extract the true positives for the category (diagonal element)
    TP = matrix.numpy()[idx, idx]

    # Sum all elements in the column corresponding to the category (all predicted occurrences of the category)
    FP = sum(matrix.numpy()[:, idx]) - TP

    # Compute precision: TP / (TP + FP), handling division by zero
    precision = TP / (TP + FP + tf.keras.backend.epsilon())
    ### ENTER STUDENT CODE ABOVE ###

    return precision


def f1_score(matrix: tf.Tensor, idx: int) -> tf.Tensor:
    """Calclate the f1_score metric for a given confusion matrix and category.

    Arguments
    ---------
    matrix : tensorflow.Tensor
        The confusion matrix for the trained model. (rows: real labels, cols: predicted labels)
    idx : int
        The category index (0: silence, 1: unknown, 2: ...)

    Returns
    -------
    recall : tensorflow.Tensor
        The calculated f1_score value (between 0 and 1)
    """

    f1_score = None

    ### ENTER STUDENT CODE BELOW ###
    # Compute Precision
    precision_val = precision(matrix, idx) 

    # Compute Recall
    recall_val = recall(matrix, idx)

    # Compute F1 Score
    f1_score = 2 * (precision_val * recall_val) / (precision_val + recall_val + tf.keras.backend.epsilon())
    ### ENTER STUDENT CODE ABOVE ###

    return f1_score


def get_student_metrics(matrix: tf.Tensor, idx) -> Dict[str, tf.Tensor]:
    ret = {
        "recall": recall(matrix, idx),
        "precision": precision(matrix, idx),
        "f1_score": f1_score(matrix, idx),
    }
    return {key: value.numpy() for key, value in ret.items() if value is not None}
