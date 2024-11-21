# Includes

import tensorflow as tf
import numpy as np

# Further imports are NOT allowed, please use the APIs in `tf`, `tf.keras` and `tf.keras.layers`!


def create_micro_kws_student_model(
    model_settings: dict, model_name: str = "micro_kws_student"
) -> tf.keras.Model:
    """Builds a MicroKWS model with the keras API.

    Arguments
    ---------
    model_settings : dict
        Dict of different settings for model training.

    Returns
    -------
    model : tf.keras.Model
        Model of the 'Student' architecture.
    """

    # Get relevant model setting.
    input_frequency_size = model_settings["dct_coefficient_count"]
    input_time_size = model_settings["spectrogram_length"]

    inputs = tf.keras.Input(shape=(model_settings["fingerprint_size"]), name="input")

    ### ENTER STUDENT CODE BELOW ###

    output = basic_model(model_settings)

    ### ENTER STUDENT CODE ABOVE ###

    model = tf.keras.Model(inputs, output)
    model._name = model_name
    return model

def basic_model(model_settings: dict):
    # Get relevant model setting.
    input_frequency_size = model_settings["dct_coefficient_count"]
    input_time_size = model_settings["spectrogram_length"]

    inputs = tf.keras.Input(shape=(model_settings["fingerprint_size"]), name="input")
    # Hint: The following code is just an example, for the final challenge,
    # you will need to add more layers here.

    # Reshape the flattened input.
    x = tf.reshape(inputs, shape=(-1, input_time_size, input_frequency_size, 1))

    # First convolution.
    x = tf.keras.layers.DepthwiseConv2D(
        depth_multiplier=4,
        kernel_size=(5, 4),
        strides=(2, 2),
        padding="SAME",
        activation="relu",
    )(x)

    # Flatten for fully connected layers.
    x = tf.keras.layers.Flatten()(x)

    # Output fully connected.
    output = tf.keras.layers.Dense(units=model_settings["label_count"], activation="softmax")(x)
    return output

def create_arm_conv_model(model_settings: dict) -> tf.keras.Model:
    """Builds a Convolutional model with the keras API."""

    # Get relevant model settings.
    input_frequency_size = model_settings["dct_coefficient_count"]
    input_time_size = model_settings["spectrogram_length"]

    inputs = tf.keras.Input(shape=(model_settings["fingerprint_size"]), name="input")

    # Reshape the flattened input.
    x = tf.reshape(inputs, shape=(-1, input_time_size, input_frequency_size, 1))

    # First convolutional layer.
    x = tf.keras.layers.Conv2D(
        filters=16,
        kernel_size=(3, 3),
        strides=(1, 1),
        padding="SAME",
        activation=None,
    )(x)
    x = tf.keras.layers.BiasAdd()(x)  # Explicit bias addition
    x = tf.keras.layers.ReLU()(x)  # ReLU activation

    # First max-pooling layer.
    x = tf.keras.layers.MaxPooling2D(pool_size=(2, 2), strides=(2, 2), padding="SAME")(x)

    # Second convolutional layer.
    x = tf.keras.layers.Conv2D(
        filters=32,
        kernel_size=(3, 3),
        strides=(1, 1),
        padding="SAME",
        activation=None,
    )(x)
    x = tf.keras.layers.BiasAdd()(x)  # Explicit bias addition
    x = tf.keras.layers.ReLU()(x)  # ReLU activation

    # Second max-pooling layer.
    x = tf.keras.layers.MaxPooling2D(pool_size=(2, 2), strides=(2, 2), padding="SAME")(x)

    # Flatten for the dense layer.
    x = tf.keras.layers.Flatten()(x)

    # Fully connected layer.
    x = tf.keras.layers.Dense(units=128, activation=None)(x)
    x = tf.keras.layers.BiasAdd()(x)  # Explicit bias addition

    # Output layer with softmax activation.
    output = tf.keras.layers.Dense(units=model_settings["label_count"], activation="softmax")(x)
    return output


def create_arm_low_latency_conv_model(model_settings: dict):
    """Builds a Low Latency model with the keras API."""
    # Get relevant model setting.
    input_frequency_size = model_settings["dct_coefficient_count"]
    input_time_size = model_settings["spectrogram_length"]

    inputs = tf.keras.Input(shape=(model_settings["fingerprint_size"]), name="input")
    # Reshape the flattened input.
    x = tf.reshape(inputs, shape=(-1, input_time_size, input_frequency_size, 1))

    # First convolutional layer.
    x = tf.keras.layers.Conv2D(
        filters=16,
        kernel_size=(5, 5),
        strides=(1, 1),
        padding="SAME",
        activation=None,  # No activation here, we will add ReLU separately.
    )(x)
    x = tf.keras.layers.BiasAdd()(x)  # Explicit bias addition
    x = tf.keras.layers.ReLU()(x)  # ReLU activation

    # Flatten for the dense layers.
    x = tf.keras.layers.Flatten()(x)

    # Fully connected layer 1.
    x = tf.keras.layers.Dense(units=128, activation=None)(x)
    x = tf.keras.layers.BiasAdd()(x)  # Explicit bias addition
    x = tf.keras.layers.ReLU()(x)  # ReLU activation
    x = tf.keras.layers.Dropout(rate=0.3)(x)  # Add dropout for regularization

    # Fully connected layer 2.
    x = tf.keras.layers.Dense(units=64, activation=None)(x)
    x = tf.keras.layers.BiasAdd()(x)  # Explicit bias addition
    x = tf.keras.layers.ReLU()(x)  # ReLU activation
    x = tf.keras.layers.Dropout(rate=0.3)(x)  # Add dropout for regularization

    # Fully connected layer 3.
    x = tf.keras.layers.Dense(units=32, activation=None)(x)
    x = tf.keras.layers.BiasAdd()(x)  # Explicit bias addition
    x = tf.keras.layers.ReLU()(x)  # ReLU activation
    x = tf.keras.layers.Dropout(rate=0.3)(x)  # Add dropout for regularization

    # Output layer.
    output = tf.keras.layers.Dense(units=model_settings["label_count"], activation="softmax")(x)
    return output

def create_lstm_model(model_settings: dict):
    """Builds a MicroKWS model using LSTM layers with the keras API.
    """

    # Get relevant model setting.
    input_frequency_size = model_settings["dct_coefficient_count"]
    input_time_size = model_settings["spectrogram_length"]

    # Input layer.
    inputs = tf.keras.Input(shape=(model_settings["fingerprint_size"]), name="input")

    ### Reshape the flattened input to 2D (time steps x features)
    x = tf.reshape(inputs, shape=(-1, input_time_size, input_frequency_size))

    ### Add LSTM layers
    x = tf.keras.layers.LSTM(units=64, return_sequences=True, activation="tanh")(x)
    x = tf.keras.layers.Dropout(rate=0.3)(x)  # Add dropout for regularization

    # Second LSTM layer
    x = tf.keras.layers.LSTM(units=32, activation="tanh")(x)
    x = tf.keras.layers.Dropout(rate=0.3)(x)  # Add dropout for regularization

    ### Add a fully connected layer
    x = tf.keras.layers.Dense(units=64, activation="relu")(x)
    x = tf.keras.layers.Dropout(rate=0.3)(x)  # Add dropout for regularization

    ### Output layer
    output = tf.keras.layers.Dense(units=model_settings["label_count"], activation="softmax")(x)

    return output

def create_mix_depthwise_lstm_model(model_settings: dict):
    """Builds a MicroKWS model using DepthwiseConv2D and LSTM layers.
    """

    # Get relevant model settings.
    input_frequency_size = model_settings["dct_coefficient_count"]
    input_time_size = model_settings["spectrogram_length"]

    inputs = tf.keras.Input(shape=(model_settings["fingerprint_size"]), name="input")

    ### Model Implementation ###

    # Reshape the input to (time, frequency, channels)
    x = tf.reshape(inputs, shape=(-1, input_time_size, input_frequency_size, 1))

    # Depthwise Conv2D layer
    x = tf.keras.layers.DepthwiseConv2D(
        depth_multiplier=4,
        kernel_size=(3, 3),
        strides=(2, 2),
        padding="same",
        activation="relu",
        name="depthwise_conv_1",
    )(x)

    # Another Depthwise Conv2D layer
    x = tf.keras.layers.DepthwiseConv2D(
        depth_multiplier=4,
        kernel_size=(3, 3),
        strides=(2, 2),
        padding="same",
        activation="relu",
        name="depthwise_conv_2",
    )(x)

    # Flatten the spatial dimensions for LSTM input
    x = tf.keras.layers.Reshape(
        target_shape=(-1, input_frequency_size * 4), name="reshape_for_lstm"
    )(x)

    # TODO check if useful, very big layer
    # Add an LSTM layer with dropout
    x = tf.keras.layers.LSTM(
        units=64, return_sequences=True, activation="tanh", name="lstm_layer_1"
    )(x)
    x = tf.keras.layers.Dropout(rate=0.3, name="dropout_layer_1")(x)

    # Add another LSTM layer
    x = tf.keras.layers.LSTM(
        units=32, return_sequences=False, activation="tanh", name="lstm_layer_2"
    )(x)
    x = tf.keras.layers.Dropout(rate=0.3, name="dropout_layer_2")(x)

    # Add a Dense layer with softmax for classification
    output = tf.keras.layers.Dense(
        units=model_settings["label_count"], activation="softmax", name="output_layer"
    )(x)
    return output
